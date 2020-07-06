package Tasklicious::Models {
  use Mojo::Base -base, -signatures;

  use Mojo::SQLite;
  use Tasklicious::Model::User;

  has 'dsn';

  sub connect($self) {
    Mojo::SQLite->new->from_filename($self->dsn);
  }

  sub register($self) {
    return {
      database_client => sub {
        state $database_client = $self->connect;
      },
      users => sub ($app) {
        state $user_model
          = Tasklicious::Model::User->new(client => $app->database_client);
      }
    };
  }
}

1;
