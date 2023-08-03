// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IGalaxy {
	function orbits(uint256 id) external view returns (uint256);
    function suborbits(uint256 id, uint256 orbit) external view returns (uint256);
	function planetAt(
		uint256 id, 
		uint256 orbit) external view returns (uint256);

	function moonAt(
		uint256 id,
		uint256 orbit,
		uint256 suborbit
		) external view returns (uint256);

	function planetType(
		uint256 id, 
		uint256 orbit) external view returns (string memory);
	function moonType(
		uint256 id, 
		uint256 orbit, 
		uint256 suborbit) external view returns (string memory);
}

interface ICaptain {
	function val(uint256 tokenId, string memory property) external pure returns (uint256);
	function getStats(uint256 id) public view returns (uint256, uint256, uint256);
	function getName (uint256 tokenId) public view returns (string memory);
	function ownerOf(uint256 tokenId) public view virtual override returns (address);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
contract MoonbasePermaverseAlpha {
	IGalaxy galaxy = IGalaxy(0x55D4b5707d480066a6c65Fa384F28e3deE22F00b);
	ICaptain captain = ICaptain();
	IShips ships = IShips();
	IResources resources = IResources();
	IHardware hardware = IHardware();
	IERC20 moonbase = IERC20(0x539e584Ea743DF75661Aa088A81eeF1A0FFD1236);

	mapping(address => uint256) captainByAddress;
	mapping(uint256 => uint256) xpById;
	mapping(uint256 => uint256) repById;
	mapping(uint256 => uint256) fuelById;

	mapping(uint256 => uint256) bankBalanceById;

	mapping(uint256 => uint256) locationById;

	mapping(uint256 => uint256) joinBlockById;
	mapping(uint256 => uint256) fuelClaimBlockById;

	mapping(uint256 => uint256) shieldsById;

	mapping(uint256 => uint256) activeShipById;

	mapping(uint256 => bool) hasSpaceportByLocation;
	mapping(uint256 => bool) hasMajorSpaceportByLocation;
	mapping(uint256 => uint256) spaceportOwnerById;

	constructor() {
		hasMajorSpaceportByLocation[0] = true;
		hasMajorSpaceportByLocation[13] = true;
		hasMajorSpaceportByLocation[42] = true;
		hasMajorSpaceportByLocation[69] = true;
		hasMajorSpaceportByLocation[137] = true;
		hasMajorSpaceportByLocation[420] = true;
		hasMajorSpaceportByLocation[42069] = true;
		hasMajorSpaceportByLocation[69420] = true;
		hasMajorSpaceportByLocation[137137] = true;
	}

	function _isCaptainOwner(uint256 tokenId, address sender) internal {
		require(captain.ownerOf(tokenId) == sender, "does not own the captain");
	}

	function _userIsHere(uint256 tokenId, uint256 location) internal {
		require(locationById[tokenId] == location, "user is not here");
	}

	// Major Spaceports sell ships and hardware and shields
	// they provide access to the bank
	// their locations are set at deployment
	function _hasMajorSpaceport(uint256 location) internal returns (bool) {
		require(hasMajorSpaceportByLocation[location], "system does not have major spaceport");
	}

	// Spaceports buy and sell resources
	function _hasSpaceport(uint256 location) internal {
		require(hasSpaceportByLocation[location], "system does not have spaceport");
	}

	
	/*
	struct SpaceportInventory {
		uint256 credits,
		uint256 metalore,
		uint256 anaerobes,
		uint256 medicine,
		uint256 organics,
		uint256 oil,
		uint256 uranium,
		uint256 equipment,
		uint256 spice
	} */

	mapping(uint256 => uint256[]) inventoryByLocation;

	// transfers resources to a spaceport
	function _toSpaceport(address from, uint256 location, uint256 id, uint256 amountIn) internal {
		resources.safeTransferFrom(from, address(this), id, amountIn, bytes(""));
		inventoryByLocation[location][id-1] = inventoryByLocation[location][id-1] + amountIn;
	}

	// transfers resources from a spaceport
	function _fromSpaceport(address to, uint256 location, uint256 id, uint256 amountIn) internal {
		resources.safeTransferFrom(address(this), to, id, amountIn, bytes(""));
		inventoryByLocation[location][id-1] = inventoryByLocation[location][id-1] - amountIn;
	}



	// Users can build a spaceport in a system without one
	// This costs 1 $MOONBASE and 1,000,000 Credits
	function buildSpaceport(uint256 location) public {
		require(!hasSpaceportByLocation[location] && !hasMajorSpaceportByLocation[location], "system has a spaceport");
		
		// transfer moonbase
		moonbase.transfer(msg.sender, address(this), 10 ** 18);
		
		// transfer credits
		resources.safeTransferFrom(msg.sender, address(this), 1, 1000000, bytes(""));

		spaceportOwnerById[location] = captainByAddress[msg.sender];
		hasSpaceportByLocation[location] = true;
	}







	/*
	struct Location {
		bool notInSpace,
		bool notOnPlanet,
		bool notOnMoon,
		bool notInSpaceport,
		uint64 systemId,
		uint64 planetId,
		uint64 moonId 

	} */

	function join(uint256 tokenId) public {
		_isCaptainOwner(tokenId, msg.sender);
		//mint ship
		//set fuel
		//puts you in system #0 or random
		//set xp to 0
		//set rep to 1000
	}


	// FLY AROUND -DUMB
	// land on a planet
	// land on a spaceport
	// fight npcs



	function withdrawBankBalance() public {

		// update balance
		// mint credits to caller
	
	}
	function depositBankBalance() public {

		
	
	}

	function claimWarpFuel() public {
		//warp fuel accumulates from join block
		//manual claim
	}

	function buyShip(uint256 tokenId) public {
		_hasMajorSpaceport()
		// if you are in system with major Spaceport
		// burn existing ship
		// mint new ship

	}

	function setActiveShip() public {
		// burn active ship
	}

	mapping(uint256 => uint256) onSpaceport;
	function landAtSpaceport(uint256 tokenId) public {
		// function called to sleep
		onSpaceport[tokenId] = true;

	}




}