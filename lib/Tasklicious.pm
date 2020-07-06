package Tasklicious {
  use Mojo::Base 'Mojolicious', -signatures;

  use Mojo::SQLite;

  sub startup ($self) {
    my $config = $self->plugin('Config');

    $self->secrets($config->{secrets});

    $self->helper(
      database_client => sub($app) {
        state $database_client
          = Mojo::SQLite->new->from_filename($app->config('database'));
      }
    );

    $self->helper(
      users => sub($app) {
        state $user_model
          = Tasklicious::Model::User->new(client => $app->database_client);
      }
    );

    my $routes = $self->routes;
    $routes->get('/')->to('home#index')->name('root_path');
  }
}

1;
