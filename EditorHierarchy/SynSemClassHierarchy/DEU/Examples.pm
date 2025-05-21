#
# Example sentences for German classmembers
#

package SynSemClassHierarchy::DEU::Examples;

use utf8;
use strict;

sub getAllExamples {
	my ($self, $data_cms, $classmember) = @_;
	return () unless ref($classmember);
	my @sents = ();

	my $corpref = ();

	#paracrawl_ge sentences
	$corpref = "paracrawl_ge";
	
	my $extlex = $data_cms->getExtLexForClassMemberByIdref($classmember, $corpref);
	if ($extlex){
  		my ($links) = $extlex->getChildElementsByTagName("links");
	  	foreach my $link ($links->getChildElementsByTagName("link")){
  			my $enlemma = $link->getAttribute("enlemma");
		  	my $gelemma = $link->getAttribute("gelemma");
			$gelemma =~ s/ /_/g;
			$gelemma =~ s/\(/_lp_/;
			$gelemma =~ s/\)/_rp_/;
			
			my $examplesFile = "DEU/example_sentences/Vtext_deu_" . underline_lemma($gelemma) . ".php";
		  
			my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
		  	if (!$sentencesPath){
				print "getAllExamples: There is not sentencesPath for $examplesFile\n";
				next;
		  	}
	
		 	if (open (my $fh,"<:encoding(UTF-8)", $sentencesPath)){
			  	while(<$fh>){
					chomp($_);
					next if ($_!~/^<([^>]*)><([^>]*)><(de|en)> (.*)$/);
					my $sentID=$1;
		
					my $lpair=$2;
					my $lang=$3;
					my $text=$4;
				
					next if ($lpair !~ /^$enlemma\.$gelemma$/);
		 		
					push @sents, [$corpref."##".$sentID."##".$lpair."##". SynSemClassHierarchy::Config->getCode3($lang)."##0", $text];
				}
				close $fh;
			}else{
				print "getAllExamples: Cann't open $sentencesPath file for $examplesFile\n";
				next;
			}
	  	}
	} #sentences from paracrawl_ge 

	#ssc sentences
	my $lemma = $classmember->getAttribute("lemma");
	if ($lemma =~ /^(.*), ((|\()sich(|\)))$/){
		$lemma = $2 . "_" . $1; 
	}
 	$corpref = "ssc";
	my $examplesFile = "DEU/example_sentences/Vtext_deu_SSC_" . underline_lemma($lemma) . ".txt";

	my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
	if ($sentencesPath){
		if (open (my $fh,"<:encoding(UTF-8)", $sentencesPath)){
			while(<$fh>){
				chomp($_);
				next if ($_!~/^<([^>]*)><([^>]*)> (.*)$/);
				my $sentID=$1;
				my $verb=$2;
				my $text=$3;
				next if ($verb !~ /^$lemma$/);
 				push @sents, [$corpref."##".$sentID."##".$verb."##deu##0", $text];
			}
			close $fh;
		}
	}
	
	#valbu sentences
 	$corpref = "valbu";
	my %valbu_links=();
	my $extlex = $data_cms->getExtLexForClassMemberByIdref($classmember, $corpref);
	if ($extlex){
  		my ($links) = $extlex->getChildElementsByTagName("links");
	  	foreach my $link ($links->getChildElementsByTagName("link")){
			my $vlemma = $link->getAttribute("lemma");
			if ($vlemma =~ /^(.*), ((|\()sich(|\)))$/){
				$vlemma = $2 . "_" . $1; 
			}
			$valbu_links{$vlemma}{$link->getAttribute("id")}{$link->getAttribute("sense")} = 1;
		}
	}

	foreach my $vlemma (sort keys %valbu_links){
		my $examplesFile = "DEU/example_sentences/Vtext_deu_VALBU_" . underline_lemma($vlemma) . ".txt";

		my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);
		if ($sentencesPath){
			if (open (my $fh,"<:encoding(UTF-8)", $sentencesPath)){
				while(<$fh>){
					chomp($_);
					next if ($_!~/^<([^>]*)><([^>]*)> (.*)$/);
					my $sentID=$1;
					my $verb=$2;
					my $text=$3;
					if ($sentID =~ /valbu-([^-]*)-([^-]*)-s/){
						my $sense = $1;
						my $id = $2;
						next unless ($valbu_links{$verb}{$sense}{$id});
 						push @sents, [$corpref."##".$sentID."##".$verb."##deu##0", $text];
					}
				}
				close $fh;
			}
		}
	}
	return @sents;
}

	
sub underline_lemma{
	my ($lemma) = @_;

	$lemma =~ s/ /_/g;
	$lemma =~ s/\(/_lp_/;
	$lemma =~ s/\)/_rp_/;
	  	  	
	$lemma =~ s/(ö|ä|ß|ü|ë)/_\1_/g;
	$lemma =~ tr/öäßüë/oasue/;

	return $lemma;
}

1;
