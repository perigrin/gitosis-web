package Gitosis::Web;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

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

our $VERSION = '0.01';

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

# Start the application
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
