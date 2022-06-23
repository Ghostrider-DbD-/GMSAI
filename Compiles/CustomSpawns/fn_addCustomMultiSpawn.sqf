

params[
	"_pos",    			// Position of the center of the area to patrol
	"_shape",			// Marker shape: "RECTANGLE" or "ELLIPSE"
	"_size",			// Marker [sizea, sizeb]
	"_difficulty",		// can be one of the existing matricies of difficulties or a custom one.
	"_unitsPerGroup",	// integer or range [2,3]
	"_groups",			// integer or range [2,3]
	"_respawns",		// -1 for indefinate, 0 for none, 1..N for specified number
	"_respawnTime",		// integer or range [300,600]
	"_types"			// an array with the _types data
						// This allows multipe types of patrols to be linked to a single map marker
						// This can be formated as follows:
						// Note that you can have one, some or all of these types of patrols spawned.
						/*
						_types = [
							[GMSAI_infantry,_groups,_unitsPerGroup],
							[GMSAI_vehicle,_groups,_vehicles],  //  where _vehicles is a weighted array 
							[GMSAI_ugv,_groups,_UGVs],  // where _UGVs is a weighted array
							[GMSAI_uav,_groups,_UAVs],  // where _UAVs is a weighted array
							[GMSAI_air,_groups,_aircraft]// where _aircraft is a weighted array
						];
						*/
];

private "_m";
if (GMSAI_debug >= 0) then 
{
	_m = createMarker["customInfantry%1",random(1000000)];	
	_m setMarkerShape _shape;
	_m setMarkerPos _pos;
	_m setMarkerSize _size;
	_m setMarkerColor "COLORBLUE";
	_m setMarkerBrush "SolidBorder";	
} else {
	_m = createMarkerLocal ["customInfantry%1",random(1000000)];
	_m setMarkerShapeLocal _shape;
	_m setMarkerPosLocal _pos;
	_m setMarkerSizeLocal _size;
	_m setMarkerColorLocal "COLORBLUE";
	_m setMarkerBrushLocal "SolidBorder";
};
_types = [
	[GMSAI_vehicle,_groups,_vehicles]
];
private _settings = [_groups,_unitsPerGroup,_difficulty,1.0,_respawns,_respawnTime,180,_types];
[_m,_settings,false] call GMSAI_fnc_addStaticSpawn;