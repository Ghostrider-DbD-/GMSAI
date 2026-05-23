/*
	GMSAI_fnc_dynamicAIManager 

	Purpose: handles spawning of dynamic AI. 
			These spawn with the intent of hunting a specific player but can hunt others in the area if that player is gone. 

	Parameters: None 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
#define GMSAI_dynamicSpawnDistance 300
#define GMSAI_dynamicDespawnDistance 400
#define GMSAI_alertAIDistance 300
#define GMSAI_dynamicRespawnAt "respawnAt"
#define GMSAI_maxDynamicRespawns "respawns"
#define GMSAI_dynamicGroup "dynGroup"
#define GMSAI_dynRespawns "dynRespawns"

if !(GMSAI_useDynamicSpawns) exitWith { [format["GMSAI_fnc_dynamicAIManager Disabled"]] call GMSAI_fnc_log };
//[format["GMSAI_fnc_dynamicAIMonitor: allPlayers = %1",allPlayers]] call GMSAI_fnc_log;
if (( count GMSAI_dynamicGroups) >= GMSAI_maxActiveDynamicSpawns) exitWith {if (GMSAI_debug >0) then {[format["GMSAI_fnc_dynamicAIManager: Max dynamic spawns reached"]] call GMSAI_fnc_log}};
{
	private _player = _x;
	if !(alive _player) then {
		if (GMSAI_debug >1) then {[format["GMSAI_fnc_dynamicAIMonitor: dead player player %1 encountered spawn aborted",_player]] call GMSAI_fnc_log};
	} else {
		//diag_log format["GMSAI_fnc_dynamicAIMonitor: nearestGMSAI = %1",([position _player,500] call GMSCore_fnc_nearestGMSAI)];
		private _linkedGroups = _player getVariable [GMSAI_dynamicGroup,[]];

		private _activeGroups = [];
		{
			private _group = _x;
			if (({alive _x} count (units _group)) > 0) then {_activeGroups pushback _group} else {
				[_group] call GMSCore_fnc_addToGraveyardGroup; // Add the dead units to the graveyard group
				deleteGroup _group;
			};
		} forEach _linkedGroups;

		_player setVariable[GMSAI_dynamicGroup,_activeGroups];

		if !(_activeGroups isEqualTo []) exitWith 
		{
			//[format["GMSAI_fnc_dynamicAIMonitor: group %2 linked to player %1",_player, _activeGroups]] call GMSAI_fnc_log;
			private _lastPinged = _player getVariable["DYN_lastPinged",0];
			// Do the messaging at somewhat random intervals
			if ((diag_tickTime - _lastPinged) > (180 + random(120))) then 
			{
				private _msg = selectRandom GMSAI_dynamicSpawned;
				private _plr = allPlayers select{_x distance player < 300};
				{[format[_msg,_player]]  remoteExec ["GMSCore_fnc_huntedMessages",_x]} forEach _plr;
				_player setVariable["DYN_lastPinged",diag_tickTime];
			};
		};
		
		if !(([getPosATL _player,500] call GMSCore_fnc_nearestGMSAI) isEqualTo []) exitWith 
		{
			if (GMSAI_debug > 1) then {[format["GMSAI_fnc_dynamicAIMonitor: AI Units found near player %1",_player]] call GMSAI_fnc_log};
		};
		
		private _respawns = _player getVariable[GMSAI_dynRespawns,0];
		private _respawnAt = _player getVariable [GMSAI_dynamicRespawnAt, -1];
		if (_respawnAt == -1) then 
		{
			_respawnAt = diag_tickTime + GMSAI_dynamicRespawnTime;  //  Use the trigger time here since this is not a respawn. Respawns occur only when the player has killed all AI in a region and remained in the region.
			_player setVariable[GMSAI_dynamicRespawnAt,_respawnAt];
		};		
		
		//diag_log format["GMSAI_fnc_dynamicAIManager: _respawnAt = %1 : curr Time %2",_respawnAt,diag_tickTime];

		private _lastLoc = _player getVariable[GMSAI_lastPlayerLocation,[]];
		if (_lastLoc isEqualTo []) then 
		{
			_lastLoc = getPosATL _player;
			_player setVariable[GMSAI_lastPlayerLocation,_lastLoc];		
		};

		private _lastLocTime = _player getVariable[GMSAI_lastPlayerLocationTime ,-1];
		if (_lastLocTime == -1) then 
		{
			_lastLocTime = diag_tickTime;
			_player setVariable[GMSAI_lastPlayerLocationTime,_lastLocTime];		
		};
		
		//private _stationary = false;
		if ((_lastLoc distance _player) > 300) exitWith // do not consider spawning if the player is on the move.
		{
			_lastLoc = getPosATL _player;
			_player setVariable[GMSAI_lastPlayerLocation,_lastLoc];
			_player setVariable[GMSAI_lastPlayerLocationTime,diag_tickTime];
			//[format["dynamicAIManager: Player %1 is on the move, no dynamic AI Spawn for now",name _player]] call GMSAI_fnc_log;
		};
		
		if (diag_tickTime < ( GMSAI_maxLoiterTime + _lastLocTime)) exitWith // if the player is hanging out in one area for more than 300 secs then lets spawn some baddies 
		{
			//_stationary = true;
			//[format["dynamicAIManager: Player %1 has not been stationary long enough to spawn AI", name _player]] call GMSAI_fnc_log;
		};
		
		if (diag_tickTime >_respawnAt) then 
		{
			//private _nearAI = [_player] call GMSCore_fnc_nearestGMSAI;

			if ([getPosATL _player,GMSAI_BlacklistedLocation,"_dynamicAIManager"] call GMSCore_fnc_isBlacklisted) then 
			{
				//[format["dynamicAIManager: player %1 in blacklisted area",_player]] call GMSAI_fnc_log;
			} else {
				if (GMSAI_maximumDynamicRespawns == -1 || _respawns <= GMSAI_maximumDynamicRespawns) then
				{
					if (vehicle _player == _player && random(1) < GMSAI_dynamicRandomChance) then
					{
						private _groups = [_player,GMSAI_dynamicRandomGroups] call GMSAI_fnc_spawnDynamicPatrols; 
						{GMSAI_dynamicGroups pushBack _x} forEach _groups;
						[format[selectRandom GMSAI_dynamicSpawned,_player]]  remoteExec ["GMSCore_fnc_huntedMessages",_player];
						_player setVariable["DYN_lastPinged",diag_tickTime];
						private _players = allPlayers select {(_player distance _x) < 300 && !(_x isEqualTo _player)};
						{[format[selectRandom GMSAI_areaActive,_x]] remoteExec ["GMSCore_fnc_huntedMessages",_x]} forEach _players;
						diag_log format["GMSAI_fnc_dynamicAIManager: spawnDynamicPatrols %1 for player %2",_groups,_player];
						_player setVariable [GMSAI_dynamicGroup , _groups];
						_player setVariable [GMSAI_dynRespawns, _respawns + 1];
						_player setVariable [GMSAI_dynamicRespawnAt,diag_tickTime + GMSAI_dynamicDespawnTime];
					};					
				};
			};
		} else {
			_player setVariable [GMSAI_dynamicRespawnAt,diag_tickTime + GMSAI_dynamicDespawnTime];
		};
	};
	//[format["dynamicAIManager: processed player %1 Name of %2",_forEachIndex,_player]] call GMSAI_fnc_log;
} forEach allPlayers;
