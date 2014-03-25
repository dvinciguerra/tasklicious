package Tasklicious::Email;
use Mojo::Base -base;

# attributes
has 'from';
has 'to';
has 'type';
has 'subject';
has 'body';

has '_service' => sub  { 'dafault' };


# methods
sub send {}

1;
