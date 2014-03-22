package Tasklicious::Controller::Home;
use Mojo::Base 'Tasklicious::Controller::Base';

sub index {
    my $self = shift;

    # authenticated
    return $self->redirect_to('/profile')
      if $self->is_user_authenticated;

    # goto login page
    return $self->redirect_to('/account/login');
}

sub profile {
    my $self = shift;

    my $schema = $self->schema;
    my $list = $schema->resultset('Task')
      ->search( {}, { order_by => { -desc => 'id' }, rows => 5 } );

    # statistics
    my $total_count = $schema->resultset('Task')->count;
    my $todo_count = $schema->resultset('Task')->count({ closed => undef });
    my $done_count = ($total_count - $todo_count);
    my $unassigned_count = $schema->resultset('Task')->count({ assigned => 0 });
    my $noproject_count = $schema->resultset('Task')->count({ project_id => { '!=' => 0 } });

    return $self->render( list => $list, total_count => $total_count,
        done_count => $done_count, todo_count => $todo_count,
        unassigned_count => $unassigned_count, noproject_count => $noproject_count
    );
}

1;
