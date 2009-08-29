package Gitosis::Web::Controller::Root;
use Moose;
BEGIN { extends 'Reaction::UI::Controller::Root' }

use aliased 'Reaction::UI::ViewPort';
use aliased 'Reaction::UI::ViewPort::SiteLayout';

use namespace::autoclean;

__PACKAGE__->config(
    view_name    => 'Site',
    window_title => 'MyApp Window',
    namespace    => '',
);

sub base : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;
    $self->push_viewport( SiteLayout,
        title           => 'MyApp Test Title',
        static_base_uri => join( '', $ctx->uri_for('/static') ),
        meta_info =>
          { http_header => { 'Content-Type' => 'text/html;charset=utf-8', }, },
    );
}

sub root : Chained('base') PathPart('') Args(0) {
    my ( $self, $ctx ) = @_;
    $self->push_viewport( ViewPort, layout => 'root' );
}

1;
__END__
