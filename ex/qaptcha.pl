#!/usr/bin/env perl
use Mojo::Base -strict;

use Mojolicious::Lite;
use lib 'lib';

plugin 'Qaptcha';

get '/inline' => sub {
  my $self = shift;
  $self->render(inline => 'Hello Qaptcha! <%= qaptcha_include %>');
};
any '/index' => sub {
  my $self = shift;
  $self->render();
};

app->start();

__DATA__

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
<head>
%= qaptcha_include
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

