package AMGui::Wx::Menu::Run;

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
    
    # tips are shown in the status bar
    my %tips = (
        wxID_RUN_NEXT          => _T("Classifies the next-after-highlighted item in the testing dataset."),
        wxID_RUN_BATCH         => _T("Classifies the whole testing dataset"),
        wxID_RUN_LINEAR        => _T("For computing scores Linear uses occurrences, Quadratic uses pointers."),
        wxID_RUN_INCLUDE_NULLS => _T("If checked, treats null variables in a test item as regular variables."),
        wxID_RUN_INCLUDE_GIVEN => _T("If checked, allows a test item to be included in the data set during classification.")
    );
    
    $self->Append(wxID_RUN_NEXT,
                 _T("Run AM on the &next item\tCtrl+R"),
                 $tips{wxID_RUN_NEXT});
    $self->Append(wxID_RUN_BATCH,
                 _T("Run AM on &all items in the current dataset\tCtrl+Shift+R"),
                 $tips{wxID_RUN_BATCH});

    $self->AppendSeparator;

    $self->AppendCheckItem(wxID_RUN_LINEAR,
                           _T("&Linear"),
                           $tips{wxID_RUN_LINEAR});
    $self->Check(wxID_RUN_LINEAR,
                 $main->amoptions->{linear});
    
    $self->AppendCheckItem(wxID_RUN_INCLUDE_NULLS,
                           _T("Include &nulls"), 
                           $tips{wxID_RUN_INCLUDE_NULLS});
    $self->Check(wxID_RUN_INCLUDE_NULLS,
                 !$main->amoptions->{exclude_nulls});
    
    $self->AppendCheckItem(wxID_RUN_INCLUDE_GIVEN,
                           _T("Include &given"), 
                           $tips{wxID_RUN_INCLUDE_GIVEN});
    $self->Check(wxID_RUN_INCLUDE_GIVEN,
                 !$main->amoptions->{exclude_given});
    
    return $self;
}

sub title {
    return _T("&Run");
}

1;
