use Test::More;
use File::Spec;
use File::Basename 'dirname';
use File::Temp 'tempdir';
use Cwd 'abs_path';
use File::Path 'make_path';
use File::Copy 'copy';

BEGIN {
  eval { require Mojolicious::Plugin::Qaptcha; 1 }
    or plan skip_all => 'Mojolicious::Plugin::Qaptcha required';
}

subtest 'development mode' => sub {
  my $expected = abs_path(File::Spec->catdir(dirname(__FILE__), '..', 'jquery'));
  my $got      = abs_path(Mojolicious::Plugin::Qaptcha::_basedir());
  is $got, $expected, 'uses development jquery directory';
};

subtest 'installed mode' => sub {
  my $dev_dir = File::Spec->catdir(dirname(__FILE__), '..', 'jquery');
  my $bak     = "$dev_dir.bak";
  rename $dev_dir, $bak or BAIL_OUT("rename failed: $!");
  my $share = tempdir(CLEANUP => 1);
  no warnings 'redefine';
  local *File::ShareDir::dist_dir = sub { $share };
  my $basedir = Mojolicious::Plugin::Qaptcha::_basedir();
  is $basedir, $share, 'fallback to File::ShareDir path';
  rename $bak, $dev_dir or BAIL_OUT("restore failed: $!");
};

subtest 'blib share mode' => sub {
  my $base = tempdir(CLEANUP => 1);

  my $libdir = File::Spec->catdir(
    $base, qw(blib lib auto share dist Mojolicious-Plugin-Qaptcha lib)
  );
  my $moddir = File::Spec->catdir($libdir, qw(Mojolicious Plugin));
  make_path($moddir);
  my $src
    = File::Spec->catfile(dirname(__FILE__), '..', 'lib', 'Mojolicious', 'Plugin',
    'Qaptcha.pm');
  copy($src, File::Spec->catfile($moddir, 'Qaptcha.pm'))
    or BAIL_OUT("copy failed: $!");

  make_path(File::Spec->catdir($base, 'jquery'));

  local @INC = ($libdir, @INC);
  delete $INC{'Mojolicious/Plugin/Qaptcha.pm'};
  no warnings 'redefine';
  require Mojolicious::Plugin::Qaptcha;
  my $got      = abs_path(Mojolicious::Plugin::Qaptcha::_basedir());
  my $expected = abs_path(File::Spec->catdir($base, 'jquery'));
  is $got, $expected, 'works with blib/lib/auto/share module';
};

done_testing;
