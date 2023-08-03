set -e

~/.foundry/bin/forge test -vv
python3 scripts/domeUrisFromMeta.py 'gen/domeURIs.json' > gen/domeURIs.html
brave-browser gen/domeURIs.html
