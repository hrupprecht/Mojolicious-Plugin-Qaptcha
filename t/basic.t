use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'Qaptcha';

get '/inline' => sub {
  my $self = shift;
  $self->render(inline => 'Hello Qaptcha! <%= qaptcha_include %>');
};
get '/index' => sub {
  my $self = shift;
  $self->render();
};


my $t = Test::Mojo->new;
$t->get_ok('/inline')->status_is(200)
  ->content_like(qr'Hello Qaptcha!')
  ->content_like(qr'script');

$t->get_ok('/index')->status_is(200)
  ->content_like(qr'Hello Qaptcha!')
  ->content_like(qr'script')
  ->content_like(qr'QapTcha - jQuery Plugin')
  ->content_like(qr'QapTcha CSS');

$t->get_ok('/images/bg_draggable_qaptcha.jpg')->status_is(200)
  ->content_type_is('image/jpeg');

done_testing();

__DATA__

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
<head>
%= qaptcha_include;
</head>
<body>
%= content;
</body>
</html>

@@ index.html.ep
%= layout 'default';
'Hello Qaptcha!'
<div class="phpresponse">No SESSION.. Form can not be submitted...</div>
<form method="post" action="">
  <fieldset>
    <label>First Name</label> <input name="firstname" type="text"><br>
    <label>Last Name</label> <input name="lastname" type="text">
    <div class="QapTcha"></div>
    <input name="submit" value="Submit form" style="margin-top:15px;" type="submit">
  </fieldset>
</form>

