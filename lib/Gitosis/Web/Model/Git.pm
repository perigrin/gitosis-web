package Gitosis::Web::Model::Git;
use base 'Catalyst::Model::Factory::PerRequest';
__PACKAGE__->config(
    class       => 'Git',
    constructor => 'repository',
);

sub prepare_arguments {
    my ( $self, $c ) = @_;
    return ( Repository => $c->stash->{repo_path} );
}

1;
__END__
