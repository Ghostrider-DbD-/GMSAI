
/*
	GMSAI_fnc_initializeCustomSpawns

	Purpose: initialize user-defined custom spawns defined in GMSAI_CustomLocations in GMSAI_configs.sqf

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:

*/
// The configs are defined as follows (see GMSA(_configs.sqf for further examples))
/*
	position // [[x,y,z],width,length,angle,isRectangle],
	infantryGroups, // can be an integer, or [min,max] not used but must be included ?
	unitsPerInfantryGroup,  // Used
	Difficulty,  // This is a weighted array of one or more of the difficulty matricies defined below
	Chance,
	Respawns,  // -1 for infinite respawns
	respawnTimer, // integer or [min,max]  // [300,450] would be 5 to 7.5 min
	despawnTimer,  // default is 120
	patrolTypes [
		[GMSAI_ugv,[1],[]],	  // if you want to specify which UGV to spawn add the classNames in a weighted array 
		[GMSAI_uav,[1],[]],   // if you want to specify which UAV to spawn add the classNames in a weighted array 
		[GMSAI_air,[1],[]],	   // if you want to specify which aircraft to spawn add the classNames in a weighted array 
		[GMSAI_infantry,[1,2],[]]	
	]
*/
//[format["Configuring custom spawns for %1 spawns",count GMSAI_CustomLocations]] call GMSAI_fnc_log;
{
	_x params["_name","_area","_unitsPerGroup","_difficulty","_chance","_respawns","_respawnTimer","_despawnTime","_patrolTypes"];
	_area params["_pos","_sizex","_sizey","_angle","_isRectangle"];
	private ["_m1","_m2"];
	if (GMSAI_debug > 1) then {[format[" Adding Custom Spawn %1 | pos %2 | ",_name,_area]] call GMSAI_fnc_log};
	if (GMSAI_debug > 0) then 
	{
		_m1 = createMarker [format["GMSAI_customSpawn%1",_forEachIndex],_pos];
		_m1 setMarkerShape "RECTANGLE";
		_m1 setMarkerSize [_sizex, _sizey];
		_m1 setMarkerColor "COLORORANGE";
		if (GMSAI_debug > 1) then 
		{
			_m2 = createMarker [format["GMSAI_customSpawnText%1",_forEachIndex],_pos];
			_m2 setMarkerType "hd_dot";
			_m2 setMarkerText format["Custom Spawn %1",_name];
		};
	} else {
		_m1 = createMarkerLocal [format["GMSAI_customSpawn%1",_forEachIndex],_pos];		
		_m1 setMarkerShapeLocal "RECTANGLE";
		_m1 setMarkerSizeLocal [_sizex, _sizey];
	};
	private _aiDescriptor = [_unitsPerGroup,_difficulty,_chance,_respawns,_respawnTimer,_despawnTime,_patrolTypes];
	[_m1, _aiDescriptor, false] call GMSAI_fnc_addStaticSpawn;
} forEach GMSAI_CustomLocations;