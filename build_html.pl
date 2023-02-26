#!/usr/bin/env perl

use strict;

use Mojo::Template;
use Mojo::File;
use Mojo::JSON qw(decode_json);
use Mojo::Util;

my $results = decode_json(Mojo::File->new("docs/results.json")->slurp);

my $distros = $results->{distros};


my $with_verify_SSL = [
  grep {
    my $distro_name = $_;
    my $r = $distros->{$distro_name};
    grep { $_->{lines}->{text} =~ /verify_SSL/i } @{$r->{matches}}
  } sort keys %$distros
];

my $without_verify_SSL = [
  grep {
    my $distro_name = $_;
    !grep {$distro_name eq $_} @$with_verify_SSL;
  } sort keys %$distros
];

my $html = Mojo::Template->new->vars(1)
  ->render_file("docs/index.html.ep", {
    results => $results,
    with_verify_SSL => $with_verify_SSL,
    without_verify_SSL => $without_verify_SSL,
});

print $html;
