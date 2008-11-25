package Gitosis::Web::Controller::Account;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Data::Dumper;
use DateTime;
use DateTime::TimeZone;

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Gitosis::Web::Controller::Account in Account.');
}

sub signup : Global {
    my ($self, $c) = @_;
    $c->stash->{timezones} = [
        DateTime::TimeZone->all_names
    ];
    if ($c->req->method eq 'POST') {
        if (length($c->req->param('password')) < 5
                or length($c->req->param('confirm_password')) < 5) {
            $c->stash->{message} = $c->localize('Please select a password containing 5 letters or more');
            return;
        }
    }

    warn "signup\n";
    $c->add_widget({
        id    => 'Signup',
        class => 'Page_Account_Signup',
    });
}

sub openid : Global : Args(1) {
    my ($self, $c, $type) = @_;
    $type ||= $c->req->param('type');
    warn "openid ($type)\n";
    if ($c->authenticate({}, "openid")) {
        warn "We're authenticated\n";
        #$c->flash( message => "You signed in with OpenID!" );
        $c->res->redirect( $c->uri_for('/') );
    }
    $c->add_widget({
        id    => 'OpenID',
        class => 'Page_Account_OpenID',
    });
}

sub login : Global {
    my ($self, $c) = @_;
    warn "Login\n";
    my $username = $c->req->param('username') || "";
    my $password = $c->req->param('password') || "";
    if ($username and $password and $c->authenticate({ username => $username, password => $password }, "account")) {
        warn "We're authenticated\n";
        #$c->flash( message => "You signed in with OpenID!" );
        $c->res->redirect( $c->uri_for('/') );
    }
    $c->add_widget({
        id    => 'Login',
        class => 'Page_Account_Login',
    });
}

sub forgot_password : Local {
    my ($self, $c) = @_;
    warn "Forgot Password\n";
}

1;
