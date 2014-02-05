package Tasklicious::API;

use Mojo::Loader;

sub load {
    my ($self, $api_class) = @_;

    my $module = "Tasklicious::API::${api_class}";
    my $loader = Mojo::Loader->new;
    
    # try load
    if( my $e = $loader->load($module) ){
        die "API loader: $e";
    }

    # getting instance
    my $obj = $module->new;

    return $obj 
        if $obj && $obj->isa('Tasklicious::API::Base');
}

1;
