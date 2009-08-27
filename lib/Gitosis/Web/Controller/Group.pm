package Gitosis::Web::Controller::Group;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Gitosis::Web::Controller::Group - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub group : Path('/group') : ActionClass('REST') {
}

sub group_GET {
    my ( $self, $c, $name ) = @_;
    $c->stash->{group}    = $c->model('Gitosis')->find_group_by_name($name);
    $c->stash->{template} = 'group.tt2';
}

sub group_POST {
    my ( $self, $c, $name ) = @_;

    # we're updating, POST should have been sent as PUT
    return $self->group_PUT( $c, $name )
      if ( defined $name && $c->model('Gitosis')->find_group_by_name($name) );

    if ( my $data = $c->request->params() ) {
        $name ||= $data->{'group.name'};

        my $group = $c->model('Gitosis')->add_group( $name => $data );

        return $self->save_repo_and_redirect(
            $c => $c->uri_for( '/group', $group->name ) );
    }
    die 'Missing Request Data';    # Throw the correct error here
}

sub group_PUT {
    my ( $self, $c, $name ) = @_;
    if ( my $data = $c->request->params() ) {
        my $group = $c->model('Gitosis')->update_group( $name => $data );
        return $self->save_repo_and_redirect(
            $c => $c->uri_for( '/group', $group->name ) );
    }
    die 'Missing Request Data';    # Throw the correct error here
}

sub group_DELETE {

}

#
# Helper Methods
#

sub save_repo_and_redirect {
    my ( $self, $c, $url ) = @_;
    $c->model('Gitosis')->save_repo();
    return $c->res->redirect($url);
}

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
