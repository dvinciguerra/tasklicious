package Tasklicious::Controller::Account;
use Mojo::Base 'Tasklicious::Controller::Base';

use DateTime;
use Mojo::ByteStream;


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


        if ($name && $email && $password){

            # password to hash
            my $bs = Mojo::ByteStream->new( $password );
            $password = $bs->sha1_sum;

            # user found
            my $user_rs = $self->schema->resultset('User');
            my $user = $user_rs->find({ email => $email });

            # error: user found
            if($user){
                return $self->render(
                    message => {
                        type => 'warning',
                        text => ' This e-mail is already an account!'
                    }
                );
            }

            $user    = eval {
                $user_rs->create(
                    {
                        name     => $name,
                        email    => $email,
                        password => $password,
                        created  => DateTime->now( time_zone => 'local' )
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
        else {
            # required fields
            return $self->render(
                message => {
                    type => 'danger',
                    text => 'All fields are required!'
                }
            );
        }
    }

    return $self->render( message => 0 );
}

sub forgot {
    my $self = shift;

    if ( $self->is_post ) {

        # form params
        my $email    = $self->param('email')    || undef;

        # user found
        my $user_rs = $self->schema->resultset('User');
        my $user    = eval {
            $user_rs->find({ email => $email });
        };

        # debug
        $self->app->log->debug($@);


        # error
        if ( $user && $user->in_storage ) {

            # generate token
            my $bs = Mojo::ByteStream
                ->new($user->email . DateTime->now);
            

            # seting user token
            $user->update({ token => $bs->sha1_sum });

            # TODO send here an email to user with
            #   change-password form link

            # success
            return $self->stash(
                message => {
                    type => 'success',
                    text => 'The e-email has been sent!'
                }
            );
        }

        # not found
        return $self->render(
            message => {
                type => 'danger',
                text => 'E-mail address is not found!'
            }
        );
    }

    return $self->render( message => 0 );
}


sub change {
    my $self = shift;

    my $token = $self->param('token') || 0;

    # user found
    my $user_rs = $self->schema->resultset('User');
    my $user    = eval {
        $user_rs->find({ token => $token });
    };

    # not found
    unless ($user) {
        return $self->render(
            message => {
                type => 'danger',
                text => 'Token is invalid or expired!'
            }
        );
    }

    if ( $self->is_post ) {

        # form params
        my $password    = $self->param('password')    || undef;
        my $confirm    = $self->param('confirm')    || undef;

        # user found
        if($user && ($password eq $confirm)){
            
            my $bs = Mojo::ByteStream->new($password);

            # seting user token
            $user->update({ password => $bs->sha1_sum });


            # success
            return $self->stash(
                message => {
                    type => 'success',
                    text => 'Account password has been changed!'
                }
            );
        }
    }

    return $self->render( message => 0 );
}



1;
