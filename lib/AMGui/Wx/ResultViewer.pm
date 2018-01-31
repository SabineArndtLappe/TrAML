package AMGui::Wx::ResultViewer;
# TODO: perhaps this class should not be under Wx any more
# and can be renamed to, e.g., ReportManager

use strict;
use warnings;

#use Data::Dumper;

use AMGui::Constant;

use AMGui::Wx::Report::Predictions;
use AMGui::Wx::Report::AnalogicalSets;
use AMGui::Wx::Report::Gangs;

use Class::XSAccessor {
    getters => {
        main           => 'main',
        results        => 'results',
        dataset_viewer => 'dataset_viewer',
        purpose        => 'purpose',
        reports        => 'reports'
    }
};

sub new {
    my ($class, $main, $reports) = @_;

    my $self = bless {
        main    => $main,
        purpose => AMGui::Wx::Viewer::RESULTS,
        reports => [], # an array of active reports
        results => [], # (arrayref of) AM::Result objects
        dataset_viewer => undef  # DatasetViewer associated with this ResultViewer
    }, $class;

    $self->{report_classes} = {
        wxID_REPORT_PREDICTION     => "AMGui::Wx::Report::Predictions",
        wxID_REPORT_ANALOGICAL_SET => "AMGui::Wx::Report::AnalogicalSets",
        wxID_REPORT_GANGS          => "AMGui::Wx::Report::Gangs"
    };

    $self->set_reports($reports) if defined $reports;

    return $self;
}

sub close {
    my $self = shift;
    $self->unset_dataset_viewer;
}

sub set_reports {
    my ($self, $reports) = @_;
    # clear all current reports
    # TODO: need to close no longer necessary tabs? or just grey them out
    #       to show they are no longer used?
    # TODO: maybe reuse existing reports, create (and populate) a new one
    # Take into account Results
    $self->{reports} = [];
    # set new reports
    foreach my $report_id (@{$self->main->order_of_reports}) {
        if ( $reports->{$report_id} ) {
            my $class = $self->{report_classes}->{$report_id};
            push @{$self->reports}, $class->new($self->main, $self);
        }
    }
    #warn "The following reports have been set: " . $self->reports;
    return $self;
}

sub set_dataset_viewer {
    my ($self, $viewer) = @_;
    $self->{dataset_viewer} = $viewer;

    # CAREFUL a DatasetViewer can have more than one ResultViewers,
    # one for batch mode and another one for simple classify-one mode.
    # Most likely, setting a backlink here does not make sense, since
    # a ResultViewer is never created *before* a DatasetViewer has been
    # created.
    #$viewer->set_result_viewer($self); #will cause infinite mutual recursion
}

sub unset_dataset_viewer {
    my $self = shift;
    if (defined $self->{dataset_viewer}) {
        my $viewer = $self->dataset_viewer;
        $self->{dataset_viewer} = undef;
        $viewer->unset_result_viewer; # TODO: what is several result viewers?
    }
    return 1;
}

sub set_classifier {
    my ($self, $classifier) = @_;
    $self->{classifier} = $classifier;
    $classifier->set_result_viewer($self);
    return $self;
}

# return the report that is displayed in the active tab
#sub active_report {
#}

######################################################################

# TODO: problem! when this method is called as a callback from classify_all
# in order to display results as they are generated, the tab does not get updated
# until the processing has finished. Statusbar however is updated successfully!
sub add {
    my ($self, $result) = @_;

    my $last = -1 + push(@{$self->results}, $result);

    # add the newly added item to GUI (reports)
    foreach my $report (@{$self->reports}) {
        $report->add($last, $result);
        $report->show;
    }

    # and switch to the tab with the first report
    ($self->reports->[0])->show(TRUE);

    # highlight the the most recent result
    # TODO: oops, will not work for gangs report. maybe focus_last?
    #TODO#$report->focus($row);

    return $self;
}

######################################################################
# The following methods are simply forwarded to contained objects
#

sub focus {
    my ($self, $idx) = @_;
    my $report = $self->{reports}->[0]; # TODO: select correct report
    return $report->focus($idx);
}

sub show_in_statusbar {
    my ($self, $msg) = @_;
    my $report = $self->{reports}->[0]; # TODO: select correct report
    return $report->show_in_statusbar($msg);
}

1;
