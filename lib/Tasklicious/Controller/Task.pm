package Tasklicious::Controller::Task;
use base 'Tasklicious::Controller::Base';

use Tasklicious::API;

sub index {
    my $self = shift;

    my $id = $self->param('id') || undef;

    # load task api
    my $task_api = Tasklicious::API->load('Task');

    unless($id){
        # end-point: GET /api/v1/task -> return all
        return $task_api->get_list($self) 
            if $self->req->method eq 'GET';

        return $task_api->create($self) 
            if $self->req->method eq 'POST';
    }

    # end-point: GET /api/v1/task/:id -> return all
    return $task_api->get_load($self) 
        if $self->req->method eq 'GET';

    # end-point: DELETE /api/v1/task/:id -> return all
    return $task_api->delete($self) 
        if $self->req->method eq 'DELETE';
}

sub list {
    my $self = shift;

    # load task api
    my $task_api = Tasklicious::API->load('Task');

    # end-point: GET /api/v1/task -> return all
    return $task_api->get_list($self) 
        if $self->req->method eq 'GET';
}
    
sub create {    
    my $self = shift;

    # load task api
    my $task_api = Tasklicious::API->load('Task');

    unless($task_api){
        $self->render( status => 500, text=>'cannot load api' );
    }

    # end-point: POST /api/v1/task -> create new
    return $task_api->create($self) 
        if($self->req->method eq 'POST');
}

sub edit {
    my $self = shift;

    # load task api
    my $task_api = Tasklicious::API->load('Task');
    
    # end-point: POST /api/v1/task/:id -> edit
    return $task_api->edit($self) 
        if $self->is_post
}

sub delete {
    my $self = shift;

    # load task api
    my $task_api = Tasklicious::API->load('Task');
    
    # end-point: DELETE /api/v1/task/:id -> delete one
    return $task_api->delete($self)
        if $self->req->method eq 'DELETE';
}


1;
