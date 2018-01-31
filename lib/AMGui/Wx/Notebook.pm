package AMGui::Wx::Notebook;

use 5.022000;
use strict;
use warnings;

use Wx qw[:everything];
use Wx::Locale gettext => '_T';

use AMGui::Wx              ();
use AMGui::Wx::AuiManager  ();
use AMGui::Wx::Viewer;

our $VERSION = '1.00';
our @ISA     = qw{
    Wx::AuiNotebook
};

use Class::XSAccessor {
    getters => {
        main => 'main'
    },
};

#http://docs.wxwidgets.org/trunk/classwx_aui_notebook.html

# TODO
# 1. after tabs were rearranged by dragging, their retain their initial index.
#    the effect is that NextTab and PreviousTab are incorrect.
#    This seems to be a lang-lasting BUG
# 2. Only a few events are actually dispatched. wxPerl sucks!

sub new {
    my( $class, $main, $id, $pos, $size, $style, $name ) = @_;
    $main  = undef              unless defined $main;
    $id    = -1                 unless defined $id;
    $pos   = wxDefaultPosition  unless defined $pos;
    $size  = wxDefaultSize      unless defined $size;
    $name  = ""                 unless defined $name;

    my $aui = $main->aui;

    my $help = [
        "== USAGE ==",
        "1. Open a file in 'commas' format. File/Open or Ctrl-O",
        "   Once it is loaded, double click an item. It will be classified and results will appear in another tab",
        "2. Open a project ('data' and 'test' files with training and testing datasets respectively) at once.",
        "   The testing dataset gets associated with the training dataset so that double clicking an item in testing",
        "   automatically uses associated training dataset.",
        "3. Pressing Run or Ctrl+Shift+R classifies all items in a dataset",
        "   Logic for determining which dataset is training and which one is testing is complex:",
        "   the current tab is inspected and",
        "   a) if the current tab is a testing dataset that was loaded in parallel with a training dataset,",
        "      both datasets are used according to their primary purpose (data - as training, test as testing)",
        "   b) if the current tab contains a dataset that was loaded alone, it is used as both training and testing",
        "   c) all other cases are not yet processed",
        "4. When on a Result tab, pressing Ctrl-R runs the classification on the *next after highlighted* item in",
        "   the associated Testing dataset and displays classification results in the Results tab.",
        "   The same when on Testing dataset tab.",
        "5. Saving:",
        "   + Pressing Ctrl+S saves current tab data to the filename associated with the tab",
        "     + or to a new filename, if none is associated",
        "   + Pressing Ctrl+Shift+S asks the user for a filename and saves the current tab to that filename.",
        "   + Reports of different types suggest appropriate output file names",
        "6. Controlling Linear/Quadratic, Nulls and Given",
        "   + Menu Run/Linear acts as toggle for switching between Linear (checked) and Quadratic modes.",
		"   + Menu Run/Include Nulls and Run/Include given act like toggle for corresponding options in AM library.",
		"7. Possibility to generate several/different types of reports",
		"   + Menu Reports"
    ];

    my $self = $class->SUPER::new(
        $main,
        -1,
        Wx::wxDefaultPosition,
        Wx::wxDefaultSize,
        Wx::wxAUI_NB_TOP|Wx::wxBORDER_NONE|Wx::wxAUI_NB_SCROLL_BUTTONS
            |Wx::wxAUI_NB_TAB_MOVE|Wx::wxAUI_NB_CLOSE_ON_ALL_TABS
            |Wx::wxAUI_NB_WINDOWLIST_BUTTON
    );

    $self->{main} = $main;

    $aui->AddPane(
        $self,
        AMGui::Wx->aui_pane_info(
            Name           => 'notebook',
            Resizable      => 1,
            PaneBorder     => 0,
            Movable        => 1,
            CaptionVisible => 0,
            CloseButton    => 0,
            MaximizeButton => 0,
            Floatable      => 1,
            Dockable       => 1,
            Layer          => 1,
        )->Center,
    );

    $aui->caption('notebook' => _T('Hello'), );

    $self->{help} = AMGui::Wx::Viewer->new($self)->set_lines($help);
    $self->create_tab($self->{help}, _T("Usage"));

    Wx::Event::EVT_AUINOTEBOOK_PAGE_CHANGED(
        $self, $self,
        sub { shift->on_auinotebook_page_changed(@_); }, );

    Wx::Event::EVT_AUINOTEBOOK_PAGE_CLOSE(
        $self, $self,
        sub { shift->on_auinotebook_page_close(@_) }, );

    # this event does not happen, thank you, AUINotebook developers
#    Wx::Event::EVT_AUINOTEBOOK_DRAG_MOTION(
#        $self, $self,
#        sub { shift->on_auinotebook_drag_motion(@_)}, );

    Wx::Event::EVT_AUINOTEBOOK_DRAG_DONE(
        $self, $self,
        sub { shift->on_auinotebook_drag_done(@_)}, );

    # this event does not happen, thank you, AUINotebook developers
#    Wx::Event::EVT_AUINOTEBOOK_BEGIN_DRAG(
#        $self, $self,
#        sub { shift->on_auinotebook_begin_drag(@_)}, );

    # this event does not happen, thank you, AUINotebook developers
#    Wx::Event::EVT_AUINOTEBOOK_END_DRAG(
#        $self, $self,
#        sub { shift->on_auinotebook_end_drag(@_)}, );

    $main->update_aui;

    return $self;
}

sub create_tab {
    my ($self, $obj, $title) = @_;
    $title ||= '(' . _T('Unknown') . ')';

    $self->AddPage($obj, $title, 1);
    $obj->SetFocus;
    return $self->GetSelection;
}

sub page_ids {
    my $self = shift;
    return ($self->first_page_id..$self->last_page_id);
}

sub first_page_id {
    my $self = shift;
    return 0;
}

sub last_page_id {
    my $self = shift;
    return $self->GetPageCount-1;
}

sub select_next_tab {
    my $self = shift;
    $self->AdvanceSelection();
    return $self->GetSelection;
}

sub select_previous_tab {
    my $self = shift;
    $self->AdvanceSelection(0);
    return $self->GetSelection;
}

# replacement to non-available GetCurrentPage;
sub get_current_page {
    my $self = shift;
    return $self->GetPage($self->GetSelection);
}

sub close_current_page {
    my $self = shift;
    my $id = $self->GetSelection;
    my $page = $self->GetPage($id);
    $page->close  if $page;
    return $self->DeletePage($id)
}

# issue close on objects associated with this page
#sub close_page_data {
#    my ($self, $id) = @_;
#    my $page = $self->GetPage($id);
#    $page->close;
#    warn "Done";
#    return 1;
#}

######################################################################
# event handlers

sub on_auinotebook_page_close {
    my ($self, $event) = @_;
    my $page = $self->GetPage($event->GetSelection);
    $page->close  if $page;
    return 1;
}

sub on_auinotebook_page_changed {
    my ($self, $event) = @_;
    #$self->main->inform("Page Changed");
    $event->Skip;
}

#sub on_auinotebook_begin_drag {
#    my ($self, $event) = @_;
#    $event->Skip;
#}

#sub on_auinotebook_end_drag {
#    my ($self, $event) = @_;
#    warn @_;
#    $self->main->inform("End drag");
#    $event->Skip;
#}

# happens
sub on_auinotebook_drag_done {
    my ($self, $event) = @_;
#    warn @_;
#    warn "Current tab id=" . $self->GetSelection;
    $event->Skip;
}

1;
