/*
	GMSAI_fnc_getGroupDebugMarker
	
	Purpose: a simple get function that returns the marker used as a debug marker for the group. 

	Parameters: _group, the group to get from 

	Returns: the marker in question 
	
	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_group"];
private _m = _group getVariable["GMSAI_debugMarker",""];
_m