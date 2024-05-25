/*
	GMSAI_fnc_spawnInfantryGroup 

	Purpose: a core function to spawn a group and configure all of the parameters needed by GMS and GMSAI.
		These parameters are sorted by setVariable commands for the group. 

	Parameters:
		_spawnPos, where the group should be centered
		[_unit], number of units formated as [_min,_max], [_min] or _miin
		_difficulty, a number 1 to N corresponding to the difficulty level for the group. 
		_patrolMarker, the marker describing the area within which the group should patrol. Set this to "" to ignore all that.
	
	Returns: _group, the group that was spawned. 

	Copyright 2020 Ghostrider-GRG-

	Notes: 
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

params[
		["_difficulty",GMSAI_difficultyRed],
		["_spawnPos",[0,0,0]], // center of the patrol area
		["_units",0],  // units to spawn, can be integer, [1], or range [2,3]
		["_patrolMarker",""],
		["_deleteMarker",true]  // when true the marker that defines borders of the patrol area will be deleted when the group is Null
	];

/*

params[
		"_pos",  // center of the area in which to spawn units
		"_units",  // Number of units to spawn
		["_side",GMSCore_side],
		["_baseSkill",0.7],
		["_alertDistance",500], 	 // How far GMS will search from the group leader for enemies to alert to the kiillers location
		["_intelligence",0.5],  	// how much to bump knowsAbout after something happens
		["_bodycleanuptimer",600],  // How long to wait before deleting corpses for that group
		["_maxReloads",-1], 			// How many times the units in the group can reload. If set to -1, infinite reloads are available.
		["_removeLaunchers",true],
		["_removeNVG",true],
		["_minDamageToHeal",0.4],
		["_maxHeals",1],
		["_smokeShell",""]
	];

*/

//diag_log format["GMSAI_fnc_spawnInfantryGroup: GMSAI_side = %1",GMSAI_side];

private _group = [
		_spawnPos,
		[_units] call GMSCore_fnc_getIntegerFromRange,
		GMSAI_side,
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

_group setVariable[GMSAI_groupDifficulty,_difficulty];

[_group,GMSAI_skillbyDifficultyLevel select _difficulty] call GMSCore_fnc_setupGroupSkills;  // TODO: revisit this once a system for skills is determined - simpler the better
[_group, GMSAI_unitLoadouts select _difficulty, GMSAI_LaunchersPerGroup, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
[_group,_difficulty,GMSAI_money select _difficulty] call GMSCore_fnc_setupGroupMoney;
//_group call GMSAI_fnc_addEventHandlers;

#define waypointTimeoutInfantryPatrols 180

if !(_patrolMarker isEqualTo "") then // setup waypoints using the information stored in the marker 
{

	[
		_group,
		GMSAI_BlacklistedLocations,
		_patrolMarker,
		waypointTimeoutInfantryPatrols,
		GMSAI_chanceToGarisonBuilding,
		"infantry",
		_deletemarker
	] call GMSCore_fnc_initializeWaypointsAreaPatrol;
};
[_group,GMSAI_fnc_unitKilled] call GMSCore_fnc_addChainedMPKilled;
[_group, GMSAI_BlacklistedLocations] call GMSCore_fnc_setGroupBlacklist;
_group