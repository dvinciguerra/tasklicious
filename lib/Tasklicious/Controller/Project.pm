package Tasklicious::Controller::Project;
use Mojo::Base 'Tasklicious::Controller::Base';

use Tasklicious::API;

sub index {
    my $self = shift;

    # load project api
    my $project_api = Tasklicious::API->load('Project');

    # end-point: GET /api/v1/project/:id -> return one
    return $project_api->get_load($self)
        if $self->req->method eq 'GET' && $self->param('id');
    
    # end-point: GET /api/v1/project -> return all
    return $project_api->get_list($self)
        if $self->req->method eq 'GET';

    # end-point: POST /api/v1/project/:id -> edit
    return $project_api->edit($self)
        if $self->req->method eq 'POST' && $self->param('id');

    # end-point: POST /api/v1/project -> create new
    return $project_api->create($self)
        if $self->req->method eq 'POST';

    # end-point: DELETE /api/v1/project/:id -> delete one
    return $project_api->delete($self)
        if $self->req->method eq 'DELETE';

    render $self->render( text => 'nothing to do' );
}

1;
