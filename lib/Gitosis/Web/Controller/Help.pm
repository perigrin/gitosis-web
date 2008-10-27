package Gitosis::Web::Controller::Help;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Gitosis::Web::Controller::Help - Catalyst Controller

=head1 DESCRIPTION

Controller dispatcher to serve help pages.  C<root/help/*.html> are automatically served
based on the URI arguments.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
}


=head2 default 

Default dispatch handler that serves static HTML help documents.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = join("/", @{ $c->req->args }) . ".html";
}


=head1 AUTHOR

Michael Nachbaur,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
