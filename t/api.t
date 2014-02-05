use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
use lib "$FindBin::Bin/../lib";

my $t = Test::Mojo->new('Tasklicious');
#$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

$t->post_ok('/api/task' => form => {title => 'Foo', description => 'Bar'})
  ->status_is(200);

$t->delete_ok('/api/task/1')
  ->status_is(200);

done_testing();
