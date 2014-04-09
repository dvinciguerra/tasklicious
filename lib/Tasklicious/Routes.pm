package Tasklicious::Routes;
use Mojo::Base -strict;

sub load {
    my ( $class, $route ) = @_;

    # error
    die "error with route instance!\n"
      unless $route && $route->isa('Mojolicious::Routes');

        
    # routes for authentication
    $route->any('/login')->to( controller => 'Account', action => 'login' );
    $route->any('/logout')->to( controller => 'Account', action => 'logout' );
    $route->any('/register')->to( controller => 'Account', action => 'register' );
    $route->any('/forgot')->to( controller => 'Account', action => 'register' );
    $route->any('/change/:token')
        ->to(controller => 'Account', action => 'change', token => 0 );

    # route to dashboard
    $route->any('/user/profile/:id')->over( authenticated => 1 )
        ->to( controller => 'Home', action => 'profile', id => 0 );
    
    # routes to task actions
    $route->get('/task/list')->over( authenticated => 1 )
        ->to( controller => 'Task', action => 'list', );
    $route->get('/task/load/:id')->over( authenticated => 1 )
        ->to( controller => 'Task', action => 'load', id => 0 );
    $route->any('/task/edit/:id')->over( authenticated => 1 )
        ->to( controller => 'Task', action => 'edit', id => 0 );

    #add custom route here
    
    return $route;
}

1;

__END__
=pod 

=head1 NAME

Tasklicious::Routes - Route container for Tasklicious


=head1 DESCRIPTION

This class is a simple container where you will add all your custom routes 
used at your Tasklicious.


=head2 Methods


=head3 load(L<Mojolicious::Routes> instance)

    package Tasklicious::Routes;

    # config custom routes to Mojolicious::Routes
    my $r = $self->routes;
    Tasklicious::Routes->load($r);


=head1 AUTHOR

2013-2014 (c) Bivee

L<http://bivee.com.br>

=head1 COPYRIGHT AND LICENSE

2013-2014 (c) Bivee

This is a free software; you can redistribute it and/or modify it under the same terms 
as a Perl 5 programming language system itself.

=cut
