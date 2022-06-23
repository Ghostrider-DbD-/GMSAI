	
/*
	GMSAI_fnc_spawnUAVPatrol 
	Purpose: spawn a UAV patrol that will go from location to location on the map hunting for players 

	Parameters: 
	Parameters: 
		_pos, position to spawn chopper 
		_patrolArea - can be "Map" or "Region". "Region will respect the boundaries of a map marker while Map will patrol the entire map. 
		_blackListed - areas to avoid formated as [[x,y,z],radius]
		_center, center of the area, either mapCenter of center of the patrol area 
		_size, size of the area to be patroled, either mapSize or dimension of the patrol area 
		_shape, shap of the patrol area (rectangle by default)
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
		"_droneClassName",				// classname of the drone to use
		"_pos",					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea","Map"],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_blackListed",[]],  	// areas to avoid within the patrol region
		["_timeout",GMSAI_waypointTimeout],  		// The time that must elapse before the antistuck function takes over.]];
		["_markerDelete",false]
];

if !(isClass(configFile >> "CfgVehicles" >> _droneClassName)) exitWith 
{
	[format["GMSAI_fnc_spawnUAVPatrol: invalid classname %1",_droneClassname]] call GMSAI_fnc_log;
	[grpNull,objNull]
};
private _crewCount = [_droneClassName,false]  call BIS_fnc_crewCount;
private _uav = objNull;
private _group = [
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
/*
params[
	["_className",""],	
	["_group",grpNull],
	["_pos",[0,0,0]],
	["_dir",0],
	["_height",0],	
	["_disable",0],  // a value greater than 0 will increase damage of the object to that level; set to 1.0 to disable turretes, 0.7 to neutralize vehciles
	["_removeFuel",false],  // when true fuel is removed from the vehicle
	["_releaseToPlayers",true],
	["_deleteTimer",300],
	["_vehHitCode",[]],
	["_vehKilledCode",[]]
];
*/
if !(isNull _group) then 
{
	[_group,GMSAI_unitDifficulty select (_difficulty)] call GMSCore_fnc_setupGroupSkills;
	[_group, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
	[_group,_difficulty,GMSAI_money] call GMSCore_fnc_setupGroupMoney;
	_uav = [
		_droneClassName,
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

	if !(isNull _uav) then 
	{
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
		_group addVehicle _uav;
	} else {
		[_group] call GMSCore_fnc_despawnInfantryGroup;
		_group = grpNull;
	};
};
[_group, GMSAI_BlacklistedLocations] call GMSCore_fnc_setGroupBlacklist;
[_group,_uav]
