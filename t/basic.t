use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'Qaptcha';

get '/inline' => sub {
  my $self = shift;
  $self->render(inline => 'Hello Qaptcha! <%= qaptcha_include %>');
};
get '/default' => sub {
  my $self = shift;
  $self->render('default');
};


my $t = Test::Mojo->new;
$t->get_ok('/inline')->status_is(200)
  ->content_like(qr'Hello Qaptcha!')
  ->content_like(qr'script');

$t->get_ok('/default')->status_is(200)
  ->content_like(qr'Hello Qaptcha!')
  ->content_like(qr'script');


done_testing();

__END__
__DATA__

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
<head>
%= qaptcha_include
</head>
<body>
%= content
</body>
</html>

@@ default.html.ep
%= layout 'default'
'Hello Qaptcha!'
