package Gitosis::Web::View::Template;

use strict;
use base 'Catalyst::View::TT::Alloy';
use Gitosis::Web;

__PACKAGE__->config(
    {
        CATALYST_VAR => 'c',
        INCLUDE_PATH => [
            Gitosis::Web->path_to( 'root' ),
        ],
        PRE_PROCESS  => 'lib/config/main',
        WRAPPER      => 'lib/site/wrapper',        
        ERROR => 'error.tt2',
        TIMER => 0,
        TEMPLATE_EXTENSION => '.html',
    }
);

1;

