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
        - location
        - xp
        - reputation
        - bank balances
        - shields
        - warp fuel (or transferrable...? need to think on incentives)
        - pending warp fuel (needs to be claimed)
        - ship
    - transferrable
        - credits

Credits will be actual 1155s. Captain can deposit 1155s into bank (burns 1155), and withdraw (mints back to captain).

### Captains
Captains are intergalactic, and can be used in all games (even at the same time).

### Captain joins a game!
When you get into the game, you mint a ship and get 0 credits (or 100,000 credits, TBD) on person and in bank.

> Note: issue with starting with 100k credits is that if captains and game-entry are free, the only thing stopping you from minting infinite credits is gas to mint and join.

### Captain enters a solar system
A Captain can check their radar to see what planets, moons, other Captains, NPCs and spaceports are present.

### In space, Captain can perform actions
- Start battle with NPC in the current system
- Start battle with Captain in the current solar system
- Interact with the spaceport (if present)
- Interact with a planet or colony
- Land on a planet in the current solar system (gain protection for the night)
- Land on a spaceport in the current solar system (gain protection for the night)

### Captain can interact with a spaceport
- Can interact _without_ landing on the spaceport!
- Buy ship (burns current one, costs credits)
- Buy resources or hardware
- Buy a drink
- Stay the night (no action required) - costs credits over time

### Captain can interact with a planet
- Plant a biodome

### Captain can interact with a colony

### Sleeping in spaceports
A Captain is vulnerable in space! Sleeping in a spaceport will protect you from pirates. Over time you will accumulate debt. If your debt exceeds your credit balance, you will be ejected into space and will be vulnerable again!
> Note: Captain's `isInSpaceport` and `creditBalance` are storage entries in the Game contract, but the `getIsInSpaceport()` and `getCreditBalance()` view functions are dynamic. You accumulate debt over time. If your `debt > credits`, you are ejected to space. At that time, an enemy will see you as vulnerable because your `getIsInSpaceport()` returns false.
> Note: if you can enter a spaceport and have protection for a year but never pay your debt, you could transfer your credits away and you just had protection for free. Maybe you need to pay up-front if you are planning to stay at a spaceport for > 1 week.

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
