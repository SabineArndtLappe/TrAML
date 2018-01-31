package AMGui::Constant;

use base qw( Exporter );

#BEGIN { $Exporter::Verbose = 1 }

use strict;
use warnings;

#our @ISA = qw(Exporter);

our @EXPORT = qw(
    wxID_RUN_BATCH wxID_RUN_NEXT
    wxID_RUN_LINEAR wxID_RUN_INCLUDE_NULLS wxID_RUN_INCLUDE_GIVEN
    wxID_REPORT_PREDICTION wxID_REPORT_ANALOGICAL_SET wxID_REPORT_GANGS
    wxID_OPEN_PROJECT
    wxID_NEXT_TAB wxID_PREV_TAB
    FALSE TRUE
    MSG_TRAINING_NOT_FOUND
);

# in Run menu
use constant wxID_RUN_BATCH         => 1010;
use constant wxID_RUN_NEXT          => 1011;
use constant wxID_RUN_LINEAR        => 1012;
use constant wxID_RUN_INCLUDE_NULLS => 1013;
use constant wxID_RUN_INCLUDE_GIVEN => 1014;

# in File menu
use constant wxID_OPEN_PROJECT => 1020;

# in Window menu
use constant wxID_NEXT_TAB => 1030;
use constant wxID_PREV_TAB => 1031;

# in Report menu
use constant wxID_REPORT_PREDICTION     => 1041;
use constant wxID_REPORT_ANALOGICAL_SET => 1042;
use constant wxID_REPORT_GANGS          => 1043;

use constant WIN32 => !!( ( $^O eq 'MSWin32' ) or ( $^O eq 'cygwin' ) );

use constant FALSE => 0;
use constant TRUE  => 1;

# I know this is a bad idea
use constant MSG_TRAINING_NOT_FOUND =>
    "Could not find associated Training dataset.\nPerhaps you have closed the tab?";

1;
