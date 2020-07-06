package Tasklicious::Routes {
  use Mojo::Base -base, -signatures;

  has 'routes';

  sub register($self) {
    my $routes = $self->routes;

    $routes->get('/')->to('home#index')->name('root_path');

    return $routes;
  }
}

1;
