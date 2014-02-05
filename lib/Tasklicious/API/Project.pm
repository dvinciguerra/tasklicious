package Tasklicious::API::Project;
use Mojo::Base 'Tasklicious::API::Base';

use Mojo::JSON;
use Tasklicious::Model;

sub get_list {
    my $self = shift;
}

sub get_load {
    my ($self, $app) = @_;

    # param
    my $id = $app->param('id') || 0;

    my $schema = Tasklicious::Model->init_db;
    my $rs = $schema->resultset('Project');
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    # try load model by id
    my $model = $rs->find($id);

    # model found
    if($model && $model->in_storage){
        return $app->render( json => $model );
    }
} 

sub edit {
    my $self = shift;
}

sub create {
    my $self = shift;
}

sub delete {
    my $self = shift;
}


1;
