package Gitosis::Web;
our $VERSION = '0.01';
use Moose;
use Catalyst::Runtime '5.70';

use Catalyst qw(
  -Debug
  ConfigLoader
  Static::Simple

  Authentication
  Session
  Session::Store::FastMmap
  Session::State::Cookie

  Unicode
);

has gitweb_engine => (
    isa        => 'Gitosis::Web::Engine',
    is         => 'ro',
    lazy_build => 1,
    handles    => [
        qw(
          add_group
          update_group
          find_group_by_name
          save_repo
          )
    ],
);

sub _build_gitweb_engine {
    require Gitosis::Web::Engine;
    return Gitosis::Web::Engine->new( app => $_[0] );
}

# Configure the application.
#
# Note that settings in gitosis_web.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name    => 'Gitosis::Web',
    static  => { dirs => [qw(static/html static/css static/images static/js)] },
    session => {},

    authentication => {
        default_realm => 'openid',
        realms        => {
            openid => {
                ua_args =>
                  { whitelisted_hosts => [qw/ 127.0.0.1 localhost /], },
                credential => {
                    class => "OpenID",
                    store => { class => "OpenID", },
                },
            },

        },
    },

);

__PACKAGE__->setup;

=head1 NAME

Gitosis::Web - Catalyst based application

=head1 SYNOPSIS

    script/gitosis_web_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Gitosis::Web::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Chris Prather

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
