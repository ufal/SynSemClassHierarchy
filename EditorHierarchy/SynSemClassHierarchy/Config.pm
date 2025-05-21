#
# package for reading variables from config file
#

package SynSemClassHierarchy::Config;

use strict;
use utf8;

my %resourcePath;
my %tredPath;
my %tredDataPath;
my %tredDataPath;
my %languages;
my %searchBy;
my %beFont;

my $geometry;
   
my $config_file="../Config/config_file_hierarchy";
    
sub loadConfig{
   my ($self)=@_;
		   
   $resourcePath{value}="";
   $tredPath{value}="";
   $languages{value}="";
   $searchBy{value}="";
   $geometry="1500x1500";
		      
   return unless -e $config_file;

   open(IN, $config_file);
   
   while(<IN>){
	   chomp($_);
	   $_=~s/ //g;
									
	   if ($_ =~ /^;*ResourcePath=/){
		   $resourcePath{value}=$_;
	       $resourcePath{valid}=(($_=~/^;/) ? 0 : 1);
	       $resourcePath{value}=~s/^;*ResourcePath=//;
	       $resourcePath{value}=~s/"//g;
	   }elsif ($_ =~ /^;*TrEdPath=/){
	       $tredPath{value}=$_;
	       $tredPath{valid}=(($_=~/^;/) ? 0 : 1);
	       $tredPath{value}=~s/^;*TrEdPath=//g;
	       $tredPath{value}=~s/"//g;
	   }elsif ($_ =~ /^;*TrEdDataPath_([a-z]*)=/){
	       my $lang=$1;
		   $tredDataPath{$lang}{value}=$_;
	       $tredDataPath{$lang}{valid}=(($_=~/^;/) ? 0 : 1);
	       $tredDataPath{$lang}{value}=~s/^;*TrEdDataPath_$lang=//g;
	       $tredDataPath{$lang}{value}=~s/"//g;
	   }elsif ($_ =~ /^;*Languages=/){
	       $languages{value}=$_;
	       $languages{valid}=(($_=~/^;/) ? 0 : 1);
	       $languages{value}=~s/^;*Languages=//g;
	       $languages{value}=~s/"//g;
	   }elsif ($_ =~ /^;*ClassSearchBy=/){
	       $searchBy{value}=$_;
	       $searchBy{valid}=(($_=~/^;/) ? 0 : 1);
	       $searchBy{value}=~s/^;*ClassSearchBy=//g;
	       $searchBy{value}=~s/"//g;
		   my $langs = $languages{value};
		   $langs =~ s/,/|/g;
		   if ($searchBy{value} !~ /^($langs|id|classmembers|roles)$/){
			$searchBy{value} = "id";
			print "Bad value for ClassSearchBy in config_file_hierarchy (valid values are ";
			foreach (split(",",$languages{value})){
				print "'$_', ";
			} 
			print "'id', 'classmembers, or 'roles')\n";
		   }
	   }elsif ($_ =~ /^BEFont=/){
	       $beFont{value}=$_;
	       $beFont{valid}=(($_=~/^;/) ? 0 : 1);
	       $beFont{value}=~s/BEFont=//;
	       $beFont{value}=~s/"//g;
	   }elsif ($_ =~ /^Geometry=/){
	       $geometry=$_;
	       $geometry=~s/Geometry=//;
	       $geometry=~s/"//g;
	   }
	}
	
	close IN;
}
												  
sub saveConfig{
  my ($self, $top)=@_;
  my $new_geometry=$top->geometry;
													  
  return 1 if ($new_geometry eq $geometry);
													  
  my $renamed = 0;
  
  if (-e $config_file){
	  $renamed = rename $config_file, "${config_file}~";
														      
	  if (!$renamed){
		  print "Can not change config file!\n";
		  return 0;
	  }
  }
													  
  if (!open(OUT, '>', "$config_file" )) {
	  print "Can not change config file!\n"; 
	  rename "${config_file}~", $config_file if $renamed;
	  return 0;
  }else{
	  print "Saving SynEd configuration to $config_file ...\n";
	
	  if ($resourcePath{value} eq ""){
		  print OUT ';; ResourcePath="c:\\Users\\user_name\\Editor\\my_res,/c:\\Users\\user_name\\Editor\\resources"' . "\n";
	  }else{
		  print OUT ";;" if (!$resourcePath{valid});
		  print OUT 'ResourcePath="' . $resourcePath{value} . '"' . "\n";
	  }
	
	  if ($tredPath{value} eq ""){
		  print OUT ';; TrEdPath="c:\\Users\\user_name\\tred\\tred.bat"' . "\n";
	  }else{
		  print OUT ";;" if (!$tredPath{valid});
		  print OUT 'TrEdPath="' . $tredPath{value} . '"' . "\n";
	  }

	  foreach my $lang (sort keys %tredDataPath){
		  if ($tredDataPath{$lang}{value} eq ""){
			  print OUT ';; TrEdDataPath_' . $lang . '="c:\\Users\\user_name\\TrEdDataCes"' . "\n";
		  }else{
			  print OUT ";;" if (!$tredDataPath{$lang}{valid});
			  print OUT 'TrEdDataPath_' . $lang . '="' . $tredDataPath{$lang}{value} . '"' . "\n";
		  }
	  }

	  print OUT "\n";
	  if ($languages{value} eq ""){
	  	  print OUT ';; Languages="ces,eng, deu, spa"' . "\n";
	  }else{
	  	  print OUT ";;" if (!$languages{valid});
		  print OUT 'Languages="' . $languages{value} . '"' . "\n";
	  }
	
	  print OUT "\n" . ';; Options for Class Searching can be "id", one of the Languages options, "classmembers", or "roles"' . "\n";
	  if ($searchBy{value} eq ""){
	  	  print OUT ';; ClassSearchBy="id"' . "\n";
	  }else{
	  	  print OUT ";;" if (!$searchBy{valid});
		  print OUT 'ClassSearchBy="' . $searchBy{value} . '"' . "\n";
  	  }
	
	  print OUT "\n;; Font settings for the Browsing Entries in the form ['type', size] (['Arial', 12])\n";
	  if ($beFont{value} eq ""){
	  	  print OUT ';; BEFont=""' . "\n";
	  }else{
		  print OUT ";;" if (!$beFont{valid});
		  print OUT 'BEFont="' . $beFont{value} . '"' . "\n";
	  }
	
	  print OUT "\n\n";
	  print OUT ';; Options changed by SynEd on every close (DO NOT EDIT)' . "\n";
	  print OUT 'Geometry=' . $new_geometry . "\n";
	
	  close OUT;
	  return 1;
  }
}
													    



sub getFromResources{
	my ($self,$fileName)=@_;
	
	my @resources = "";
	@resources = split(/,/,$resourcePath{value}) if ($resourcePath{valid});
	push @resources, "../resources/";
	foreach my $res (@resources){
		$res =~ s/\/$//;
		if (-e $res . "/" . $fileName){
			return $res . "/" . $fileName;
		}
	}

	return 0;
}

sub getDirFromResources{
	my ($self,$dirName)=@_;
	
	my @resources = "";
	@resources = split(/,/,$resourcePath{value}) if ($resourcePath{valid});
	push @resources, "../resources/";
	foreach my $res (@resources){
		$res =~ s/\/$//;
		if (-e $res . "/" . $dirName and -d $res."/".$dirName){
			return $res . "/" . $dirName . "/";
		}
	}

	return 0;

}

sub getTrEd{
	my ($self)=@_;
	if ($tredPath{valid}){
		return "$tredPath{value}";
	}else{
		return "";
	}
}

sub getTrEdDataPath{
	my ($self, $lang)=@_;
	if (defined $tredDataPath{$lang}){
		if ($tredDataPath{$lang}{valid}){
			return "$tredDataPath{$lang}{value}";
		}else{
			return "";
		}
	}else{
		return "";
	}
}

sub getLanguages{
	my ($self)=@_;

	if ($languages{valid}){
		my @langs = map { $self->getCode3($_) } split(',', $languages{value});
		return @langs;
	}else{
		return ("ces","eng");
	}
}

sub getClassSearchBy{
	my ($self)=@_;

	if ($searchBy{valid}){
		return "$searchBy{value}";
	}else{
		return ("id");
	}
}

sub getBEFont{
	my ($self)=@_;

	if ($beFont{valid}){
		return "$beFont{value}";
	}else{
		return 0;
	}
}

sub getGeometry{
  my ($self)=@_;
	
  if ($geometry eq ""){
		return "1500x1500";
  }else{
		return "$geometry";
  }
		
}
	
#Language codes and names
my %codes3=();
my %langNames=();
sub loadCodeTable{
	my ($self)=@_;
	my $code_table = $self->getFromResources("code_table_639.txt");
	if ($code_table eq "" or not open (IN, $code_table)){
		print "CAN NOT OPEN code_table_639.txt for language codes and names!!!\n";
		return;
	}

	while(<IN>){
		chomp($_);
		my ($c3, $c2, $c1, $lname) = split('\t', $_);
		next if ($lname eq "Lang Name");
		$codes3{$c2} = $c3;
		$codes3{$c1} = $c3;
		$langNames{$c3} = $lname;
	}
}


sub getCode3{
	my ($self, $lang) = @_;

	return $codes3{$lang} || $lang;
}

sub getLangName{
	my ($self, $lang) = @_;
	my $code3=$self->getCode3($lang);
	return $langNames{$code3} || $lang;
}

1;
