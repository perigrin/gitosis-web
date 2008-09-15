package Gitosis::Web::View::TT::Alloy;

use strict;
use base 'Catalyst::View::TT::Alloy';

__PACKAGE__->config(
    {
        CATALYST_VAR => 'c',
        INCLUDE_PATH => [
            Gitosis::Web->path_to( 'root', 'src' ),
            Gitosis::Web->path_to( 'root', 'lib' )
        ],
        ERROR => 'error.tt2',
        TIMER => 0
    }
);

1;

