package Gitosis::Web::Engine;
use Moose;
use MooseX::AttributeHelpers;
use JSON::XS;

has app => (
    isa     => 'Gitosis::Web',
    is      => 'ro',
    handles => [qw(model)],
);

has widgets => (
    metaclass  => 'Collection::Array',
    isa        => 'ArrayRef[HashRef]',
    is         => 'ro',
    auto_deref => 1,
    lazy_build => 1,
    provides   => { push => 'add_widget', }
);
sub _build_widgets { [] }

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
    $repo->command( 'commit', '-am', 'update from gitweb' );
    $repo->command('push');
}

sub widget_js {
    my ($self) = @_;
    my $js = '';
    foreach my $widget (@{ $self->widgets }) {
        $js .= sprintf(q{Widgets['%s'] = new %s($('%s'), %s);},
            $widget->{id},
            $widget->{class},
            $widget->{id},
            encode_json $widget->{args},
        );
    }
    $js = "var Widgets = {}; window.addEvent('domready', function() { $js });";
    warn "JS Init: $js\n";
    return $js;
}

no Moose;
1;
__END__
