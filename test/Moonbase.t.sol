// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MoonbaseGalaxyAlpha} from "../src/MoonbaseGalaxyAlpha.sol";
import {MoonbaseBiodome} from "../src/MoonbaseBiodome.sol";

contract MoonbaseTest is Test {
    MoonbaseGalaxyAlpha public galaxy;
    MoonbaseBiodome public biodome;
    address public owner;
    uint256 constant public NUM_DOMES = 100;

    // HELPER FUNCTIONS
    function getBiodomeCost(uint tokenId) public view returns (uint) {
        uint quality = biodome.getFarmQuality(tokenId);
        return biodome.costs(quality);
    }

    function setSenderAndFund(address sender, uint256 amount) public {
        vm.prank(sender);
        vm.deal(sender, amount);
    }

    // TEST SETUP
    function setUp() public {
        galaxy = new MoonbaseGalaxyAlpha();
        biodome = new MoonbaseBiodome();
        owner = vm.addr(1);
    }

    // TESTS
    function testMint() public {
        string[] memory uris = new string[](NUM_DOMES);
        for (uint256 tokenId = 0; tokenId < NUM_DOMES; tokenId++) {

            uint cost = getBiodomeCost(tokenId);
            setSenderAndFund(owner, cost);
            biodome.create{value: cost}(tokenId);

            assertEq(biodome.ownerOf(tokenId), owner);

            uris[tokenId] = biodome.tokenURI(tokenId);
        }
        string memory urisJson = vm.serializeString("", "uris", uris);
        vm.writeJson(urisJson, "./gen/domeURIs.json");
    }
}
