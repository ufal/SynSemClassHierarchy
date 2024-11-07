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

	my %processed_pairs=();
	my @pairs=();
	my $corpref = "";

	my $reflexicon = $classmember->getAttribute("lexidref");

	if ($reflexicon eq "pdtvallex"){
		#pcedt sentences
		$corpref = "pcedt";
		my $extlex = $data_cms->getExtLexForClassMemberByIdref($classmember, "czengvallex");
		if ($extlex){
			my ($links)=$extlex->getChildElementsByTagName("links");
			foreach my $link ($links->getChildElementsByTagName("link")){
		  		my $enid = $link->getAttribute("enid");
			  	my $csid = $link->getAttribute("csid");
    	  		$csid = $SynSemClassHierarchy::LibXMLVallex::substituted_pairs->{$csid} if (defined $SynSemClassHierarchy::LibXMLVallex::substituted_pairs->{$csid});
			  	push @pairs, $enid . "#" . $csid;
		    }
		}
	}
	if (scalar @pairs == 0){
		my $csid = $classmember->getAttribute("idref");
		if ($csid =~ /^PDT-Vallex-ID-/){
			$csid =~ s/PDT-Vallex-ID-//;
		    $csid = $SynSemClassHierarchy::LibXMLVallex::substituted_pairs->{$csid} if (defined $SynSemClassHierarchy::LibXMLVallex::substituted_pairs->{$csid});
			push @pairs, ".*#" . $csid;
		}elsif ($csid =~ /^Vallex-ID-/){
			my $pdtvallexlex = $data_cms->getExtLexForClassMemberByIdref($classmember, "pdtvallex");
	  		if ($pdtvallexlex){
				my ($pdtlinks) = $pdtvallexlex->getChildElementsByTagName("links");
				foreach my $pdtlink ($pdtlinks->getChildElementsByTagName("link")){
		  		  	my $pdtref = $pdtlink->getAttribute("idref");
			    	$pdtref = $SynSemClassHierarchy::LibXMLVallex::substituted_pairs->{$pdtref} if (defined $SynSemClassHierarchy::LibXMLVallex::substituted_pairs->{$pdtref});
				  	push @pairs, ".*#" . $pdtref;
			    }
			}
		}elsif ($csid =~ /^NomVallex-ID-/){
			$csid =~ s/^NomVallex-ID-//;
			$csid =~ s/-(impf|pf|biasp|no-aspect)([0-9])*$//;
			push @pairs, $csid . "#" . $1.$2;
			$corpref="nomvallex";		  
		}
	}
  
	foreach my $pair (@pairs){  #ugly hack for substituted frames (files with sentences are for active/reviewed frames, but in czengvallex can be pairs
		  							#with substituted frame, active frame or both - subsituted and active - we need to avoid duplicity
		next if ($processed_pairs{$pair});
		$processed_pairs{$pair}=1;
		
		if ($corpref eq "nomvallex"){
			my ($nomid, $aspect) = split("#", $pair);
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
	
		}else{
			my ($enid, $csid)=split('#', $pair);
			my $examplesFile= "CES/example_sentences/Vtext_ces." . $csid . ".php";
		
			my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
			if (!$sentencesPath){
				#try another sentences resources
				for my $corpus ('pdt', 'pcedt', 'faust', 'pdtsc'){	
					$examplesFile = "CES/example_sentences/Vtext_ces_" . $corpus . "_" . $csid . ".txt";
					$sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
					if ($sentencesPath){
						$corpref = $corpus;
						last;
					}
				}
				if (!$sentencesPath){
					print "getAllExamples: There is not sentencesPath for $examplesFile\n";
					next;
				}
			}

			if (open (my $fh,"<:encoding(UTF-8)", $sentencesPath)){
				while(<$fh>){
					chomp($_);
					next if ($_!~/^(<train>|<test>|)<[^>#]*#([^>]*)><([^>]*)> (.*)$/);
					my $data_type=$1;
					my $nodeID=$2;
				
					my $frpair=$3;
					my $text=$4;
					next if ($enid ne ".*" and $frpair !~ /^$enid\.$csid$/);
			
					my $testData=0;
					if ($data_type eq "<test>" or ($data_type eq "" and $nodeID =~ /wsj2/)){
						$testData=1;
					}
		 			push @sents, [$corpref."##".$nodeID."##".$frpair."##ces##".$testData, $text]
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

sub underline_string{
	my $string = shift;

    $string =~ s/([áéěíóúůýžščřďťňÁÉĚÍÓÚŮÝŽŠČŘĎŤŇ])/_\1/g;
    $string=~tr/[áéěíóúůýžščřďťňÁÉĚÍÓÚŮÝŽŠČŘĎŤŇ]/[aeeiouuyzscrdtnAEEIOUUYZSCRDTN]/;
	return $string;
}

1;

