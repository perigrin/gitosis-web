package Gitosis::Config;
use Moose;
use Gitosis::Config::Reader;
use Gitosis::Config::Writer;

has config => (
    isa        => 'HashRef',
    is         => 'ro',
    lazy_build => 1
);

sub _build_config {
    { gitosis => {}, };
}

#
# METHODS
#

sub new_from_file {
    confess "$_[1] doesn't exist" unless -e $_[1];
    return ( blessed $_[0] || $_[0] )
      ->new( config => Gitosis::Config::Reader->read_file( $_[1] ) );
}

sub add_group {
    my ( $self, $name, $data ) = @_;
    $self->config->{"group $name"} ||= ( $data || {} );
}

sub add_repo {
    my ( $self, $name, $data ) = @_;
    $self->config->{"repo $name"} ||= ( $data || {} );
}

sub to_string {
    Gitosis::Config::Writer->write_string( $_[0]->config );
}

no Moose;
1;
__END__
