/*
	GMSAI_fnc_monitorStaticPatrolAreas 

	Purpose: check static spawns without AI for players and spawn AI if players are in the patrol area. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		Need to add code to track respawns here.
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

#define areadDescriptorIndex 0
#define staticDescriptorIndex 1
#define areaActiveIndex 2 
#define spawnedGroupsIndex 3 
#define debugMarkersIndex 4 
#define respawnAtIndex 5 
#define timesSpawnedIndex 6
#define lastDetectedIndex 7 
#define deleteMarkerIndex 8
#define lastPingedPlayerIndex 9 

//if (isNIl "GMSAI_samInProgress") then {GMSAI_samInProgress = false};
if (GMSAI_samInProgress) exitWith {};
private _start = diag_tickTime;
//if (isNil "GMSAI_lastCheckStatics") then {GMSAI_lastCheckStatics = diag_tickTime};
//[format["_monitorStaticPatrolAreas (30): time %1 | time since last check %2 | count GMSAI_StaticSpawns = %3",diag_tickTime,diag_tickTime - GMSAI_lastCheckStatics,count GMSAI_StaticSpawns]] call GMSAI_fnc_log;
GMSAI_lastCheckStatics = diag_tickTime;

GMSAI_samInProgress = true;
for "_i" from 1 to (count GMSAI_StaticSpawns) do
{
	private _addBack = true; 
	if (_i > (count GMSAI_StaticSpawns)) exitWith {};
	private _area = GMSAI_StaticSpawns deleteAt 0;
	
	_area params["_patrolAreaMarker","_staticAiDescriptor","_areaActive","_spawnedGroups","_debugMarkers","_respawnAt","_timesSpawned","_lastDetected","_markerDelete","_lastPingedPlayer"];	
	
	//  params["_unitsPerGroup","_difficulty","_chance","_maxRespawns","_respawnTime", "_despawnTime","_types"];
	_staticAiDescriptor params["_unitsPerGroup","_difficulty","_chance","_maxRespawns","_respawnTime", "_despawnTime","_types"];
	//[format["_monitorStaticPatrolAreas: _staticAIDescriptor = %1",_staticAIDescriptor]] call GMSAI_fnc_log;
		
	if (_respawnAt == -1) then {_area set[respawnAtIndex,diag_tickTime + GMSAI_staticTriggerTime]};
	private _triggerAt = GMSAI_staticRespawnTime;
	if (_areaActive) then 
	{
		private _deactivate = false;
		private _configureRespawn = false;
		private _players = allPlayers inAreaArray _patrolAreaMarker;
		private _aliveGroups = [];
		{
			private _group = _x;
			if (!(isNull _group) && (({alive _x} count (units _group)) > 0)) then 
			{
				_aliveGroups pushBack _group;
			};
		} forEach _spawnedGroups;
		// Handle the case in which the area has no players and despawn AI after a certain interval then configure the area to be triggered again.	
		if (_players isEqualTo []) then 
		{
			if (diag_tickTime > (_lastDetected + _despawnTime)) then 
			{	
				{[_x] call GMSCore_fnc_destroyVehicleAndCrew;} forEach _aliveGroups;
				{
					//[format["_monitorStaticPatrolAreas: deleting marker %1",_x]] call GMSAI_fnc_log;
					deleteMarker _x;
				} forEach _debugMarkers;				
				//[format["_monitorStaticPatrolAreas: despawning AI at %1 with despawnTime %2 and _markerDelete %3",diag_tickTime,_despawnTime,_markerDelete]] call GMSAI_fnc_log;
				if (_markerDelete) then {
					//[format["_monitorStaticPatrolAreas: deleting marker %1",_patrolAreaMarker]] call GMSAI_fnc_log;
					deleteMarker _patrolAreaMarker;
					_addBack = false;
				} else {				
					//diag_log format["monitorStaticPatrolAreas: deactivating %1",_patrolAreaMarker];
					_area set[areaActiveIndex,false];
					_area set[lastDetectedIndex,diag_tickTime];					
					_area set[respawnAtIndex, -1];
					_area set[spawnedGroupsIndex,[]];
					_area set[debugMarkersIndex,[]];
				};		
			};
		} else {
			if (_aliveGroups isEqualTo []) then
			{
				//diag_log format["monitorStaticPatrolAreas (86): _aliveGroups = %1 | _markerDelete %2",_aliveGroups,_markerDelete];
				if (_markerDelete) then {
					deleteMarker _patrolAreaMarker;
					_addBack = false;
				} else {				
					//[format["_monitorStaticPatrolAreas (91): configuring respawn for active area: Time %1 | _respawnTime %2 | typeName _respawnTime %3",diag_tickTime,_respawnTime, typeName _respawnTime]] call GMSAI_fnc_log;
					{deleteMarker _x} forEach _debugMarkers;
					_area set[areaActiveIndex,false];					
					_area set[lastDetectedIndex,diag_tickTime];	
					/*
					[format["_monitorStaticPatrolAreas (99): _respawnTime = %1 | typename _respawnTime %2",_respawnTime,typeName _respawnTime]] call GMSAI_fnc_log;
					if !(_respawnAt isEqualType 0) then {
						[format["Invalid Respawn Timer %1 Used for Area %2 || Default Respawn Timer of %3 was used",_respawnAt,_patrolAreaMarker,GMSAI_staticRespawnTime],"warning"] call GMSAI_fnc_log;
						_respawnAt = GMSAI_staticRespawnTime;
					};
					*/
					//private _respawnAt = diag_tickTime + _respawnTime;
					//[format["_monitorStaticPatrolAreas (100): configuring respawn for active area: _respawnAt = %1",_respawnAt]] call GMSAI_fnc_log;										
					_area set[respawnAtIndex, [_respawnAt] call GMSCore_fnc_getNumberFromRange];  
					_area set[spawnedGroupsIndex,[]];
					_area set[debugMarkersIndex,[]];
				};
			} else {
				_area set[lastDetectedIndex,diag_tickTime];
				if ((diag_tickTime - _lastPingedPlayer) > (180 + random(120))) then 				
				{
					private _targets = [];
					{
						private _groupTarget = [_x] call GMSCore_fnc_getHunt;
						if !(isNull _groupTarget) then 
						{
							_targets pushBackUnique _groupTarget;
							_players deleteAt (_players find _groupTarget);
						};
					} forEach _aliveGroups;
					{[format[selectRandom GMSAI_playerTargeted,name _x]] remoteExec ["GMSCore_fnc_huntedMessages",_x]} forEach _targets;
					{[format[selectRandom GMSAI_areaActive,name _x]] remoteExec ["GMSCore_fnc_huntedMessages",_x];} forEach _players;
					_area set [9,diag_tickTime];
				};		
			};
		};		
		if (_addBack) then {GMSAI_StaticSpawns pushBack _area};
		//[format["_monitorStaticPatrolAreas (120): GMSAI_StaticSpawns = %1",GMSAI_StaticSpawns]]
	};
	if !(_areaActive) then 
	{
		if (_timesSpawned >= _maxRespawns && _maxRespawns >= 0) then 
		{
			deleteMarker _patrolAreaMarker;
		} else {
			if (diag_tickTime > (_lastDetected + GMSAI_staticTriggerTime)) then 
			{
				if ((_timesSpawned < _maxRespawns) || (_maxRespawns == -1)) then
				{
					if (diag_tickTime > _respawnAt) then
					{
						if (random(1) < _chance) then
						{
							private _players = allPlayers inAreaArray _patrolAreaMarker;
							if (!(_players isEqualTo []) || (GMSAI_debug > 0)) then 						
							{
								_area set[areaActiveIndex,true];
								_area set[timesSpawnedIndex, _timesSpawned + 1];
								private _r = [
									_patrolAreaMarker,
									_unitsPerGroup,
									selectRandomWeighted _difficulty,
									_types,
									_players,
									_markerDelete
								] call GMSAI_fnc_spawnPatrolTypes;
								//[format["GMSAI_fnc_monitorStaticPatrolAreas: patrols spawned - _markerDelete %1 | area = %2 | result %3",_markerDelete,_patrolAreaMarker,_r]] call GMSAI_fnc_log;
								
								private _msg = selectRandom GMSAI_playerTriggered;
								//[format["_monitorStaticPatrolAreas: _msg %1 | count GMSAI_playerTriggered %2",_msg,count GMSAI_playerTriggered]] call GMSAI_fnc_log;
								{
									[format[_msg,name _x]] remoteExec ["GMSCore_fnc_huntedMessages",_x];
								} forEach _players;

								_area set [spawnedGroupsIndex, _r select 0];
								_area set [debugMarkersIndex,_r select 1];
								_area set [lastDetectedIndex,diag_tickTime];
								_area set [lastPingedPlayerIndex,diag_tickTime];
							};
						};
					} else {
						//diag_log format["_monitorActiveSpawns: can't respawn: time %1 | respawn time %2",diag_tickTime,_respawnAt];
					};
				};
			};
			GMSAI_StaticSpawns pushBack _area;
		};
	};
};
GMSAI_samInProgress = false;
//[format["monitorStaticSpawns<END>: elapsedTime = %1 | count GMSAI_StaticSpawns  %2  <END>: ",diag_tickTime - _start, count GMSAI_StaticSpawns]] call GMSAI_fnc_log;