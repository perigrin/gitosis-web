package Gitosis::Web;
our $VERSION = '0.01';
use Moose;
use Catalyst::Runtime '5.70';
use Sys::Hostname ();

use Catalyst qw(
  -Debug
  ConfigLoader
  Static::Simple

  Authentication
  Session
  Session::Store::FastMmap
  Session::State::Cookie

  Unicode
  I18N
  Browser
);

has widgets => (
    isa        => 'Gitosis::Web::Widgets',
    lazy_build => 1,
    handles    => [
        qw(
          add_widget
          widgets
          widget_js
          )
    ],
);

sub _build_widgets {
    require Gitosis::Web::Widgets;
    return Gitosis::Web::Widgets->new( app => $_[0] );
}

# Configure the application.
#
# Note that settings in gitosis_web.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

my $login = $ENV{USER};
my ($sys_hostname) = Sys::Hostname::hostname() =~ m/^([^\.]+)/;

__PACKAGE__->config(
    name                   => 'Gitosis::Web',
    'Plugin::ConfigLoader' => {
        file => __PACKAGE__->path_to('conf'),
        config_local_suffix =>
          join( '_', grep { defined } ( $login, $sys_hostname ) ),
    },
    static                   => { dirs => [qw( static )] },
    session                  => {},
    'Plugin::Authentication' => {
        default => {
            credential => {
                class          => 'Password',
                password_field => 'password',
                password_type  => 'clear'
            },
            store => {
                class => 'Minimal',
                users => {
                    guest => {
                        password => "password",
                    },
                }
            }
        }
      }

);

__PACKAGE__->setup;

1;
__END__

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

