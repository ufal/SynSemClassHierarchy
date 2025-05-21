#
# Example sentences for English classmembers
#

package SynSemClassHierarchy::ENG::Examples;

use utf8;
use strict;

sub getAllExamples {
	my ($self, $data_cms, $classmember) = @_;
	return () unless ref($classmember);
	my @sents = ();
	my %processed_pairs=();
	my @pairs=();

	my $corpref = ();
	#pcedt 2.0 sentences
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
	if (scalar @pairs == 0){
		my $enid = $classmember->getAttribute("idref");
		if ($enid =~ /EngVallex-ID-/){
			$enid =~ s/EngVallex-ID-//;
			push @pairs, $enid . "#.*";
		}
	}
  
	foreach my $pair (@pairs){  #ugly hack for substituted frames (files with sentences are for active/reviewed frames, but in czengvallex can be pairs
		  							#with substituted frame, active frame or both - subsituted and active - we need to avoid duplicity
		next if ($processed_pairs{$pair});
		$processed_pairs{$pair}=1;

		my ($enid, $csid)=split('#', $pair);
		my $examplesFile= "ENG/example_sentences/Vtext_eng." . $enid . ".php";
		
		my $sentencesPath=SynSemClassHierarchy::Config->getFromResources($examplesFile);

		if (!$sentencesPath){
			#try another sentences resources
			for my $corpus ('pedt'){	
				$examplesFile = "ENG/example_sentences/Vtext_eng_" . $corpus . "_" . $enid . ".txt";
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
				next if ($corpref eq "pcedt" and $csid ne ".*" and $frpair !~ /^$enid\.$csid$/);
	
				my $testData=0;
				if ($data_type eq "<test>" or ($data_type eq "" and $nodeID =~ /wsj_2/)){
					$testData=1;
				}
	 			push @sents, [$corpref."##".$nodeID."##".$frpair."##eng##".$testData, $text]
				#push @sents, [$_, $corpref."##".$nodeID."##".$frpair."##ces", $lexEx, $testData,  $text]
			}
			close $fh;
		}else{
			print "getAllExamples: Cann't open $sentencesPath file for $examplesFile\n";
			next;
		}
	}

	
	#ssc sentences
	$corpref = "ssc";
	my $lemma = $classmember->getAttribute("lemma");
	my $examplesFile = "ENG/example_sentences/Vtext_eng_SSC_" . $lemma . ".txt";
		  
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
 				push @sents, [$corpref."##".$sentID."##".$verb."##eng##0", $text]
			}
			close $fh;
		}else{	
			print "getAllExamples: Cann't open $sentencesPath file for $examplesFile\n";
		}
	}

		
		
	#paracrawl_ge sentences
	$corpref = "paracrawl_ge";
	
	my $extlex = $data_cms->getExtLexForClassMemberByIdref($classmember, $corpref);
	if ($extlex){
  		my ($links) = $extlex->getChildElementsByTagName("links");
	  	foreach my $link ($links->getChildElementsByTagName("link")){
  			my $enlemma = $link->getAttribute("enlemma");
		  	my $gelemma = $link->getAttribute("gelemma");
		  	$gelemma =~ s/ /_/g;
	    
	  	  	my $examplesFile = "ENG/example_sentences/Vtext_eng_" . $enlemma . ".php";
		  
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
	
		 			push @sents, [$corpref."##".$sentID."##".$lpair."##". SynSemClassHierarchy::Config->getCode3($lang) . "##0", $text]
				}
				close $fh;
			}else{
				print "getAllExamples: Cann't open $sentencesPath file for $examplesFile\n";
				next;
			}
	  	}
	 
	} #sentences from paracrawl_ge 
	
	return @sents;
}

sub getNodeForTrEdOpen{
	my ($self, $corp, $node)=@_;
	return "" if ($corp ne "pcedt");

	$node =~ s/EnglishT-wsj_(....)(-.*)/wsj_\1.treex.gz#EnglishT-wsj_\1\2/;
	return $node;
}
1;
