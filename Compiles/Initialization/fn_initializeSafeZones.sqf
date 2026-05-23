/*
	GMSAI_fnc_initializeSafeZones

	Purpose: set up user-specified GMSAI safezones
	Parameters: none
	Returns: none 
	Copyright 2020 Ghostrider-GRG-

	Notes:
		Safezones also will detect and delete GMS_RC AI
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

{
	[_x, GMSAI_maxSafeZoneLoiterTime] call GMSCore_fnc_addSafeZone;
} forEach GMSAI_safeZones;
diag_log format["GMSAI_fnc_initializeSafeZones COMPLETE at %1",diag_tickTime];