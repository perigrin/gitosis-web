package Gitosis::Web::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Cwd;

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

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash->{gitosis}  = $c->model('GitosisConfig');
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

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
    my $view = $c->config->{name} . "::View::Template";
    $c->forward($view)
        unless ($c->response->body);
}

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
