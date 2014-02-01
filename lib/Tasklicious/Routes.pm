package Tasklicious::Routes;
use Mojo::Base -strict;

sub load {
    my ( $class, $route ) = @_;

    # error
    die "error with route instance!\n"
      unless $route && $route->isa('Mojolicious::Routes');

    # custom routes
    my $custom = {
        # route for /profile
        '/profile' => 
            {controller=>'Home', action=>'profile', authenticated=>1},

        # route for /user/edit/0
        '/:controller/:action/:id' => 
            {controller=>'Home', action=>'index', id=>0},


        #add custom route here
    };

    # add routes
    $route->any($_)->over(authenticated => $custom->{$_}->{authenticated} || 0)->to( $custom->{$_} )
        for keys %$custom;

    return $route;
}

1;

__END__
=pod 

=head1 NAME

Tasklicious::Routes - Route container for MyAPP app


=head1 DESCRIPTION

This class is a simple container where you will add all your custom routes 
used at your MyAPP app.


=head2 Methods


=head3 load(L<Mojolicious::Routes> instance)

    package Tasklicious::Routes;

    # config custom routes to Mojolicious::Routes
    my $r = $self->routes;
    Tasklicious::Routes->load($r);


=head1 AUTHOR

2013 (c) Bivee

L<http://bivee.com.br>

=head1 COPYRIGHT AND LICENSE

2013 (c) Bivee

This is a free software; you can redistribute it and/or modify it under the same terms 
as a Perl 5 programming language system itself.

=cut
