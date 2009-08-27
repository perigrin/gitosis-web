package Gitosis::Web::View::TT;
use Moose;
use Gitosis::Web;

BEGIN { extends 'Catalyst::View::TT' }

__PACKAGE__->config(
    {
        CATALYST_VAR       => 'c',
        INCLUDE_PATH       => [ Gitosis::Web->path_to('root' src) ],
        PRE_PROCESS        => 'lib/config/main',
        WRAPPER            => 'lib/site/wrapper',
        ERROR              => 'error.tt2',
        TIMER              => 0,
        TEMPLATE_EXTENSION => '.tt2',
    }
);

1;

