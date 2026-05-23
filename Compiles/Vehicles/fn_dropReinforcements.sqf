/*
	GMSAI_fnc_dropReinforcements 

	Purpose: drop a group at a set location by parachutes. 

	Parameters: 
		_group, the group to be airdroped 
		_aircraft, the aircraft from which to release them 
		_target, the player targetd by these reinforcements 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params["_group","_aircraft","_target","_dropPos"];
//[[format["dropReinforcements called: _group = %1 | _aircraft = %2 | _target = %3 | _dropPos %4",_group,_aircraft,_target,_dropPos]]] call GMSAI_fnc_log;
_group setSpeedMode "LIMITED";
//uiSleep 10;
private _difficulty = selectRandomWeighted GMSAI_paratroopDifficulty;
private ["_m","_debugMarkers"];
// Use a small marker here to force the group to spawn in a small area
if (GMSAI_debug >= 1) then 
{
	_m = createMarker [format["paraGroup%1",random(1000000)],_dropPos];	
	_m setMarkerShape "RECTANGLE";
	_m setMarkerSize [30,30];
	_m setMarkerColor "Color5_FD_F";
	_m setMarkerAlpha 0.5;
	_m setMarkerBrush "GRID";
} else {
	_debugMarkers = [];
	_m = createMarkerLocal[format["paraGroup%1",random(1000000)],_dropPos];
	_m setMarkerShapeLocal "RECTANGLE";
	_m setMarkerSizeLocal [30,30];
};
/*
params[
	["_patrolAreaMarker",""],
	["_unitsPerGroup",0],
	["_difficulty",0],
	["_types",[]],
	["_players",[]],
	["_markerDelete",false]
];
*/
private _t = [
	_m,  // forces the spawner to ignore marker-related stuff like setting up the patrol 
	[GMSAI_numberParatroops] call GMSCore_fnc_getIntegerFromRange,
	_difficulty,
	[[GMSAI_infantry,[1],[]]],
	[],
	true
] call GMSAI_fnc_spawnPatrolTypes;

// GMSAI_fnc_spawnPatrolTypes returns an array: [_groups, _debugMarkers];
_paraGroup = (_t select 0) select 0;
_paraGroup setVariable["GMSAI_isParagropu",true];
_debugMarkers = _t select 1;
//[[format["dropReinforcements: _paraGroup %1 created and configured using area marker %2",_paraGroup,_m]]] call GMSAI_fnc_log;
// But we want the final patrol to be within a much larger region
if (GMSAI_debug >= 1) then 
{
	_m setMarkerSize [300,300];
} else {
	_m setMarkerSizeLocal [300,300];
};

[_paraGroup,_dropPos,_aircraft] call GMSCore_fnc_dropParatroops;
[_paraGroup,_target] call GMSCore_fnc_setHunt;
GMSAI_paratroopGroups pushBack _paraGroup;

//[[format["dropReinforcements: _group %1 AREA patrol configured",_paraGroup]]] call GMSAI_fnc_log;
#define respawnAt -1
#define timesSpawned 1
#define lastDetected diag_tickTime 
#define deletePatrolMarker true
#define areaActive true
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
[
	_m,
	GMSAI_dynamicSettings,
	areaActive,
	[_paraGroup],
	_debugMarkers,
	respawnAt,
	timesSpawned,
	lastDetected,
	deletePatrolMarker,
	GMSAI_paratroopRespawnTimer
] call GMSAI_fnc_addActiveSpawn;

//uiSleep 5;
// Now let's have the group start its patrol using the _target information we provided above
private _mode = _group getVariable["paradropMode",0];
private _wp = [_group,0];
private _wpPos = (getPosATL _aircraft) getPos[500, getDir _aircraft];
_wp setWPPos _wpPos;
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 0;
#define GMSAI_paradropMode "paradropMode"
#define droppedbyPatrolHeli 1 
#define calledInByUAV 2 
#define calledByUAVGroup "calledByGroup"
switch (_mode) do 
{
	case droppedbyPatrolHeli: {
		IF (GMSAI_paratroopGunship) THEN 
		{
			//  https://community.bistudio.com/wiki/BIS_fnc_stalk
			//  [stalker, stalked, refresh, radius, endCondition, endDestination] spawn BIS_fnc_stalk
			[_group, group _target] spawn {
				params["_group","_targetGroup"];
				while {
					[_group, _targetGroup] call BIS_fnc_stalk;
				} do {uiSleep 5};
				[_group,"disengage"] call GMSCore_fnc_setGroupBehavior;
				private _wp = [_group,0];
				private _wpPos = (getPosATL _aircraft) getPos[500, getDir _aircraft];
				_wp setWPPos _wpPos;
				_wp setWaypointStatements ["true","this call GMSCore_fnc_nextWaypointAreaPatrol;"];	
				_wp setWaypointType "MOVE";
				_wp setWaypointCompletionRadius 0;						
			};
		} else {
			[_group,"disengage"] call GMSCore_fnc_setGroupBehavior;
			private _wp = [_group,0];
			private _wpPos = (getPosATL _aircraft) getPos[100, getDir _aircraft];
			//[format["GMSAI_fnc_dropReinforcements: handling case of !gunship - _group %1 located at %3 disengaging and moving to _pos %2",_group,_wpPos,position _aircraft]] call GMSCore_fnc_log;
			_wp setWPPos _wpPos;
			_wp setWaypointStatements ["true","this call GMSCore_fnc_nextWaypointAreaPatrol;"];	
			_wp setWaypointType "MOVE";
			_wp setWaypointCompletionRadius 0;			
		};
	};
	case calledInByUAV: {_wp setWaypointStatements ["true","this call GMSAI_fnc_destroyWaypoint;"];};
};
_group setCurrentWaypoint _wp;

// Clear the flag on the group that spotted the _target which could be a heli crew or UAV.
// If a UAV spotted the crew its crew group will be stored and can be used to identify it.
private _calledByGroup = _group getVariable[calledByUAVGroup,grpNull];
//diag_log format["_dropReinforcements: _calledByGroup = %1",_calledByGroup];
if (isNull _calledByGroup) then 
{
	_group setVariable[GMSAI_paraInbound,false];
} else {
	_calledByGroup setVariable[GMSAI_paraInbound,false];
};




