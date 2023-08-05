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

	function _user(address sender) internal view returns (uint256) {
		require(captain.ownerOf(captainByAddress[sender]) == sender, "sender not the owner");
		return captainByAddress[sender];
	}

	mapping (uint256 => uint256) discovererBySystemId;
	mapping (uint256 => uint256) asteroidsBySystemId;

	// ship state
	mapping (uint256 => uint256) shieldsById;
	mapping (uint256 => uint256) energyById;
	mapping (uint256 => uint256) filledHardwareSlotsById;
	mapping (uint256 => uint256[]) hardwareBalancesById;

	


	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// Ships ------------------------------------------------------------------------

	struct Ship {
        uint256 id; 
        string name; 
        string description; 
        string imgdata;
        uint256 totalSupply;
        uint256 cost;
        uint256 shield_capacity;
        uint256 cargo_holds;
        uint256 hardware_slots;
        uint256 top_speed;
        uint256 turning;
        uint256 thrust;
        uint256 energy_regen;
        uint256 fuel_per_warp;
    }

    // ship equips
	mapping (uint256 => uint256) weaponById;
	mapping (uint256 => uint256) shipmodById;
	mapping(uint256 => uint256) activeShipById;


	struct Weapon {
		uint256 id;
		string memory name;
		uint256 cost;
		uint256 damage;
		uint256 energy_use;
		uint256 fire_rate;
	}

	mapping (uint256 => Weapon) weaponByWeaponId;

	function _addWeapon(
		uint256 id,
		string memory name,
		uint256 cost,
		uint256 damage,
		uint256 energy_use,
		uint256 fire_rate
		) internal {
		require(weaponByWeaponId[id].id != id,"weapon exists");
		weaponByWeaponId[id] = Weapon(id, name, cost, damage, energy_use, fire_rate);
	}

	function addWeapon(
		uint256 id,
		string memory name,
		uint256 cost,
		uint256 damage,
		uint256 energy_use,
		uint256 fire_rate) public onlyOwner {
		_addWeapon(id, name, cost, damage, energy_use, fire_rate);
	}

	function _weapon(uint256 id) internal view returns (Weapon memory) {
		return weaponByWeaponId[id];
	}

	function modifyWeapon(
		uint256 id,
		string memory name,
		uint256 cost,
		uint256 damage,
		uint256 energy_use,
		uint256 fire_rate) public onlyOwner {
		weaponByWeaponId[id] = Weapon(id, name, cost, damage, energy_use, fire_rate);
	}

	struct ShipMod {
		uint256 id;
		string memory name;
		uint256 cost;
	}

	mapping (uint256 => ShipMod) shipModByShipModId;

	function _addShipMod(
		uint256 id,
		string memory name,
		uint256 cost
		) internal {
		require(shipModByShipModId[id].id != id,"shipMod exists");
		shipModByShipModId[id] = ShipMod(id, name, cost, damage, energy_use, fire_rate);
	}

	function addShipMod(
		uint256 id,
		string memory name,
		uint256 cost) public onlyOwner {
		_addShipMod(id, name, cost, damage, energy_use, fire_rate);
	}

	function _shipMod(uint256 id) internal view returns (ShipMod memory) {
		return shipModByShipModId[id];
	}

	function modifyShipMod(
		uint256 id,
		string memory name,
		uint256 cost) public onlyOwner {
		shipModByShipModId[id] = ShipMod(id, name, cost, damage, energy_use, fire_rate);
	}

	struct Hardware {
		uint256 id;
		string memory name;
		uint256 cost;
	}

	mapping (uint256 => Hardware) hardwareByHardwareId;

	function _addHardware(
		uint256 id,
		string memory name,
		uint256 cost
		) internal {
		require(hardwareByHardwareId[id].id != id,"hardware exists");
		hardwareByHardwareId[id] = Hardware(id, name, cost, damage, energy_use, fire_rate);
	}

	function addHardware(
		uint256 id,
		string memory name,
		uint256 cost) public onlyOwner {
		_addHardware(id, name, cost, damage, energy_use, fire_rate);
	}

	function _hardware(uint256 id) internal view returns (Hardware memory) {
		return hardwareByHardwareId[id];
	}

	function modifyHardware(
		uint256 id,
		string memory name,
		uint256 cost) public onlyOwner {
		hardwareByHardwareId[id] = Hardware(id, name, cost, damage, energy_use, fire_rate);
	}



    function _useFuel(uint256 user, uint256 amount) internal {
    	require(fuelById[user] >= amount, "not enough fuel");
    	fuelById[user] -= amount; 
    }


    uint256 fuel_reduction_per_wis = 2;
    uint256 shipMod_fuelReducer_id = 1;
    uint256 shipMod_fuel_reduction = 10;
    function _fuelCostToWarp(uint256 user) internal returns (uint256) {
    	( , uint256 wis, ) = captain.getStats(user);
    	uint256 active_ship = activeShipById[user];
    	uint256 fpw = ships.itemById(active_ship).fuel_per_warp;
    	uint256 user_fps = fpw - wis * fuel_reduction_per_wis;
    	if (shipmodById[user] == shipMod_fuelReducer_id) {
    		user_fps -= shipMod_fuel_reduction;
    	}

    	return user_fps;
    }

    uint256 fuel_shards_gen_per_block = 1;
    uint256 fuel_shards_per_fuel = 12;
    // assume 1 block per second
    // in 120 blocks we want 10 fuel generated
    // in 12 blocks we want 1 fuel generated 
    mapping(uint256 => uint256) lastFuelClaimBlockById;
    function _claimFuel(uint256 user) internal {
    	uint256 blocks = block.number - lastFuelClaimBlockById[user];
    	require(blocks >= 12, "wait longer");
    	uint256 generatedFuelShards = fuel_shards_gen_per_block * blocks;
    	require(generatedFuelShards >= 12, "not enough for one fuel");
    	uint256 generatedFuel = generatedFuelShards/fuel_shards_per_fuel;
    	lastFuelClaimBlockById[user] = block.number;
    	fuelById[user] += generatedFuel;
    }

    function _landOnBody(uint256 user) internal {
    	_claimFuel(user);
    	_useFuel(user, 10);
    	
    }

    function _warp(uint256 user, uint256 to) internal {
    	_claimFuel(user);
    	_useFuel(user, _fuelCostToWarp(user));
    	locationById[user] = to;
    	if (discovererBySystemId[to] == 0) {
			discovererBySystemId[to] = user;
			asteroidsBySystemId[to] = 1113527;
		}
    }


	function warp(uint256 location) public {
		uint256 user = _user(msg.sender);
		uint256 loc = (location > 0) ? location - 1 : 0;
	
		if (locationById[user] > location) {
			require(locationById[user] - location == 1, "not next to system");
		} else {
			require(location - locationById[user] == 1, "not next to system");
		}
		_warp(user, location);
	}
	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// SPACEBASE ---------------------------------------------------------------------
	
	// Spacebases sell ships and hardware and shields
	// they provide access to the bank
	// their locations are set at deployment
	mapping(uint256 => bool) hasSpacebaseByLocation;
	function _hasSpacebase(uint256 location) internal {
		require(hasSpacebaseByLocation[location], "system does not have spacebase");
	}
	function _atSpacebase(address user) internal {
		_hasSpacebase(locationById[_user(user)]);
		require(fuelById[_user(user)] >= 1, "not enough fuel");
	}

	uint256 totalCreditsInSpacebases = 0;

	function _creditsToSpacebase(address user, uint256 amount) internal {
		_atSpacebase(user);
		resources.safeTransferFrom(user,address(this),1,amount,bytes(""));
		totalCreditsInSpacebases += amount;
	}

	function _creditsFromSpacebase(address user, uint256 amount) internal {
		_atSpacebase(_user(sender));
		if (totalCreditsInSpacebases >= amount) {
			resources.safeTransferFrom(address(this),user,1,amount,bytes(""));
			totalCreditsInSpacebases -= amount;
		} else {
			uint256 deficit = amount - totalCreditsInSpacebases;
			resources.safeTransferFrom(address(this),user,1,totalCreditsInSpacebases,bytes(""));
			totalCreditsInSpacebases = 0;
			resources.mint(user,1,deficit);
		}
		
	}
	// buy and sell ships and shields ----------------------------------------------------------------------
	function _isValidShip(uint256 shipId) internal {
		require(shipId > 0, "0 invalid ship Id");
		require(ships.itemById(shipId).id == shipId, "not a real ship");
	}
	function _sellShip(address user, uint256 shipId) internal {
		_isValidShip(shipId);
		_atSpacebase(user);
		uint256 cost = ships.itemById(shipId).cost;
		ships.burn(sender,activeShipById[_user(user)],1);
		resources.mint(sender,1,cost/10);
	}

	function _buyShip(address user, uint256 shipId) internal {
		_isValidShip(shipId);
		_atSpacebase(user);
		uint256 cost = ships.itemById(shipId).cost;
		_creditsToSpacebase(user,cost);
		ships.mint(user,activeShipById[_user(user)],1);
	}

	function buyNewShipSellOldShip(uint256 shipId) public {
		uint256 user = _user(msg.sender);
		uint256 cost = ships.itemById(shipId).cost;
		uint256 active = activeShipById[user];
		_sellShip(user,active);
		_buyShip(user,shipId);
		activeShipById[user] = shipId;
		shieldsById[user] = 2000;
		energyById[user] = 1000;
	}
	uint256 shield_cost = 5;
	function _buyShields(address user, uint256 amount) internal {
		_atSpacebase(user);
		uint256 u = _user(user);
		uint256 shieldcap = ships.itemById(active).shield_capacity;
		uint256 currentShields = shieldsById[u];
		require(currentShields + amount <= shieldcap,"too many shields");

		_creditsToSpacebase(user,1,amount * shield_cost);
		shieldsById[u] += amount;
		
	}
	function buyShields(uint256 amount) public {
		_buyShields(_user(msg.sender),amount);
	}

	function buyNewShipSellOldShipMaxShields(uint256 shipId) public {
		uint256 u = _user(msg.sender);
		uint256 cost = ships.itemById(shipId).cost;
		uint256 active = activeShipById[u];
		_sellShip(msg.sender,active);
		_buyShip(msg.sender,shipId);
		activeShipById[u] = shipId;
		shieldsById[u] = 2000;
		energyById[u] = 1000;
		_buyShields(msg.sender, amount);
	}

	// buy and sell weapons ----------------------------------------------------------------------
	function _isValidWeapon(uint256 weaponId) internal {
		require(weaponId > 0, "0 invalid weapon Id");
		require(weaponByWeaponId[weaponId].id == weaponId, "not a real weapon");
	}

	function _buyWeapon(address user, uint256 weaponId) internal {
		_isValidWeapon(weaponId);
		_atSpacebase(user);
		uint256 u = _user(user);
		require(weaponById[u] == 0, "user already has weapon");
		uint256 cost = weaponByWeaponId[weaponId].cost;
		_creditsToSpacebase(user,cost);
		weaponById[u] = weaponId;
	}

	function _sellWeapon(address user, uint256 weaponId) internal {
		_isValidWeapon(weaponId);
		_atSpacebase(user);
		uint256 u = _user(user);
		require(weaponById[u] == weaponById, "does not have weapon");
		uint256 cost = weaponByWeaponId[weaponId].cost;
		_creditsFromSpacebase(user, cost/10);
		weaponById[u] = 0;
	}

	function buyWeapon(uint256 weaponId) public {
		uint256 u = _user(msg.sender);
		if (weaponById[u] == 0) {
			_buyWeapon(msg.sender, weaponId);
		} else {
			_sellWeapon(msg.sender, weaponId);
			_buyWeapon(msg.sender, weaponId);
		}
	}

	// buy and sell shipmods ----------------------------------------------------------------------
	function _isValidShipMod(uint256 shipModId) internal {
		require(shipModId > 0, "0 invalid shipModId");
		require(shipModByShipModId[shipModId].id == shipModId, "not a real shipMod");
	}
	function _buyShipMod(address user, uint256 shipModId) internal {
		_isValidShipMod(shipModId);
		_atSpacebase(user);
		uint256 u = _user(user);
		require(shipModById[u] == 0, "user already has ShipMod");
		uint256 cost = shipModByShipModId[shipModId].cost;
		_creditsToSpacebase(user,cost);
		shipModById[user] = shipModId;
	}

	function _sellShipMod(address user, uint256 shipModId) internal {
		_isValidShipMod(shipModId);
		_atSpacebase(user);
		uint256 u = _user(user);
		require(shipModById[u] == shipModId, "does not have shipmod");
		uint256 cost = shipModByShipModId[shipModId].cost;
		_creditsFromSpacebase(user, cost/10);
		shipModById[u] = 0;
	}

	function buyShipMod(uint256 shipModId) public {
		uint256 u = _user(msg.sender);
		if (shipModById[u] == 0) {
			_buyShipMod(msg.sender, shipModId);
		} else {
			_sellShipMod(msg.sender, shipModById[u]);
			_buyShipMod(msg.sender, shipModId);
		}
	}

	// buy and sell hardware ----------------------------------------------------------------------
	function _isValidHardware(uint256 hardwareId) internal {
		require(hardwareId > 0, "0 invalid hardwareId");
		require(hardwareByHardwareId[hardwareId].id == hardwareId, "not a real hardwareId");
	}
	function _buyHardware(address user, uint256 hardwareId, uint256 amount) internal {
		_isValidHardware(hardwareId);
		_atSpacebase(user);
		uint256 u = _user(user);
		uint256 cost = hardwareByHardwareId[hardwareId].cost*amount;
		require(filledHardwareSlotsById[u] + amount <= ships.itemById(activeShipById[u]).hardware_slots, "not enough hardware slots");
		_creditsToSpacebase(user,cost);
		filledHardwareSlotsById[u] += amount;
		hardwareBalancesById[u][hardwareId] += amount;
	}

	function _sellHardware(address user, uint256 hardwareId, uint256 amount) internal {
		_isValidHardware(hardwareId);
		_atSpacebase(user);
		uint256 u = _user(user);
		require(hardwareBalancesById[u][hardwareId] >= amount, "not enough hardware");
		uint256 cost = hardwareByHardwareId[hardwareId].cost*amount;
		_creditsFromSpacebase(user, cost/10);
		filledHardwareSlotsById[u] -= amount;
		hardwareBalancesById[u][hardwareId] -= amount;
	}

	function buyHardware(uint256 hardwareId, uint256 amount) public {
		_buyHardware(msg.sender, hardwareId, amount);
	}

	function sellHardware(uint256 hardwareId, uint256 amount) public {
		_sellHardware(msg.sender, hardwareId, amount);
	}









	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// --------------------------------------------------------------------------------------
	// SPACEPORTS ------------------------------------------------------------------------
	
	
	// Spaceports buy and sell resources
	mapping(uint256 => bool) hasSpaceportByLocation;
	function _hasSpaceport(uint256 location) internal {
		require(hasSpaceportByLocation[location], "system does not have spaceport");
	}

	function _atSpaceport(uint256 user) internal {
		_hasSpaceport(locationById[user]);
	}

	mapping(uint256 => uint256[9]) inventoryByLocation;

	function _stockOf(uint256 location, uint256 id) returns (uint256) {
		return inventoryByLocation[location][id-1];
	}

	// transfers resources to a spaceport
	function _toSpaceport(address from, uint256 location, uint256 id, uint256 amount) internal {
		_atSpaceport(_user(from));
		resources.safeTransferFrom(from, address(this), id, amount, bytes(""));
		inventoryByLocation[location][id-1] = inventoryByLocation[location][id-1] + amount;
	}

	// transfers resources to a spaceport Owner
	function _toSpaceportOwner(address from, uint256 location, uint256 id, uint256 amount) internal {
		resources.safeTransferFrom(from, spaceportOwnerById[location], id, amount, bytes(""));
	}

	// transfers resources from a spaceport
	function _fromSpaceport(address to, uint256 location, uint256 id, uint256 amount) internal {
		_atSpaceport(_user(to));
		resources.safeTransferFrom(address(this), to, id, amount, bytes(""));
		inventoryByLocation[location][id-1] = inventoryByLocation[location][id-1] - amount;
	}

	// Users can build a spaceport in a system without one
	// This costs 1 $MOONBASE and 1,000,000 Credits
	mapping(uint256 => uint256) spaceportOwnerById;
	function buildSpaceport() public {
		uint256 location = locationById[_user(msg.sender)];
		require(!hasSpaceportByLocation[location] && !hasSpacebaseByLocation[location], "system has a spaceport");
		
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
	/*
		Users can buy resources at spaceports
		1% or a minimum of 1 credit is transferred to the owner of the spaceport
		the remaining credits are transferred to the spaceport
		and the resources are transferred to the user
		
	*/

	function buyFromSpaceport(uint256 id, uint256 amount) public {
		uint256 u = _user(msg.sender);
		_atSpaceport(u);
		uint256 location = locationById[u];
		uint256 cost = _costOf(location, id, amount);
		uint256 tax = (cost > 199) ? cost/100 : 1;
		require(cost - tax > 0, "cost is too low");
		_landOnBody(u);
		_toSpaceport(msg.sender, location, 1, cost - tax);
		_toSpaceportOwner(msg.sender, location, 1, tax);
		_fromSpaceport(msg.sender, location, id, amount);
	}

	/*
		Users can sell resources at spaceports
		1% or a minimum of 1 resource is transferred to the owner of the spaceport
		the remaining resources are transferred to the spaceport
		and the credits are transferred to the user
		
	*/

	function sellToSpaceport(uint256 id, uint256 amount) public {
		uint256 u = _user(msg.sender);
		_atSpaceport(u);
		uint256 location = locationById[u];
		uint256 cost = _willPay(location, id, amount);
		uint256 tax = (amount > 199) ? amount/100 : 1;
		require(amount - tax > 0, "amount is too low");
		_landOnBody(u);
		_toSpaceport(msg.sender, location, id, amount - tax);
		_toSpaceportOwner(msg.sender, location, id, tax);
		_fromSpaceport(msg.sender, location, 1, cost);
	}

	/*
		Users can craft shields at spaceports
		It costs 1 Iron Ore and 1 credit per unit.
		1000 shields cost 1000 iron ore and 1000 credits.
		The credits are sent directly to the owner of the spaceport
	*/

	uint256 shieldCraftOreCost = 1;
	function craftShields(uint256 amount) {
		uint256 u = _user(msg.sender);
		_atSpaceport(u);
		uint256 location = locationById[u];
		uint256 shieldcap = ships.itemById(active).shield_capacity;
		uint256 currentShields = shieldsById[u];
		require(currentShields + amount <= shieldcap,"too many shields");
		_landOnBody(u);
		_toSpaceport(msg.sender, location, 3, amount*shieldCraftOreCost);
		_toSpaceportOwner(msg.sender, location, 1, amount);
		shieldsById[u] += amount;
	}
	/*
		Users can craft fuel at spaceports
		It costs 10 Liquid Hydrogen and 10000 credits per unit.
		1000 warp fuel costs 10,000 Liquid Hydrogen and 10,000,000 credits.
		The credits are sent directly to the owner of the spaceport
	*/

	uint256 fuelCraftLHCost = 10;
	function craftFuel(uint256 amount) {
		uint256 u = _user(msg.sender);
		_atSpaceport(u);
		_landOnBody(u);
		uint256 location = locationById[u];
	
		uint256 currentFuel = fuelById[u];
		require(currentFuel + amount <= 5000,"too much fuel");
		
		_toSpaceport(msg.sender, location, 2, amount*fuelCraftLHCost);
		_toSpaceportOwner(msg.sender, location, 10000, amount);
		fuelById[u] += amount;
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
		uint256 u = _user(msg.sender);
		_landOnBody(u);
		uint256 id = bodyId(location, planetId, moonId, isMoon);
		if (discovererByBodyId[id] == 0) {
			discovererByBodyId[id] = u;
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
		uint256 u = _user(msg.sender);

		uint256 kek = uint256(keccak256(
			abi.encodePacked(
				toString(block.number),
				toString(location),
				toString(u)
				)
			));

		uint256 greatness = kek % 6;

		resources.mint(msg.sender, 2, (greatness + 1)*10);

	}




	// --------------------------------------------------------------------------------
	// IN-SYSTEM ACTIVITY -------------------------------------------------------------
	// --------------------------------------------------------------------------------
	// NPC Fighting -------------------------------------------------------------------

	function _getUserAttack(uint256 u) internal returns (uint256) {
		
		Weapon wep = weaponByWeaponId[weaponById[u]];
		uint256 shipEnergyRegen = ships.itemById(activeShipById[u]).energy_regen;
		uint256 dps = wep.damage*wep.fire_rate;
		uint256 dmg = wep.damage*energyById[u]/wep.energy_use;

		uint256 timeToUseEnergy = energyById[u]/(wep.energy_use * wep.fire_rate);

		uint256 timeToUse

	}

	function _generateNPC() internal returns (uint256 attack, uint256 defense, uint256 xp, uint256 credits) {
		attack = uint256(keccak256(block.number)) % 16001;
		defense = uint256(keccak256(block.number)) % 16001;
		xp = uint256(keccak256(block.number)) % 10001;
		credits = uint256(keccak256(block.number)) % 100001;
	}

	function _fightNPC(uint256 location) public returns (bool) {
		uint256 user = _user(msg.sender);
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
	// reputation ----------------------------------------------------------------
	mapping (uint256 => uint256) bountyById;
	uint256 neutral_rep = 50000;
	uint256 bounty_credits_per_bad_rep = 1000;
	function _isGood(uint256 rep) internal view returns (bool) {
		if (rep >= neutral_rep) {
			return true;
		} else {
			return false;
		}
	}
	function _increaseRep(uint256 u, uint256 amount) internal {
		repById[u] += amount;
		if (!_isGood(repById[u])) {
			bountyById[u] = bounty_credits_per_bad_rep * (neutral_rep - repById[u]);
		}
	}
	}

	function _decreaseRep(uint256 u, uint256 amount) internal {
		if (repById[u] >= amount) {
			repById[u] -= amount;
		} else {
			repById[u] = 0;
		}
		if (!_isGood(repById[u])) {
			bountyById[u] = bounty_credits_per_bad_rep * (neutral_rep - repById[u]);
		}
	}



	
	



	function fightPirates() public {
		
		uint256 u = _user(msg.sender);
		uint256 win = _fightNPC(locationById[u]);
		if (win) {
			_increaseRep(u,10);
		} else {
			_increaseRep(u,1);
		}
	}

	function huntInnocents() public {
		uint256 u = _user(msg.sender);
		uint256 win = _fightNPC(locationById[u]);
		if (win) {
			_decreaseRep(u,1);
		} else {
			_decreaseRep(u,10);
		}
	}

	// ------------------------------------------------------------------------------
	// Colonists resources #9
	uint256 rep_penalty_for_murder = 0;
	function _killColonists(address user, uint256 amount) internal {
		uint256 u = _user(user);
		resources.burn(user,9,amount);
		_decreaseRep(u,amount*rep_penalty_for_murder);
	}

	function killColonists(uint256 amount) public {
		_killColonists(msg.sender,amount);
	}


	function stealFromSpaceport(uint256 id, uint256 amount) public {
		uint256 u = _user(msg.sender);
		_atSpaceport(u);
		uint256 location = locationById[u];
		require(repById[u] < neutral_rep, "rep must be bad");
		_landOnBody(u);
		


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
		_hasSpacebase()
		// if you are in system with major Spaceport
		// burn existing ship
		// mint new ship

	}

	

	

constructor() {
		hasSpacebaseByLocation[0] = true;
		hasSpacebaseByLocation[13] = true;
		hasSpacebaseByLocation[42] = true;
		hasSpacebaseByLocation[69] = true;
		hasSpacebaseByLocation[137] = true;
		hasSpacebaseByLocation[420] = true;
		hasSpacebaseByLocation[42069] = true;
		hasSpacebaseByLocation[69420] = true;
		hasSpacebaseByLocation[137137] = true;
	}


}