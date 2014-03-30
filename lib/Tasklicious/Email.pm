package Tasklicious::Email;
use Mojo::Base -base;

# attributes


# methods
sub get_service {
    my ($self, $service) = (shift, shift);

    unless($service){
        require Tasklicious::Email::Gmail;
        return Tasklicious::Email::Gmail->new(@_);
    }
}

1;
