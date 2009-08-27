package Gitosis::Web::Model::Gitosis;
use base 'Catalyst::Model::Factory::PerRequest';
__PACKAGE__->config( class => 'Gitosis::Web::Engine' );

1;
__END__