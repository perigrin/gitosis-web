package Gitosis::Web::Model::SSHKeys;

use strict;
use base 'Catalyst::Model::File';
use Cwd;

__PACKAGE__->config(
    root_dir => getcwd . '/projects/gitosis-admin/keydir',
);

=head1 NAME

Gitosis::Web::Model::SSHKeys - Catalyst File Model

=head1 SYNOPSIS

See L<Gitosis::Web>

=head1 DESCRIPTION

L<Catalyst::Model::File> Model storing files under
L<>

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
