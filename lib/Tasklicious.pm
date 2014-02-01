package Tasklicious;
use Mojo::Base 'Mojolicious';

use Tasklicious::Routes;
use Tasklicious::Authentication;

sub startup {
    my $self = shift;

    # load auth plugin
    $self->plugin('authentication' => {
        'autoload_user' => 1,
        'session_key' => 'my_eureka_portal_bitch',
        'load_user' => sub {
           return Tasklicious::Authentication->load_user(@_);
        },
        'validate_user' => sub {
           return Tasklicious::Authentication->validate_user(@_);
        },
    });

    # Router
    my $r = $self->routes;
    $r->namespaces( ['Tasklicious::Controller'] );

    # default route to controller
    $r->get('/')->to('Home#index');

    Tasklicious::Routes->load($r);
}

1;