// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Svg} from "../src/Svg.sol";
import {MoonbaseCaptainURI} from "../src/MoonbaseOGCaptainSimpleURI.sol";
import {IVisualizer, MoonbaseOGCaptain} from "../src/MoonbaseOGCaptainSimple.sol";

contract MoonbaseOGcaptainimpleTest is Test {
    //IVisualizer public visualizer;
    Svg public svg;
    MoonbaseCaptainURI public visualizer;
    MoonbaseOGCaptain public captain;
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
        svg = new Svg();
        captain = new MoonbaseOGCaptain();
        visualizer = new MoonbaseCaptainURI(address(svg), address(captain));
        captain.setVisualizer(address(visualizer));
        owner = vm.addr(1);
    }

    // TESTS
    function testMint() public {
        string[] memory uris = new string[](NUM_NFTS);
        for (uint256 tokenId = FIRST_TOKEN_ID; tokenId < NUM_NFTS + FIRST_TOKEN_ID; tokenId++) {
            console2.log("tokenId: %s", tokenId);

            setSenderAndFund(owner, 1 ether);
            string memory name = string.concat("Captain ", vm.toString(tokenId));
            captain.mint(name, 5, 5, 5);

            assertEq(captain.ownerOf(tokenId), owner);

            console2.log("here0");
            uris[tokenId - FIRST_TOKEN_ID] = captain.tokenURI(tokenId); // FIXME(dbanks12): failing here!
            console2.log("here1");
        }
        string memory urisJson = vm.serializeString("", "uris", uris);
        vm.writeJson(urisJson, "./gen/captainURIs.json");
    }
}
