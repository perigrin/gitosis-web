package Gitosis::Web::Engine;
use Moose;
use Gitosis::Config;
use Git::Wrapper;

has directory => ( isa => 'Str', is => 'ro', required => 1 );

has config => (
    isa        => 'Gitosis::Config',
    is         => 'ro',
    lazy_build => 1,
    handles    => [qw(groups find_group_by_name)],
);

sub _build_config {
    my ($self) = @_;
    Gitosis::Config->new( file => $self->directory . '/gitosis.conf' );
}

has repo => (
    isa        => 'Git::Wrapper',
    is         => 'ro',
    lazy_build => 1,
    handles    => { pull => 'update_repo', },
);

sub _build_repo {
    my ($self) = @_;
    my $repo = Git::Wrapper->new( Directory => $self->directory );
    $repo->pull;
    return $repo;
}

sub add_group {
    my ( $self, $data ) = @_;

    my $cfg = $self->config;
    if ( my $group = $cfg->find_group_by_name( $data->{'group.name'} ) ) {
        return $group;
    }

    my $group = { name => $data->{'name'}, };
    $group->{writable} = $data->{'writable'} if $data->{'writable'};
    $group->{members}  = $data->{'members'}  if $data->{'members'};
    $cfg->add_group($group);

    $cfg->save;
    return $cfg->find_group_by_name( $data->{'name'} );
}

sub update_group {
    my ( $self, $name, $data ) = @_;

    my $cfg   = $self->config;
    my $group = $cfg->find_group_by_name($name);

    $group->name( $data->{'group.name'} ) if exists $$data{'group.name'};
    $group->writable( $$data{'group.writable'} )
      if exists $$data{'group.writable'};
    $group->members( $data->{'group.members'} )
      if exists $$data{'group.members'};

    $cfg->save;
    return $group;
}

sub save_repo {
    my ( $self, $message ) = @_;
    my $repo = $self->repo;
    $self->config->save;
    $repo->commit( { all => 1, message => "Gitosis Web: $message" } );
    $repo->push;
}

no Moose;
1;
__END__
