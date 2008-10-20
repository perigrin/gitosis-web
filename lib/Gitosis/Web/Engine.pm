package Gitosis::Web::Engine;
use Moose;

has app => (
    isa     => 'Gitosis::Web',
    is      => 'ro',
    handles => [qw(model)],
);

sub find_group_by_name {
    shift->model('GitosisConfig')->find_group_by_name(@_);
}

sub add_group {
    my ( $self, $data ) = @_;

    my $cfg = $self->model('GitosisConfig');
    if ( my $group = $cfg->find_group_by_name( $data->{'group.name'} ) ) {
        warn 'Group exists';
        return $group;
    }

    $cfg->add_group(
        {
            name     => $data->{'group.name'},
            writable => $data->{'group.writable'},
            members  => $data->{'group.members'},
        }
    );

    $cfg->save;
    return $cfg->find_group_by_name( $data->{'group.name'} );
}

sub update_group {
    my ( $self, $name, $data ) = @_;

    my $cfg   = $self->model('GitosisConfig');
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
    my ($self) = @_;
    my $repo = $self->model('GitosisRepo');
    $repo->commit( all => 1, message => 'update from gitweb' );
    $repo->push();
}

no Moose;
1;
__END__
