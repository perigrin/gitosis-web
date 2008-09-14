package Gitosis::Config::Script::GitosisConfig;
use Moose;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Gitosis::Config;
with qw(MooseX::Getopt);

has _gitosis => (
    reader     => 'gitosis',
    isa        => 'Gitosis::Config',
    is         => 'ro',
    lazy_build => 1,
);

sub _build__gitosis {
    Gitosis::Config->new_from_file( $_[0]->config_base );
}

has config_base => (
    isa => 'Str',
    is  => 'ro',
);

has groups => (
    isa     => 'ArrayRef',
    is      => 'ro',
    trigger => sub { shift->_group_trigger(@_) },
);

sub _group_trigger {
    for my $name ( @$_[1] ) {
        $_[0]->gitosis->add_group($name);
    }
}

has repo => (
    isa     => 'ArrayRef',
    is      => 'ro',
    trigger => sub { shift->_repo_trigger(@_) },
);

sub _repo_trigger {
    for my $name ( @$_[1] ) {
        $_[0]->gitosis->add_repo($name);
    }
}

print __PACKAGE__->new_with_options->gitosis_config->to_string;

no Moose;
1;
__END__
