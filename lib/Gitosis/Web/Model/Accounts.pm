{

    package Gitosis::Web::Account;
    use Moose;
    use Moose::Util::TypeConstraints;

    has [qw( email password firstname lastname timezone )] => (
        isa => 'Str',
        is  => 'rw',
    );

}

{

    package Gitosis::Web::Model::UserAuth;
    use Moose;
    BEGIN { extends 'Catalyst::Model' }

    use Moose::Util::TypeConstraints;
    use MooseX::AttributeHelpers;
    use MooseX::Types::Path::Class qw(File);

    use YAML ();

    has file => (
        isa        => File,
        is         => 'rw',
        coerce     => 1,
        lazy_build => 1,
    );

    sub _build_file { 'users.conf' }

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

    sub _build_users {
        YAML::Load( $_[0]->file->slurp ) or die "$!";
    }

    sub to_string {
        YAML::Dump( $_[0]->users ) or die "$!";
    }

    sub save {
        my ($self) = @_;
        $self->file->openw->print( $self->to_string ) or die "$!";
    }

    no Moose;
}

1;
__END__
