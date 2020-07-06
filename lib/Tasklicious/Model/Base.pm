package Tasklicious::Model::Base {
  use Mojo::Base -base -signatures;

  has 'client';

  sub find($self) { }

  sub create($self) { }

  sub update($self) { }

  sub delete($self) { }
}

1;
