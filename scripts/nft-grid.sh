#!/bin/bash
set -e

# first run:
#~/.foundry/bin/forge test -vv

if [[ "$1" == domes ]]; then
    python3 scripts/domeUrisFromMeta.py 'gen/domeURIs.json' > gen/domeURIs.html
    firefox gen/domeURIs.html
fi
if [[ "$1" == captains ]]; then
    python3 scripts/domeUrisFromMeta.py 'gen/captainURIs.json' > gen/captainURIs.html
    firefox gen/captainURIs.html
fi
