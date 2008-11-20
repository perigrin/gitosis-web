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


=head2 auto 

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    $self->{widget_args} = {
        ssh_keys => [
            grep { /\.pub$/ } map { "$_" } $c->model('SSHKeys')->list
        ],
    };
}


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
            %{ $self->{widget_args} },
        },
    });
    if ($c->request->method eq 'POST') {
        my $data = $c->request->params();
        $c->stash->{group} = $data;
        my $name = $data->{'name'};
        if (!$name) {
            $c->stash->{message} = $c->localize('You need to supply a project name');
            return;
        } elsif ($c->find_group_by_name($name)) {
            $c->stash->{message} = $c->localize('Project [_1] already exists', $name);
            return;
        }
        my $group = $c->add_group($data);
        if ($group) {
            $c->response->redirect($c->uri_for("/project", $group->name));
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
    $c->add_widget({
        id    => 'UserList',
        class => 'Page_Project_UserList',
        args  => {
            %{ $self->{widget_args} },
        },
    });
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
    $c->stash->{user} = {
        name => defined $key ? $name : undef,
        key => $key,
    };
}

sub user_POST {
    my ( $self, $c, $name ) = @_;
    warn "POST user ($name)";
    use Data::Dumper;
    my $data = $c->request->params();
    warn Dumper($data);
    if (defined $name and grep { $_ =~ /$name\.pub$/ } $c->model('SSHKeys')->list) {
        warn "Foo $$data{action}\n";
        if ($data->{action} eq 'delete') {
            warn "Doing dat delete thang";
            return $self->user_DELETE($c, $name);
        } else {
            warn "Doing dat put thang";
            return $self->user_PUT($c, $name);
        }
    }

    if ($data) {
        warn "POST data: " . Dumper($data);
        if ($data->{existingname}) {
            push @{ $c->stash->{project}->members }, $data->{existingname} . ".pub";
        } else {
            my $key = $data->{'key'};
            unless ($key) {
                $c->stash->{message} = $c->localize('You need to supply an SSH key');
                return;
            }
            my $name = $name || $data->{'name'};
            unless ($name =~ /^[\w\-_\.]+$/) {
                $c->stash->{message} = $c->localize('Key name is required, and cannot contain whitespaces');
                return;
            }

            $c->model('SSHKeys')->splat( "$name.pub", $key );
            push @{ $c->stash->{project}->members }, "$name.pub";
        }
        $c->stash->{gitosis}->save;
        $c->res->redirect("/" . $c->req->path);
    } else {
        die 'Missing Request Data';    # Throw the correct error here
    }
}

sub user_PUT {
    my ( $self, $c, $name ) = @_;
    warn "PUT";
    die 'PUT requires name' unless $name;

    if (my $data = $c->request->params()) {
        my $key = $data->{'key'};
        $c->model('SSHKeys')->splat( "$name.pub", $key );
        $c->res->redirect($c->req->uri);
    } else {
        die 'Missing Request Data';    # Throw the correct error here
    }
}

sub user_DELETE {
    my ( $self, $c, $name ) = @_;
    warn "DELETE";
    die 'DELETE requires name' unless $name;
    my $group = $c->stash->{project};

    my $filename = "$name.pub";
    $c->model('SSHKeys')->file($filename)->remove();

    #foreach my $project (@{ $c->stash->{gitosis} }) {
    #    $project->members->
    #}

    $c->response->redirect($c->uri_for("/project", $group->name));
}

1;
