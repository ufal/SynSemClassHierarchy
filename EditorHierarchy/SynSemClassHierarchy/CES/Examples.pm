#
# Example sentences for Czech classmembers
#

package SynSemClassHierarchy::CES::Examples;

use utf8;
use strict;
sub getAllExamples {
	my ($self, $data_cms, $classmember) = @_;
	return () unless ref($classmember);
	my @sents = ();

	my @csids = ();
	my $corpref = "";

	my $csid = $classmember->getAttribute("idref");
	if ($csid =~ /^PDT-Vallex-ID-/){
		$csid =~ s/PDT-Vallex-ID-//;
		push @csids, $csid;
		$corpref = "pdt-c";
	}elsif ($csid =~ /^Vallex-ID-/){
		my $pdtvallexlex = $data_cms->getExtLexForClassMemberByIdref($classmember, "pdtvallex");
	  	if ($pdtvallexlex){
			my ($pdtlinks) = $pdtvallexlex->getChildElementsByTagName("links");
			foreach my $pdtlink ($pdtlinks->getChildElementsByTagName("link")){
			  	my $pdtref = $pdtlink->getAttribute("idref");
			  	push @csids,  $pdtref;
		    }
		}
		$corpref = "pdt-c";
	}elsif ($csid =~ /^NomVallex-ID-/){
		$csid =~ s/^NomVallex-ID-//;
		$csid =~ s/-(impf|pf|biasp|no-aspect)([0-9])*$//;
		push @csids, $csid . "#" . $1.$2;
		$corpref="nomvallex";		  
	}
  
	foreach my $id (@csids){  
		if ($corpref eq "nomvallex"){
			my ($nomid, $aspect) = split("#", $id);
			my $examplesFile = "CES/example_sentences/Ntext_ces." . underline_string($nomid) . ".txt";
		
			my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
			if (!$sentencesPath){
				print "getAllExamples: There is not $sentencesPath file for $examplesFile\n";
				next;
			}

			if ( open (my $fh, "<:encoding(UTF-8)", $sentencesPath)){
				while (<$fh>){
					chomp($_);
					next if ($_!~/^<([^>]*)><([^>]*)><([^>]*)><([^>]*)> (.*)$/);
					my $nodeID = $1;
					my $corpref = $2;
					my $l_aspect = $3;
					my $frpair = $4; 
					my $text = $5;
					if ($l_aspect eq $aspect){ 
						push @sents, [$corpref . "##" . $nodeID . "##" . $frpair . "##ces##0", $text];
					}
				}
				close $fh;
			}else{
				print "getAllExamples: Cann't open $sentencesPath file for $examplesFile\n";
				next;
			}
	
		}elsif ($corpref eq "pdt-c"){
			my $file_id = "";
			if ($id =~ /^v41([a-z]*)([A-Z]*)$/){
				$file_id = "v41" . $1 . "_" . $2;
			}
			my $examplesFile= "CES/example_sentences/Vtext." . $file_id . ".txt";
		
			my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
			if (!$sentencesPath){
				print "getAllExamples: There is not sentencesPath for $examplesFile\n";
				next;
			}

			if (open (my $fh,"<:encoding(UTF-8)", $sentencesPath)){
				while(<$fh>){
					chomp($_);
					next if ($_!~/^<([^>]*)><([^>]*)><([^>]*)> (.*)$/);
					my $corp=$1;
					my $nodeID=$2;
				
					my $pdtID=$3;
					my $text= format_sent($4);
			
					my $testData=0;
		 			push @sents, [$corp."##".$nodeID."##".$pdtID."##ces##".$testData, $text]
				}
				close $fh;
			}else{
				print "getAllExamples: Can't open $sentencesPath file for $examplesFile\n";
				next;
			}
		}

	}

	return @sents;
}

sub getNodeForTrEdOpen{
	my ($self, $corp, $nodeID)= @_;
	return "" if ($corp !~ /^(faust|pcedt|pdt|pdtsc)$/);

	my ($file, $root, $node) = split("#", $nodeID, 3);
	return $file . "#" . $node;
}

sub underline_string{
	my $string = shift;

    $string =~ s/([áéěíóúůýžščřďťňÁÉĚÍÓÚŮÝŽŠČŘĎŤŇ])/_\1/g;
    $string=~tr/[áéěíóúůýžščřďťňÁÉĚÍÓÚŮÝŽŠČŘĎŤŇ]/[aeeiouuyzscrdtnAEEIOUUYZSCRDTN]/;
	return $string;
}

sub format_sent{
	my $text = shift;

	$text =~ s/<a([^>]*)>/\1/g;
	$text =~ s/<b([^>]*)>/\1/g;
	$text =~ s/<f([^>]*)>/<start_varg>\1<end_varg>/g;
	$text =~ s/<g([^>]*)>/\1/g;
	$text =~ s/<G([^>]*)>/\1/g;
	$text =~ s/<h([^>]*)>//g;
	$text =~ s/<H([^>]*)>//g;
	$text =~ s/<j([^>]*)>/<start_vargaux>\1<end_vargaux>/g;
	$text =~ s/<v([^>]*)>/<start_vs>\1<end_vs>/g;
	$text =~ s/<V([^>]*)>/<start_vs>\1<end_vs>/g;
	$text =~ s/<w([^>]*)>//g;
	$text =~ s/<W([^>]*)>//g;
	$text =~ s/<y([^>]*)>/<start_vauxs>\1<end_vauxs>/g;

	return $text;
}

1;

