package Mojolicious::Plugin::Qaptcha;
use Mojo::Base 'Mojolicious::Plugin';
use FindBin qw'$Bin';
use Mojo::Util 'slurp';
use File::Basename 'dirname';

our $VERSION = '0.01';

sub register {
  my ($self, $app) = @_;

  $app->helper(qaptcha_include => \&_qaptcha_include);

  my $r = $app->routes;
  $r->route('/qaptcha')->to(
    cb => sub {
      my $self = shift;
      if ($self->session('qaptcha_key') && $self->session('qaptcha_key' ne ''))
      {
        my $key = $self->session('qaptcha_key');

        if ($self->session($key) && $self->session($key) ne '') {
          return 1;
        }
        else {
          return 0;
        }
      }
      $self->session('qaptcha_key', undef);
    }
  );
  $r->route('/images/bg_draggable_qaptcha.jpg')->to(
    cb => sub {
      my $self = shift;
      $self->render(
        data => slurp(
          &_basedir . "/images/bg_draggable_qaptcha.jpg"
        ),
        format => 'jpg'
      );
    }
  );
}

sub _qaptcha_include {
  my $c        = shift;
  my $url_base = shift;

  #TODO make jquery optional/configurable
  my $jquery          = slurp( &_basedir . "/jquery/jquery.js");
  my $jquery_ui       = slurp( &_basedir . "/jquery/jquery-ui.js");
  my $jquery_ui_touch = slurp( &_basedir . "/jquery/jquery.ui.touch.js");
  my $qaptcha_js      = slurp( &_basedir . "/jquery/QapTcha.jquery.js");
  my $qaptcha_css     = slurp( &_basedir . "/jquery/QapTcha.jquery.css");

  require Mojo::DOM;
  my $script = <<EOS;
<script type="text/javascript>
$jquery
$jquery_ui
$jquery_ui_touch
$qaptcha_js
</script>
<style>$qaptcha_css</style>
EOS
  my $dom = Mojo::DOM->new($script);

  require Mojo::ByteStream;
  return Mojo::ByteStream->new($dom->to_xml);
}

sub _basedir {
  return dirname(__FILE__) . "/../../.."
}
1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Qaptcha - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Qaptcha');

  # Mojolicious::Lite
  plugin 'Qaptcha';

=head1 DESCRIPTION

L<Mojolicious::Plugin::Qaptcha> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::Qaptcha> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
