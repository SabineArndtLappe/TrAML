package AMGui::Wx::DatasetViewer;

use strict;
use warnings;
#use Data::Dumper;

use Wx qw[:everything];
use Wx::Locale gettext => '_T';

use AMGui::Constant;
use AMGui::Wx::TabularViewer;

our @ISA = 'AMGui::Wx::TabularViewer';

use Class::XSAccessor {
    getters => {
        dataset       => 'dataset',
        result_viewer => 'result_viewer'
    },
};

sub new {
    my ($class, $main, $dataset) = @_;

    my $self = $class->SUPER::new($main);
    bless $self, $class;

    $self->{dataset}       = $dataset; # AMGui::Dataset
    $self->{title}         = $dataset->filename;
    $self->{result_viewer} = undef;

    # Create the table header: column names
    my @columns = ("Index", "Class");
    for (my $i=0; $i < $self->dataset->cardinality; $i++) {
        push @columns, "F" . (1+$i); # a separate column for every feature
    }
    push @columns, "Comment";

    $self->add_columns(\@columns);

    # Populate the table (rows) with items from the dataset
    for (my $i=0; $i < $self->dataset->size; $i++) {
        my $data_item = $self->dataset->nth_item($i); # AM::DataSet::Item
        $self->add_row($i, $data_item);
    }
    $self->adjust_column_widths;

    # show the table in a new notebook page
    $self->main->notebook->AddPage($self, $self->{title}, 1);
    $self->Select(0, FALSE); # ensure nothing selected

    Wx::Event::EVT_LIST_ITEM_ACTIVATED($self, $self->GetId, \&on_double_click_item);

    return $self;
}

# Given a AM::DataSet::Item, lay it down in a row
sub add_row {
    my ($self, $pos_in_dataset, $dataset_item) = @_;

    my @columns = (
        $pos_in_dataset,      # position of this item in AM::DataSet
        $dataset_item->class  # expected class
    );

    push @columns, @{$dataset_item->features}; # each feature in its column
    push @columns, $dataset_item->comment;     # comment, often word itself

    return $self->SUPER::add_row($pos_in_dataset, \@columns);
}

sub purpose {
   my $self = shift;
   return $self->dataset->purpose;
}

sub close {
    my $self = shift;
    $self->dataset->close;
    $self->unset_result_viewer;
    return 1;
}

sub set_result_viewer {
    my ($self, $viewer) = @_;
    $self->{result_viewer} = $viewer;
    $viewer->set_dataset_viewer($self); # a backlink from ResultViewer to DatasetViewer
    return 1;
}

sub unset_result_viewer {
    my $self = shift;
    if (defined $self->result_viewer) {
        my $viewer = $self->{result_viewer};
        $self->{result_viewer} = undef;
        $viewer->unset_dataset_viewer;
    }
    return 1;
}

# TODO: setting should trigger refreshing the view. which in turn requires asking the user
# if he wants to lose current state
#sub set_dataset {
#    my ($self, $dataset) = @_;
#    $self->{dataset} = $dataset;
#    return $self->{dataset};
#}

sub on_double_click_item {
    my ($self, $event) = @_;
    #$event->GetItem->GetData; #=> position of clicked item in AM::DataSet
    $self->main->classify_item($self);
    $event->Skip;
}

sub current_data_item {
    my $self = shift;
    return $self->dataset->nth_item( $self->GetFirstSelected );
}

sub advance_selection {
    my $self = shift;

    my $curr_idx = $self->GetFirstSelected; # also GetFocused?
    my $next_idx;

    if ( $curr_idx == -1 ) {
        $next_idx = 0;
    } elsif ($curr_idx+1 == $self->GetItemCount) {
        # looking at the last item, keep it selected
    } else {
        $next_idx = $curr_idx+1;
    }

    if (defined $next_idx) {
        $self->Select($next_idx, TRUE); # this also deselects previous item
        $self->Focus($next_idx);
    }

    return defined $next_idx;
}

sub training {
    my $self = shift;
    return $self->dataset->training; #=> AMGui::DataSet
}

# full path to the associated file
sub path {
    my $self = shift;
    return $self->dataset->path;
}

sub set_path {
    my ($self, $path) = @_;
    $self->dataset->set_path($path);
    return $self;
}

sub save {
    my $self = shift;
    return $self->dataset->save;
}

1;
