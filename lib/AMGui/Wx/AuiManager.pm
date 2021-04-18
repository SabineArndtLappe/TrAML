package AMGui::Wx::AuiManager;

use strict;
use warnings;

our $VERSION = '1.00';

use Class::Adapter::Builder
    ISA      => 'Wx::AuiManager',
    AUTOLOAD => 1;

sub new {
    my $class  = shift;
    my $object = Wx::AuiManager->new;
    my $self   = $class->SUPER::new($object);

    # Locale caption gettext values
    $self->{caption} = {};

    # Set the managed window
    $self->SetManagedWindow( $_[0] );

#    # Set/fix the flags
#    # Do NOT use hints other than Rectangle on Linux/GTK
#    # or the app will crash.
#    my $flags = $self->GetFlags;
#    $flags &= ~Wx::AUI_MGR_TRANSPARENT_HINT;
#    $flags &= ~Wx::AUI_MGR_VENETIAN_BLINDS_HINT;
#    $self->SetFlags( $flags ^ Wx::AUI_MGR_RECTANGLE_HINT );

    return $self;
}

sub caption {
    my $self = shift;
    $self->{caption}->{ $_[0] } = $_[1];
    $self->GetPane( $_[0] )->Caption( $_[1] );
    return 1;
}

1;
