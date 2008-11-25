package Gitosis::Web::Model::UserAuth;
use Moose;
use Moose::Util::TypeConstraints;
extends 'Catalyst::Model';

use NEXT;
use Carp;
use YAML;

subtype 'Gitosis::Web::Model::UserAuth::List' => as 'ArrayRef';

has 'users' => (
    metaclass  => 'Collection::Hash',
    isa        => 'HashRef[HashRef]',
    is         => 'ro',
    auto_deref => 1,
    lazy_build => 1,
    provides   => {
        'set'    => 'add_user',
        'get'    => 'get_user',
        'empty'  => 'has_user',
        'count'  => 'num_users',
        'delete' => 'delete_user',
    },
);

sub BUILD {
    my ( $self, $args ) = @_;

    if ( exists $args->{config} ) {
        $self->users( Load( $self->{config} ) );
    }
}

has [qw( file )] => (
    isa => 'Str',
    is  => 'rw',
);

sub to_string {
    my ($self) = @_;
    return Dump( $self->users );
}

sub save {
    my ($self) = @_;
    die 'Must have a filename, please set file()' unless $self->file;
    $self->file->openw->print( $self->to_string ) or die "$!";
}

sub auth {
    my ( $self, $c, $userinfo ) = @_;

    my $where =
        exists $userinfo->{user_id}  ? { user_id  => $userinfo->{user_id} }
      : exists $userinfo->{username} ? { username => $userinfo->{username} }
      :                                return;

    my $key = $userinfo->{user_id} || $userinfo->{username};

    if ( my $val = $c->cache->get($key) ) {
        return $val;
    }

    my $user = $c->model('TestApp')->resultset('User')->search($where)->first;
    $user = $user->{_column_data};
    $c->cache->set( $key, $user );
    return $user;
}

no Moose;
1;
__END__
