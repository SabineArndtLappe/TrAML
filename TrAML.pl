#!/usr/bin/perl
#
# @File AMGui.pl
# @Author Kai Koch, Mikalai Krot
#
package main;
use strict;
use warnings;

use Wx::Perl::Packager;
use Wx;
use lib './lib/';
use AMGui;

#unless(caller){
    my $app = AMGui->new;
    $app->MainLoop;
#}