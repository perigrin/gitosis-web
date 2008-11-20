package Gitosis::Web::Model::GitosisRepo;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
    class       => 'Git',
    constructor => 'repository',
);

sub mangle_arguments {
    my ( $self, $args ) = @_;
    return %$args;    # now the args are a plain list
}

1;
__END__
