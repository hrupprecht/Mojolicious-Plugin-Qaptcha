#!/usr/bin/env perl
use Mojo::Base -strict;

use Mojolicious::Lite;
use lib 'lib';

plugin 'Qaptcha';

get '/inline' => sub {
  my $self = shift;
  $self->render(inline => 'Hello Qaptcha! <%= qaptcha_include %>');
};
any '/' => sub {
  my $self = shift;
  $self->stash(
    form_processing => sprintf("form data %s processed",
      $self->session('qaptcha_key') ? '' : 'not')
  );
  $self->render('index');
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
<span>
<div>
%= c.session('qaptcha_key');
</div>
<div>
%= $form_processing;
</div>
</span>
<form method="post" action="">
  <fieldset>
    <label>First Name</label> <input name="firstname" type="text"><br>
    <label>Last Name</label> <input name="lastname" type="text">
    <input name="submit" value="Submit form" style="margin-top:15px;" type="submit">
    <br />
    <div class="QapTcha"></div>
  </fieldset>
</form>

