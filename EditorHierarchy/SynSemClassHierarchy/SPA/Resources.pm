=head1 NAME

SynSemClassHierarchy::SPA::Resources

=cut

package SynSemClassHierarchy::SPA::Resources;

use utf8;
use strict;
use locale;

sub read_resources{
	require SynSemClassHierarchy::SPA::Links;
	require SynSemClassHierarchy::SPA::Examples;

	my $ancora_mapping_file = SynSemClassHierarchy::Config->getFromResources("SPA/ancora_mapping.txt");
	die ("Can not read file ancora_mapping.txt") if ($ancora_mapping_file eq "0");
	$SynSemClassHierarchy::SPA::LexLink::ancora_mapping=SynSemClassHierarchy::SPA::LexLink->getMapping("ancora",$ancora_mapping_file);

	my $sensem_mapping_file = SynSemClassHierarchy::Config->getFromResources("SPA/sensem_mapping.txt");
	die ("Can not read file sensem_mapping.txt") if ($sensem_mapping_file eq "0");
	$SynSemClassHierarchy::SPA::LexLink::sensem_mapping=SynSemClassHierarchy::SPA::LexLink->getMapping("sensem",$sensem_mapping_file);

}
	
1;
