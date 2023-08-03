// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MoonbaseCaptainURI} from "../src/MoonbaseOGCaptainSimpleURI.sol";
import {IVisualizer, MoonbaseOGCaptain} from "../src/MoonbaseOGCaptainSimple.sol";

contract MoonbaseOGCaptainSimpleTest is Test {
    //IVisualizer public visualizer;
    MoonbaseCaptainURI public visualizer;
    MoonbaseOGCaptain public captains;
    address public owner;
    uint256 constant public NUM_NFTS = 100;
    uint256 constant public FIRST_TOKEN_ID = 1;

    // HELPER FUNCTIONS
    function setSenderAndFund(address sender, uint256 amount) public {
        vm.prank(sender);
        vm.deal(sender, amount);
    }

    // TEST SETUP
    function setUp() public {
        visualizer = new MoonbaseCaptainURI();
        captains = new MoonbaseOGCaptain(address(visualizer));
        owner = vm.addr(1);
    }

    // TESTS
    function testMint() public {
        string[] memory uris = new string[](NUM_NFTS);
        for (uint256 tokenId = FIRST_TOKEN_ID; tokenId < NUM_NFTS + FIRST_TOKEN_ID; tokenId++) {
            console2.log("tokenId: %s", tokenId);

            setSenderAndFund(owner, 1 ether);
            string memory name = string.concat("Captain ", vm.toString(tokenId));
            captains.mint(name, 5, 5, 5);

            assertEq(captains.ownerOf(tokenId), owner);

            uris[tokenId] = captains.tokenURI(tokenId); // FIXME(dbanks12): failing here!
        }
        string memory urisJson = vm.serializeString("", "uris", uris);
        vm.writeJson(urisJson, "./gen/captainURIs.json");
    }
}
