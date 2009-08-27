package Gitosis::Web::Model::SSHKeys;
use Moose;
BEGIN { extends 'Catalyst::Model::File' }

__PACKAGE__->config();

1;
__END__

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
