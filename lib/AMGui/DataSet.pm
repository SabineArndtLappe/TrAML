package AMGui::DataSet;

use strict;
use warnings;

use Algorithm::AM::DataSet;
use File::Spec;

use Class::XSAccessor {
    getters => {
        data     => 'data',      # instance of AM::DataSet
        path     => 'path',      # full/path/to/filename
        format   => 'format',    # data formats available in AM::DataSet
        filename => 'filename',  # last portion of the path: filename
        purpose  => 'purpose',
        training => 'training'   # associated training dataset
    },
    setters => {
        set_purpose  => 'purpose',
        set_training => 'training'
    }
};

# TODO: move into Viewer component
use constant TRAINING => 'training';
use constant TESTING  => 'testing';

sub new {
    my ($class, %args) = @_;

    my $self = bless {}, $class;

    # path, format
    while (my ($key,$value) = each %args) {
        $self->{$key} = $value;
    }

    $self->{data}     = Algorithm::AM::DataSet::dataset_from_file(%args);
    $self->{purpose}  = undef ; # TRAINING or TESTING
    $self->{training} = $self;

    $self->set_path( $self->path ); # this sets both path and filename

    return $self;
}

sub is_training {
    my $self = shift;
    return 0  unless defined $self->purpose;
    return $self->purpose eq TRAINING;
}

sub is_testing {
    my $self = shift;
    return 0  unless defined $self->purpose;
    return $self->purpose eq TESTING;
}

######################################################################

sub unpurpose {
    my $self = shift;
    $self->{purpose} = undef;
}

sub close {
    my $self = shift;
    # if the current dataset is testing, when its holding tab is closed
    # we unlink associated training dataset so that it becomes possible
    # to use the latter as both training and testing, as if sole
    # dataset was loaded originally
    if ( $self->is_testing ) {
        $self->training->unpurpose;
    }
    $self->{data} = undef;
    return 1;
}

sub size {
    my $self = shift;
    return $self->{data}->size;
}

sub cardinality {
    my $self = shift;
    return $self->{data}->cardinality;
}

sub items_as_strings {
    my $self = shift;
    my @lines = map { $self->nth_item_as_string($_) } 0..$self->size-1;
    return \@lines;
}

# Return nth item from the dataset,
# => instance of AM::DataSet::Item
sub nth_item {
    my ($self, $index) = @_;
    my $item = $self->{data}->get_item($index);
    return $item;
}

sub nth_item_as_string {
    my ($self, $index) = @_;
    return $self->item_as_string($self->nth_item($index));
}

# Build a string from an AM::DataSet::Item in 'commas' format only
# TODO: Ideally, we want to have the very original line from the source file
#       unless we switch to wxGrid in future :)
sub item_as_string {
    my ($self, $item) = @_;
    return join ",", (
        $item->class,
        "\t" . join("\t", @{$item->features}) . "\t",
        $item->comment      # can be fake!
    );
}

#sub file {
#    my ($self) = shift;
#    return $self->path;
#}

sub set_path {
    my ($self, $path) = @_;
    $self->{path}     = $path;
    $self->{filename} = ( File::Spec->splitpath( $path ) )[-1];
    return 1;
}

sub save {
    my ($self, $format) = @_;
    $format = $self->format  unless defined $format;

    warn "TODO: Saving to " . $self->path . " in " . $format . " format ";
    return 1;
}

1;

