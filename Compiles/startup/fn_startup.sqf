/*
	Purpose: called when the mod is loaded and initializes and starts it up.
	Copyright 2020 Ghostrider-GRG-
*/
//diag_log format["[GMSAI] running fn_startup at %1",diag_tickTime];
if (!(isServer) || hasInterface) exitWith {diag_log "[GMSAI] ERROR: GMSAI SHOULD NOT BE RUN ON A CLIENT PC";};
if (!isNil "GMSAI_Initialized") exitWith {diag_log "[GMSAI] 	ERROR: GMSAI AREADY LOADED";};
[] spawn GMSAI_fnc_initialize;
//diag_log format["[GMSAI] fn_startup completed at %1",diag_tickTime];