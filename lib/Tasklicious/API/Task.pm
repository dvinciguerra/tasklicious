package Tasklicious::API::Task;
use Mojo::Base 'Tasklicious::API::Base';

use DateTime;
use Mojo::JSON;
use Tasklicious::Model;

sub get_list {
    my ( $self, $app ) = @_;

    my $schema = Tasklicious::Model->init_db;
    my $rs     = $schema->resultset('Task');
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    my $list;
    push @$list, $_ for $rs->all;

    # return all
    # TODO specific user only
    return $app->render( json => $list );
}

sub get_load {
    my ( $self, $app ) = @_;

    # param
    my $id = $app->param('id') || 0;

    my $schema = Tasklicious::Model->init_db;
    my $rs     = $schema->resultset('Task');
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    # try load model by id
    # specific user only
    my $model = $rs->find($id);

    # model found
    if ($model) {
        return $app->render( json => $model ); 
    }
}

sub edit {
    my $self = shift;
}

sub create {
    my ($self, $app) = @_;

    # param
    my $title       = $app->param('title')       || undef;
    my $description = $app->param('description') || undef;
    my $created     = DateTime->now;

    use Data::Dumper;
    #return $app->render( text => Dumper( $app->param ) );

    my $schema = Tasklicious::Model->init_db;
    my $rs     = $schema->resultset('Task');

    # try load model by id
    # TODO specific user only
    my $model = eval {
        $rs->create(
            {
                title       => $title,
                description => $description,
                created     => $created,
            }
        );
    };

    if($@){
        return $app->render( status => 500, text => $@ );
    }

    # model found
    if ( $model && $model->in_storage ) {
        return $app->render( json => $model->id );
    }
    else {
        return $app->render(
            status => 500,
            text   => 'Error creating task'
        );
    }
}

sub delete {
    my ($self, $app) = @_;

    # param
    my $id       = $app->param('id')       || 0;

    my $schema = Tasklicious::Model->init_db;
    my $rs     = $schema->resultset('Task');

    # try load model by id
    # TODO specific user only
    my $model = $rs->delete({ id => $id });
    
    # model found
    if ( $model ) {
        return $app->render( json => 1 );
    }
    else {
        return $app->render(
            status => 500,
            text   => 'Error creating task'
        );
    }
}

1;
