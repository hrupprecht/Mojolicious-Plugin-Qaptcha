package Mojolicious::Plugin::Qaptcha;
use Mojo::Base 'Mojolicious::Plugin';
use FindBin qw'$Bin';
use Mojo::Util 'slurp';
use File::Basename 'dirname';

our $VERSION = '0.01';

sub register {
  my ($self, $app, $config) = @_;
  $app->config->{$_} = $config->{$_} for keys %$config;

  $app->helper(qaptcha_include      => \&_qaptcha_include);
  $app->helper(qaptcha_is_unlocked  => \&_is_unlocked);

  my $r = $app->routes;
  $r->route('/qaptcha')->to(
    cb => sub {
      my $self = shift;
      my $aResponse = {};
      $aResponse->{error} = 0;

      if ($self->param('action') && $self->param('qaptcha_key'))
      {
        $self->session('qaptcha_key', undef);
        if($self->param('action') eq 'qaptcha'){
          $self->session('qaptcha_key', $self->param('qaptcha_key'));
        }
        else {
          $aResponse->{error} = 1;
        }
        return $self->render(json => $aResponse);
      }
      else {
        $aResponse->{error} = 1;
        return $self->render(json => $aResponse);
      }
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
  $app->hook(after_dispatch => sub {
    my $c = shift;
    $c->session('qaptcha_key', undef)
      if $c->req->url->path->to_string ne '/qaptcha';
  });
}

sub _qaptcha_include {
  my $c        = shift;
  my $url_base = shift;

  my $jquery
    = $c->app->config->{inbuild_jquery} == 1
    ? slurp(&_basedir . "/jquery/jquery.js")
    : '';
  my $jquery_ui
    = $c->app->config->{inbuild_jquery_ui} == 1
    ? slurp(&_basedir . "/jquery/jquery-ui.js")
    : '';
  my $jquery_ui_touch
    = $c->app->config->{inbuild_jquery_ui_touch} == 1
    ? slurp(&_basedir . "/jquery/jquery.ui.touch.js")
    : '';
  my $qaptcha_js = slurp(&_basedir . "/jquery/QapTcha.jquery.js");
  my $qaptcha_css     = slurp( &_basedir . "/jquery/QapTcha.jquery.css");

  require Mojo::DOM;
  my $script = <<EOS;
<script type="text/javascript">
$jquery
$jquery_ui
$jquery_ui_touch
$qaptcha_js
\$(document).ready(function(){
  \$('.QapTcha').QapTcha({
    txtLock : "Locked : form can't be submited",
    txtUnlock : 'Unlocked : form can be submited',
    disabledSubmit : false,
    PHPfile : '/qaptcha',
    autoRevert:true,
    autoSubmit:false
  });
});
</script>
<style>$qaptcha_css</style>
EOS
  my $dom = Mojo::DOM->new($script);

  require Mojo::ByteStream;
  return Mojo::ByteStream->new($dom->to_xml);
}

sub _is_unlocked {
  my $self = shift;
  if($self->session('qaptcha_key')){
    if($self->req->param($self->session('qaptcha_key')) eq ''){
      return 1;
    }
  }
  return 0;
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
