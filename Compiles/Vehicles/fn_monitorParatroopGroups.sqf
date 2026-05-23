/*
	GMSAI_fnc_monitorParatroopGroups
	Purpose: Just removes null groups from an array used to keep track of how many reinforcement groups are spawned.

	Parameters: None 

	Returns: None 
	
	Copyright 2020 Ghostrider-GRG-

	Notes: All hunting logic is handled by GMS using an area patrol.
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

[GMSAI_paratroopGroups] call GMSCore_fnc_removeNullEntries; 

