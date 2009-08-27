package Gitosis::Web::View::JSON;
use Moose;
BEGIN { extends 'Catalyst::View::JSON' }

__PACKAGE__->config(
    {
        allow_callback => 1,
        callback_param => 'callback',
        expose_stash   => [qw( stash )],
    }
);

1;
__END__
