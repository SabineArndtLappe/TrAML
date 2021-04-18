package AMGui::AM;

use strict;
use warnings;

use Algorithm::AM;
use Algorithm::AM::Batch;

use AMGui::Constant;

#use Data::Dumper;

use Class::XSAccessor {
    getters => {
        classifier    => 'classifier',
        training      => 'training',      # training dataset, AM::DataSet
        testing       => 'testing',       # testing dataset, AM::DataSet
        result        => 'result',        # last result, AM::Result
        result_viewer => 'result_viewer', # holds classification results (AM::Result) and manages reports
        options       => 'options',       # a hash of options that AM accepts (linear, include_nulls, include_given)
        progressbar   => 'progressbar'
    },
    setters => {
        set_result_viewer => 'result_viewer',
        set_progressbar   => 'progressbar'
    }
};

sub new {
    my ($class, $opts) = @_;

    my $self = bless {
        options => {%$opts} # copy options
    }, $class;
    $self->{progressbar} = undef;

    return $self;
}

sub set_training {
    my ($self, $dataset) = @_;
    $self->{training} = $dataset;
    return $self;
}

sub set_testing {
    my ($self, $dataset) = @_;
    $self->{testing} = $dataset;
    return $self;
}

#sub set_datasets {
#    my ($self, $training, $testing) = @_;
#    $self->{training} = $training;
#    $self->{testing}  = $testing;
#    return $self;
#}

sub close {
    my $self = shift;
    $self->{training}      = undef;
    $self->{testing}       = undef;
    $self->{result}        = undef;
    $self->{classifier}    = undef;
    $self->{result_viewer} = undef;
    return 1;
}

# Classify given test item using preset training set
sub classify {
    my ($self, $test_item) = @_;

    my %options = ((
        training_set => $self->training->data
    ), %{$self->options});

    $self->{classifier} = Algorithm::AM->new(%options);
    $self->{result} = $self->classifier->classify( $test_item ); #=> AM::Result

    $self->result_viewer->add( $self->result );
    $self->result_viewer->show_in_statusbar("Predicted class is " . $self->result->result);

    return $self->result;
}

sub classify_all {
    my ($self, $testing) = @_;
    $self->set_testing($testing)  if defined $testing;

    my %options = ((
        training_set  => $self->training->data,
        end_test_hook => $self->am_end_test_hook,
    ), %{$self->options});

    $self->{classifier} = Algorithm::AM::Batch->new(%options);

    # we've been told to show a progressbar
    if (defined $self->progressbar) {
        $self->{progressbar} = $self->progressbar->("Classifying",
                                                    "Starting...",
                                                    $self->testing->size);
    }

    $self->classifier->classify_all( $self->testing->data );

    #TODO: build other reports from existing results
    #TODO#$self->result_viewer->show_reports;

    $self->result_viewer->focus(0);

    return 1;
}

sub am_end_test_hook {
    my ($self) = @_;

    my $cnt_total = $self->testing->size;
    my ($cnt_current, $cnt_correct) = (0, 0);

    return sub {
        my ($batch, $test_item, $result) = @_;
        $cnt_current++;
        $cnt_correct++  if $result->result eq 'correct'; # TODO: AM::Result->is_correct

        $self->result_viewer->add($result);

        # TODO: maybe worth removing, because the same is shown in ProgressBar
        # However when processing completes and the ProgressBar closes,
        # the figures must be shown in the StatusBar.
        my $msg = join "; ", (
            "Total: "   . $cnt_total,
            "Current: " . $cnt_current,
            "Correct: " . $cnt_correct);
        $self->result_viewer->show_in_statusbar($msg);

        # Update the progress bar
        if (defined $self->progressbar) {
            $msg = join ", ", ("Total: "               . $cnt_total,
                               "so far: "              . $cnt_current,
                               "correctly predicted: " . $cnt_correct);
            $self->progressbar->Update($cnt_current, $msg);
        }
    }
}

1;
