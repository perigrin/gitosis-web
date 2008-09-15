package Gitosis::Web::Model::SSHKeys;

use strict;
use base 'Catalyst::Model::File';

__PACKAGE__->config(
    root_dir => '/Users/perigrin/dev/gitosis-admin/keydir',
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
