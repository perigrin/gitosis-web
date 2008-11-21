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
            map { $_ =~ /(.*)\.pub$/ } $c->model('SSHKeys')->list
        ],
    };
}


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
}


=head2 new 

=cut

sub create : Local {
    my ( $self, $c ) = @_;
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
    $c->stash->{project} = $c->find_group_by_name($name);
    $c->stash->{navbar}{classes}{project} = "selected";
    $c->add_widget({
        id    => 'RepoList',
        class => 'Page_Project_Repo',
        args  => {
            %{ $self->{widget_args} },
        },
    });
}

=head2 project 

  /project/*

Dispatches the specified project's home page.

=cut

sub project : PathPart('project') Chained('/') CaptureArgs(1) {
    my ( $self, $c, $name ) = @_;
    $c->stash->{project} = $c->find_group_by_name($name);
}

=head2 history

  /project/*/history

Dispatches the specified project's history of changes

=cut

sub history : PathPart('history') Chained('project') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{navbar}{classes}{history} = "selected";
}



=head2 users_list

  /project/*/users

Dispatches the specified project's list of users

=cut

sub user_list : PathPart('users') Chained('project') Args(0) {
    my ( $self, $c, $name ) = @_;
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
}

sub user_GET {
    my ( $self, $c, $name ) = @_;
    my $key = $c->model('SSHKeys')->slurp("$name.pub");
    warn $key;
    $c->stash->{user} = {
        name => defined $key ? $name : undef,
        key => $key,
    };
}

sub user_POST {
    my ( $self, $c, $name ) = @_;
    my $group = $c->stash->{project};
    my $data = $c->request->params();
    if (defined $name and grep { $_ =~ /$name\.pub$/ } $c->model('SSHKeys')->list) {
        if ($data->{action} eq 'remove') {
            return $self->user_DELETE($c, $name);
        } else {
            return $self->user_PUT($c, $name);
        }
    }

    if ($data) {
        if ($data->{existingname}) {
            push @{ $group->members }, $data->{existingname} . ".pub";
        } else {
            my $key = $data->{'key'};
            unless ($key) {
                $c->stash->{message} = $c->localize('You need to supply an SSH key');
                return;
            }
            my $name = $name || $data->{'name'};
            unless ($name =~ /^[\w\-_\.\@]+$/) {
                $c->stash->{message} = $c->localize('Key name is required, and cannot contain whitespaces');
                return;
            }

            $c->model('SSHKeys')->splat( "$name.pub", $key );
            push @{ $group->members }, "$name.pub";
        }
        $c->stash->{gitosis}->save;
        $c->response->redirect($c->uri_for("/project", $group->name, "users"));
    } else {
        die 'Missing Request Data';    # Throw the correct error here
    }
}

sub user_PUT {
    my ( $self, $c, $name ) = @_;
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
    die 'DELETE requires name' unless $name;
    my $group = $c->stash->{project};

    my $filename = "$name.pub";

    # Remove this ssh key from all projects' members lists
    foreach my $project ($c->stash->{gitosis}->groups) {
        my @members = grep { $_ ne $filename } @{ $project->members };
        $project->members( \@members );
    }
    $c->stash->{gitosis}->save;

    $c->response->redirect($c->uri_for("/project", $group->name, "users"));
}


=head2 repos_list

  /project/*/repos

Dispatches the specified project's list of repos

=cut

sub repo_list : PathPart('repos') Chained('project') Args(0) {
    my ( $self, $c, $name ) = @_;
}

sub repo_GET {
    my ( $self, $c, $name ) = @_;
}

1;
