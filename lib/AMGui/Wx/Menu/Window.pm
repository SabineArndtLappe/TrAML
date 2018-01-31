package AMGui::Wx::Menu::Window;

use strict;
use warnings;

use Wx::Locale gettext => '_T';

use AMGui::Constant;

our @ISA = 'Wx::Menu';

sub new {
    my $class = shift;
    my $main  = shift;
    
    my $self = $class->SUPER::new(@_);
    bless $self, $class;

    my %tips = (
        wxID_NEXT_TAB => _T("Switches to the tab on the right"),
        wxID_PREV_TAB => _T("Switches to the tab on the left")
    );

    $self->Append(wxID_NEXT_TAB,
                  _T("Next Tab\tCtrl+PGDN"),
                  $tips{wxID_NEXT_TAB});
    $self->Append(wxID_PREV_TAB,
                  _T("Previous Tab\tCtrl+PGUP"),
                  $tips{wxID_PREV_TAB});
    #$self->AppendSeparator();
  
    return $self;
}

sub title {
    return _T("&Window");
}

1;
