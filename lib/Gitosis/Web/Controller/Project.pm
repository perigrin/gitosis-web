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

sub widget_args {
    my ( $self, $c, %args ) = @_;
    return {
        ssh_keys => [ map { $_ =~ /(.*)\.pub$/ } $c->model('SSHKeys')->list ],
        message => $c->stash->{message},
        %args,
    };
}

=head2 index 

=cut

sub index : Path('/project') : ActionClass('REST') {
}

sub index_GET {
    my ( $self, $c ) = @_;
    $c->stash->{gitosis} = $c->model('Gitosis');
}

=head2 new 

=cut

sub create : Path('/project/create') ActionClass('REST') {
}

sub create_POST {
    my ( $self, $c ) = @_;
    my $data = $c->request->params();
    $c->stash->{group} = $data;
    my $name = $data->{'name'};
    if ( !$name ) {
        $c->stash->{message} =
          $c->localize('You need to supply a project name');
    }
    elsif ( $c->model('Gitosis')->find_group_by_name($name) ) {
        $c->stash->{message} =
          $c->localize( 'Project [_1] already exists', $name );
        $name = undef;
    }

    if ($name) {
        my $group = $c->model('Gitosis')->add_group($data);
        if ($group) {
            $c->response->redirect( $c->uri_for( "/project", $group->name ) );
        }
    }

    $c->add_widget(
        {
            id    => 'wProjectCreate',
            class => 'Page_Project_Create',
            args  => $self->widget_args($c),
        }
    );

}

=head2 project_home 

  /project/*

Dispatches the specified project's home page.

=cut

sub project_home : PathPart('project') Chained('/') Args(1) {
    my ( $self, $c, $name ) = @_;
    warn "HERE!";
    $c->stash->{project} = $c->model('Gitosis')->find_group_by_name($name);
    $c->stash->{navbar}{classes}{project} = "selected";
}

=head2 project 

  /project/*

Dispatches the specified project's home page.

=cut

sub project : PathPart('project') Chained('/') CaptureArgs(1) {
    my ( $self, $c, $name ) = @_;
    $c->stash->{project} = $c->model('Gitosis')->find_group_by_name($name);
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
    $c->stash->{navbar}{classes}{users} = "selected";
    if ( $c->req->method eq 'POST' ) {
        $self->user_POST($c);
    }
    $c->add_widget(
        {
            id    => 'UserList',
            class => 'Page_Project_UserList',
            args  => $self->widget_args($c)
        }
    );
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
    my $group          = $c->stash->{project};
    my $data           = $c->request->params();
    my @available_keys = $c->model('SSHKeys')->list;
    if ( defined $name and grep { $_ eq "$name.pub" } @available_keys ) {
        if ( $data->{action} eq 'remove' ) {
            return $self->user_DELETE( $c, $name );
        }
        else {
            return $self->user_PUT( $c, $name );
        }
    }

    if ($data) {
        my $name = $name || $data->{'name'};
        if ( grep { $_ eq "$name.pub" } @available_keys ) {
            push @{ $group->members }, $name . ".pub";
        }
        else {
            my $key = $data->{'key'};
            unless ($key) {
                $c->stash->{message} =
                  $c->localize('You need to supply an SSH key');
                return;
            }
            unless ( $name =~ /^[\w\-_\.\@]+$/ ) {
                $c->stash->{message} = $c->localize(
                    'Key name is required, and cannot contain whitespaces');
                return;
            }

            $c->model('SSHKeys')->splat( "$name.pub", $key );
            push @{ $group->members }, "$name.pub";
        }
        $c->model('Gitosis')->save_repo(
            sprintf(
                q{Added SSH key "%s" to project "%s"},
                $name, $group->name
            )
        );
        $c->response->redirect(
            $c->uri_for( "/project", $group->name, "users" ) );
    }
    else {
        $c->stash->{message} =
          'Missing Request Data';    # Throw the correct error here
        return;
    }
}

sub user_PUT {
    my ( $self, $c, $name ) = @_;
    unless ($name) {
        $c->stash->{message} = 'PUT requires name';
        return;
    }

    if ( my $data = $c->request->params() ) {
        my $key = $data->{'key'};
        $c->model('SSHKeys')->splat( "$name.pub", $key );
        $c->res->redirect( $c->req->uri );
    }
    else {
        $c->stash->{message} =
          'Missing Request Data';    # Throw the correct error here
        return;
    }
}

sub user_DELETE {
    my ( $self, $c, $name ) = @_;
    unless ($name) {
        $c->stash->{message} = 'DELETE requires name';
        return;
    }
    my $group = $c->stash->{project};

    my $filename = "$name.pub";

    # Remove this ssh key from all projects' members lists
    my @members = grep { $_ ne $filename } @{ $group->members };
    $group->members( \@members );
    $c->model('Gitosis')->save_repo(
        sprintf(
            q{Removed SSH key "%s" from project "%s"},
            $name, $group->name
        )
    );

    $c->response->redirect( $c->uri_for( "/project", $group->name, "users" ) );
}

=head2 repos_list

  /project/*/repos

Dispatches the specified project's list of repos

=cut

sub repo_list : PathPart('repos') Chained('project') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{navbar}{classes}{repos} = "selected";
    if ( $c->req->method eq 'POST' ) {
        $self->repo_POST($c);
    }
    $c->add_widget(
        {
            id    => 'RepoList',
            class => 'Page_Project_Repo',
            args  => $self->widget_args($c),
        }
    );
}

=head2 repo

  /project/*/repos/*

Dispatches the specified repo within the current project

=cut

sub repo : PathPart('repos') Chained('project') Args(1) ActionClass('REST') {
    my ( $self, $c, $name ) = @_;
    $c->stash->{navbar}{classes}{repos} = "selected";
    unless ( grep { $_ eq $name } @{ $c->stash->{project}->writable } ) {
        die "No such repo defined";
    }
}

sub repo_GET {
    my ( $self, $c, $name ) = @_;
    $c->stash->{repo} = { name => $name, };
}

sub repo_POST {
    my ( $self, $c, $name ) = @_;
    warn "POST Repo ($name)\n";
    my $group = $c->stash->{project};
    my $data  = $c->request->params();
    use Data::Dumper;
    warn Dumper($data);
    if ( defined $name ) {
        if ( $data->{action} eq 'remove' ) {
            return $self->repo_DELETE( $c, $name );

            #} else {
            #    return $self->repo_PUT($c, $name);
        }
    }

    if ($data) {
        $name ||= $data->{name};
        if ( grep { $_ eq $name } @{ $group->writable } ) {
            $c->stash->{message} =
              $c->localize('A repository by that name already exists');
            return;
        }
        unless ( $name =~ /^[\w\-_\.]+$/ ) {
            $c->stash->{message} = $c->localize(
                'A repository name is required, and cannot contain whitespaces'
            );
            return;
        }
        push @{ $group->writable }, $name;
        warn "Writable is: " . join( ", ", @{ $group->writable } ) . "\n";
        $c->model('Gitosis')->save_repo(
            sprintf(
                q{Added repository "%s" to project "%s"},
                $name, $group->name
            )
        );
        $c->response->redirect(
            $c->uri_for( "/project", $group->name, "repos", $name ) );
    }
}

sub repo_DELETE {
    my ( $self, $c, $name ) = @_;
    my $group = $c->stash->{project};
    my $data  = $c->request->params();

    my @repos = grep { $_ ne $name } @{ $group->writable };
    $group->writable( \@repos );

    $c->model('Gitosis')->save_repo(
        sprintf(
            q{Removed repository "%s" from group "%s"},
            $name, $group->name
        )
    );
    $c->response->redirect( $c->uri_for( "/project", $group->name, "repos" ) );
}

1;
