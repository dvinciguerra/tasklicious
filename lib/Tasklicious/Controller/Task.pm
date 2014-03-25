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


sub delete {
    my $self = shift;
}


1;
