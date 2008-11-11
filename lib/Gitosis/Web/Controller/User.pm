package Gitosis::Web::Controller::User;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub users : Path('/users') : ActionClass('REST') {
}

sub users_GET {
    my ( $self, $c, $name ) = @_;
    my $key = $c->model('SSHKeys')->slurp("$name.pub");
    warn $key;
    #$c->stash->{member} = {
    #    name => defined $key ? $name : undef,
    #    key => $key,
    #};
}

sub users_POST {
    my ( $self, $c, $name ) = @_;

    if ( defined $name ) {
        $self->member_PUT( $c, $name )
          if grep { $_ eq $name } $c->model('SSHKeys')->list;
    }

    if ( my $data = $c->request->params() ) {
        my $key = $data->{'member.key'} or die "Missing Key";
        my $name = $name || $data->{'member.name'} or die "Missing Name";
        $c->model('SSHKeys')->splat( "$name.pub", $key );
        $c->res->redirect( $c->uri_for( '/member', $name ) );
        return;
    }

    die 'Missing Request Data';    # Throw the correct error here
}

sub users_PUT {
    my ( $self, $c, $name ) = @_;
    die 'PUT requires name' unless $name;

    if ( my $data = $c->request->params() ) {
        my $key = $data->{'member.key'};
        $c->model('SSHKeys')->splat( "$name.pub", $key );
        $c->res->redirect( $c->uri_for( '/member', $name ) );
    }

    die 'Missing Request Data';    # Throw the correct error here
}

1;
