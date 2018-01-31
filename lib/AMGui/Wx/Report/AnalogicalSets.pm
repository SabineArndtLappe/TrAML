package AMGui::Wx::Report::AnalogicalSets;

use strict;
use warnings;

use AMGui::Constant;

use AMGui::Wx::TabularViewer;
#use AMGui::Wx::Viewer;

#use Data::Dumper;

our @ISA = 'AMGui::Wx::TabularViewer';

sub new {
    my ($class, $main, $mgr) = @_;

    my $self = $class->SUPER::new($main);
    bless $self, $class;
    
    $self->{title}   = "Analogical Sets";
    $self->{output_filename} = "analogical_sets.csv";
    #$self->{purpose} = AMGui::Wx::Viewer::RESULTS;
    
    # individual reports are managed by a ResultViewer that keeps them
    # synchronized. Some methods can be forwarded back to the manager.
    $self->{manager} = $mgr;

    return $self;
}

sub add {
    my ($self, $pos_in_results, $result) = @_;

    #warn "Analogical Set=" . Dumper($result->analogical_set);

    # rebuild the analogical set to make data accessible by word (comment)
    my %anset;
    foreach my $entry (values %{$result->analogical_set}) {
        my $comment = $entry->{item}->comment;
        $anset{$comment} = $entry->{score};
    }
    #my $total_points = $result->total_points; # for computing percent
    #warn Dumper(%anset);

    # generate column names using word itself (called comment in comma format)
    unless ($self->has_header) {
        my @colnames = ("Comment");
        for (my $i=0; $i < $result->training_set->size; $i++) {
            push @colnames, $result->training_set->get_item($i)->comment;
        }
        $self->add_columns(\@colnames);
    }

    # fill in cells
    my @columns = ($result->test_item->comment);
    while (my ($idx, $name) = each(@{$self->colnames})) {
        next if $idx == 0; # skip Comment that identifies the test item
        push @columns, ($anset{$name} || 0);
    }

    my $row = $self->SUPER::add_row($pos_in_results, \@columns);
    $self->adjust_column_widths;

    return $row;
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
