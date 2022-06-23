/*
	GMSAI_fnc_spawnVehiclePatrol 
	Purpose: spawn a vehicle patrol that will go from location to location on the map or patrols a proscribed area hunting for players 
	
		Parameters: 
		_pos,  			center of the region in which the group will operate 
		_patrolType, 	"Map" or Region, where region would be am area proscribed by a marker defined by center, size and shape 
		_blackListed     positions to be avoided formated as [[x,y,z], radious]
		_center			the center of the patrol area or map center if the mode is "Map"
		_size			The size of the patrol area or mapsize if the mode is "Map" 
		_shape			Normally, this is a rectangle 
		_timeout		how quickly the group is sent back if it wanders out of the mission area.
		_isSubmersible  true/false  When true, and if the vehicle is on or in water, it will be set to move below the surface 
		
	Returns: [_group,_vehicle]
		_group ( the group spawned) 
		_vehicle (the vehicle spawned)

	Copywrite 2020 by Ghostrider-GRG- 

	Notes:
		Locations: are any town, city etc defined at startup.
		when '_isSubmersible == true the script will assume it should set swimInDepth as well
		Locations: are any town, city etc defined at startup. 
 
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
		"_difficulty",
		"_classname",			// className of vehicle to spawn
		"_pos",					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea",GMSAI_patrolRoads],  // "Map" will direct the vehicle to patrol the entire map, "Region", a smaller portion of the map.
		["_blackListed",[]],  	// areas to avoid within the patrol region
							 	// These parameters are ignored if the vehicle will patrol the entire map.
		["_timeout",GMSAI_waypointTimeout],		// The time that must elapse before the antistuck function takes over.]];
		["_isSubmersible",false],  //  when true, the swimIndepth will be set to (ASL - AGL)/2
		["_markerDelete",false],
		["_spawnOnRoad",true]
	];  

private _calcCrewCount = [GMSAI_patroVehicleCrewCount] call GMSCore_fnc_getIntegerFromRange;
private _vehCrewLimit = ([_className,true]  call BIS_fnc_crewCount);
private _crewCount = _calcCrewCount min _vehCrewLimit;
//[format["GMSAI_fnc_spawnVehiclePatrol: vehicle %1 | _calcCrewCount %2 | _vehCrewLimit %3",_className,_calcCrewCount,_vehCrewLimit]] call GMSAI_fnc_log;
private _vehicle = objNull;
_pos = [_pos select 0, _pos select 1, 0];
private _group = [
	_pos,// why not the location of the road
	[_crewCount] call GMSCore_fnc_getIntegerFromRange,
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
		["_className",""], // Clasname of vehicle to be spawned
		["_spawnPos",[0,0,0]],  //  selfevident
		["_dir",0],  //  selfevident
		["_height",0],		
		["_disable",0],  // this should be disabled turrets that we remove ammo from
		["_removeFuel",false],  // when true fuel is removed from the vehicle
		["_releaseToPlayers",true],
		["_deleteTimer",300],
		["_vehHitCode",[]],
		["_vehKilledCode",[]]
	];
	*/
	
if !(isNull _group) then 
{
	_vehicle = [
		_className,
		_pos,
		random(360),
		0,  /// Height can be 0 for a vehicle patroling on land
		0,	// value for damage applied to vehicle - leave for now at 0
		GMSA_removeFuel,
		GMSAI_releaseVehiclesToPlayers, 
		GMSAI_vehicleDeleteTimer,
		[GMSAI_fnc_vehicleHit],
		[GMSAI_fnc_vehicleKilled]	   
	] call GMSCore_fnc_spawnPatrolVehicle;  // this removes inventory, sets all key variables and adds event handlers
	
	if !(isNull _vehicle) then 
	{
		//diag_log format["GMSAI_fnc_spawnVehiclePatrol: _vehicle = %1 | _group = %2 | _deleteMarker = %3",_vehicle,_group,_markerDelete];
		[_vehicle,_group] call GMSCore_fnc_loadVehicleCrew;
		//diag_log format["GMSAI_fnc_spawnVehiclePatrol: crew _vehicle = %1 ", crew _vehicle];
		[_group,GMSAI_unitDifficulty select _difficulty] call GMSCore_fnc_setupGroupSkills;
		[_group, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
		[_group,_difficulty,GMSAI_money] call GMSCore_fnc_setupGroupMoney;
		if (_isSubmersible) then 
		{
			// set the swimindept to 1/2 the height of surface level above ground leve of the driver of the vehicle
			_driver swimInDepth (((getPosATL(ASLtoATL(getPosASL(driver _vehicle))) ) select 2)/2);
		};
		//diag_log format["GMSAI_fnc_spawnVehiclePatrol: _patrolArea = %1",_patrolArea];
		if (_patrolArea isEqualTo GMSAI_patrolRoads) then 
		{
			(driver _vehicle) call GMSCore_fnc_initializeWaypointRoadsPatrol;
		} else {
			if (_spawnOnRoad) then 
			{
				private _road = [_pos, 75,[]] call BIS_fnc_nearestRoad;
				if !(_road isEqualTo objNull) then 
				{
					private _info = getRoadInfo _road;
					private _segmentPos = _info select 7;
					_vehicle setPos [_segmentPos select 0, _segmentPos select 1, 0];  // road segment start
				};
			};
			private _movetoPos = [[[getMarkerPos _patrolArea,markerSize _patrolArea]],[]/* add condition that the spawn is not near a trader*/] call BIS_fnc_randomPos;
			(driver _vehicle) moveTo _movetoPos;
			[
				_group,
				_blacklisted,
				_patrolArea,
				_timeout,
				GMSAI_chanceToGarisonBuilding,
				"vehicle",
				_markerDelete
			] call GMSCore_fnc_initializeWaypointsAreaPatrol;
			// Note: the group is added to the list of groups monitored by GMS. Empty groups are deleted, 'stuck' groups are identified.
		};
		[_vehicle,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
		[_vehicle,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
		if (GMSAI_disableInfrared) then {_vehicle disableTIEquipment true};
		//[format["GMSAI_fnc_spawnVehiclePatrol: _group %1 | _vehicle %2 | assignedVehicle driver _vehicle = %3",_group, _vehicle, assignedVehicle (driver _vehicle)]]
		//_vehicle addEventHandler ["GetOut", GMSAI_fnc_vehicleGetOut];
	} else {
		[_group] call GMSCore_fnc_despawnInfantryGroup;
		_group = grpNull;
	};
};
GMSAI_vehicleGroups pushBack _group;
[_group, GMSAI_BlacklistedLocations] call GMSCore_fnc_setGroupBlacklist;
[_group,_vehicle]
