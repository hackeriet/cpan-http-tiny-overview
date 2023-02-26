#!/usr/bin/env perl


use v5.32;
use Mojo::Util qw(xml_escape);
use Mojo::JSON qw(decode_json encode_json);
use Smart::Comments;
use Data::Dumper;

my $distros = {};

chomp(my $repo_rev = qx(git --git-dir ./metacpan-cpan-extracted/.git rev-parse HEAD));
die "the metacpan-cpan-extracted submodule is probably not initialized" unless $repo_rev;

chomp(my $repo_log = qx(TZ=UTC git --git-dir ./metacpan-cpan-extracted/.git log --oneline -1 ));

while (my $jsonl = <STDIN>) {
  my $row = decode_json $jsonl;
  next unless $row->{type} eq 'match';

  my $path = $row->{data}->{path}->{text};
  chomp(my $lines = $row->{data}->{lines}->{text});

  my($distro_name) = $path =~ m!distros/./(.+?)/!;
  my($distro_path) = $path =~ m!distros/(./.+)!;
  my($file_path) = $distro_path =~ m!^./.+?/(.+)!;

  my $ln = $row->{data}->{line_number};
  my $m = $distros->{$distro_name} //= { matches => [] };

  my $distro_url = "https://metacpan.org/dist/$distro_name";

  my $source_url =
    "https://github.com/metacpan/metacpan-cpan-extracted"
    ."/blob/${repo_rev}/distros/$distro_path#L$ln";

  $m->{distro_path} = $distro_path;
  $m->{distro_name} = $distro_name;
  $m->{distro_url}  = $distro_url;

  push @{$m->{matches}}, {
    %{$row->{data}},
    source_url => $source_url,
    file_path => $file_path,
  };
}



print encode_json({
  repo_rev => $repo_rev,
  repo_log => $repo_log,
  distros => $distros
});
