/*
	GMSAI_fnc_deleteGroupDebugMarker 

	Purpose: delete group debug markers 

	Parameters: _group, the group for which markers should be removed 

	Returns: None 
	
	Copyright 2020 Ghostrider-GRG-
*/

#include "\addons\GMSAI\init\GMSAI_defines.hpp" 
params["_group"];
private _m =  (_group getVariable["GMSAI_debugMarker",""]);
deleteMarker _m;	
_group setVariable["GMSAI_debugMarker",nil];
[format["deleteGroupDebugMarker: Marker %1 for group %2 delete",_m,_group]] call GMSAI_fnc_log;