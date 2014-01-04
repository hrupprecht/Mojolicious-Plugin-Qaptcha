use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

plugin 'Qaptcha';

get '/' => sub {
  my $self = shift;
  $self->render(inline => 'Hello Qaptcha! <%= qaptcha_include %>');
};

my $t = Test::Mojo->new;
$t->get_ok('/')->status_is(200)
  ->content_like(qr'Hello Qaptcha!')
  ->content_like(qr'script');

done_testing();

__END__

@@ layouts/default.html.ep
<html>
<head>

</head>
</html>

@@ default.html.ep
%= layout 'default'
