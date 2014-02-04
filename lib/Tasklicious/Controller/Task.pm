package Tasklicious::Controller::Task;
use Mojo::Base 'Tasklicious::Controller::Base';

use Tasklicious::API;

sub index {
    my $self = shift;

    # load task api
    my $task_api = Tasklicious::API->load('Task');

    # end-point: GET /api/v1/task/:id -> return one
    return $task->get_load($self)
        if $self->req->method eq 'GET' && $self->param('id');
    
    # end-point: GET /api/v1/task -> return all
    return $task->get_list($self)
        if $self->req->method eq 'GET';

    # end-point: POST /api/v1/task/:id -> edit
    return $task->edit($self)
        if $self->req->method eq 'POST' && $self->param('id');

    # end-point: POST /api/v1/task -> create new
    return $task->create($self)
        if $self->req->method eq 'POST';

    # end-point: DELETE /api/v1/task/:id -> delete one
    return $task->delete($self)
        if $self->req->method eq 'DELETE';

    render $self->render( text => 'nothing to do' );
}

1;
