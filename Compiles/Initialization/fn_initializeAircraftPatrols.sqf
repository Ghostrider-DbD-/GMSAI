/*
	GMSAI_fnc_initializeAircraftPatrols 

	Purpose: initialize the randomly spawn aircraft patrols 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
if (GMSAI_aircraftTypes isEqualTo []) exitWith 
{
	GMSAI_numberOfAircraftPatrols = 0;
	["GMSAI_aircraftTypes isEqualTo []-  Aircraft Patrols disabled"] call GMSAI_fnc_log;
};

if (GMSAI_numberOfAircraftPatrols <= 0) exitWith 
{
	["GMSAI_numberOfAircraftPatrols <= 0 - Aircraft Patrols disabled"] call GMSAI_fnc_log;
};

#define lastSpawned -1 
for "_i" from 1 to GMSAI_numberOfAircraftPatrols do
{
	GMSAI_airPatrols pushBack [GMSAI_BlacklistedLocations,grpNull,objNull,lastSpawned,0,-1,GMSAI_aircraftRespawnTime,GMSAI_airpatrolResapwns,GMSAI_aircraftPatrolDifficulty,GMSAI_aircraftTypes];  //  set respawnAt 40 so that the server has a chance to load before doing all this.
};
if (GMSAI_debug > 0) then {[format[" Initialized aircraft patrols at %1",diag_tickTime]] call GMSAI_fnc_log};