package Tasklicious::Model;
use Mojo::Base -strict;

sub load {
    my $class = shift;
    my %param = @_ if @_ % 2 == 0;

    my $ns = 'Tasklicious::Model';
    my $model = $param{model} || $_[0];

    if($model){
        # build require
        my $module_load = $ns;
        $module_load =~ s/::/\//g;

        require "${module_load}/${model}.pm";
        my $instance = "${ns}::${model}"->new;
        
        return $instance 
            if $instance && $instance->isa('Tasklicious::Model::Base');

        return undef;
    }
}

sub exists {
    die "Method unimplemented!";
}

1;

__END__
=pod 

=head1 NAME

Tasklicious::Model - Model factory for MyAPP app


=head1 SINOPSYS

    use Tasklicious::Model;

    # getting new instance of User model if exists
    my $user_model = Tasklicious::Model->load('User');


=head1 DESCRIPTION

This class is a simple factory that load and instanciate for provide a simple
way to get new instances of L<MyAPP> model classes.

This class is auto configured to find model classes under L<Tasklicious::Model>
namespace.


=head2 Methods


=head3 load(C<$scalar>)

This method get a class name, find under namespace and (if exists) return an
instance of class if it is a son class of Tasklicious::Model::Base

    package Tasklicious::Model::User;
    use base 'Tasklicious::Model::Base';

    # use here your favorite ORM our handle manually
    ...

And now you can load User class doing:

    use Tasklicious::Model;

    # get Tasklicious::Model::User class instance
    my $user_model = Tasklicious::Model->load('User');


=head3 exists(C<$scalar>)

This method returns if class exists based on required inplementation.

    my $user_model;

    # load user model if exists
    $user_model = Tasklicious::Model->load('User') 
        if Tasklicious::Model->exists('User');


=head1 AUTHOR

Daniel Vinciguerra <daniel.vinciguerra@bivee.com.br>


=head1 COPYRIGHT AND LICENSE

2013 (c) Bivee

This is a free software; you can redistribute it and/or modify it under the same terms 
as a Perl 5 programming language system itself.

=cut
