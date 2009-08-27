package Gitosis::Web::Controller::Root;
use Moose;
use Cwd qw(getcwd);
BEGIN { extends 'Catalyst::Controller::REST' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(
    default => 'text/html',
    map     => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => undef
    },
    namespace => '',
);


sub index :Path(/) {}

sub repo : Path('/repo') {
    my ( $self, $c, $name ) = @_;
    $c->stash->{repo_path} = getcwd . "/projects/$name/.git";
    $c->stash->{name}      = $name;
}

sub end : ActionClass('Serialize') {
}

1;
