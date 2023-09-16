/*
	GMSAI_fnc_mainThread 

    Purpose: run scripts at pre-specified intervals. 

    Parameters: None 

    Returns: None 
    
    Copyright 2020 Ghostrider-GRG-

    Notes: in theory, on exile, these calls could be added to the exile scheduler on the first pass 
    - save that for later 
    - may be a bit slower to do that since the exile schedule has to figure out what function to run.
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

/*  Spawn land and air patrols to initialize things */
[] call GMSAI_fnc_monitorAirPatrols;
[] call GMSAI_fnc_monitorUAVPatrols;
[] call GMSAI_fnc_monitorVehiclePatrols;        
[] call GMSAI_fnc_monitorUGVPatrols;   

/* setup our timers */
//private _1sec = diag_tickTime;
//private _5sec = diag_tickTime;
private _15sec = diag_tickTime;
//private _60sec = diag_tickTime;
private _updateInterval = diag_tickTime;
#define loopTime 15

while {true} do
{
    uiSleep loopTime;
    if (diag_tickTime > _15sec) then
    {
        //[] call GMSAI_fnc_monitorParatroopGroups;
        if (GMSAI_debug > 0) then {[] call GMSAI_fnc_monitorGroupDebugMarkers};
        _15sec = diag_tickTime + 15;
    };
    if (diag_tickTime > _updateInterval) then
    {
        _updateInterval = diag_tickTime + GMSAI_updateInterval;
        [] call GMSAI_fnc_monitorStaticPatrolAreas;  
        uiSleep 1;
        [] call GMSAI_fnc_monitorAirPatrols;
        [] call GMSAI_fnc_monitorUAVPatrols;
        uiSleep 1;      
        [] call GMSAI_fnc_dynamicAIManager;
        [] call GMSAI_fnc_monitorVehiclePatrols;        
        [] call GMSAI_fnc_monitorUGVPatrols; 
        uiSleep 1;         
        {[_x] call GMSCore_fnc_removeNullEntries} forEach [
            GMSAI_infantryGroups,
            GMSAI_AirPatrolGroups, 
            GMSAI_paratroopGroups,
            GMSAI_vehicleGroups,
            GMSAI_UAVGroups,
            GMSAI_UGVGroups
        ];
        [format[
            "Time %1 | %2 Infantry Groups | %3 Air Patrols | %4 Reinforcements | %5 Vehicle Patrols | %6 UAVs | %7 UGVs", 
            diag_tickTime,
            count GMSAI_infantryGroups,
            count GMSAI_AirPatrolGroups, 
            count GMSAI_paratroopGroups,
            count GMSAI_vehicleGroups,
            count GMSAI_UAVGroups,
            count GMSAI_UGVGroups
        ]] call GMSAI_fnc_log;
    };
};