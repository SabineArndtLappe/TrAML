package AMGui::Wx::Menu::Help;

use strict;
use warnings;

use Wx::Locale gettext => '_T';

our @ISA = 'Wx::Menu';

sub new {
    my $class = shift;
    my $main  = shift;

    my $self = $class->SUPER::new(@_);
    bless $self, $class;

    $self->Append(Wx::wxID_HELP_CONTENTS, _T("Help\tCtrl+H"), "");
    $self->AppendSeparator();
    $self->Append(Wx::wxID_ABOUT, _T("About"), "");

    return $self;
}

sub title {
    return _T("&Help");
}

1;
