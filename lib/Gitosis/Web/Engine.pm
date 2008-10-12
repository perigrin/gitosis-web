package Gitosis::Web::Engine;
use Moose;

has app => (
    isa     => 'Gitosis::Web',
    is      => 'ro',
    handles => [qw(model)],
);

sub add_group {
    my ( $self, $name, $data ) = @_;
    my $cfg = $self->model('GitosisConfig');
    if ( my $group = $cfg->find_group_by_name($name) ) {
        warn 'Group exists';
        return $group;
    }

    $cfg->add_group( { name => $name } );
    $cfg->save;
    return $cfg->lookup_group_by_name($name);
}

sub update_group {
    my ( $self, $name, $data ) = @_;

    my $cfg   = $self->model('GitosisConfig');
    my $group = $cfg->find_group_by_name($name);

    $group->name( $data->{'group.name'} )     if exists $$data{'group.name'};
    $group->writable( $$data{'group.repos'} ) if exists $$data{'group.repos'};
    $group->members( $data->{'group.members'} )
      if exists $$data{'group.members'};

    $cfg->save;
    return $group;
}

sub save_repo {
    my ($self) = @_;
    my $repo = $self->model('GitosisRepo');
    $repo->command( 'commit', '-am', 'update from gitweb' );
    $repo->command('push');
}

no Moose;
1;
__END__
