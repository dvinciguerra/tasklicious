package Tasklicious::Controller::Home;
use Mojo::Base 'Tasklicious::Controller::Base';

sub index {
    my $self = shift;

    # goto login page
    return $self->redirect_to('/login')
      unless $self->is_user_authenticated;

    # database resultsets
    my $schema     = $self->schema;
    my $user_rs    = $schema->resultset('User');
    my $task_rs    = $schema->resultset('Task');
    my $project_rs = $schema->resultset('Project');

    # getting lists
    my $list =
      $task_rs->search( {}, { order_by => { -desc => 'id' }, rows => 5 } );
    my $user_list = $user_rs->search;
    my $project_list = $project_rs->search;

    # statistics
    my $total_count      = $task_rs->count;
    my $todo_count       = $task_rs->count( { closed => undef } );
    my $done_count       = ( $total_count - $todo_count );
    my $unassigned_count = $task_rs->count( { assigned => 0 } );
    my $noproject_count  = $task_rs->count( { project_id => { '!=' => 0 } } );

    # sending to view
    return $self->render(
        list             => $list,
        user_list        => $user_list,
        project_list     => $project_list,
        total_count      => $total_count,
        done_count       => $done_count,
        todo_count       => $todo_count,
        unassigned_count => $unassigned_count,
        noproject_count  => $noproject_count
    );
}

1;
