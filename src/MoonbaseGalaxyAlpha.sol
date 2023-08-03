/**
 *Submitted for verification at basescan.org on 2023-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MoonbaseGalaxyAlpha {
	string private seed = "Milky Way";
	string[] private planet_types = [
        "Gas giant",
		"Gas giant",
        "Gas giant",
		"Gas giant",
        "Gas giant",
		"Gas giant",
        "Gas giant",
		"Gas giant",
		"Arctic",
        "Arctic",
        "Arctic",
		"Volcanic",
        "Volcanic",
        "Volcanic",
		"Desert",
        "Desert",
        "Desert",
		"Mountainous",
        "Mountainous",
        "Mountainous",
		"Greenhouse",
        "Greenhouse",
        "Greenhouse",
		"Oceanic",
        "Oceanic",
        "Oceanic",
		"Rocky",
        "Rocky",
        "Rocky",
        "Earthlike",
        "Earthlike",
        "Earthlike",
        "Paradise"
	];

    string[] private moon_types = [
		"Arctic",
		"Volcanic",
		"Desert",
		"Mountainous",
		"Greenhouse",
		"Oceanic",
		"Rocky",
        "Rocky",
        "Rocky",
		"Earthlike",
		"Tiny",
        "Tiny",
        "Tiny",
        "Tiny",
        "Tiny",
        "Tiny"
	];

	// ---------------------------------------------------------------------------
    // ---------------------------------------------------------------------------
    // pseudo-randmoness ---------------------------------------------------------
    function _kek(uint256 id, string memory input) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(toString(id),seed,input)));
    }

    uint256 private max_orbits = 9;
    uint256 private max_suborbits = 16;

    function orbits(uint256 id) public view returns (uint256){
    	return _kek(id, "orbits") % (max_orbits + 1);
    }

    function suborbits(uint256 id, uint256 orbit) public view returns (uint256) {
    	return _kek(id, string(abi.encodePacked(toString(orbit),"suborbits"))) % (max_suborbits + 1);
    }

	function planetAt(
		uint256 id, 
		uint256 orbit) public view returns (uint256) {
            require(orbit <= orbits(id), "planet does not exist");
		return _kek(id, string(abi.encodePacked(".",toString(orbit)))) % planet_types.length;
	}

	function moonAt(
		uint256 id,
		uint256 orbit,
		uint256 suborbit
		) public view returns (uint256) {
            require(orbit <= orbits(id), "planet does not exist");
            require(suborbit <= suborbits(id, orbit), "moon does not exist");
		return _kek(
			id, 
			string(
				abi.encodePacked(
					".",
					toString(orbit),
					".",
					toString(suborbit)
					)
				)
			) % moon_types.length;
	}

	function planetType(
		uint256 id, 
		uint256 orbit) public view returns (string memory) {
		return planet_types[planetAt(id,orbit)];
	} 
	function moonType(
		uint256 id, 
		uint256 orbit, 
		uint256 suborbit) public view returns (string memory) {
		return moon_types[moonAt(id,orbit,suborbit)];
	} 

	function toString(uint256 value) internal pure returns (string memory) {
	// Inspired by OraclizeAPI's implementation - MIT license
	// https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

	    if (value == 0) {
	        return "0";
	    }
	    uint256 temp = value;
	    uint256 digits;
	    while (temp != 0) {
	        digits++;
	        temp /= 10;
	    }
	    bytes memory buffer = new bytes(digits);
	    while (value != 0) {
	        digits -= 1;
	        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
	        value /= 10;
	    }
	    return string(buffer);
	}
}