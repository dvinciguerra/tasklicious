package Tasklicious::Controller::Account;
use Mojo::Base 'Tasklicious::Controller::Base';

use DateTime;

sub login {
    my $self = shift;

    if ( $self->is_post ) {

        # form params
        my $email    = $self->param('email')    || undef;
        my $password = $self->param('password') || undef;

        # user found
        if ( $self->authenticate( $email, $password ) ) {
            return $self->redirect_to('/profile');
        }

        # error
        return $self->render(
            message => { type => 'danger', text => 'email or password wrong!' }
        );
    }

    return $self->render( message => 0 );
}

sub register {
    my $self = shift;

    if ( $self->is_post ) {

        # form params
        my $name     = $self->param('name')     || undef;
        my $email    = $self->param('email')    || undef;
        my $password = $self->param('password') || undef;

        # user found
        my $user_rs = $self->schema->resultset('User');
        my $user    = eval {
            $user_rs->create(
                {
                    name     => $name,
                    email    => $email,
                    password => $password,
                    created  => DateTime->now
                }
            );
        };

        # debug
        $self->app->log->debug($@);

        # error
        unless ( $user && $user->in_storage ) {
            return $self->render(
                message => {
                    type => 'danger',
                    text => 'Error saving your registration data!'
                }
            );
        }

        # success
        return $self->stash(
            message => {
                type => 'success',
                text => 'User account been created with success!'
            }
        );
    }

    return $self->render( message => 0 );
}

1;
