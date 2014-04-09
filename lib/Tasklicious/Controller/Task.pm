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

    my $id = $self->param('id') || 0;
    
    # id not defined
    return $self->render( 
        template => 'error',
        title => 'Error trying edit task',
        message => 'Task ID cannot be undefined!'
    ) unless $id;

    if($self->is_post){
        my $title = $self->param('title') || undef;
        my $description = $self->param('description') || undef;
        
        my $task_rs = $self->schema('Task');
        my $task = $task_rs->find($id);

        # not found
        return $self->render( 
            template => 'error',
            title => 'Task register error',
            message => 'Task not found when you try to edit id!'
        ) unless $task;

        $task->update({
            title => $title,
            description => $description
        });
        
        # success (goto task list)
        return $self->redirect_to('/task/list');
    }

    # TODO open task to edit form

}    

sub load {
    my $self = shift;
    my $id = $self->param('id') || 0;

    my $data;
    my $task = $self->schema('Task')->find($id);
    $data = $task->{_column_data} if $task;
    $data->{assigned_to} = eval{ $task->assigned_to->name } if $data;
    $data->{project} = eval{ $task->project->name } if $data;
    $data->{date} = $task->date? $task->date->dmy('/') : '';

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
