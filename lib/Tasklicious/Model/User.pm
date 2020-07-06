package Tasklicious::Model::User {
  use Mojo::Base 'Tasklicious::Model::Base' -signatures;

  sub all ($self) {
    $self->client->db->select('users')->hashes->to_array;
  }

  sub find ($self, $id) {
    $self->client->db->select('users', undef, {id => $id})->hash;
  }

  sub create ($self, $params) {
    $self->client->db->insert('users', $params)->last_insert_id;
  }

  sub update ($self, $id, $params) {
    $self->client->db->update('users', $params, {id => $id});
  }

  sub remove ($self, $id) {
    $self->client->db->delete('users', {id => $id});
  }
}

1;
