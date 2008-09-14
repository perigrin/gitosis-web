package Gitosis::Config::Writer;
use Moose;
extends qw(Config::INI::Writer);

sub validate_input {
  my ($self, $input) = @_;

  my %seen;
  for (my $i = 0; $i < $#$input; $i += 2) {
    my ($name, $props) = @$input[ $i, $i + 1 ];
    $seen{ $name } ||= {};

    Carp::croak "illegal section name '$name'"
      if $name =~ /(?:\n|\s;|^\s|\s$)/;

    for (my $j = 0; $j < $#$props; $j += 2) {
      my $property = $props->[ $j ];
      my $value    = $props->[ $j + 1 ];

      Carp::croak "property name '$property' contains illegal character"
        if $property =~ /(?:\n|\s;|^\s|=$)/;

      Carp::croak "value for $name.$property contains illegal character"
        if defined $value and $value =~ /(?:\n|\s;|^\s|\s$)/;

      if ( $seen{ $name }{ $property }++ ) {
        Carp::croak "multiple assignments found for $name.$property";
      }
    }
  }
}

no Moose;
1;
