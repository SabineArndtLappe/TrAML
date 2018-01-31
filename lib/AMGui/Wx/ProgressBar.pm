package AMGui::Wx::ProgressBar;

use strict;
use warnings;

use Wx::Locale gettext => '_T';

our @ISA = ("Wx::ProgressDialog");

sub new {
    my ($class, $parent, $title, $message, $maximum) = @_;

    my $self = $class->SUPER::new(
        $title,
        $message,
        $maximum,
        $parent,
        Wx::wxPD_AUTO_HIDE
        #|Wx::wxPD_CAN_ABORT
        #|Wx::wxPD_APP_MODAL|Wx::wxPD_ELAPSED_TIME
        #|Wx::wxPD_ESTIMATED_TIME|Wx::wxPD_REMAINING_TIME
    );

    return $self;
}

1;
