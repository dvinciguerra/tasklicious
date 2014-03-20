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
}

1;
