/*
	GMSAI_fnc_initializeUGVPatrols 

	Purpose: setup location-based UGV patrols that could roam the entire map. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

if (GMSAI_UGVtypes isEqualTo []) exitWith 
{
	GMSAI_numberOfUGVPatrols = 0;
	["GMSAI_UGVtypes isEqualTo [] - UGV Patrols Disabled"] call GMSAI_fnc_log;
};

if (GMSAI_numberOfUGVPatrols <= 0) exitWith 
{
	if (GMSAI_debug > 0) then {[" GMSAI_numberOfUGVPatrols <= 0 - UGV Patrols disabled"] call GMSAI_fnc_log};
};

#define lastSpawned -1 
for "_i" from 1 to GMSAI_numberOfUGVPatrols do
{
	GMSAI_UGVPatrols pushBack [GMSAI_BlacklistedLocations,grpNull,objNull,lastSpawned,0,-1,GMSAI_UGVrespawnTime,GMSAI_UGVPatrolRespawns,GMSAI_UGVdifficulty,GMSAI_UGVtypes];  
};

if (GMSAI_debug > 0) then {[format[" Initialized UGV Patrols at %1",diag_tickTime]] call GMSAI_fnc_log};