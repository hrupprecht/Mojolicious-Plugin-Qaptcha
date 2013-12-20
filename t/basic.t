use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'Qaptcha';

get '/' => sub {
  my $self = shift;
  $self->render(text => 'Hello Mojo!');
};

my $t = Test::Mojo->new;
$t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');

done_testing();

__END__

@@ layouts/default.html.ep
<html>
<head>

</head>
</html>

@@ default.html.ep
%= layout 'default'
