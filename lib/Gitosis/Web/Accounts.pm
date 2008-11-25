package Gitosis::Web::Account;
use Moose;
use Moose::Util::TypeConstraints;

has [qw( email password firstname lastname timezone )] => (
    isa => 'Str',
    is  => 'rw',
);

no Moose;
1;
__END__
