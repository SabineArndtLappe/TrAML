package AMGui::Wx::Menu::File;

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
        #Wx::wxID_NEW => _T("Creates a new, never seen before something"),
        Wx::wxID_OPEN => _T("Opens a file with exemplars in 'commas' format."),
        #wxID_OPEN_PROJECT => _T('Opens a training and a testing datasets at once. Expected file names are "data" and "test"'),
        #wxID_OPEN_PROJECT => _T('Opens a set of exemplars and a set of test items to be used together in a simulation experiment. Expected file names are "data" and "test"'),
        wxID_OPEN_PROJECT => _T('Opens a set of exemplars and a set of test items to be used together. Expected file names are "data" and "test"'),
        Wx::wxID_CLOSE  => _T("Closes the current tab."),
        Wx::wxID_SAVE   => _T("Saves the current tab to a known file name or asks for a filename."),
        Wx::wxID_SAVEAS => _T("Asks for a file name and saves the current tab."),
        Wx::wxID_EXIT   => _T("Closes the application.")
    );

#    $self->Append(Wx::wxID_NEW,
#                  _T("&New\tCtrl+N"),
#                  $tips{Wx::wxID_NEW});
    $self->Append(Wx::wxID_OPEN,
                  _T("&Open\tCtrl+O"),
                  $tips{Wx::wxID_OPEN});
    $self->Append(wxID_OPEN_PROJECT,
                  _T("O&pen a Project\tCtrl+Shift+O"),
                  $tips{wxID_OPEN_PROJECT});
    $self->Append(Wx::wxID_CLOSE,
                  _T("Close\tCtrl+W"),
                  $tips{Wx::wxID_CLOSE});

    $self->AppendSeparator;

    $self->Append(Wx::wxID_SAVE,
                  _T("&Save\tCtrl+S"),
                  $tips{Wx::wxID_SAVE});
    $self->Append(Wx::wxID_SAVEAS,
                  _T("Save &As...\tCtrl+Shift+S"),
                  $tips{Wx::wxID_SAVEAS});

    $self->AppendSeparator;

    $self->Append(Wx::wxID_EXIT,
                  _T("&Quit\tCtrl+Q"),
                  $tips{Wx::wxID_EXIT});

    return $self;
}

sub title {
    return _T("&File");
}

1;
