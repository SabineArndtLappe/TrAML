package AMGui::Wx;

use strict;
use warnings;

#load AMGui stuff

# must be loaded before Wx
#use threads;
#use threads::shared;

use Wx;
use Wx::AUI    ();
#use Wx::Event  (':everything');

sub aui_pane_info {
    my $class = shift;
    my $info  = Wx::AuiPaneInfo->new;
    while (@_) {
	my $method = shift;
	$info->$method(shift);
    }
    return $info;
}

1;
