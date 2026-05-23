/*
	GMSAI_fnc_destroyWaypoint

	Purpose: destroy vehicle and units therein when a waypoint is reached.

	Parameters: 
		_this = leader of the group

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

params["_group"];
private _wp = [_group,0];
private _leader = leader(_group);
private _dir = getDir(vehicle _leader);
private _destroyPos = (getPosATL _learder) getPos [3000,_dir];
_wp setWPPos _destroyPos;
_wp setWaypointType "MOVE";
_wp setWaypointStatements ["true","[group this] call GMSCore_fnc_destroyVehicleAndCrew"];