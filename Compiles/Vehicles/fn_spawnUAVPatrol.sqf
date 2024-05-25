	
/*
	GMSAI_fnc_spawnUAVPatrol 
	Purpose: spawn a UAV patrol that will go from location to location on the map hunting for players 

	Parameters: 
	Parameters: 
		_pos, position to spawn chopper 
		_patrolArea - can be "Map" or "Region". "Region will respect the boundaries of a map marker while Map will patrol the entire map. 
		_blackListed - areas to avoid formated as [[x,y,z],radius]
		_timeout - how long to wait before deciding the chopper is 'stuck'

	Returns: [
		_group, the group spawned to man the heli 
		_uav, the UAV spawned selected by selectRandomWeighted GMSAI_aircraftTypes,  
	]

	Copywrite 2020 by Ghostrider-GRG-

	Notes: 
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp"  

params[
		"_difficulty",
		"_className",				// classname of the drone to use
		"_pos",					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea","Map"],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_blackListed",[]],  	// areas to avoid within the patrol region
		["_timeout",GMSAI_waypointTimeout],  		// The time that must elapse before the antistuck function takes over.]];
		["_markerDelete",false]
];

private _uav = objNull;
private _group = grpNull; 
try {
	if !(isClass(configFile >> "CfgVehicles" >> _className)) throw -3;
	private _crewCount = [_className,false]  call BIS_fnc_crewCount;
	
	_group = [
		_pos,
		_crewCount,
		GMSCore_side,
		GMSAI_baseSkill,
		GMSA_alertDistanceByDifficulty select _difficulty,
		GMSAI_intelligencebyDifficulty select _difficulty,
		GMSAI_bodyDeleteTimer,
		GMSAI_maxReloadsInfantry,
		GMSAI_launcherCleanup,
		GMSAI_removeNVG,
		GMSAI_minDamageForSelfHeal,
		GMSAI_maxHeals,
		GMSAI_unitSmokeShell,
		[GMSAI_fnc_unitHit],
		[GMSAI_fnc_unitKilled],
		GMSAI_chanceToGarisonBuilding
	] call GMSCore_fnc_spawnInfantryGroup;

	if (isNull _group) throw -2;	

	[_group,GMSAI_unitDifficulty select (_difficulty)] call GMSCore_fnc_setupGroupSkills;
	[_group, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
	//[_group,_difficulty,GMSAI_money] call GMSCore_fnc_setupGroupMoney;
	_uav = [
		_className,
		_group,	
		_pos, 
		0, 			// dir
		300,		// height
		0,			// disable 
		GMSA_removeFuel,		// remove fuel
		GMSAI_releaseVehiclesToPlayers,
		GMSAI_vehicleDeleteTimer,
		[GMSAI_fnc_vehicleHit],
		[GMSAI_fnc_vehicleKilled]	
	] call GMSCore_fnc_spawnPatrolUAV;	

	if (isNull _uav) throw -1;
	
	[
		_group,
		_blacklisted,
		_patrolArea,
		_timeout,
		GMSAI_chanceToGarisonBuilding,
		"air",
		_markerDelete
	] call GMSCore_fnc_initializeWaypointsAreaPatrol;
	[_uav,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
	[_uav,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
	if (GMSAI_disableInfrared) then {_uav disableTIEquipment true};	
	[_group, GMSAI_BlacklistedLocations] call GMSCore_fnc_setGroupBlacklist;	
}

catch 
{ 
	switch (_exception) do {
		case -3: {
			[format["_spawnUAVPatrol: invalid classname %1 passed",_className],'warning'] call GMSAI_fnc_log;
		};

		case -2: {
			[format["_spawnUAVPatrol: GMSCore_fnc_spawnInfantryGroup returned grpNull"],'warning'] call GMSAI_fnc_log;
		};

		case -1: {
			[format["_spawnUAVPatrol:  GMSCore_fnc_spawnPatrolUAV return objNull"],'warning'] call GMSAI_fnc_log;
			[_group] call GMSCore_fnc_despawnInfantryGroup;
			_group = grpNull;			
		};
	};
}; 
//[format["_spawnUAVPatrol:  GMSCore_fnc_spawnPatrolUAV returning _group %1 | _uav %2",_group, _uav]] call GMSAI_fnc_log;
[_group,_uav]
