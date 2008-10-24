package Gitosis::Web::Controller::Project;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Gitosis::Web::Controller::Project - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    warn "project -> index";
}


=head2 project_home 

=cut

sub project : Chained : CapturedArgs(1) {
    my ( $self, $c ) = @_;
    my $name = $c->req->captures->[0];
    warn "project -> project_home ($name)";
    $c->stash->{project} = $c->find_group_by_name($name);
    warn "Project: " . $c->stash->{project};
}

#sub users : LocalRegex('([^/]+)/users') {
#    my ( $self, $c ) = @_;
#    warn "project -> users";
#    #my $name = $c->req->captures->[0];
#    #$c->stash->{project} = $c->find_group_by_name($name);
#    warn "Project (users): " . $c->stash->{project};
#}


=head1 AUTHOR

Michael Nachbaur,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
