package Tasklicious::Authentication;

use Mojo::ByteStream;
use Tasklicious::Model;

sub load_user {
    my ($class, $app, $uid) = @_;

    my $schema = Tasklicious::Model->init_db;
    return $schema->resultset('User')->find($uid);
}

sub validate_user {
    my ($class, $app, $username, $password, $extas) = @_;

    my $schema = Tasklicious::Model->init_db;
    my $user_rs = $schema->resultset('User');

    my $bs = Mojo::ByteStream->new($password);

    my $user = $user_rs->find( 
        { email => $username, password => $bs->sha1_sum }
    );

    # user found
    return $user->id || undef if $user;
}

1;
