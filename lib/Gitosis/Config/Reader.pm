package Gitosis::Config::Reader;
use Moose;
extends qw(Config::INI::Reader);

sub can_ignore {
  my ($self, $line) = @_;

  # Skip comments and empty lines
  return $line =~ /\A\s*(?:;|$|#)/ ? 1 : 0;
}


no Moose;
1;
