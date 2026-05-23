/*
	GMSAI_fnc_deleteGroupDebugMarker 

	Purpose: delete group debug markers 

	Parameters: _group, the group for which markers should be removed 

	Returns: None 
	
	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_debugMarkers",[],[[]]];
{
	deleteMarkerLocal _x;
} forEach _debugMarkers;

