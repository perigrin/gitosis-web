package Gitosis::Web::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Gitosis::Web::Controller::Root - Root Controller for Gitosis::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{gitosis}  = $c->model('Config');
    $c->stash->{template} = 'index.tt2';
}

sub repo : Path('/repo') {
    my ( $self, $c, $name ) = @_;
    $c->stash->{name}     = $name;
    $c->stash->{template} = 'repo.tt2';
}

sub member : Path('/member') : ActionClass('REST') {

}

sub member_GET {
    my ( $self, $c, $name ) = @_;
    $c->stash->{name}     = $name;
    $c->stash->{key}      = $c->model('SSHKeys')->slurp("$name.pub");
    $c->stash->{template} = 'member.tt2';
}

sub member_POST {
    my ( $self, $c, $name ) = @_;
    if ( my $key = $c->request->param('member.key') ) {
        $c->model('SSHKeys')->splat( "$name.pub", $key );
    }
    $c->res->redirect( $c->uri_for( '/member', $name ) );
}

sub openid : Path('/login') {
    my ( $self, $c ) = @_;
    if ( $c->authenticate() ) {
        $c->flash( message => "You signed in with OpenID!" );
        $c->res->redirect( $c->uri_for('/') );
    }
    else {
        $c->stash->{template} = 'login.tt2';
    }
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {
}

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
