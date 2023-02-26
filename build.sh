#!/bin/sh
set -ex
./search.sh > docs/search.json
./search2results.pl < docs/search.json > docs/results.json
jq -r 'keys[]' < docs/results.json > docs/distros.txt
./build_html.pl > docs/index.html
