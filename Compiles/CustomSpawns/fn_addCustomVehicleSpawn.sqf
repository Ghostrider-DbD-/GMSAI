

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
	"_pos",    			// Position of the center of the area to patrol
	"_shape",			// Marker shape: "RECTANGLE" or "ELLIPSE"
	"_size",			// Marker [sizea, sizeb]
	"_difficulty",		// can be one of the existing matricies of difficulties or a custom one.
	"_unitsPerGroup",	// integer or range [2,3]
	"_groups",			// integer or range [2,3]
	"_respawns",		// -1 for indefinate, 0 for none, 1..N for specified number
	"_respawnTime",		// integer or range [300,600]
	"_vehicles"			// weighted array with one or more classNames ["Name1",1,"Name2",2, ... etc]
];
[format["<START> addCustomVehicleSpawn: marker pos %1 | shape %2 | size %3",_pos,_shape,_size]] call GMSAI_fnc_log;
private "_m";
if (GMSAI_debug >= 0) then 
{
	_m = createMarker[format["customVehicle%1",random(1000000)],_pos];	
	_m setMarkerShape _shape;
	_m setMarkerPos _pos;
	_m setMarkerSize _size;
	_m setMarkerColor "COLORGREEN";
	_m setMarkerBrush "Border";	
} else {
	_m = createMarkerLocal [format["customVehicle%1",random(1000000)],_pos];
	_m setMarkerShapeLocal _shape;
	_m setMarkerPosLocal _pos;
	_m setMarkerSizeLocal _size;
};
_types = [
	[GMSAI_vehicle,_groups,_vehicles]
];
private _settings = [_groups,_unitsPerGroup,_difficulty,1.0,_respawns,_respawnTime,180,_types];
[_m,_settings,false] call GMSAI_fnc_addStaticSpawn;
[format["addCustomVehicleSpawn: marker pos ?%1 | shape %2 | size %3",_pos,_shape,_size]] call GMSAI_fnc_log;