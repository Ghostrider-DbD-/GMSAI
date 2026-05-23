/*
	GMSAI_fnc_updateGroupDebugMarker 

	Purpose: update the position of the debug marker to be over the group leader 

	Parameters: _group, the group to handle 

	Returns: none 
	
	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_group"];
private _m = _group getVariable["GMSAI_debugMarker",""];	
_m setMarkerPos getPosATL(leader _group);