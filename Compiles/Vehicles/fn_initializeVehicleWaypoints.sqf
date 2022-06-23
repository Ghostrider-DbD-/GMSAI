/*
	GMSAI_fnc_initializeVehicleWaypoints 

	Purpose: Initialize waypoints for vehicle patrols using a location-based system whereby they can patrol the entire map. 

	Parameters: _driver, the driver of the vehicle 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		- this function is used to get the newly spawn vehicle from a random location to the road. 
		- condier hiding it till this has happened and disable AI from firing just to give them a chance to catch up. 
		- consider helping them identify nearby players on spawn for the same reason. 

*/

params ["_driver"]; 
private _veh = vehicle _driver;
//diag_log format["_nextWaypointVehicle: initializing waypoints for: _driver = %1 | _group = %2 | _veh = %3",_driver,_group,_veh];
private _road = [getPosATL _veh,1000] call BIS_fnc_nearestRoad;
//diag_log format["_nextWaypointVehicle: nearest road is at %1 | road is meters from vehicle %2 | relative dir %3",getPosATL _road, _veh distance _road,_veh getRelDir _road];
private _wp = _group addWaypoint [_group,0,0,"movetoRoad"];
_wp setWaypointPosition[getPosATL _road,0];
_wp setWaypointStatements ["true","this call GMSAI_fnc_nextWaypointVehicles;"];	
_group setCurrentWaypoint [_group,0]; 