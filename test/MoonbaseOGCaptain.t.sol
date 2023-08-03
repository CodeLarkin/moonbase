// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MoonbaseOGCaptain} from "../src/MoonbaseOGCaptain.sol";

contract MoonbaseOGCaptainTest is Test {
    MoonbaseOGCaptain public captains;
    address public owner;
    uint256 constant public NUM_DOMES = 100;

    // HELPER FUNCTIONS
    function getCost(uint tokenId) public view returns (uint) {
        uint quality = captains.getFarmQuality(tokenId);
        return captains.costs(quality);
    }

    function setSenderAndFund(address sender, uint256 amount) public {
        vm.prank(sender);
        vm.deal(sender, amount);
    }

    // TEST SETUP
    function setUp() public {
        captains = new MoonbaseOGCaptain();
        owner = vm.addr(1);
    }

    // TESTS
    function testMint() public {
        string[] memory uris = new string[](NUM_DOMES);
        for (uint256 tokenId = 0; tokenId < NUM_DOMES; tokenId++) {

            uint cost = getCost(tokenId);
            setSenderAndFund(owner, cost);
            captains.create{value: cost}(tokenId);

            assertEq(captains.ownerOf(tokenId), owner);

            uris[tokenId] = captains.tokenURI(tokenId);
        }
        string memory urisJson = vm.serializeString("", "uris", uris);
        vm.writeJson(urisJson, "./gen/domeURIs.json");
    }
}
