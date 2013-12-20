package Mojolicious::Plugin::Qaptcha;
use Mojo::Base 'Mojolicious::Plugin';

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
        $myVar = $self->session('qaptcha_key');

        if ($self->session($myVar) && $self->session($myVar) ne '') {
          return 1;
        }
        else {
          return 0;
        }
      }
      delete $self->session('qaptcha_key');
    }
  );
}

sub _qaptcha_include {
  my $c        = shift;
  my $url_base = shift;

  require Mojo::DOM;
  my $dom = Mojo::DOM->new('<script>alert('test')</script>');

  require Mojo::ByteStream;
  return Mojo::ByteStream->new($dom->to_xml);
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
