package Gitosis::Web::Model::Git;
use base 'Catalyst::Model::Factory';
__PACKAGE__->config(
    class       => 'Git::Wrapper',
);

sub prepare_arguments {
    my ( $self, $c ) = @_;
    return ( $c->stash->{repo_path} );
}

1;
__END__
