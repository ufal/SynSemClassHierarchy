=head1 NAME

SynSemClassHierarchy::DEU::Resources

=cut

package SynSemClassHierarchy::DEU::Resources;

use utf8;
use strict;
use locale;

sub read_resources{
	require SynSemClassHierarchy::DEU::Links;
	require SynSemClassHierarchy::DEU::Examples;

	my $gup_mapping_file = SynSemClassHierarchy::Config->getFromResources("DEU/gup_mapping.txt");
	die ("Can not read file gup_mapping.txt") if ($gup_mapping_file eq "0");
	$SynSemClassHierarchy::DEU::LexLink::gup_mapping=SynSemClassHierarchy::DEU::LexLink->getMapping("gup",$gup_mapping_file);

	my $valbu_mapping_file = SynSemClassHierarchy::Config->getFromResources("DEU/valbu_mapping.txt");
	die ("Can not read file valbu_mapping.txt") if ($valbu_mapping_file eq "0");
	$SynSemClassHierarchy::DEU::LexLink::valbu_mapping=SynSemClassHierarchy::DEU::LexLink->getMapping("valbu",$valbu_mapping_file);
}
	
1;
