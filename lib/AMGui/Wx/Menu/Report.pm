package AMGui::Wx::Menu::Report;

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
        wxID_REPORT_PREDICTION     => _T("Summary of predicted classification."),
        wxID_REPORT_ANALOGICAL_SET => _T("Analogical set."),
        wxID_REPORT_GANGS          => _T("Gang effects.")
    );

    $self->AppendCheckItem(wxID_REPORT_PREDICTION,
                           _T("&Predicted Classification"),
                           $tips{wxID_REPORT_PREDICTION});
    $self->Check(wxID_REPORT_PREDICTION,
                 $main->reports->{wxID_REPORT_PREDICTION});

    $self->AppendCheckItem(wxID_REPORT_ANALOGICAL_SET,
                           _T("&Analogical Set"),
                           $tips{wxID_REPORT_ANALOGICAL_SET});
    $self->Check(wxID_REPORT_ANALOGICAL_SET,
                 $main->reports->{wxID_REPORT_ANALOGICAL_SET});

    $self->AppendCheckItem(wxID_REPORT_GANGS,
                           _T("&Gangs"),
                           $tips{wxID_REPORT_GANGS});
    $self->Check(wxID_REPORT_GANGS,
                 $main->reports->{wxID_REPORT_GANGS});

    return $self;
}

sub title {
    return _T("R&eports");
}

1;
