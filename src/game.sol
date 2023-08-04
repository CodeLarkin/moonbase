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

	

	mapping(uint256 => uint256) xpById;
	mapping(uint256 => uint256) repById;
	mapping(uint256 => uint256) fuelById;

	mapping(uint256 => uint256) bankBalanceById;

	mapping(uint256 => uint256) locationById;

	mapping(uint256 => uint256) joinBlockById;
	mapping(uint256 => uint256) fuelClaimBlockById;


	mapping(uint256 => uint256) activeShipById;

	

	

	function _userIsHere(uint256 tokenId, uint256 location) internal {
		require(locationById[tokenId] == location, "user is not here");
	}


	

	function _isCaptainOwner(uint256 tokenId, address sender) internal {
		require(captain.ownerOf(tokenId) == sender, "does not own the captain");
	}

	mapping(address => uint256) captainByAddress;
	function _setCaptain(uint256 id, address user) internal {
		_isCaptainOwner(id, user);
		captainByAddress[user] = id;
	}

	mapping (uint256 => uint256) discovererBySystemId;
	mapping (uint256 => uint256) asteroidsBySystemId;

	// ship state
	mapping (uint256 => uint256) shieldsById;
	mapping (uint256 => uint256) energyById;

	// ship equips
	mapping (uint256 => uint256) weaponById;
	mapping (uint256 => uint256) shipmod1ById;
	mapping (uint256 => uint256) shipmod2ById;
	mapping (uint256 => uint256) shipmod3ById;  
	
	mapping(uint256 => uint256) activeShipById;

	function warp(uint256 location) public {
		uint256 user = captainByAddress[msg.sender];
		uint256 loc = (location > 0) ? location - 1 : 0;
	
		if (locationById[user] > location) {
			require(locationById[user] - location == 1, "not next to system");
		} else {
			require(location - locationById[user] == 1, "not next to system");
		}
		
		locationById[user] = location;
		if (discovererBySystemId[location] == 0) {
			discovererBySystemId[location] = user;
			asteroidsBySystemId[location] = 1113527;
		}

	}


	


	

	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// SPACEPORTS ------------------------------------------------------------------------
	
	// Major Spaceports sell ships and hardware and shields
	// they provide access to the bank
	// their locations are set at deployment
	mapping(uint256 => bool) hasMajorSpaceportByLocation;
	function _hasMajorSpaceport(uint256 location) internal returns (bool) {
		require(hasMajorSpaceportByLocation[location], "system does not have major spaceport");
	}

	// Spaceports buy and sell resources
	mapping(uint256 => bool) hasSpaceportByLocation;
	function _hasSpaceport(uint256 location) internal {
		require(hasSpaceportByLocation[location], "system does not have spaceport");
	}

	mapping(uint256 => uint256[9]) inventoryByLocation;

	function _stockOf(uint256 location, uint256 id) returns (uint256) {
		return inventoryByLocation[location][id-1];
	}

	// transfers resources to a spaceport
	function _toSpaceport(address from, uint256 location, uint256 id, uint256 amount) internal {
		resources.safeTransferFrom(from, address(this), id, amount, bytes(""));
		inventoryByLocation[location][id-1] = inventoryByLocation[location][id-1] + amount;
	}

	// transfers resources to a spaceport Owner
	function _toSpaceportOwner(address from, uint256 location, uint256 id, uint256 amount) internal {
		resources.safeTransferFrom(from, spaceportOwnerById[location], id, amount, bytes(""));
	}

	// transfers resources from a spaceport
	function _fromSpaceport(address to, uint256 location, uint256 id, uint256 amount) internal {
		resources.safeTransferFrom(address(this), to, id, amount, bytes(""));
		inventoryByLocation[location][id-1] = inventoryByLocation[location][id-1] - amount;
	}

	// Users can build a spaceport in a system without one
	// This costs 1 $MOONBASE and 1,000,000 Credits
	mapping(uint256 => uint256) spaceportOwnerById;
	function buildSpaceport(uint256 location) public {
		require(!hasSpaceportByLocation[location] && !hasMajorSpaceportByLocation[location], "system has a spaceport");
		
		// transfer moonbase
		moonbase.transfer(msg.sender, address(this), 10 ** 18);
		
		// initialize inventory array
		inventoryByLocation[location] = [0,0,0,0,0,0,0,0,0];

		// transfer credits
		_toSpaceport(msg.sender, address(this), 1, 1e6);

		// update the owner mapping
		spaceportOwnerById[location] = captainByAddress[msg.sender];

		hasSpaceportByLocation[location] = true;
	}

	uint256[9] resource_cost_min = [1,2,3,4,6,8,10,14,20];
	uint256[9] resource_cost_max = [1,3,5,7,10,13,16,21,100];
	uint256 inventory_low = 1000;
	uint256 inventory_full = 10000;

	// calculates the cost to buy an amount of resource #id
	// from spaceport at provided location
	function _costOf(uint256 location, uint256 id, uint256 amount) internal returns (uint256 cost) {
		
		uint256 stock = _stockOf(location, id);
		require(stock >= amount, "not enough supply"); 
		if (stock - amount < inventory_low) {
			cost = resource_cost_max[id-1]*amount;
		}
		if (stock - amount >= inventory_low && stock - amount <= inventory_full) {
			uint256 pct = (stock - amount) * 1000 / (inventory_full - inventory_low);
			cost = ((resource_cost_max[id-1] - resource_cost_min[id-1])*(stock - amount)/(inventory_full - inventory_low) + resource_cost_min[id-1])*amount;
		}
			
		if (stock - amount > inventory_full) {
			cost = resource_cost_min[id-1]*amount;
		}
	}

	// calculates the amount of credits you'd receive for an amount of resource #id
	// from spaceport at provided location
	function _willPay(uint256 location, uint256 id, uint256 amount) internal returns (uint256 cost) {
		uint256 stock = _stockOf(location, id);
		uint256 credits = _stockOf(location, 1);
		require(stock >= amount, "not enough supply"); 
		if (stock + amount < inventory_low) {
			cost = resource_cost_max[id-1]*amount;
		}
		if (stock + amount >= inventory_low && stock + amount <= inventory_full) {
			uint256 pct = (stock - amount) * 1000 / (inventory_full - inventory_low);
			cost = ((resource_cost_max[id-1] - resource_cost_min[id-1])*(stock + amount)/(inventory_full - inventory_low) + resource_cost_min[id-1])*amount;
		}	
		if (stock + amount > inventory_full) {
			cost = resource_cost_min[id-1]*amount;
		}

		require(credits >= cost, "not enough credits");
		cost = cost - 4;
	}

	function buyFromSpaceport(uint256 location, uint256 id, uint256 amount) public {
		uint256 cost = _costOf(location, id, amount);
		uint256 tax = (cost > 199) ? cost/100 : 1;
		require(cost - tax > 0, "cost is too low");
		_toSpaceport(msg.sender, location, 1, cost - tax);
		_toSpaceportOwner(msg.sender, location, 1, tax);
		_fromSpaceport(msg.sender, location, id, amount);
	}

	function sellToSpaceport(uint256 location, uint256 id, uint256 amount) public {
		uint256 cost = _willPay(location, id, amount);
		uint256 tax = (amount > 199) ? amount/100 : 1;
		require(amount - tax > 0, "amount is too low");
		_toSpaceport(msg.sender, location, id, amount - tax);
		_toSpaceportOwner(msg.sender, location, id, tax);
		_fromSpaceport(msg.sender, location, 1, cost);
	}

	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// PLANETS AND SHIT ---------------------------------------------------------------------
	function bodyString(
		uint256 location, 
		uint256 planetId, 
		uint256 moonId, 
		bool isMoon) public view returns (string memory) {
		string memory output;
		output = string(abi.encodePacked(
			toString(location), 
			"."
			toString(planetId)
			))
		if (isMoon) {
			output = string(abi.encodePacked(
				output,
				".",
				toString(moonId)));
		}
		return output;
	}

	function bodyId(uint256 location, uint256 planetId, uint256 moonId, bool isMoon) public view returns (uint256){
		return uint256(keccak256(bodyString(location, planetId, moonId, isMoon)));
	} 

	string[] private planet_types = [
        "Gas giant",
		"Gas giant",
        "Gas giant",
		"Gas giant",
        "Gas giant",
		"Gas giant",
        "Gas giant",
		"Gas giant", // 7
		"Arctic",
        "Arctic",
        "Arctic", // 10
		"Volcanic",
        "Volcanic",
        "Volcanic", // 13
		"Desert",
        "Desert",
        "Desert", // 16
		"Mountainous",
        "Mountainous",
        "Mountainous", //19
		"Greenhouse",
        "Greenhouse",
        "Greenhouse", // 22
		"Oceanic",
        "Oceanic",
        "Oceanic", // 25
		"Rocky",
        "Rocky",
        "Rocky", // 28
        "Earthlike",
        "Earthlike",
        "Earthlike", // 31
        "Paradise" // 32
	];

	string[] private moon_types = [
		"Arctic", 
		"Volcanic",
		"Desert",
		"Mountainous",
		"Greenhouse",
		"Oceanic",
		"Rocky", // 6
        "Rocky",
        "Rocky",
		"Earthlike", // 9
		"Tiny", 
        "Tiny",
        "Tiny",
        "Tiny",
        "Tiny",
        "Tiny" // 15
	];



	

	function _typeOf(uint256 location, uint256 planetId, uint256 moonId, bool isMoon) internal view returns (uint256) {
		uint256 output;
		if (isMoon) {
			output = uint256(keccak256(galaxy.planetType(location,planetId)));
		} else {
			output = uint256(keccak256(galaxy.moonType(location,planetId,moonId)));
		}
		return output;
	}
	function _type(string memory typeString) internal view returns (uint256) {
		return uint256(keccak256(typeString);
	}

	// 0 - credits
	// 1 - liquid hydrogen
	// 2 - iron ore
	// 3 - anaerobes
	// 4 - medicine
	// 5 - organics
	// 6 - oil
	// 7 - uranium
	// 8 - spice
	// 9 - colonists

	function _getResourceBaseYield(
		uint256 location, 
		uint256 planetId, 
		uint256 moonId, 
		bool isMoon) internal view returns (uint256[10] memory) {
		uint256 typeKek = _typeOf(location, planetId, moonId, isMoon);
		uint256[10] memory yields;

		if (typeKek == _type("Gas Giant")) {
			yields = [0,8,0,0,0,0,0,0,0,0];
		}

		if (typeKek == _type("Tiny")) {
			yields = [0,0,2,0,0,0,0,0,0,0];
		}

		if (typeKek == _type("Arctic")) {
			yields = [0,0,1,2,1,1,4,0,0,3];
		}

		if (typeKek == _type("Desert")) {
			yields = [0,0,2,1,1,1,6,0,4,2];
		}

		if (typeKek == _type("Earthlike")) {
			yields = [0,0,3,0,2,8,2,1,0,5];
		}

		if (typeKek == _type("Greenhouse")) {
			yields = [0,0,1,8,1,0,1,1,0,0];
		}

		if (typeKek == _type("Mountainous")) {
			yields = [0,0,5,1,0,0,0,5,0,2];
		}

		if (typeKek == _type("Oceanic")) {
			yields = [0,0,1,1,4,3,2,2,1,4];
		}

		if (typeKek == _type("Paradise")) {
			yields = [0,0,4,4,4,4,4,4,2,6];
		}

		if (typeKek == _type("Rocky")) {
			yields = [0,0,8,1,0,0,0,1,0,1];
		}

		if (typeKek == _type("Volcanic")) {
			yields = [0,0,4,2,1,0,1,1,0,0];
		}

		return yields;

	}

	function _getResourceYield(
		uint256 location, 
		uint256 planetId, 
		uint256 moonId, 
		bool isMoon) internal view returns (uint256[10] memory) {

		uint256[10] baseyield = _getResourceBaseYield(location, planetId, moonId, isMoon);
		uint256[10] yield;

		for (uint256 i = 0; i < baseyield.length; i++) {
			if (isMoon) {
				yield[i] = (baseyield > 0) ? baseyield - 1 : 0; 
			} else {
				yield[i] = baseyield[i];
			}	
		}

	}

	function remove(uint index, uint256[] memory array)  returns(uint[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;
    }

	mapping (uint256 => uint256) discovererByBodyId;
	mapping (uint256 => uint256) lastExploredBlockById;

	// --------------------------------------------------------------------------------
	// IN-SYSTEM ACTIVITY -------------------------------------------------------------
	// --------------------------------------------------------------------------------
	// Exploring Planets --------------------------------------------------------------

	function exploreBody(
		uint256 location, 
		uint256 planetId, 
		uint256 moonId, 
		bool isMoon) public {

		require(lastExploredBlockById[id] + 1000 > block.number,"wait longer");
		uint256 user = captainByAddress[msg.sender];
		uint256 id = bodyId(location, planetId, moonId, isMoon);
		if (discovererByBodyId[id] == 0) {
			discovererByBodyId[id] = user;
		}

		uint256[10] yields = _getResourceYield(location, planetId, moonId, isMoon);
		yields = remove(0, yields);
		yields = remove(yields.length-1, yields);

		resources.mintBatch(msg.sender, [2,3,4,5,6,7,8,9], yields);
		lastExploredBlockById[id] = block.number;

	}

	

	// --------------------------------------------------------------------------------
	// IN-SYSTEM ACTIVITY -------------------------------------------------------------
	// --------------------------------------------------------------------------------
	// Asteroid Mining ----------------------------------------------------------------
	function mineAsteroids(uint256 location) public {

		require(asteroidsBySystemId[location] > 0, "no asteroids left");
		uint256 user = captainByAddress[msg.sender];

		uint256 kek = uint256(keccak256(
			abi.encodePacked(
				toString(block.number),
				toString(location),
				toString(user)
				)
			));

		uint256 greatness = kek % 6;

		resources.mint(msg.sender, 2, (greatness + 1)*10);

	}


	// --------------------------------------------------------------------------------
	// IN-SYSTEM ACTIVITY -------------------------------------------------------------
	// --------------------------------------------------------------------------------
	// NPC Fighting -------------------------------------------------------------------
	function _generateNPC() internal returns (uint256 attack, uint256 defense, uint256 xp, uint256 credits) {
		attack = uint256(keccak256(block.number)) % 16001;
		defense = uint256(keccak256(block.number)) % 16001;
		xp = uint256(keccak256(block.number)) % 10001;
		credits = uint256(keccak256(block.number)) % 100001;
	}

	function _fightNPC(uint256 location) public returns (bool) {
		uint256 user = captainByAddress[msg.sender];
		_userIsHere(user, location);
		(uint256 attack, uint256 defense, uint256 xp, uint256 credits) = _generateNPC();
		(uint256 atk, uint256 def) = _getUserCombatStats();

		uint256 userOverpower = (atk > defense) ? atk - defense : 0;
		uint256 npcOverpower = (attack > def) ? attack - def : 0;
		bool win;
		if (npcOverpower > userOverpower) {
			win = false;
		} else {
			if (userOverpower > 0) {
				win = true;
				if (npcOverpower > 0) {
					shieldsById[user] = userOverpower - npcOverpower;
				} else {
					shieldsById[user] = def - attack;
				}
			} else {
				uint256 ttkNpc = 1e6*defense/atk;
				uint256 ttkUser = 1e6*def/attack;
				if(ttkUser >= ttkNpc) {
					win = true;
					shieldsById[user] = shieldsById[user] - attack;
				} else {
					win = false;
				}
			}
		}

		if (!win) {
			xpById[user] -= xpById[user]/10;
			ships.burn(msg.sender,activeShipById[user],1);
			ships.mint(msg.sender,escapePodId,1);
			activeShipById[user] = escapePodId;
			shieldsById[user] = 1000;
		} else {
			resources.mint(msg.sender,1,credits);
			xpById[user] += xp/4;
		}

		return win;

	}

	function fightPirates(uint256 location) public {
		uint256 win = _fightNPC(location);
		if (win) {
			repById += 10;
		} else {
			repById += 1;
		}
	}

	function huntInnocents(uint256 location) public {
		uint256 win = _fightNPC(location);
		if (win) {
			repById -= 1;
		} else {
			repById -= 10;
		}
	}






	function join(uint256 tokenId) public {
		_isCaptainOwner(tokenId, msg.sender);
		//mint ship
		//set fuel
		//puts you in system #0 or random
		//set xp to 0
		//set rep to 1000
	}



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


}