/*
	GMSAI_fnc_monitorGroupDebugMarkers 

	Purpose: monitors known debug markers so that if a group is accidently deleted without clearing the marker the debug marker is removed. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
for "_i" from 1 to (count GMSAI_groupDebugMarkers) do 
{
	if (_i > (count GMSAI_groupDebugMarkers)) exitWith {};
	private _m = GMSAI_groupDebugMarkers deleteAt 0;
	_m params["_group","_marker"];
	if ((isNull _group) || ({alive _x} count (units _group)) == 0) then 
	{
		deleteMarker _marker;
	} else {
		_marker setMarkerPos (getPosATL(leader _group));
		GMSAI_groupDebugMarkers pushBack _m;
	};
};