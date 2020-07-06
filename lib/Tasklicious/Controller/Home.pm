package Tasklicious::Controller::Home {
  use Mojo::Base 'Mojolicious::Controller', -signatures;

  sub index($self) {
    $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
  }
}

1;
