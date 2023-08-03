set -e

# first run:
#~/.foundry/bin/forge test -vv

    python3 scripts/domeUrisFromMeta.py 'gen/domeURIs.json' > gen/domeURIs.html
    brave-browser gen/domeURIs.html
fi
if [ "$1" == captains ]; then
    python3 scripts/domeUrisFromMeta.py 'gen/captainURIs.json' > gen/captainURIs.html
    brave-browser gen/domeURIs.html
fi
