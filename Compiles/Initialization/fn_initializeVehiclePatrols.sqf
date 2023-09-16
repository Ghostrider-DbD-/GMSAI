/*
	GMSAI_fnc_initializeVehiclePatrols 

	Purpose: initialize vehicle patrols that run beteween locations and could span the whole map. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 
		TODO: think about area-based versions of this script
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
if (GMSAI_noVehiclePatrols <= 0) exitWith 
{
	["GMSAI_noVehiclePatrols <= 0 - Vehicle Patrols Disabled"] call GMSAI_fnc_log;
};
if (GMSAI_patrolVehicles isEqualTo []) exitWith 
{
	[format["GMSAI_patrolVehicles isEqualTo [] - Vehicle Patrols Disabled"]]
};
#define lastSpawned -1 
#define crewOnFoot grpNull
for "_i" from 1 to GMSAI_noVehiclePatrols do
{
	GMSAI_vehiclePatrols pushBack [
		GMSAI_BlacklistedLocations,
		grpNull,
		objNull,
		lastSpawned,
		0,
		-1,
		GMSAI_vehiclePatrolRespawnTime,
		GMSAI_vehiclePatrolRespawns,
		GMSAI_vehiclePatroDifficulty,
		GMSAI_patrolVehicles,
		crewOnFoot
	]; // set respawnat to 10 to allow server to get started before spawning vehicle patrols
};
[format[" Initialized Land Vehicle patrols at %1",diag_tickTime]] call GMSAI_fnc_log;