/*	
	GMSAI_fnc_addStaticspawn

	Purpose: add a spawn for infantry within a speciried area.
	
	Parameters: 
		_areaDescriptor,  Information about the map marker/location, size etc
		_staticAiDescriptor, information about the AI to be spawned 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-

	Notes:
	
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _addStaticAiSpawn: _this = %1",_this];
params[
	["_areaDescriptor",[]],  //  The marker that defines the boundaries of the area to be patrolled
	["_staticAiDescriptor",[]],  // parameters for AI to be spawned 
	["_deleteMarkeronNullGroup",true] // when true _areaDescriptor will be deleted if the group linked to it is null 
								// This should be false for most or all GMSAI calls 
								// the exception woudl be spawning a single group to patrol a single area
								// as the paratroops might do
	];

#define respawnAt 0
#define timesSpawned 0
#define debugMarker ""
#define areaActive false 
#define spawnedGroups []
#define debugMarkers [] 
#define lastDetected -1
#define lastPingedPlayer 0
// Note: the _locationEnabled variable is not useful beyond initialization
_staticAiDescriptor params["_unitsPerGroup","_difficulty","_chance","_maxRespawns","_respawnTime", "_despawnTime","_types"];

if (GMSAI_debug > 1) then {[format[" Adding static spawn with area descriptor of %1 | _deleteMarkeronNullGroup %2 | _staticAiDescriptor of %3",_areaDescriptor,_deleteMarkeronNullGroup,_staticAiDescriptor]] call GMSAI_fnc_log};

GMSAI_StaticSpawns pushBack [
	_areaDescriptor,
	[_unitsPerGroup,_difficulty,_chance,_maxRespawns,_respawnTime,_despawnTime,_types],
	areaActive,
	spawnedGroups,
	debugMarkers,  // group debug markers
	respawnAt,
	timesSpawned,
	lastDetected,
	_deleteMarkeronNullGroup,
	lastPingedPlayer
];
