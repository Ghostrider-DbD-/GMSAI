/*
	GMSAI_fnc_spawnPatrolTypes

	Purpose: spawn patrols within an area that are infantry, vehicle, air, UAV or UGV based on parameters.

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		Need to add code to track respawns here.

	TODO: Does not yet handle shps or submersibles
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
	["_patrolAreaMarker",""],
	["_unitsPerGroup",0],
	["_difficulty",0],
	["_types",[]],
	["_players",[]],
	["_markerDelete",false]
];

//private _vehicleTypes = +_types;
private _spawnedGroups = [];
private _debugMarkers = [];
private "_group";
//[format["GMSAI_fnc_spawnPatrolTypes: _markerDelete = %1",_markerDelete]] call GMSAI_fnc_log;
{
	_x params["_groupType","_groups","_types"];
	//[format["GMSAI_fnc_spawnPatrolTypes: _groupType %1 | _groups %2 | _types %3",_groupType,_groups,_types]] call GMSAI_fnc_log;

	private _spawnOnWater = if (surfaceIsWater (markerPos _patrolAreaMarker)) then {true} else {false};
	//params[["_areaMarker",""],["_noPositionsToFind",0],["_testIsAllowed", true],["_allowWater", false]];		
	private _locations = [
			_patrolAreaMarker,
			[_groups] call GMSCore_fnc_getIntegerFromRange,
			true,
			_spawnOnWater
	] call GMSCore_fnc_findRandomPosWithinArea;

	{
		private _groupSpawnPos = _x;
		switch (_groupType) do 
		{
			case GMSAI_infantry: {
				diag_log format["spawnPatrolTypes: case Infantry"];
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
				diag_log format["spawnPatrolTypes: case vehicle"];
				private _vehList = if (_types isEqualTo []) then {GMSAI_patrolVehicles} else {_types};
				if !(_vehList isEqualTo []) then {
				diag_log format["spawnPatrolTypes: _vehType selected = %1 | _ugv %2", _vehType];
					_vehType = selectRandomWeighted _vehList;
					private _vehDiff = [_difficulty] call GMSCore_fnc_getIntegerFromRange;
					[format["_spanPatrolTypes-GMSAI_vehicle: _vehType %1 | _groupSpawnPos %2", _vehType, _groupSpawnPos]] call GMSAI_fnc_log;
					private _t = [
						_vehDiff,
						_vehType,
						_groupSpawnPos,
						_patrolAreaMarker,
						_markerDelete			
					] call GMSAI_fnc_spawnVehiclePatrol;
					//[format["_spawnPatrolTypes: GMSAI_vehicle: _t = %1", _t]] call GMSAI_fnc_log;
					_group = _t select 0;
				} else {
					_group = grpNull;
					[format["_spawnPatroTypes: GMSAI_patrolVehicles and the area-specific list of vehicles are both empty for area %1", _patrolAreaMarker]] call GMSAI_fnc_log;
				};
			};
			case GMSAI_ugv: {
				diag_log format["spawnPatrolTypes: case UGV"];
				private _ugvList = if (_types isEqualTo []) then {GMSAI_UGVtypes} else {_types};
				if !(_ugvList isEqualTo []) then {
					private _ugv = selectRandomWeighted _ugvList;
					private _t = [
						[_difficulty] call GMSCore_fnc_getIntegerFromRange,	
						_ugv,		
						_groupSpawnPos,
						_patrolAreaMarker,
						_markerDelete,  // always use false: we will delete the marker(s) separately for these more complex patrols
						true  // force spawning on roads
					] call GMSAI_fnc_spawnUGVPatrol;
					_group = _t select 0;
				} else {
					_group = grpNull;
					[format["_spawnPatroTypes: GMSAI_UGVtypes and the area-specific list of vehicles are both empty  for area %1", _patrolAreaMarker]] call GMSAI_fnc_log;
				};
			};
			case GMSAI_uav: {
				diag_log format["spawnPatrolTypes: case UAV"];
				private _uavList = 	if (_types isEqualTo []) then {GMSAI_UAVTypes} else {_types};
				if !(_uavList isEqualTo []) then {
					private _uav = selectRandomWeighted _uavList;
					private _t = [
						[_difficulty] call GMSCore_fnc_getIntegerFromRange,
						_uav,
						_groupSpawnPos,
						_patrolAreaMarker,
						//[],
						300,
						_markerDelete  // always use false: we will delete the marker(s) separately for these more complex patrols
					] call GMSAI_fnc_spawnUAVPatrol;
					_group = _t select 0;		
				} else { 
					_group = grpNull;
					[format["_spawnPatroTypes: No UAV Spawned-GMSAI_UAVTypes and the area-specific list of vehicles are both empty  for area %1", _patrolAreaMarker]] call GMSAI_fnc_log;
				};
			};
			case GMSAI_air: {
				diag_log format["spawnPatrolTypes: case AIR"];
				private _airDiff = [_difficulty] call GMSCore_fnc_getIntegerFromRange;
				_pos = [_patrolAreaMarker, []] call GMSAI_fnc_findPositionAirPatrol;
				private _aircraftList = if (_types isEqualTo []) then {GMSAI_aircraftTypes} else {_types};
				if !(_aircraftList isEqualTo []) then {
					private _aircraft = selectRandomWeighted _aircraftList;
					private _t = [
						_airDiff,										
						_aircraft,					
						_pos,
						_patrolAreaMarker,
						_markerDelete  // always use false: we will delete the marker(s) separately for these more complex patrols
					] call GMSAI_fnc_spawnAircraftPatrol;
					_group = _t select 0;		
				} else { 
					_group = grpNull;
					[format["_spawnPatroTypes:  No aircraft Spawned - GMSAI_aircraftTypes and the area-specific list of vehicles are both empty  for area %1", _patrolAreaMarker]] call GMSAI_fnc_log;					
				};
			};
		};
		//[format["_fnc_spawnPatrolTypes: _group spawned = %1",_group]] call GMSAI_fnc_log;
		if !(isNull _group) then 
		{
			_spawnedGroups pushBack _group;
		};
	} forEach _locations;
} forEach _types;
diag_log format["spawnPatrolTypes: _spawnedGroups %1 | _debugMarkers %2", _spawnedGroups,_debugMarkers];
[_spawnedGroups,_debugMarkers]
