package Gitosis::Web::View::TT;
use Moose;
BEGIN { extends 'Catalyst::View::TT' }

__PACKAGE__->config(
    {
        CATALYST_VAR => 'c',
        INCLUDE_PATH => [
            Gitosis::Web->path_to( 'root', 'src' ),
            Gitosis::Web->path_to( 'root', 'lib' )
        ],
        PRE_PROCESS        => 'config/main',
        WRAPPER            => 'site/wrapper',
        ERROR              => 'error.tt2',
        TIMER              => 0,
        PLUGIN_BASE        => ['Gitosis::Web::Template::Plugin'],
        TEMPLATE_EXTENSION => '.tt2',
    }
);

1;
