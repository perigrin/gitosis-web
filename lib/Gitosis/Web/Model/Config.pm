package Gitosis::Web::Model::Config;
use base 'Catalyst::Model::Adaptor';
__PACKAGE__->config( class => 'Gitosis::Config' );
