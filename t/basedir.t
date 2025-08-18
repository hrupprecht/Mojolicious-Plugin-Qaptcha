use Test::More;
use File::Spec;
use File::Basename 'dirname';
use File::Temp 'tempdir';
use Cwd 'abs_path';

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

done_testing;
