/*
	GMSAI_variables.sqf 

	Purpose: list variables used by the mission system 

	Copyright 2020 Ghostrider-GRG-
*/

GMSAI_StaticSpawns = [];
GMSAI_groups = [];
GMSAI_DynamicGroupsSpawned = 0;
GMSAI_dynamicGroups = [];
GMSAI_groupDebugMarkers = [];
GMSAI_infantryGroups = [];
GMSAI_airPatrols = [];
GMSAI_AirPatrolGroups = [];
GMSAI_UAVPatrols = [];
GMSAI_UAVGroups = [];
GMSAI_paratroopGroupsSpawned = 0;
GMSAI_paratroopGroups = [];
GMSAI_UGVPatrols = [];  //  UGV patrols on roads or within specific areas other than the static spawns.
GMSAI_UGVGroups = [];    // Groups for all land UGV patrols
GMSAI_vehiclePatrols = [];  //  Vehicle patrols on roads or within specific areas other than the static spawns.
GMSAI_vehicleGroups = [];   // Groups for all land vehicle patrols
GMSAI_emptyVehicles = [];
GMSAI_lastCheckStatics = diag_tickTime;
GMSAI_samInProgress = false;
//["Variables loaded"] call GMSAI_fnc_log;