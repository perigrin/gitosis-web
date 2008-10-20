#!/usr/bin/perl -l

use strict;
use warnings;

<<<<<<< HEAD:script/gitosis_web_admin.pl
use lib qw(
  /usr/share/perl5/
);

$ENV{PERL5LIB} = "$ENV{PERL5LIB}:/usr/share/perl5";

=======
>>>>>>> 210021f3d84c0b169d5fbc3117cf9bb7b547de41:script/gitosis_web_admin.pl
use FindBin;
use FCGI::Engine::Manager;

my $cmd = shift @ARGV;
die 'Must supply command!' unless $cmd;

my $conf = "$FindBin::Bin/../conf/fcgi_engine.yml";
print FCGI::Engine::Manager->new( conf => $conf )->$cmd;
