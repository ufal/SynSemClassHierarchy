#
# package for importing or exporting data
#

package SynSemClassHierarchy::InOut;

use strict;
use utf8;

sub importData{
	my ($self)=@_;

	if ($self->data()->changed){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Save the changes before importing !");
		return;
	}

	import_data($self);

	SynSemClassHierarchy::Editor::warning_dialog($self, "Imported !");
	#update window
}


sub import_data{
	#preparation for data import according to specified criteria
}

sub exportData{
  my ($self)=@_;

  if ($self->data()->changed){
	my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "There are some changes!\n Do you want to export unsaved data?");
	return if ($answer eq "No");
  }

  my $selectedClass=$self->subwidget('classlist')->focused_class_node();

  my $all=1;

  if ($selectedClass){
	my @buttons=('All Lexicon', 'Only selected');
	my $answer = SynSemClassHierarchy::Editor::question_complex_dialog($self, 
				"Export for all Lexicon or only for class " . $self->subwidget('classlist')->focused_class_id . "?", 
				\@buttons, 'Only selected');
	$all=0 if ($answer eq "Only selected");  	
  }


  #my ($sec,$min,$hour,$day,$month,$year) = localtime(time);
#  $year += 1900;
  my $target_file;
  if ($all){
  	$target_file = "exporData_SynSemClass";
  }else{
  	$target_file="exportData_" . $self->subwidget('classlist')->focused_class_id;
  }

  # $target_file .= "_" . $year . sprintf("_%02d", $month) . sprintf("_%02d", $day) . sprintf("_%02d", $hour) . sprintf("_%02d", $min) . sprintf("_%02d", $sec) . ".csv";
  $target_file .=".csv";

  open (OUT,">:encoding(UTF-8)", "../InOut/$target_file");
  print "exporting data ...\n";

  my @exportingClasses;

  my $data_main = $self->data->main;
  if ($all){
  	@exportingClasses=$data_main->getClassNodes();
  }else{
  	@exportingClasses=($selectedClass);
  }

  my @languages = @{$data_main->languages};
  foreach my $class (@exportingClasses){
	my $class_id = $data_main->getClassId($class);
	print "\texporting class $class_id ...\n";
	my @commonRoles = $data_main->getCommonRolesSLs($class);

	my %rolesOrder;
	my $rolesCount=0;
	foreach (@commonRoles){
		$rolesOrder{$_}=$rolesCount;
		$rolesCount++;	
	}

	print OUT "Class\tClassMember\tPOS\tStatus\t\t";
	for (my $i=0; $i<$rolesCount; $i++){
		print OUT "Role/Functor\t";
	}
	print OUT "\t";
	print OUT "Note\tRestrict\t\tOntoNotes\tFrameNet\tWordNet\tCzEngVallex\tPDTVallex\tEngVallex\tVallex\tVerbNet\tPropBank\tFrameNet Des Deutschen\tGUP\tVALBU\tParaCrawl German\n\n";

	
	my $classNote=$data_main->getClassNote($class);

	print OUT "\n\t\t\t\t";
	foreach (@commonRoles){
		print OUT "$_\t";
	}
	print OUT "\t";
	print OUT $classNote;
	print OUT "\n";

	foreach my $lang (@languages){
	  my $data_cms = $self->data->lang_cms($lang);
	  my $class_lang = $data_cms->getClassByID($class_id);
      my $class_lemma = $data_cms->getClassLemma($class_lang);
	  print OUT "$class_lemma ($lang)\n";
	  foreach my $cm ($data_cms->getClassMembersNodes($class_lang)){

		my $lemma = $data_cms->getClassMemberAttribute($cm, 'lemma');
		my $lang = $data_cms->getClassMemberAttribute($cm, 'lang');
		my $lexidref = $data_cms->getClassMemberAttribute($cm, 'lexidref');
		my $idref = $data_cms->getClassMemberAttribute($cm, 'idref');
		$idref =~ s/^.*-ID-//;
		my $status = $data_cms->getClassMemberAttribute($cm, 'status');
		my $pos = $data_cms->getClassMemberAttribute($cm, 'POS');
		my $note = $data_cms->getClassMemberNote($cm) || "";
		$note=~s/\n/;/g;
		my $restrict = $data_cms->getClassMemberRestrict($cm) || "";
		$restrict=~s/\n/;/g;

		my @mappingList = $self->data->getClassMemberMappingList($lang,$cm);
		my %functorsOrder;
		foreach (@mappingList){

			if (not defined $rolesOrder{$_->[2]}){
				$rolesOrder{$_->[2]} = $rolesCount;
				$rolesCount++
			}
			my $order=$rolesOrder{$_->[2]};
			if ($functorsOrder{$order}){     #for mapping like Medium->ACT, Medium->LOC(in) 
				$functorsOrder{$order} .= ", " . $_->[1];
			}else{
				$functorsOrder{$order} = $_->[1];
			}
		}

		my %links=();
		foreach my $ln_type ("on", "fn", "wn", "czengvallex", "pdtvallex", "engvallex", "vallex", "vn", "pb", "fnd", "gup", "valbu", "paracrawl_ge"){
			@{$links{$ln_type}} = $data_cms->getClassMemberLinksForType($cm, $ln_type);
		}

		print OUT "\t" . $lemma . " ($idref)\t$pos\t$status\t\t";
		for (my $i=0; $i<$rolesCount; $i++){
			print OUT $functorsOrder{$i} if (defined $functorsOrder{$i});
			print OUT "\t";
		}
		print OUT "\t";
		print OUT "$note\t$restrict\t\t";

		my $not_first = 0;
		foreach my $ln_type ("on", "fn", "wn", "czengvallex", "pdtvallex", "engvallex", "vallex", "vn", "pb", "fnd", "gup", "valbu", "paracrawl_ge"){
			$not_first =0;
			if ($data_cms->get_no_mapping($cm, $ln_type)){
				print OUT "NM";
			}elsif (scalar @{$links{$ln_type}} > 0){
		      foreach (@{$links{$ln_type}}){
				if ($not_first){
					print OUT ", ";
				}else{
					$not_first = 1;
				}
				if ($ln_type eq "on"){
					print OUT $_->[3] . "#" . $_->[4];				
				}elsif($ln_type eq "fn"){
					print OUT $_->[3];
					print OUT "/" . $_->[4] if ($_->[4] ne "");
				}elsif($ln_type eq "wn"){
					print OUT $_->[3] . "#" . $_->[4];
				}elsif($ln_type eq "czengvallex"){
					print OUT $_->[5] . "(" . $_->[4] . "):" . $_->[7] . "(" . $_->[6] . ")" if ($lang eq "eng");
					print OUT $_->[7] . "(" . $_->[6] . "):" . $_->[5] . "(" . $_->[4] . ")" if ($lang eq "ces");
				}elsif($ln_type eq "pdtvallex" or $ln_type eq "engvallex"){
					print OUT $_->[4] . "(" . $_->[3] . ")";
				}elsif($ln_type eq "vallex"){
					print OUT $_->[5] . "/" . $_->[4] . "(" . $_->[3] . ")";
				}elsif($ln_type eq "vn"){
					print OUT $_->[3];
					print OUT "#" . $_->[4] if ($_->[4] ne "");		
				}elsif($ln_type eq "pb"){
					print OUT $_->[5] ."/" . $_->[3] . "." . $_->[4];
				}elsif($ln_type eq "fnd"){
					print OUT $_->[4] . " " . $_->[3];
				}elsif($ln_type eq "gup"){
					print OUT $_->[5] ."/" . $_->[3] . "." . $_->[4];
				}elsif($ln_type eq "valbu"){
					print OUT $_->[3] ." " . $_->[4] . "/" . $_->[5];
				}elsif($ln_type eq "paracrawl_ge"){
					print OUT $_->[4] . " " . $_->[3];
				}
			  }
				
			}
			print OUT "\t";
		}	

		print OUT "\n";	
	}

  }

    print OUT "\n";
  }


  close OUT;
	
  SynSemClassHierarchy::Editor::info_dialog($self, "The export was completed!");
}








1;

