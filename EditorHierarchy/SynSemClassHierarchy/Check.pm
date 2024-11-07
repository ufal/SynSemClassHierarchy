#
# package for checking and correcting synsemclass.xml
#

package SynSemClassHierarchy::Check;

use strict;
use utf8;

sub check{
	my ($self)=@_;

	if ($self->data()->changed){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Save the changes before correcting !");
		return;
	}

	check_specification($self);
}

check_specification{
	#preparation for data check according to specified criteria
}

return 1;
