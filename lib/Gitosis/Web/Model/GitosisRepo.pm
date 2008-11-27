package Gitosis::Web::Model::GitosisRepo;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
    class       => 'Git::Wrapper',
);

sub mangle_arguments {
    my ( $self, $args ) = @_;
    return $args->{root_dir};
}

1;
__END__
