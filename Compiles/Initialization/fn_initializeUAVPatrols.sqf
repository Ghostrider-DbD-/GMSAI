/*
	GMSAI_fnc_initializeUAVPatrols 

	Purpose: setup UAV patrols that roam the map. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		TODO: need to think about area-based varients of this function.
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
if (GMSAI_numberOfUAVPatrols <= 0) exitWith 
{
	[" GMSAI_numberOfUAVPatrols <= 0 - UAV Patrols disabled"] call GMSAI_fnc_log;
};
if (GMSAI_UAVTypes isEqualTo []) exitWith 
{
		[format["GMSAI_UAVTypes == [] - UAV Patrols Disabled"]] call GMSAI_fnc_log;
};
#define lastSpawned -1 
for "_i" from 1 to GMSAI_numberOfUAVPatrols do
{
	GMSAI_UAVPatrols pushBack [GMSAI_BlacklistedLocations,grpNull,objNull,lastSpawned,0,-1,GMSAI_UAVRespawnTime,gmsai_uavPatrolResapwns,GMSAI_UAVDifficulty,GMSAI_UAVTypes];  //  set respawnat to 80 so that the server has a chance to load up before spawning UAV
};
[format[" Initialized UAV Patrols at %1",diag_tickTime]] call GMSAI_fnc_log;


