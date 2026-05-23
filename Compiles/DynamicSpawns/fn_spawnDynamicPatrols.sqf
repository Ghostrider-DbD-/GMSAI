/*
	GMSAI_fnc_spawnDynamicPatrols

	Purpose: Spawn a dynamic patrol (patrol that moves within an area centered on a player that despawns when the player moves away or dies.

	Parameters: 
		_player: the player target of the patrol 
		_noGroup: number of groups of units for the patrol [1 group should be sufficient] 

	Returns: 
		array of groups spawned 

	Copyright 2020 Ghostrider-GRG-

	Notes: checks if other AI units are nearby and cools down if so to avoid having dynamics spawned in an area for more than one player.

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

params["_player","_noGroups"];
//diag_log format["GMSAI_fnc_spawnDynamicPatrols called with _player = %1 | _noGroups = %1",_player,_noGroups];
private _spawnPos = (getPosATL _player) getPos[GMSAI_dynamicSpawnDistance,random(359)];	
private _dynamicPatrolMarker = "";
if (GMSAI_debug >= 1) then 
{										
	_dynamicPatrolMarker = createMarker[format["GMSAI_dynamic%1",diag_tickTime],_spawnPos];
	_dynamicPatrolMarker setMarkerShape "RECTANGLE";
	_dynamicPatrolMarker setMarkerSize [GMSAI_dynamicSpawnDistance + 100,GMSAI_dynamicSpawnDistance + 100];
	_dynamicPatrolMarker setMarkerColor "COLORBLACK";
	_dynamicPatrolMarker setMarkerAlpha 0.4;
} else {
	_dynamicPatrolMarker = createMarkerLocal[format["GMSAI_dynamic%1",diag_tickTime],_spawnPos];
	_dynamicPatrolMarker setMarkerShapeLocal "RECTANGLE";
	_dynamicPatrolMarker setMarkerSizeLocal [GMSAI_dynamicSpawnDistance + 100,GMSAI_dynamicSpawnDistance + 100];
};
_player setVariable["DYN_marker",_dynamicPatrolMarker];
#define doMarkerDelete true
private _t = [
	_dynamicPatrolMarker,
	[GMSAI_dynamicRandomUnits] call GMSCore_fnc_getIntegerFromRange,
	selectRandomWeighted GMSAI_dynamicUnitsDifficulty,
	[[GMSAI_infantry,[1],[]]],
	allPlayers,
	doMarkerDelete
] call GMSAI_fnc_spawnPatrolTypes;
_t params ["_groups","_debugMarkers"];

//diag_log format["dynamicSpawns: _groups %1 | _debugMarkers %2",_groups,_debugMarkers];
{
	_group = _x;
	_group reveal[_player,0.1];	
	[_group,_player] call GMSCore_fnc_setHunt;

	[
		_group,
		GMSAI_BlacklistedLocations,
		_dynamicPatrolMarker,
		GMSAI_dynamicDespawnTime,
		GMSAI_chanceToGarisonBuilding,
		"infantry",
		doMarkerDelete
	] call GMSCore_fnc_initializeWaypointsAreaPatrol;

	//if (GMSAI_debug >= 1) then {_debugMarkers = [_group] call GMSAI_fnc_addGroupDebugMarker};
} forEach _groups;

/*
	["_patrolArea",""],
	["_aiSettings",[]],
	['_active',true],
	["_groups",[]],
	["_debugMarkers",[]],
	["_respawnAt",-1],
	["_timesSpawned",1],
	["_lastDetected",diag_tickTime],
	["_deleteMarker",false]
*/
#define respawnAt -1
#define timesSpawned 1
#define lastDetected diag_tickTime 
#define deletePatrolMarker true
#define areaActive true
[
	_dynamicPatrolMarker,
	GMSAI_dynamicSettings,
	areaActive,
	_groups,
	_debugMarkers,
	respawnAt,
	timesSpawned,
	lastDetected,
	deletePatrolMarker,
	GMSAI_dynamicRespawnTime
] call GMSAI_fnc_addActiveSpawn;
_groups
