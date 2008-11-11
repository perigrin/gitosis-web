package Gitosis::Web::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Cwd;

__PACKAGE__->config(
    'namespace' => '',
    'default'   => 'text/x-json',
    'stash_key' => 'rest',
    'map'       => {
        'text/html'          => [ 'View', 'Template', ],
        'text/x-yaml'        => 'YAML',
        'text/x-json'        => 'JSON',
        'text/x-data-dumper' => [ 'Data::Serializer', 'Data::Dumper' ],
    },
);

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash->{gitosis}  = $c->model('GitosisConfig');
    $c->stash->{browser} = $c->request->browser;
}

sub index : Private {
    my ( $self, $c ) = @_;

    warn "Index?";
}

sub repo : Path('/repo') {
    my ( $self, $c, $name ) = @_;
    $c->stash->{repo_path} = getcwd . "/projects/$name/.git";
    $c->stash->{repo}      = $c->model('Git');
    $c->stash->{name}      = $name;
}

sub login : Global {
    my ( $self, $c ) = @_;
    if ( $c->authenticate() ) {
        $c->flash( message => "You signed in with OpenID!" );
        $c->res->redirect( $c->uri_for('/') );
    }
}

sub end : ActionClass('Serialize') {}

1;
