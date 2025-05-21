=head1 NAME

SynSemClassHierarchy::ENG::Resources

=cut

package SynSemClassHierarchy::ENG::Resources;

use utf8;
use strict;
use locale;

sub read_resources{
	require SynSemClassHierarchy::LibXMLVallex;
	require SynSemClassHierarchy::LibXMLCzEngVallex;
	require SynSemClassHierarchy::ENG::Links;
	require SynSemClassHierarchy::ENG::Examples;

	my $engvallex_file = SynSemClassHierarchy::Config->getFromResources("ENG/vallex_en.xml");
	die ("Can not read file vallex_en.xml") if ($engvallex_file eq "0");
	$SynSemClassHierarchy::LibXMLVallex::engvallex_data=SynSemClassHierarchy::LibXMLVallex->new($engvallex_file,1);

	unless ($SynSemClassHierarchy::LibXMLCzEngVallex::czengvallex_data){
		my $czengvallex_file = SynSemClassHierarchy::Config->getFromResources("ENG/frames_pairs.xml");
		die ("Can not read file vallex_cz.xml") if ($czengvallex_file eq "0");
		$SynSemClassHierarchy::LibXMLCzEngVallex::czengvallex_data=SynSemClassHierarchy::LibXMLCzEngVallex->new($czengvallex_file,1);
	}

	my $fn_mapping_file = SynSemClassHierarchy::Config->getFromResources("ENG/framenet_mapping.txt");
	die ("Can not read file framenet_mapping.xml") if ($fn_mapping_file eq "0");
	$SynSemClassHierarchy::ENG::LexLink::framenet_mapping=SynSemClassHierarchy::ENG::LexLink->getMapping("framenet",$fn_mapping_file);

	my $oewn_mapping_file = SynSemClassHierarchy::Config->getFromResources("ENG/oewn_mapping.txt");
	die ("Can not read file oewn_mapping.xml") if ($oewn_mapping_file eq "0");
	$SynSemClassHierarchy::ENG::LexLink::oewn_mapping=SynSemClassHierarchy::ENG::LexLink->getMapping("oewn",$oewn_mapping_file);
}
	
1;
