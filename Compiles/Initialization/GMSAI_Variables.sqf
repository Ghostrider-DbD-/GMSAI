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
GMSAI_UAVPatrolGroups = [];
GMSAI_paratroopGroupsSpawned = 0;
GMSAI_paratroopGroups = [];
GMSAI_UGVPatrols = [];  //  UGV patrols on roads or within specific areas other than the static spawns.
GMSAI_UGVPatrolGroups = [];    // Groups for all land UGV patrols
GMSAI_vehiclePatrols = [];  //  Vehicle patrols on roads or within specific areas other than the static spawns.
GMSAI_vehiclePatrolGroups = [];   // Groups for all land vehicle patrols
GMSAI_emptyVehicles = [];

GMSAI_monitorAircraftPatrolsActive = false; 
GMSAI_monitorUAVPatrolsActive = false;
GMSAI_monitorVehiclePatrolsActive = false;
GMSAI_monitorUGVPatrolsActive = false; 

GMSAI_lastCheckStatics = diag_tickTime;
GMSAI_samInProgress = false;
//["Variables loaded"] call GMSAI_fnc_log;