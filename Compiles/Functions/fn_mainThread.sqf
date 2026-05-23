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

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

/*  Spawn land and air patrols to initialize things */
/*
[] call GMSAI_fnc_monitorAirPatrols;
[] call GMSAI_fnc_monitorUAVPatrols;
[] call GMSAI_fnc_monitorVehiclePatrols;        
[] call GMSAI_fnc_monitorUGVPatrols;   
*/

/* setup our timers */
//private _1sec = diag_tickTime + 1;
//private _5sec = diag_tickTime + 5;
private _10sec = diag_tickTime;
private _20sec = diag_tickTime;
private _60sec = diag_tickTime;


while {true} do
{
    //[format["_mainThread: Start of main loop at %1",diag_tickTime]] call GMSAI_fnc_log;
    uiSleep 10;
    if (diag_tickTime > _10sec) then {
        [] call GMSAI_fnc_dynamicAIManager;
        [] call GMSAI_fnc_monitorStaticPatrolAreas;          
        _10sec = diag_tickTime + 10;
    };
    if (diag_tickTime > _60sec) then {
        //[] call GMSAI_fnc_monitorParatroopGroups;
        _60sec = diag_tickTime +60;
        [] call GMSAI_fnc_monitorAirPatrols;
        [] call GMSAI_fnc_monitorUAVPatrols;
        [] call GMSAI_fnc_monitorVehiclePatrols;  
        [] call GMSAI_fnc_monitorUGVPatrols;             
        {[_x] call GMSCore_fnc_removeNullEntries} forEach [
            GMSAI_infantryGroups,
            GMSAI_AirPatrolGroups, 
            GMSAI_paratroopGroups,
            GMSAI_vehiclePatrolGroups,
            GMSAI_UAVPatrolGroups,
            GMSAI_UGVPatrolGroups
        ];
        [format[
            "Time %1 | %2 Infantry Patrols | %4 Paratroops |%3 Air Patrols |  %5 Vehicle Patrols | %6 UAVs | %7 UGVs", 
            diag_tickTime,
            (count GMSAI_infantryGroups) + (count GMSAI_dynamicGroups),
            count GMSAI_AirPatrolGroups, 
            count GMSAI_paratroopGroups,
            count GMSAI_vehiclePatrolGroups,
            count GMSAI_UAVPatrolGroups,
            count GMSAI_UGVPatrolGroups
        ]] call GMSAI_fnc_log;
    };
    //[format["_mainThread: End of main loop at %1",diag_tickTime]] call GMSAI_fnc_log;    
};