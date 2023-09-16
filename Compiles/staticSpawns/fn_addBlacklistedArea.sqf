/*
	GMSAI_fnc_addBlacklistedArea 

	Purpose: provide a means for server owners to add a blacklisted area. 

	Parameters: 
		_center,  // the center of the blacklisted area 
		_shape, // either "RECTANGLE" or "ELLIPSE" 
		_size  // either [sizeA,sizeB] or radius 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 
*/

params[
	"_center",
	["_shape","RECTANGLE"],
	["_size",[200,200]]
];

private _m = createMarkerLocal [format["blacklist%1",count GMSAI_BlacklistedLocations],_center];
_m setMarkerShapeLocal _shape;
_m setMarkerSizeLocal _size;
GMSAI_BlacklistedLocations pushBack [_m];
