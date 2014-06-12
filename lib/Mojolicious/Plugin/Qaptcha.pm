package Mojolicious::Plugin::Qaptcha;

use Mojo::Base 'Mojolicious::Plugin';
use FindBin qw'$Bin';
use Mojo::Util 'slurp';
use File::Basename 'dirname';
use File::Spec;
use File::ShareDir;

our $VERSION = '0.10';

sub register {
  my ($self, $app, $config) = @_;
  $app->config->{$_} = $config->{$_} for keys %$config;

  $app->config->{qaptcha_url} ||= q|/qaptcha|;

  $app->helper(qaptcha_include     => \&_qaptcha_include);
  $app->helper(qaptcha_is_unlocked => \&_is_unlocked);

  my $r = $app->routes;
  $r->route($app->config->{qaptcha_url})->to(
    cb => sub {
      my $self      = shift;
      my $aResponse = {};
      $aResponse->{error} = 0;

      if ($self->param('action') && $self->param('qaptcha_key')) {
        $self->session('qaptcha_key', undef);
        if ($self->param('action') eq 'qaptcha') {
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
        data   => slurp(&_basedir . "/bg_draggable_qaptcha.jpg"),
        format => 'jpg'
      );
    }
  );
  $app->hook(
    after_dispatch => sub {
      my $c = shift;
      $c->session('qaptcha_key', '')
        if $c->req->url->path->to_string ne $app->config->{qaptcha_url};
    }
  );
}

sub _qaptcha_include {
  my $c        = shift;
  my $url_base = shift;

  my $cfg = $c->app->config;

  my $jquery = $cfg->{inbuild_jquery}
    && $cfg->{inbuild_jquery} == 1 ? slurp(&_basedir . "/jquery.js") : '';
  my $jquery_ui
    = $cfg->{inbuild_jquery_ui} && $cfg->{inbuild_jquery_ui} == 1
    ? slurp(&_basedir . "/jquery-ui.js")
    : '';
  my $jquery_ui_touch
    = $cfg->{inbuild_jquery_ui_touch} && $cfg->{inbuild_jquery_ui_touch} == 1
    ? slurp(&_basedir . "/jquery.ui.touch.js")
    : '';
  my $qaptcha_js  = slurp(&_basedir . "/QapTcha.jquery.js");
  my $qaptcha_css = slurp(&_basedir . "/QapTcha.jquery.css");

  $cfg->{txtLock}        ||= q|Locked : form can't be submited|;
  $cfg->{txtUnlock}      ||= q|Unlocked : form can be submited|;
  $cfg->{disabledSubmit} ||= q|false|;
  $cfg->{autoRevert}     ||= q|true|;
  $cfg->{autoSubmit}     ||= q|false|;

  require Mojo::DOM;
  my $script = <<EOS;
<script type="text/javascript">
$jquery
$jquery_ui
$jquery_ui_touch
$qaptcha_js
\$(document).ready(function(){
  \$('.QapTcha').QapTcha({
    txtLock : "$cfg->{txtLock}",
    txtUnlock : "$cfg->{txtUnlock}",
    disabledSubmit : $cfg->{disabledSubmit},
    PHPfile : '$cfg->{qaptcha_url}',
    autoRevert : $cfg->{autoRevert},
    autoSubmit : $cfg->{autoSubmit}
  });
});
</script>
<style>$qaptcha_css</style>
EOS
  my $dom = Mojo::DOM->new($script);
  $dom->xml(1);

  require Mojo::ByteStream;
  return Mojo::ByteStream->new($dom->to_string);
}

sub _is_unlocked {
  my $self = shift;
  if ($self->session('qaptcha_key')) {
    no warnings 'uninitialized';
    if ($self->req->param($self->session('qaptcha_key')) eq '') {
      return 1;
    }
  }
  return 0;
}

sub _basedir {
  my $dir
    = File::Spec->catdir(
    dirname(__FILE__) . "/../../../jquery" //
    File::ShareDir::dist_dir('Mojolicious-Plugin-Qaptcha'));
  return $dir;
}

=head1 NAME

Mojolicious::Plugin::Qaptcha - jQuery QapTcha Plugin for Mojolicious

=head1 SYNOPSIS

  # Mojolicious
  $app->plugin('Qaptcha', {
    inbuild_jquery          => 1,
    inbuild_jquery_ui       => 1,
    inbuild_jquery_ui_touch => 1,
    txtLock                 => "LOCKED",
    txtUnlock               => "UNLOCKED",
    disabledSubmit          => "true",
    autoRevert              => "false",
    autoSubmit              => "true",
    qaptcha_url             => '/do_unlock',
  });

  # Mojolicious::Lite
  plugin 'Qaptcha', {
    inbuild_jquery          => 1,
    inbuild_jquery_ui       => 1,
    inbuild_jquery_ui_touch => 1,
    txtLock                 => "LOCKED",
    txtUnlock               => "UNLOCKED",
    disabledSubmit          => "true",
    autoRevert              => "false",
    autoSubmit              => "true",
    qaptcha_url             => '/do_unlock',
  };

and in your templates

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
  <form method="post">
    <fieldset>
      <label>First Name</label> <input name="firstname" type="text"><br>
      <label>Last Name</label> <input name="lastname" type="text">
      <input name="submit" value="Submit form" style="margin-top:15px;" type="submit">
      <br />
      <!-- put a qaptcha element inside a form -->
      <div class="QapTcha"></div>

    </fieldset>
  </form>

and in your controller

  # Mojolicious::Lite
  any '/' => sub {
    my $self = shift;

    do_something if $self->qaptcha_is_unlocked;

    $self->render('index');
  };

  # Mojolicious
  sub index {
    my $self = shift;

    do_something if $self->qaptcha_is_unlocked;

    $self->render('index');
  }

=head1 DESCRIPTION

L<Mojolicious::Plugin::Qaptcha> is a L<Mojolicious> plugin.

It brings jQuery QapTcha functionality inside your html form
in an element with class 'QapTcha'.
When QapTcha is unlocked, next request has to
submit form. Otherwise QapTcha will be locked back.

=head1 METHODS

L<Mojolicious::Plugin::Qaptcha> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new, $options_hash);

Register plugin in L<Mojolicious> application.


=head2 HELPERS

=over 4

=item qaptcha_include

Includes (optional configured) jquery and qaptcha javascript.

=item qaptcha_is_unlocked

Returns 1 if QapTcha is unlocked.

=back

=head2 OPTIONS

=over 4

=item inbuild_jquery

If set to 1 jQuery 1.8.2 is rendered into %= qaptcha_include.

=item inbuild_jquery_ui

If set to 1 jQuery UI - v1.8.2 is rendered into %= qaptcha_include.

=item inbuild_jquery_ui_touch

If set to 1 jQuery.UI.iPad plugin is rendered into %= qaptcha_include.

=item txtLock

Text to display for locked QapTcha

=item txtUnlock

Text to display for unlocked QapTcha

=item disabledSubmit

Add the "disabled" attribut to the submit button
default: false

=item autoRevert

Slider returns to the init-position, when the user hasn't dragged it to end
default: true

=item autoSubmit

If true, auto-submit form when the user has dragged it to the end
default: false

=item qaptcha_url

Configurable route to unlock qaptcha

=back

an example is located in L<ex/qaptcha.pl|https://github.com/hrupprecht/Mojolicious-Plugin-Qaptcha/blob/master/ex/qaptcha.pl>.

=head1 INSTALLATION

To install this module, run the following commands:

	perl Build.PL
	./Build
	./Build test
	./Build install

SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc Mojolicious::Plugin::Qaptcha

You can also look for information at:

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/Mojolicious-Plugin-Qaptcha

    CPAN Ratings
        http://cpanratings.perl.org/d/Mojolicious-Plugin-Qaptcha

    Search CPAN
        http://search.cpan.org/dist/Mojolicious-Plugin-Qaptcha/

=head1 SOURCE REPOSITORY

L<http://github.com/hrupprecht/Mojolicious-Plugin-Qaptcha>

=head1 AUTHOR

Holger Rupprecht - C<Holger.Rupprecht@gmx.de>

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Holger Rupprecht

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
