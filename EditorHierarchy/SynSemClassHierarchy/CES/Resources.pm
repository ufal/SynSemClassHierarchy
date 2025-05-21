=head1 NAME

SynSemClassHierarchy::CES::Resources

=cut

package SynSemClassHierarchy::CES::Resources;

use utf8;
use strict;
use locale;

sub read_resources{
	require SynSemClassHierarchy::LibXMLVallex;
	require SynSemClassHierarchy::LibXMLCzEngVallex;
	require SynSemClassHierarchy::CES::Links;
	require SynSemClassHierarchy::CES::Examples;

	my $pdtvallex_file = SynSemClassHierarchy::Config->getFromResources("CES/pdtvallex-4.5.xml");
	die ("Can not read file pdtvallex-4.5.xml") if ($pdtvallex_file eq "0");
	$SynSemClassHierarchy::LibXMLVallex::pdtvallex_data=SynSemClassHierarchy::LibXMLVallex->new($pdtvallex_file,1);

	my $substituted_pairs_file = SynSemClassHierarchy::Config->getFromResources("CES/substitutedPairs.txt");
	die ("Can not read file substutedPairs.txt") if ($substituted_pairs_file eq "0");
	$SynSemClassHierarchy::LibXMLVallex::substituted_pairs=SynSemClassHierarchy::LibXMLVallex->getSubstitutedPairs($substituted_pairs_file);

	my $pdtvallex2_8_file = SynSemClassHierarchy::Config->getFromResources("CES/pdtvallex-2.8.xml");
	die ("Can not read file pdtvallex-2.8.xml") if ($pdtvallex2_8_file eq "0");
	$SynSemClassHierarchy::LibXMLVallex::pdtvallex2_8_data=SynSemClassHierarchy::LibXMLVallex->new($pdtvallex2_8_file,1);

	unless ($SynSemClassHierarchy::LibXMLCzEngVallex::czengvallex_data){
		my $czengvallex_file = SynSemClassHierarchy::Config->getFromResources("CES/frames_pairs.xml");
		die ("Can not read file vallex_cz.xml") if ($czengvallex_file eq "0");
		$SynSemClassHierarchy::LibXMLCzEngVallex::czengvallex_data=SynSemClassHierarchy::LibXMLCzEngVallex->new($czengvallex_file,1);
	}

	my $vallex4_5_mapping_file = SynSemClassHierarchy::Config->getFromResources("CES/vallex4.5_mapping.txt");
	die ("Can not read file vallex4.5_mapping.xml") if ($vallex4_5_mapping_file eq "0");
	$SynSemClassHierarchy::CES::LexLink::vallex4_5_mapping=SynSemClassHierarchy::CES::LexLink->getMapping("vallex4.5",$vallex4_5_mapping_file);

	my $pdtval_val3_mapping_file = SynSemClassHierarchy::Config->getFromResources("CES/pdtval_val3_mapping.txt");
	die ("Can not read file pdtval_val3_mapping.xml") if ($pdtval_val3_mapping_file eq "0");
	$SynSemClassHierarchy::CES::LexLink::pdtval_val3_mapping=SynSemClassHierarchy::CES::LexLink->getMapping("pdtval_val3",$pdtval_val3_mapping_file);

	my $nomvallex_mapping_file = SynSemClassHierarchy::Config->getFromResources("CES/nomvallex_mapping.txt");
	die ("Can not read file nomvallex_mapping.xml") if ($nomvallex_mapping_file eq "0");
	$SynSemClassHierarchy::CES::LexLink::nomvallex_mapping=SynSemClassHierarchy::CES::LexLink->getMapping("nomvallex",$nomvallex_mapping_file);

	my $vallex_changes_file = SynSemClassHierarchy::Config->getFromResources("CES/vallex.changes");
	die ("Can not read file vallex.changes") if ($vallex_changes_file eq "0");
	$SynSemClassHierarchy::CES::LexLink::pdtvallex4_5_changes=SynSemClassHierarchy::CES::LexLink->getMapping("pdtvallex4.5_changes",$vallex_changes_file);

}
	
1;
