package Tasklicious::Controller::Task;
use base 'Tasklicious::Controller::Base';


sub index {
    my $self = shift;
}

sub list {
    my $self = shift;

    # load task api
    my $schema = $self->schema;
    my $list = $schema->resultset('Task')
        ->search({ });
    
    $self->stash( list => $list );
}
    
sub create {    
    my $self = shift;
}

sub edit {
    my $self = shift;
}    

sub load {
    my $self = shift;
    my $id = $self->param('id') || 0;

    my $data;
    my $task = $self->schema('Task')->find($id);
    $data = $task->{_column_data} if $task;
    $data->{assigned_to} = eval{ $task->assigned_to->name } if $data;
    $data->{project} = eval{ $task->project->name } if $data;

    return $self->render( json => $data );
}

sub delete {
    my $self = shift;

    my $id = $self->param('id') || 0;

    my $task = $self->schema('Task')->find($id);
    $task->delete if $task;

    # TODO getting request page reference and redirect
    return $self->redirect_to('/task/list');
}


1;
