/*	
	GMSAI_fnc_addActiveSpawn

	Purpose: add a spawn initialized elsewhere for monitoring purposes
	
	Parameters: 
		_areaDescriptor,  Information about the map marker/location, size etc
		_staticAiDescriptor, information about the AI to be spawned 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		TODO: need to confirm the nature of the two parameters but I think the description of them is correct	
		TODO: Is this used?
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

params[
	["_patrolArea",""],
	["_aiSettings",[]],
	['_active',true],
	["_groups",[]],
	["_debugMarkers",[]],
	["_respawnAt",-1],
	["_timesSpawned",1],
	["_lastDetected",diag_tickTime],
	["_deleteMarker",false],
	["_respawnTimer",1000000]
];
{[format["GMSAI_fnc_addActiveSpawn: _this %1 = %2",_forEachIndex,_this select _forEachIndex]] call GMSAI_fnc_log;};
GMSAI_StaticSpawns pushBack [
	_patrolArea,
	_aiSettings,
	_active,
	_groups,
	_debugMarkers,
	_respawnAt,
	_timesSpawned,
	_lastDetected,
	_deleteMarker,
	_respawnTimer
];