/*
	GMSAI_fnc_spawnAircraftPatrol 
	
	Purpose: spawn a helicopter patrol that will go from location to location on the map hunting for players 
			Locations: are any town, city etc defined at startup. 

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
		_heli, the chopper spawned selected by selectRandomWeighted GMSAI_aircraftTypes,  
	]

	Copywrite 2020 by Ghostrider-GRG- 

	Notes: 
*/

#include "\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

params[
		["_difficulty",0],
		["_className",""],			// className of the aircraft to spawn
		["_pos",[0,0,0]],					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea","Map"],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_blackListed",[]],  	// areas to avoid within the patrol region
		["_timeout",GMSAI_waypointTimeout],  // The time that must elapse before the antistuck function takes over.]];
		["_markerDelete",false]
	];	

//private _difficulty = selectRandomWeighted GMSAI_aircraftPatrolDifficulty;

private _crewCount = (GMSAI_aircraftGunners + 2) min ([_className,false]  call BIS_fnc_crewCount);
private _aircraft = objNull;
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
if !(isNull _group) then 
{
	[_group,GMSAI_unitDifficulty select (_difficulty)] call GMSCore_fnc_setupGroupSkills;
	[_group, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
	[_group,_difficulty,GMSAI_money] call GMSCore_fnc_setupGroupMoney;
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
	//[format["_spawnAircraftPatrol: GMSAI_fnc_aircraftHit = %1",GMSAI_fnc_aircraftHit]] call GMSAI_fnc_log;
	 _aircraft = [
		_classname,
		_group,
		_pos,
		0,  	//  dir
		GMSAI_aircraftFlyinHeight,  	//  Height
		0,  	// Disable  
		GMSA_removeFuel,  // what level to set fuel when released to players
		GMSAI_releaseVehiclesToPlayers,
		GMSAI_vehicleDeleteTimer,
		[GMSAI_fnc_aircraftHit],
		[GMSAI_fnc_vehicleKilled]
	] call GMSCore_fnc_spawnPatrolAircraft;

	if !(isNull _aircraft) then 
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
		[_aircraft,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
		[_aircraft,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
		if (GMSAI_disableInfrared) then {_heli disableTIEquipment true};
		_group addVehicle _aircraft;
	} else {
		[_group] call GMSCore_fnc_despawnInfantryGroup;
		_group = grpNull;
	};
};
[_group, GMSAI_BlacklistedLocations] call GMSCore_fnc_setGroupBlacklist;
[_group,_aircraft]

