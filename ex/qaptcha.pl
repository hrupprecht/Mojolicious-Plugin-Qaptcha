#!/usr/bin/env perl
use Mojo::Base -strict;

use Mojolicious::Lite;
use lib 'lib';

plugin 'Qaptcha';

get '/inline' => sub {
  my $self = shift;
  $self->render(inline => 'Hello Qaptcha! <%= qaptcha_include %>');
};
get '/index' => sub {
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
<h1>Hello Qaptcha!</h1>
