package Tasklicious::Authentication;

use Tasklicious::Model;

sub load_user {
    my ($class, $app, $uid) = @_;

    my $model = Tasklicious::Model->load('User');
    return $model->find( where => [id => $uid], single => 1);
}

sub validate_user {
    my ($class, $app, $username, $password, $extas) = @_;

    my $model = Tasklicious::Model->load('User');
    my $user = $model->find( 
        where => [ email=>$username, password=>$password], single => 1
    );

    # user found
    return $user->column('id') || undef if $user;

    return;
}

1;
