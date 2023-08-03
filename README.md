## Moobase

### A game tracks
- xp
- reputation
- bank balances

### A game contains
- a galaxy (systems, planets, etc)
- ships
- resources
- hardware
- corporations
- per-captain
    - non-transferrable
        - xp
        - reputation
        - bank balances
        - shields
        - warp fuel (or transferrable...? need to think on incentives)
    - transferrable
        - credits

Credits will be actual 1155s. Captain can deposit 1155s into bank (burns 1155), and withdraw (mints back to captain).

### Captains
Captains are intergalactic, and can be used in all games (even at the same time).

### Captain joins a game!
When you get into the game, you mint a ship and get 0 credits (or 100,000 credits, TBD) on person and in bank.

> Note: issue with starting with 100k credits is that if captains and game-entry are free, the only thing stopping you from minting infinite credits is gas to mint and join.

### Captain needs warp fuel
A Captain starts the game with some amount of warp fuel (1000) upon joining.
A Captain starts to generate warp fuel from moment (block) they join the game. Captain will have to manually generate fuel.


## Foundry - Setup/Usage

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
