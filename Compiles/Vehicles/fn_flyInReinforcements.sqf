/*
	GMSAI_fnc_flyInReinforcements 

	Purpose: fly in a heli and drop reinforcements by parachute at a specified location 

	Parameters: 
		_dropPos, where the drop should occure 
		_group, the group the be dropped 
		_target, the player target to be hunted by the reinforcements 

	Returns: None 
	
	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_dropPos","_group",["_target",ObjNull]];
[format["flyInReinforcements CALLED: _dropPos = %1 | _targetPos = %2 | _group = %3 | _target = %4",_dropPos,getPosATL _target,_group,_target]] call GMSAI_fnc_log;
/*
	steps to follow for this script:
	1. set a position under the aircraft detecting the player for dropoff 
	  and set the respawn timer stored on the object to respawnInterval + diagTickTime
	2. spawn in a group, set damage = false, and equip, holding them at [0,0,0]
	3. pass the dropoff position and group info to the script in GSM core functions
	4. once all units are on the ground, pass control of the group off to group manager and paratroop manager

	TODO: test if this is used.
	TODO: Add 'gunship' option that specifies that the heli will patrol the area and try to take out any players spotted.
	// TODO: update parameter list for call to GMSCore_fnc_spawnPatrolAircraft
*/

// make sure no other reinforcements are called in for a while

//private _dropPos = getPosATL(leader _group); // the drop pos would be near the location of the flight crew when reinforcements are called in. 

private _difficulty = selectRandomWeighted GMSAI_paratroopDifficulty;
private _aircraftType = selectRandomWeighted GMSAI_paratroopAircraftTypes;
private _startPos = _dropPos getPos [1500, random(359)];
private _crewCount = [_aircraftType,false]  call BIS_fnc_crewCount;
[format["flyInReinforcements: _crewCount = %1 | _startPos %2 | _dropPos %3 distance = %4",_crewCount,_startPos,_dropPos, _startPos distance _dropPos]] call GMSAI_fnc_log;
/*
params[
		["_pos",[0,0,0]],  // center of the area in which to spawn units
		["_units",0],  // Number of units to spawn
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
		["_smokeShell",""],
		["_aiHitCode",[]],
		["_aiKilledCode",[]],
		["_chanceGarison",0]
];
*/
private _crewGroup = [
	[0,0,0],
	_crewCount,
	GMSCore_side,
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
//diag_log format["GMSAI_fnc_flyInReinforcements: _crewGroup = %1",_crewGroup];
[_crewGroup,GMSAI_unitDifficulty select (_difficulty)] call GMSCore_fnc_setupGroupSkills;
[_crewGroup, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
[_crewGroup,_difficulty,GMSAI_money select _difficulty] call GMSCore_fnc_setupGroupMoney;

private _heli = [
	_aircraftType,
	_crewGroup,
	_startPos,
	0,
	GMSAI_paratroopDespawnTimer,
	false,
	GMSAI_releaseVehiclesToPlayers,
	GMSAI_vehicleDeleteTimer,
	GMSAI_aircraftFlyinHeight,
	[GMSAI_fnc_vehicleHit],
	[GMSAI_fnc_vehicleKilled]
] call GMSCore_fnc_spawnPatrolAircraft;
_crewGroup setVariable[calledByUAVGroup,_group];
_crewGroup setSpeedMode "LIMITED";
//[_group,"disengage"] call GMSCore_fnc_setGroupBehaviors;
private _wp = [_crewGroup,0];
_wp setWaypointCompletionRadius 0;
_wp setWaypointBehaviour "AWARE";
_wp setWaypointCombatMode "YELLOW";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointPosition  [_dropPos,0];
_wp setWaypointTimeout [0,0.5,1];
_wp setWaypointType "MOVE";
_wp setWaypointStatements ["true","this spawn GMSAI_fnc_reachedDropPos;"];
_crewGroup setCurrentWaypoint _wp;

diag_log format["GMSAI_fnc_getToDropWaypoint: will activate GMSAI_fnc_dropParatroops upon waypoint completion"];