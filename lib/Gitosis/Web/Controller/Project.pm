package Gitosis::Web::Controller::Project;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

Gitosis::Web::Controller::Project - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    warn "project -> index";
}


=head2 new 

=cut

sub create : Local {
    my ( $self, $c ) = @_;
    warn "project -> create";
    $c->add_widget({
        id    => 'wProjectCreate',
        class => 'Page_Project_Create',
        args  => {
            ssh_keys => [
                grep { /\.pub$/ } map { "$_" } $c->model('SSHKeys')->list
            ],
        },
    });
    if ($c->request->method eq 'POST') {
        my $data = $c->request->params();
        use Data::Dumper;
        warn Dumper($data);
        $c->stash->{data} = $data;
        my $name = $data->{'group.name'};
        if (!$name) {
            $c->stash->{message} = $c->localize('You need to supply a project name');
            return;
        } elsif ($c->find_group_by_name($name)) {
            $c->stash->{message} = $c->localize('Project [_1] already exists', $name);
            return;
        }
        my $group = $c->add_group($data);
        if ($group) {
            $c->response->redirect($c->uri_for("/project/name", $group->name));
            return;
        }
    }
}


=head2 project_home 

  /project/*

Dispatches the specified project's home page.

=cut

sub project_home : PathPart('project') Chained('/') Args(1) {
    my ( $self, $c, $name ) = @_;
    #my $name = $c->req->captures->[0];
    warn "project -> project_home ($name)";
    $c->stash->{project} = $c->find_group_by_name($name);
    $c->stash->{navbar}{classes}{project} = "selected";
    warn "Project: " . $c->stash->{project};
}

=head2 project 

  /project/*

Dispatches the specified project's home page.

=cut

sub project : PathPart('project') Chained('/') CaptureArgs(1) {
    my ( $self, $c, $name ) = @_;
    warn "project -> ($name)";
    $c->stash->{project} = $c->find_group_by_name($name);
}

=head2 history

  /project/*/history

Dispatches the specified project's history of changes

=cut

sub history : PathPart('history') Chained('project') Args(0) {
    my ( $self, $c ) = @_;
    warn "project -> history";
    $c->stash->{navbar}{classes}{history} = "selected";
}



=head2 users_list

  /project/*/users

Dispatches the specified project's list of users

=cut

sub user_list : PathPart('users') Chained('project') Args(0) {
    my ( $self, $c, $name ) = @_;
    warn "project -> users";
    $c->stash->{navbar}{classes}{users} = "selected";
    if ($c->req->method eq 'POST') {
        $self->user_POST($c);
    }
}


=head2 user

  /project/*/users/*

Dispatches the specified user within the current project

=cut

sub user : PathPart('users') Chained('project') Args(1) ActionClass('REST') {
    my ( $self, $c, $name ) = @_;
    $c->stash->{navbar}{classes}{users} = "selected";
    warn "project -> user ($name)";
}

sub user_GET {
    my ( $self, $c, $name ) = @_;
    warn "GET user ($name)";
    my $key = $c->model('SSHKeys')->slurp("$name.pub");
    warn $key;
    $c->stash->{member} = {
        name => defined $key ? $name : undef,
        key => $key,
    };
}

sub user_POST {
    my ( $self, $c, $name ) = @_;
    warn "POST user ($name)";
    if (defined $name and grep { $_ eq $name } $c->model('SSHKeys')->list) {
        $self->user_PUT($c, $name);
    }

    if (my $data = $c->request->params()) {
        my $key = $data->{'member.key'} or die "Missing Key";
        my $name = $name || $data->{'member.name'} or die "Missing Name";
        $c->model('SSHKeys')->splat( "$name.pub", $key );
        $c->res->redirect($c->req->uri);
    } else {
        die 'Missing Request Data';    # Throw the correct error here
    }
}

sub user_PUT {
    my ( $self, $c, $name ) = @_;
    die 'PUT requires name' unless $name;

    if (my $data = $c->request->params()) {
        my $key = $data->{'member.key'};
        $c->model('SSHKeys')->splat( "$name.pub", $key );
        $c->res->redirect($c->req->uri);
    } else {
        die 'Missing Request Data';    # Throw the correct error here
    }
}

1;
