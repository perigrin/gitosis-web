package Gitosis::Web::Model::Config;
use base 'Catalyst::Model::Factory::PerRequest';
__PACKAGE__->config( class => 'Gitosis::Config' );
