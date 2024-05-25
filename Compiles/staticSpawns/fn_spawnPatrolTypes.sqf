/*
	GMSAI_fnc_spawnPatrolTypes

	Purpose: spawn patrols within an area that are infantry, vehicle, air, UAV or UGV based on parameters.

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		Need to add code to track respawns here.

	TODO: Add check for UAV/UGV
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
	["_patrolAreaMarker",""],
	["_unitsPerGroup",0],
	["_difficulty",0],
	["_types",[]],
	["_players",[]],
	["_markerDelete",false]
];

private _spawnedGroups = [];
private _debugMarkers = [];
//[format["GMSAI_fnc_spawnPatrolTypes: _markerDelete = %1",_markerDelete]] call GMSAI_fnc_log;
{
	_x params["_groupType","_groups","_types"];
	//[format["GMSAI_fnc_spawnPatrolTypes: _groupType %1 | _groups %2 | _types %3",_groupType,_groups,_types]] call GMSAI_fnc_log;
	private "_group";
	// params["_areaMarker","_noPositionsToFind",["_units",[]],["_separation",100],["_blackList",[]]];
	private _locations = [
			_patrolAreaMarker,
			[_groups] call GMSCore_fnc_getIntegerFromRange,
			_players,
			10,
			["water"]						
	] call GMSCore_fnc_findRandomPosWithinArea;

	{
		private _groupSpawnPos = _x;
		switch (_groupType) do 
		{
			case GMSAI_infantry: {
				//diag_log format["spawnPatrolTypes: case Infantry"];
				_group = [
					[_difficulty] call GMSCore_fnc_getIntegerFromRange,										
					_groupSpawnPos,
					[_unitsPerGroup] call GMSCore_fnc_getIntegerFromRange,
					_patrolAreaMarker,
					_markerDelete  // always use false: we will delete the marker(s) separately for these more complex patrols
				] call GMSAI_fnc_spawnInfantryGroup;
				GMSAI_infantryGroups pushBack _group;
			};
			case GMSAI_vehicle: {
				//diag_log format["spawnPatrolTypes: case vehicle: _difficulty = %1",_difficulty];
				if (_types isEqualTo []) then {_types = GMSAI_patrolVehicles};
				private _vehDiff = [_difficulty] call GMSCore_fnc_getIntegerFromRange;
				//diag_log format["spawnPatrolTypes: case vehicle:",_vehDiff];
				private _t = [
					_vehDiff,
					selectRandomWeighted _types,
					_groupSpawnPos,
					_patrolAreaMarker,
					GMSAI_BlacklistedLocations,
					GMSAI_waypointTimeout,
					_markerDelete,
					true // no reason to spawnOnRoads for these patrols
				] call GMSAI_fnc_spawnVehiclePatrol;
				_group = _t select 0;		
			};
			case GMSAI_ugv: {
				//diag_log format["spawnPatrolTypes: case UGV"];
				if (_types isEqualTo []) then {_types = GMSAI_UGVtypes};
				private _t = [
					[_difficulty] call GMSCore_fnc_getIntegerFromRange,	
					selectRandomWeighted _types,														
					_groupSpawnPos,
					_patrolAreaMarker,
					[],
					300,					
					_markerDelete,  // always use false: we will delete the marker(s) separately for these more complex patrols
					true  // force spawning on roads
				] call GMSAI_fnc_spawnUGVPatrol;
				_group = _t select 0;
				[format["GMSAI_fnc_spawnPatrolTypes: spawned UGV patrol with group %1 | count GMSAI_UGVGroups %2",_group, GMSAI_UGVGroups]] call GMSAI_fnc_log;
			};
			case GMSAI_uav: {
				//diag_log format["spawnPatrolTypes: case UAV"];
				if (_types isEqualTo []) then {_types = GMSAI_UAVTypes};
				private _t = [
					[_difficulty] call GMSCore_fnc_getIntegerFromRange,
					selectRandomWeighted _types,
					_groupSpawnPos,
					_patrolAreaMarker,
					[],
					300,
					_markerDelete  // always use false: we will delete the marker(s) separately for these more complex patrols
				] call GMSAI_fnc_spawnUAVPatrol;
				_group = _t select 0;			
			};
			case GMSAI_air: {
				//diag_log format["spawnPatrolTypes: case AIR: _difficulty = %1",_difficulty];
				if (_types isEqualTo []) then {_types = GMSAI_aircraftTypes};
				private _airDiff = [_difficulty] call GMSCore_fnc_getIntegerFromRange;
				//diag_log format["spawnPatrolTypes: case AIR:",_airDiff];
				private _t = [
					_airDiff,										
					selectRandomWeighted _types,					
					_groupSpawnPos,
					_patrolAreaMarker,
					[],
					300,
					_markerDelete  // always use false: we will delete the marker(s) separately for these more complex patrols
				] call GMSAI_fnc_spawnAircraftPatrol;
				_group = _t select 0;			
			};
		};
		//[format["_fnc_spawnPatrolTypes: _group spawned = %1",_group]] call GMSAI_fnc_log;
		if !(isNull _group) then 
		{
			if (GMSAI_debug >= 1) then {
				private _m = ([_group] call GMSAI_fnc_addGroupDebugMarker);
				_debugMarkers pushBack _m;
			};
			_spawnedGroups pushBack _group;
		};
	} forEach _locations;
} forEach _types;
//diag_log format["spawnPatrolTypes: _spawnedGroups %1 | _debugMarkers %2", _spawnedGroups,_debugMarkers];
[_spawnedGroups,_debugMarkers]
