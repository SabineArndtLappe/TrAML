package AMGui::Wx::Report::Predictions;

use strict;
use warnings;

use AMGui::Constant;

use AMGui::Wx::TabularViewer;
#use AMGui::Wx::Viewer;

our @ISA = 'AMGui::Wx::TabularViewer';

sub new {
    my ($class, $main, $mgr) = @_;

    my $self = $class->SUPER::new($main);
    bless $self, $class;
    
    $self->{title}   = "Predictions";
    $self->{output_filename} = "predictions.csv";
    #$self->{purpose} = AMGui::Wx::Viewer::RESULTS;
    
    # individual reports are managed by a ResultViewer that keeps them
    # synchronized. Some methods can be forwarded back to the manager.
    $self->{manager} = $mgr;

    return $self;
}

sub add {
    my ($self, $pos_in_results, $result) = @_;

#   warn "Inserting at pos=" . $pos_in_results;

    my @columns;
    my @colnames unless $self->has_header;

    # add features as separate columns
    push @columns, @{$result->test_item->features};
    unless ( $self->has_header ) {
        # feature columns will be named F1,F2,..,Fn
        push @colnames, map { "F" . ++$_ } 0..$#{$result->test_item->features};
    }

    # add the word being classified, conventionally placed in the comment
    push @columns, $result->test_item->comment;
    unless ( $self->has_header ) {
        push @colnames, "Comment";
    }

    # expected class and the result of prediction (correct, tie, incorrect)
    push @columns, ($result->test_item->class, $result->result);
    unless ( $self->has_header ) {
        push @colnames, ("Expected", "Predicted");
    }
    
    # for each class in the dataset...
    my @classes = $result->training_set->classes; # contains all classes
    my %scores = %{$result->scores}; # contains only classes for this item
    my $i = 0;
    for my $class (sort @classes) {
        push @columns, $class;                 # class name
        push @columns, ($scores{$class} || 0); # score of this particular class (number of pointers)
        # the score expressed in %
        # TODO: would be good to get it from AM::Result
        #       use AM::Result::scores_normalized for it?
        push @columns, $self->to_pct($scores{$class}, $result->total_points);

        unless ( $self->has_header ) {
            push @colnames, ("Class ". ++$i, "${class}_ptrs", "${class}_pct");
        }
    }

    push @columns, ($result->exclude_nulls  ? 'excluded' : 'included');
    push @columns, ($result->given_excluded ? 'excluded' : 'included');
    push @columns, $result->count_method;
    push @columns, $result->training_set->size;
    push @columns, $result->cardinality;
    #warn join(",", @columns);

    unless ( $self->has_header ) {
        push @colnames, ("Nulls", "Given", "Gang", "Size of training set", "No. of features considered");
    }

#    warn "Num columns: " . scalar @columns;
#    warn join(",", @columns);

    unless ( $self->has_header ) {
#       warn "Num colnames: " . scalar @colnames;
#       warn join(",", @colnames);
        #my $colcount = 
        $self->add_columns(\@colnames);
        #warn "Number of columns: " . $colcount;
    }

    my $row = $self->SUPER::add_row($pos_in_results, \@columns);
    $self->adjust_column_widths;

    return $row;
}

# TODO: if $part equals 0 then the outputted value is 0.000. is it okey? -- yes
sub to_pct {
    my ($self, $part, $whole) = @_;
    $part = 0 unless defined $part;
    my $percentage_format = '%.3f'; # also defined in Algorithm::AM::Result
    return sprintf($percentage_format, 100 * $part / $whole);
}

######################################################################
# these methods should be available in all report classes
# TODO: maybe move them to the base class? do they make sense there?

sub purpose {
    return $_[0]->{manager}->purpose;
}

sub dataset_viewer {
    return $_[0]->{manager}->dataset_viewer;
}

1;
