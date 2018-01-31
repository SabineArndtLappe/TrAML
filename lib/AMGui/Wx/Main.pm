package AMGui::Wx::Main;

use strict;
use warnings;

use Cwd ();
use File::Slurp;
use File::Spec;
use File::Basename;
use Try::Tiny;

use Data::Dumper;

use Wx qw[:everything];
use Wx::Locale gettext => '_T';

use AMGui::AM;
use AMGui::Constant;
use AMGui::DataSet;

use AMGui::Wx::AuiManager;
use AMGui::Wx::DatasetViewer;
use AMGui::Wx::ResultViewer;
use AMGui::Wx::Menubar;
use AMGui::Wx::Notebook;
use AMGui::Wx::StatusBar;
use AMGui::Wx::ProgressBar;

our @ISA = 'Wx::Frame';

#print Wx->VERSION; #=> 0.9928

use Class::XSAccessor {
    getters => {
        notebook  => 'notebook',
        menubar   => 'menubar',
        statusbar => 'statusbar',
        amoptions => 'amoptions',
        reports   => 'reports',
        cwd       => 'cwd',
        aui       => 'aui',
        order_of_reports => 'order_of_reports'
    },
};

sub new {
    my ($class, $parent, $id, $title, $pos, $size, $style, $name) = @_;
    $parent = undef              unless defined $parent;
    $id     = -1                 unless defined $id;
    $title  = ""                 unless defined $title;
    $pos    = wxDefaultPosition  unless defined $pos;
    $size   = wxDefaultSize      unless defined $size;
    $name   = ""                 unless defined $name;
    $style  = wxDEFAULT_FRAME_STYLE
        unless defined $style;

    my $self = $class->SUPER::new($parent, $id, $title, $pos, $size, $style, $name);

    # options that AM accepts, the default state
    $self->{amoptions} = {
        linear        => FALSE,
        exclude_given => TRUE,
        exclude_nulls => TRUE
    };

    # NOTE, the keys are *literal Strings*, not numeric values associated with these constants!
    # This may be confusing and perhaps should be changed
    $self->{reports} = {
        wxID_REPORT_PREDICTION     => TRUE,
        wxID_REPORT_ANALOGICAL_SET => FALSE,
        wxID_REPORT_GANGS          => FALSE
    };
    $self->{order_of_reports} = ["wxID_REPORT_PREDICTION",
                                 "wxID_REPORT_ANALOGICAL_SET",
                                 "wxID_REPORT_GANGS"];

    #$self->{window_1} = Wx::SplitterWindow->new($self, wxID_ANY);
    #$self->{grid_1} = Wx::Grid->new($self->{window_1}, wxID_ANY);

    $self->SetTitle(_T("Analogical Modeling"));
    $self->SetSize(Wx::Size->new(900, 700));

    #$self->{grid_1}->CreateGrid(10, 3);
    #$self->{grid_1}->SetSelectionMode(wxGridSelectCells);

    $self->{aui} = AMGui::Wx::AuiManager->new($self);

    $self->{cwd} = Cwd::cwd;

    $self->{menubar} = AMGui::Wx::Menubar->new($self);
    $self->SetMenuBar($self->{menubar}->menubar);

    $self->{statusbar} = AMGui::Wx::StatusBar->new($self);
    $self->SetStatusBar($self->{statusbar});

    $self->{notebook} = AMGui::Wx::Notebook->new($self);

    # menu File
    Wx::Event::EVT_MENU($self, wxID_NEW,           \&on_file_new);
    Wx::Event::EVT_MENU($self, wxID_OPEN,          \&on_file_open);
    Wx::Event::EVT_MENU($self, wxID_OPEN_PROJECT,  \&on_file_open_project);
    Wx::Event::EVT_MENU($self, wxID_CLOSE,         \&on_file_close);
    Wx::Event::EVT_MENU($self, wxID_SAVE,          \&on_file_save);
    Wx::Event::EVT_MENU($self, wxID_SAVEAS,        \&on_file_save_as);
    Wx::Event::EVT_MENU($self, wxID_EXIT,          \&on_file_quit);

    # menu Reports
    Wx::Event::EVT_MENU($self, wxID_REPORT_PREDICTION,     \&on_toggle_report_prediction);
    Wx::Event::EVT_MENU($self, wxID_REPORT_ANALOGICAL_SET, \&on_toggle_report_analogical_set);
    Wx::Event::EVT_MENU($self, wxID_REPORT_GANGS,          \&on_toggle_report_gangs);

    # menu Run
    Wx::Event::EVT_MENU($self, wxID_RUN_NEXT,          \&on_run_next_item);
    Wx::Event::EVT_MENU($self, wxID_RUN_BATCH,         \&on_run_batch);
    Wx::Event::EVT_MENU($self, wxID_RUN_LINEAR,        \&on_toggle_linear);
    Wx::Event::EVT_MENU($self, wxID_RUN_INCLUDE_NULLS, \&on_toggle_include_nulls);
    Wx::Event::EVT_MENU($self, wxID_RUN_INCLUDE_GIVEN, \&on_toggle_include_given);

    # menu Window
    Wx::Event::EVT_MENU($self, wxID_NEXT_TAB,      \&on_next_tab);
    Wx::Event::EVT_MENU($self, wxID_PREV_TAB,      \&on_previous_tab);
    Wx::Event::EVT_MENU($self, wxID_HELP_CONTENTS, \&on_help_contents);
    Wx::Event::EVT_MENU($self, wxID_ABOUT,         \&on_help_about);

    # Set up the pane close event
    #TODO#Wx::Event::EVT_AUI_PANE_CLOSE($self, sub { shift->on_aui_pane_close(@_); }, );

    return $self;
}

# old wxGlade code
#sub __set_properties {
#    my $self = shift;
#    $self->SetTitle(_T("Main Frame"));
#    $self->SetSize(Wx::Size->new(900, 525));
#
#    $self->{grid_1}->CreateGrid(10, 3);
#    $self->{grid_1}->SetSelectionMode(wxGridSelectCells);
#}

# old wxGlade code
#sub __do_layout {
#    my $self = shift;
#    $self->{sizer_1} = Wx::BoxSizer->new(wxHORIZONTAL);
#    #$self->{window_1}->SplitVertically($self->{grid_1}, $self->{notebook}, );
#    $self->{sizer_1}->Add($self->{window_1}, 1, wxEXPAND, 0);
#    $self->SetSizer($self->{sizer_1});
#    $self->Layout();
#}

######################################################################
# Menu event handlers

sub on_file_new {
    my ($self, $event) = @_;
    warn "Event handler (onFileNew) not implemented";
    $event->Skip;
}

# TODO: possible?
#sub create_format_selector_control {
#    my ($parent) = @_;
#    my $id = -1;
#    my $pos = wxDefaultPosition;
#    my $size = wxDefaultSize;
#    my $style = undef;
#    my $choices = ["commas", "nocommas"]; # only those that are supported by AM::DataSet
#    my $choice = Wx::Choice->new($parent, $id, $pos, $size, $choices, $style);
#    return $choice;
#}

sub on_file_open {
    my ($self, $event) = @_;

    my $wildcard = join(
        '|',
        _T('All Files'),  ( AMGui::Constant::WIN32 ? '*.*' : '*' ),
        _T('CSV Files'),  '*.csv;*.CSV',
        _T('Text Files'), '*.txt;*.TXT'
    );

    my $dialog = Wx::FileDialog->new(
        $self,
        _T('Open Files'),
        $self->cwd,    # Default directory
        '',            # Default file
        $wildcard,
        wxFD_OPEN|wxFD_FILE_MUST_EXIST
    );

    # available in Wx-2.9+
    #$dialog->SetExtraControlCreator(\&create_format_selector_control);

    # If the user really selected a file
    if ($dialog->ShowModal == wxID_OK)
    {
        my @filenames = $dialog->GetFilenames;
        $self->{cwd} = $dialog->GetDirectory;

        my @files;
        foreach my $filename (@filenames) {

            # Construct full paths, correctly for each platform
            my $fname = File::Spec->catfile($self->cwd, $filename);

            unless ( -e $fname ) {
                my $ret = Wx::MessageBox(
                    sprintf(_T('File name %s does not exist on disk. Skip it?'), $fname),
                    _T("Open File Warning"),
                    Wx::wxYES_NO|Wx::wxCENTRE,
                    $self,
                );

                next if $ret == Wx::wxYES;
            }

            push @files, $fname
        }

        $self->setup_data_viewers(\@files) if scalar(@files) > 0;
    }

    return 1;
}

# open 'data' and 'test' files
sub on_file_open_project {
    my ($self, $event) = @_;

    my $wildcard = join(
        '|',
        _T('Project Files'), 'data;Data;DATA;test;Test;TEST',
        _T('All Files'),     ( AMGui::Constant::WIN32 ? '*.*' : '*' )
     );

    my $dialog = Wx::FileDialog->new(
        $self,
        _T('Open Training and Testing datasets at once'),
        $self->cwd,    # Default directory
        '',            # Default file
        $wildcard,
        wxFD_OPEN|wxFD_FILE_MUST_EXIST|wxFD_MULTIPLE
    );

    # If the user really selected a file
    if ($dialog->ShowModal == wxID_OK)
    {
        my @filenames = $dialog->GetFilenames;
        $self->{cwd}  = $dialog->GetDirectory;

        # TODO: check that there are exactly two files
        # and swear otherwise

        my (@files, @data_types);
        foreach my $filename (@filenames) {
            # Construct full paths, correctly for each platform
            my $fname = File::Spec->catfile($self->cwd, $filename);

            unless ( -e $fname ) {
                my $ret = Wx::MessageBox(
                    sprintf(_T('File name %s does not exist on disk. Skip it?'), $fname),
                    _T("Open File Warning"),
                    Wx::wxYES_NO|Wx::wxCENTRE,
                    $self,
                );

                next if $ret == Wx::wxYES;
            }

            push @files, $fname;

            if ( lc $filename eq 'data' ) {
                push @data_types, AMGui::DataSet::TRAINING;
            } elsif (lc $filename eq 'test') {
                push @data_types, AMGui::DataSet::TESTING;
            } else {
                #TODO: react meaningfully
            }
        }

        if ( scalar(@files) == 2 ) {
            $self->setup_data_viewers(\@files, \@data_types);
        } else {
            #TODO: throw a warning: invalid number of files
            # TODO: in theory, 2+ files can be opened, it is importants that there are
            # at least one 'train' and at least one 'test' file.
        }
    }

    #$event->Skip;
    return 1;
}

sub on_file_save {
    my ($self, $event) = @_;

    my $page = $self->notebook->get_current_page;
    if ( defined $page->path ) {
        # TODO: if underlying file changed since it was opened, warn?
        $page->save;
    } else {
        $self->on_file_save_as;
    }

    return 1;
}

sub on_file_save_as {
    my ($self, $event) = @_;

    my $page = $self->notebook->get_current_page or return;

    # Guess directory to save to
    my $cwd = $self->cwd;
    if ( defined $page->path ) {
        $cwd = File::Basename::dirname($page->path);
    }

    # suggested filename to save to
    my $filename;
    $filename = $page->output_filename if $page->can("output_filename");

    # TODO: add CSV and other formats
    my $wildcard = join(
        '|',
        _T('CSV')       , '*.csv;*.CSV',
        _T('All Files') , ( AMGui::Constant::WIN32 ? '*.*' : '*' )
    );

    my $dialog = Wx::FileDialog->new(
        $self,
        _T('Save file as...'),
        $cwd,          # open in this directory
        $filename,     # suggested output file name
        $wildcard,
        Wx::wxFD_SAVE|Wx::wxFD_OVERWRITE_PROMPT
    );

    if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
        return;
    }

    # Q: what if the user pasted the path to the file? - GetPath has it
    # Q: what if the user pasted the directory name? - Dialog handles it correctly
    #$cwd  = $dialog->GetDirectory; # dirname
    my $path = $dialog->GetPath;   # fullpath with the filename

    return $page->set_path($path)->save;
}

sub on_file_save_all {
    my ($self, $event) = @_;
    $self->inform("Saving all files not implemented yet");
    $event->Skip;
}

# TODO: check if has unsaved modifications and do something about it
sub on_file_close {
    my ($self, $event) = @_;
    return $self->notebook->close_current_page;
}

sub on_file_quit {
    my ($self, $event) = @_;
    $self->Close(1);
}

######################################################################
# menu Reports

sub on_toggle_report_prediction {
    my ($self, $event) = @_;
    my $name = 'wxID_REPORT_PREDICTION'; # must be a String!
    $self->reports->{$name} = ($event->IsChecked || FALSE);
    #$self->inform("Report Prediction is set to " . $self->reports->{$name});
    return $self->reports->{$name};
}

sub on_toggle_report_analogical_set {
    my ($self, $event) = @_;
    my $name = 'wxID_REPORT_ANALOGICAL_SET'; # must be a String
    $self->reports->{$name} = ($event->IsChecked || FALSE);
    #$self->inform("Report Analogical Set is set to " . $self->reports->{$name});
    return $self->reports->{$name};
}

sub on_toggle_report_gangs {
    my ($self, $event) = @_;
    my $name = 'wxID_REPORT_GANGS'; # must be a String
    $self->reports->{$name} = ($event->IsChecked || FALSE);
    #$self->inform("Report Gangs is set to " . $self->reports->{$name});
    return $self->reports->{$name};
}

######################################################################
# menu RUN

sub on_run_batch {
    my ($self, $event) = @_;

    my $dv_testing; # DatasetViewer with the testing dataset
    my $curr_page = $self->notebook->get_current_page;

    return 0 unless $curr_page; # TODO: report an error?

    #warn "Purpose:" . $curr_page->purpose;

    # TODO: fix this warning: Use of uninitialized value in string eq at
    if ( $curr_page->purpose eq AMGui::Wx::Viewer::GENERAL ) {
        # ignore this page
        $self->inform("Please switch to a tab with a testing dataset and try again.");

    } elsif ( $curr_page->purpose eq AMGui::Wx::Viewer::RESULTS ) {
        if (defined $curr_page->dataset_viewer) {
            # this Results tab was produced by classify_item method
            $dv_testing = $curr_page->dataset_viewer;

        } else {
            # this Results tab was produced by on_run_batch method
            $self->error("This is the result tab. Please switch to a dataset tab.");
        }

    } elsif ( $curr_page->dataset->is_testing ) {
        # given a testing dataset, use associated training dataset
        $dv_testing = $curr_page;

    } elsif ( $curr_page->dataset->is_training ) {
        $self->error("Please switch to a tab with a testing dataset.");

     } else {
        # Dataset that was loaded alone.
        # This dataset is used both as training and as testing (leave-one-out)
        $dv_testing = $curr_page;
    }

    $self->is_report_selected or return 0;

    if (defined $dv_testing
        # Checking availability of training dataset to avoid advancing to the next item
        # in the situation that classification will turn out impossible.
        && $self->is_valid_dataset($dv_testing->training))
    {
        # TODO: recycle existing result viewer?
        # be careful! newly created ResultViewer must not override other ResultViewers
        # that may already be associated with the dataset viewer
        my $result_viewer = AMGui::Wx::ResultViewer->new($self, $self->reports);

        my $am = AMGui::AM->new($self->amoptions);
        $am->set_training($dv_testing->training)->set_testing($dv_testing->dataset);
        $am->set_result_viewer($result_viewer);
        $am->set_progressbar($self->make_progressbar($dv_testing));
        $am->classify_all;
    }

    return 1;
}

sub make_progressbar {
    my ($self, $parent) = @_;
    return sub {
        AMGui::Wx::ProgressBar->new($parent, shift(), shift(), shift())
    }
}

sub on_run_next_item {
    my ($self, $event) = @_;

    my $dv_testing; # DatasetViewer with the testing dataset
    my $curr_page = $self->notebook->get_current_page;

    return 0 unless $curr_page;

    #warn "Purpose:" . $curr_page->purpose;

    if ( $curr_page->purpose eq AMGui::Wx::Viewer::GENERAL ) {
        # ignore this page
        $self->inform("Please switch to a tab with a testing dataset and try again.");

    } elsif ( $curr_page->purpose eq AMGui::Wx::Viewer::RESULTS ) {
        $dv_testing = $curr_page->dataset_viewer;

    } elsif ( $curr_page->dataset->is_testing ) {
        # given a testing dataset, use associated training dataset
        $dv_testing = $curr_page;

    } elsif ( $curr_page->dataset->is_training ) {
        $self->error("Please switch to a tab with a testing dataset.");

    } else {
        # Dataset that was loaded alone.
        # This dataset is used both as training and as testing (leave-one-out)
        $dv_testing = $curr_page;
    }

    $self->is_report_selected or return 0;

    if (defined $dv_testing
        # Checking availability of training dataset to avoid advancing to the next item
        # in the situation that classification will turn out impossible.
        && $self->is_valid_dataset($dv_testing->training))
    {
        #warn "Testing:  " . $testing;
        #warn "Training: " . $training;
        #warn "DatasetViewer for testing: " . $dv_testing;

        if ( $dv_testing->advance_selection ) {
            $self->classify_item($dv_testing);
        } else {
            $self->inform("No more exemplars available.");
        }
    }

    return 1;
}

sub classify_item {
    my ($self, $dataset_viewer) = @_;

    # get data item highlighted in the current DatasetViewer
    my $test_item = $dataset_viewer->current_data_item;  #=> AM::DataSet::Item
    # reach training dataset associated with the dataset loaded in the current DatasetViewer
    my $training  = $dataset_viewer->training; #=> AMGui::DataSet

    if ( $self->is_valid_dataset($training) ) {
        # we want any new item from the current DatasetViewer to be outputted into
        # the same ResultViewer upon classification. If DatasetViewer already has
        # a ResultViewer associated with it, the latter will be reused. Otherwise
        # we create one and associate it with DatasetViewer.
        unless (defined $dataset_viewer->result_viewer) {
            my $result_viewer = AMGui::Wx::ResultViewer->new($self, $self->reports);
            $dataset_viewer->set_result_viewer($result_viewer);
        }

        # finally, create a classifier and run it
        my $am = AMGui::AM->new($self->amoptions);
        $am->set_training($training); #TODO: ->set_testing($test_item);
        $am->set_result_viewer($dataset_viewer->result_viewer);
        $am->classify($test_item);
    }

    return 1;
}

sub on_toggle_linear {
    my ($self, $event) = @_;
    $self->amoptions->{linear} = $event->IsChecked || FALSE;
    return $self->amoptions->{linear};
}

sub on_toggle_include_nulls {
    my ($self, $event) = @_;
    $self->amoptions->{exclude_nulls} = not ($event->IsChecked || FALSE);
    return $self->amoptions->{exclude_nulls};
}

sub on_toggle_include_given {
    my ($self, $event) = @_;
    $self->amoptions->{exclude_given} = not ($event->IsChecked || FALSE);
    return $self->amoptions->{exclude_given};
}

######################################################################
# menu Window

sub on_next_tab {
    my ($self, $event) = @_;
    $self->notebook->select_next_tab;
    return 1;
}

sub on_previous_tab {
    my ($self, $event) = @_;
    $self->notebook->select_previous_tab;
    return 1;
}

######################################################################
# menu Help

sub on_help_contents {
    my ($self, $event) = @_;
    $self->inform("Help::Contents not yet implemented");
    $event->Skip;
}

sub on_help_about {
    my ($self, $event) = @_;
    $self->inform("Help::About implemented yet");
    $event->Skip;
}

######################################################################

=pod

=head3 C<setup_data_viewers>

    $main->setup_data_viewers( \@files [, \@dataset_types] );

Setup (new) tabs for C<@files>, and update the GUI.

=cut

sub setup_data_viewers {
    my ($self, $files, $dataset_types) = @_;
    $#$dataset_types = $#$files  unless defined $dataset_types;

    my @data_viewers = ();
    my $training;

    # TODO: if we are loading a project ('data' and 'test')
    # and at least one of the files fails to load, do not
    # setup any viewers. we need either all or none.
    for (my $idx=0; $idx <= $#$files; $idx++) {
        my $dv = $self->setup_data_viewer($files->[$idx],
                                          $dataset_types->[$idx]);
        if ($dv) {
            push @data_viewers, $dv;
            if ($dv->dataset->is_training) {
                $training = $dv->dataset;
            }
        }
    }

    # each test dataset must be linked to corresponding training dataset
    if ( $training ) {
        foreach my $dv (@data_viewers) {
            if ( $dv->dataset->is_testing ) {
                $dv->dataset->set_training($training);
            }
        }
    }

    return scalar @data_viewers;
}

=pod

=head3 C<setup_data_viewer>

    $main->setup_data_viewer( $file, $dataset_purpose );

Setup a new tab / buffer and open C<$file>, then update the GUI.
dataset_purpose is either 'training' or 'testing'

=cut

# TODO:
#Recycle current buffer if there's only one empty tab currently opened.
#If C<$file> is already opened, focus on the tab displaying it.
#Finally, if C<$file> does not exist, create an empty file before opening it.

sub setup_data_viewer {
    my ($self, $file, $dataset_purpose) = @_;
    my $dataset_viewer;

    my $dataset = try {
        # load exemplars from file
        my %args = (
            path   => $file,
            # TODO: set format from GUI control or from file extension?
            format => 'commas'
        );
        return AMGui::DataSet->new(%args);
    } catch {
        my $msg = "Error in file $file:\n\n" . $_;
        $self->error($msg);
        return undef;
    };

    if (defined $dataset) {
        if (defined $dataset_purpose) {
            $dataset->set_purpose($dataset_purpose);
        }
        # GUI component for showing exemplars
        $dataset_viewer = AMGui::Wx::DatasetViewer->new($self, $dataset);
    }

    return $dataset_viewer;
}

######################################################################
# VALIDATORS
# that check something and show an error message

sub is_valid_dataset {
    my ($self, $dataset, $msg) = @_;
    $msg = MSG_TRAINING_NOT_FOUND unless defined $msg;
    my $status = TRUE;
    if (defined $dataset && defined $dataset->data) {
        # ok
    } else {
        $status = FALSE;
        $self->error($msg);
    }
    return $status;
}

sub is_report_selected {
    my $self = shift;
    my $msg = "No report has been selected. Please go to Reports menu and select one or more reports";
    my $report_requested = grep {$_ eq TRUE} values %{$self->reports};
    $self->error($msg) unless $report_requested;
    return $report_requested;
}

######################################################################

sub update_aui {
    my $self = shift;
    #return if $self->locked('refresh_aui');
    $self->aui->Update;
    return;
}

######################################################################

sub inform {
    my ($self, $msg) = @_;
    Wx::MessageBox(_T($msg), "Informing that", Wx::wxOK);
    return 1;
}

sub error {
    my ($self, $msg) = @_;
    Wx::MessageBox(_T($msg), "Error", Wx::wxOK|Wx::wxICON_ERROR);
    return 1;
}

1;
