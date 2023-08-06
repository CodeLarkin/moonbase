## Moobase
## Compiling and running tests

### To compile but not test
```
forge build
```

### To compile AND test
```
forge test -vv
```

## Generate grid of NFT images

### IMPORTANT: first activate your virtualenv
```
source venv/bin/activate
```

Then run one of the commands below after running a solidity test for biodomes and/or captains (via `forge test -vv`).

### To generate and view a grid of images for domes:
```
./scripts/nft-grid.sh domes
```

### To generate and view a grid of images for domes:
```
./scripts/nft-grid.sh captains
```
