package Tasklicious {
  use Mojo::Base 'Mojolicious', -signatures;

  use Tasklicious::Routes;
  use Tasklicious::Models;

  sub startup ($self) {
    my $config = $self->plugin('Config');

    $self->secrets($config->{secrets});

    # models register
    my $models = Tasklicious::Models->new(dsn => $self->config('database'));
    $self->helper($models->register);

    # routes register
    my $routes = Tasklicious::Routes->new(routes => $self->routes);
    $routes->register;
  }
}

1;
