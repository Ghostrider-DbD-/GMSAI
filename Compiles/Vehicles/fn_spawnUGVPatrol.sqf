/*
	GMSAI_fnc_spawnUGVPatrol 
	
	Purpose: spawn a UGV patrol that will go from location to location on the map hunting for players 

	Parameters: 
		_pos,  			center of the region in which the group will operate 
		_patrolType, 	"Map" or Region, where region would be am area proscribed by a marker defined by center, size and shape 
		_blackListed     positions to be avoided formated as [[x,y,z], radious]
		_center			the center of the patrol area or map center if the mode is "Map"
		_size			The size of the patrol area or mapsize if the mode is "Map" 
		_shape			Normally, this is a rectangle 
		_timeout		how quickly the group is sent back if it wanders out of the mission area.

	Returns: [_group,_ugv]
		_group ( the group spawned) 
		_ugv (the vehicle spawned)

	Copywrite 2020 by Ghostrider-GRG- 

	Notes:
		Locations: are any town, city etc defined at startup. 
*/
#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
		["_difficulty",0],			// Difficulty (integer) of the AI in the UGV
		["_className",""],		// ClassName of the UGV to spawn 
		["_pos",[0,0,0]],					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea",GMSAI_patrolRoads],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_blackListed",[]],  	// areas to avoid within the patrol region
		["_timeout",GMSAI_waypointTimeout], // The time that must elapse before the antistuck function takes over.]];
		["_markerDelete",false],
		["_spawnOnRoad",true]
];  	
if !(isClass(configFile >> "CfgVehicles" >> _className)) exitWith 
{
	[format["GMSAI_fnc_spawnUAVPatrol: invalid classname %1",_className]] call GMSAI_fnc_log;
	[grpNull,objNull]
};
private _ugvData = [];
//private _crewCount = [_className,false] call BIS_fnc_crewCount;
#define isDroneCrew true
/*
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
	GMSAI_chanceToGarisonBuilding,
	isDroneCrew
] call GMSCore_fnc_spawnInfantryGroup;
*/
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
//if !(isNull _group) then 
//{

	//[format["GMSAI_fnc_spawnUGVPatrol: spawning UGV %1 at %2",_className,_pos]] call GMSAI_fnc_log;
	_ugvData = [
		_className,
		//_group,	
		_pos, 
		0, 			// dir
		0,			// height
		0,			// disable 
		GMSA_removeFuel,		// remove fuel
		GMSAI_releaseVehiclesToPlayers,
		GMSAI_vehicleDeleteTimer,
		[GMSAI_fnc_vehicleHit],
		[GMSAI_fnc_vehicleKilled],
		GMSAI_baseSkill,
		GMSA_alertDistanceByDifficulty select _difficulty,
		GMSAI_intelligencebyDifficulty select _difficulty,
		GMSAI_unitDifficulty select (_difficulty),
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
	] call GMSCore_fnc_spawnUnmannedVehicle;
	_ugvData params["_group","_ugv"];
	//[format["GMSAI_fnc_spawnUGVPatrol: Data returned = _ugvData %1 | _group %2 | _ugv %3",_ugvData,_group,_ugv]] call GMSAI_fnc_log;
	if (isNull _group) then {deleteVehicle _ugv};
	if (isNull _ugv) then {deleteGroup _group};
	if (!(isNull _ugv)  && !(isNull _group)) then 
	{
		if (_patrolArea isEqualTo GMSAI_patrolRoads) then 
		{
			(driver _ugv) call GMSCore_fnc_initializeWaypointRoadsPatrol;
		} else {
			if (_spawnOnRoad) then 
			{
				private _road = [_pos, 75,[]] call BIS_fnc_nearestRoad;
				if !(_road isEqualTo objNull) then 
				{
					private _info = getRoadInfo _road;
					_ugv setPos (_info select 7);  // road segment start
				};				
			};
			//private _movetoPos = [[[getMarkerPos _patrolArea,markerSize _patrolArea]],[]/* add condition that the spawn is not near a trader*/] call BIS_fnc_randomPos;
			
			(driver _ugv) moveTo ((getPosATL _ugv) getPos [75,random(359)]);
			[
				_group,
				_blacklisted,
				_patrolArea,
				_timeout,
				GMSAI_chanceToGarisonBuilding,
				"vehicle",
				_markerDelete
			] call GMSCore_fnc_initializeWaypointsAreaPatrol;
		};
		[_ugv,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
		[_ugv,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
		if (GMSAI_disableInfrared) then {_ugv disableTIEquipment true};
		_group addVehicle _ugv;
	};
//  };
[_group, GMSAI_BlacklistedLocations] call GMSCore_fnc_setGroupBlacklist;
[_group,_ugv]
