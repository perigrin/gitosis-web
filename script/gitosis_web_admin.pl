#!/usr/bin/env perl -l

use strict;
use warnings;
use lib qw(/usr/share/perl5);
use FindBin;
use FCGI::Engine::Manager;

my $cmd = shift @ARGV;
die 'Must supply command!' unless $cmd;

my $conf = "$FindBin::Bin/../conf/fcgi_engine.yml";
print FCGI::Engine::Manager->new( conf => $conf )->$cmd;
