#!/bin/sh
rg -g "!*.t" -U -f rg-patterns --no-ignore --sort path --json --type perl ./metacpan-cpan-extracted/
