package Gitosis::Web::Model::GitosisConfig;
use base 'Catalyst::Model::Factory::PerRequest';
__PACKAGE__->config( class => 'Gitosis::Config' );
