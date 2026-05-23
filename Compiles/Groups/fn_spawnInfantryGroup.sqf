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

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

params[
		["_difficulty",GMSAI_difficultyRed],
		["_spawnPos",[0,0,0]], // center of the patrol area
		["_units",0],  // units to spawn, can be integer, [1], or range [2,3]
		["_patrolMarker",""],
		["_deleteMarker",true]  // when true the marker that defines borders of the patrol area will be deleted when the group is Null
	];

private _group = [
		_spawnPos,
		_patrolMarker,
		_deleteMarker, 		
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

[_group,GMSAI_skillbyDifficultyLevel select _difficulty] call GMSCore_fnc_setupGroupSkills; 
[_group, GMSAI_unitLoadouts select _difficulty, GMSAI_LaunchersPerGroup, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
[_group,_difficulty,GMSAI_money select _difficulty] call GMSCore_fnc_setupGroupMoney;
//_group call GMSAI_fnc_addEventHandlers;

[_group,GMSAI_fnc_unitKilled] call GMSCore_fnc_addChainedMPKilled;

_group