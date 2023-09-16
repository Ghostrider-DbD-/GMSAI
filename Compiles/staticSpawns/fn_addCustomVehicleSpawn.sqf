/*
	GMSAI_fnc_addCustomVehicleSpawn

	Purpose: provide a function by which server owners can add static vehicle patrols to meet their own needs. 

	Parameters: See params list below 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:

*/

params[
			_className, // className of the vehicle to use 
			_name,  	// Name of the vehicle patrol which MUST be a unique name
			_pos,	//Center of the patrol area
			_shape,  //["RECCTANGLE","ELLIPSE"] 
			_size,	 //[sizeA,sizeB]/Radius]
			_groups, //[_min,_max], [_min], _min
			_units,  // can be [_min,_max],  [_min], or _min
			_difficulty, // can be 1..N per GMSAI configs.
			_respawns,  // 0..N, -1 for infinite respawns 
			[_cooldown,GMSAI_vehiclePatrolDeleteTime],  // time in seconds until group respawns
			[_isSubmerged,false]	//  true/false  when true the swimIndepth will be set to (getPosASL - getPosATL)/2
		];

private _m = createMarkerLocal [_name,_pos];
_m setMarkerShapeLocal _shape;
_m setMarkerSizeLocal _size;	

_aiDescriptor = [_groups,_units,_difficulty,_chance,_respawns,_cooldown,GMSAI_staticDespawnTime,_classname,_isSubmerged,_className];
[_m,_aiDescriptor] call GMSAI_fnc_addStaticSpawn;
