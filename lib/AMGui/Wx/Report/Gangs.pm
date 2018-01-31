package AMGui::Wx::Report::Gangs;

use strict;
use warnings;
use Data::Dumper;

use AMGui::Constant;

use AMGui::Wx::TabularViewer;
#use AMGui::Wx::Viewer;

our @ISA = 'AMGui::Wx::TabularViewer';

sub new {
    my ($class, $main, $mgr) = @_;

    my $self = $class->SUPER::new($main);
    bless $self, $class;
    
    $self->{title}   = "Gangs";
    $self->{output_filename} = "gangs.csv";
    #$self->{purpose} = AMGui::Wx::Viewer::RESULTS;
    
    # individual reports are managed by a ResultViewer that keeps them
    # synchronized. Some methods can be forwarded back to the manager.
    $self->{manager} = $mgr;

    return $self;
}

#
sub add {
    my ($self, $pos_in_results, $result) = @_;

    my @gangs = @{$result->gang_effects};
    #warn Dumper(@gangs);

    # we expect that gangs are sorted by importance, from highest to lowest
    while (my ($gang_num, $gang) = each(@gangs)) {
        my @columns;
        my @colnames unless $self->has_header;

        #
        # add common columns that describe the test item
        #
        
        # add test item features as separate columns
        # feature columns will be named F1,F2,..,Fn
        unless ( $self->has_header ) {
            push @colnames, map { "F" . ++$_ } 0..$#{$result->test_item->features};
        }
        push @columns, @{$result->test_item->features};

        # add the word being classified, conventionally placed in the comment
        push @colnames, "Comment" unless $self->has_header;
        push @columns, $result->test_item->comment;

        #
        # gang specific columns
        #

        # the position of the gang in the set of gangs
        push @colnames, "Rank" unless $self->has_header;
        push @columns, 1+$gang_num;

        # add gang features
        # gang feature columns will be named GF1,GF2,..,GFn
        unless ($self->has_header) {
            push @colnames, map { "GF" . ++$_ } 0..$#{$gang->{features}};
        }
        push @columns, @{$gang->{features}};

        # add gang score: absolute value and percentage
        push @colnames, ("Score", "Score %")  unless $self->has_header;
        push @columns, ($gang->{score}, 
                        $self->effect_as_pct($gang->{effect})); # TODO: get it from AM

        # add info about each class
        my @classes = sort $result->training_set->classes;
        while (my ($i, $class) = each(@classes)) {
            unless ($self->has_header) {
                push @colnames, ("Class " . (1+$i), 
                                 $class . "_ptrs",
                                 $class . "_pct");
            }
            push @columns, ($class,
                            $gang->{class}->{$class}->{score} || 0,
                            $self->effect_as_pct($gang->{class}->{$class}->{effect}));
        }

        # the number of exemplars (from training) that contribute to this gang
        push @colnames, "Size" unless $self->has_header;
        push @columns, $gang->{size};

        # 'homogenous' is ...?
        push @colnames, "Homogenous" unless $self->has_header;
        push @columns, $gang->{homogenous};

        #
        # finally, add it all to GUI
        #

        # set column names
        $self->add_columns(\@colnames) unless $self->has_header;

        # NOTE: pos_is_results does not affect where the row is inserted
        $self->SUPER::add_row($pos_in_results, \@columns);
    }

    $self->adjust_column_widths;

    return TRUE;
}

######################################################################

# convert to percentage the effect field in gang data structure
# TODO: get it from AM
sub effect_as_pct {
    my ($self, $effect_value) = @_;
    $effect_value = 0 unless defined $effect_value;
    #if ($effect_value > 0) {
        return sprintf("%.3f", 100 * $effect_value);
    #} else {
        #return "0";
    #}
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
