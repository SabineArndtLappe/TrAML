#!/usr/bin/perl
use strict;
use warnings;
use lib './lib/';
use Wx::Perl::Packager;
use Wx;

package AMGui;
use base 'Wx::App';

use AMGui::Wx::Main;

our $VERSION = '0.2';
our @ISA = 'Wx::App';

sub OnInit {
    my( $self ) = @_;
    Wx::InitAllImageHandlers();
    my $main = AMGui::Wx::Main->new();
    $self->SetTopWindow($main);
    $main->Show(1);
    return 1;
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

AMGui - Perl extension for the CLI of the Perl implementation of Analogical Modeling

=head1 SYNOPSIS

  use AMGui;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for AMGui, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Mikalai Krot, E<lt>talpus@gmail.com<gt>
Kai Koch, E<lt>kai.koch@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Nikolai Krot

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.22.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
