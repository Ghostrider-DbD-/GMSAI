/*
	GMSAI_fnc_addCustomStaticSpawn

	Purpose: provide a function by which server owners can add static infantry patrols to meet their own needs. 

	Parameters: See params list below 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 

	GMSAI_fnc_addStaticSpawn expects the following parameters 
	params["_areaDescriptor","_staticAiDescriptor"];

	_areaDescriptor params["_patrolAreaMarker","_staticAiDescriptor","_spawnType","_spawnedGroups","_respawnAt","_timesSpawned","_debugMarker"];	
	_staticAiDescriptor params["_noGroupsToSpawn","_unitsPerGroup","_difficulty","_chance","_maxRespawns","_respawnTime", "_despawnTime"];	

*/

params[ 
			"_name",  // This can be any name you like
			"_pos",	//Center of the patrol area
			"_shape",  //["RECCTANGLE","ELLIPSE"] 
			"_size",	 //[sizeA,sizeB]/Radius]
			"_units",  // can be [_min,_max],  [_min], or _min
			"_difficulty", // can be 1..N per GMSAI configs.
			"_respawns",  // 0..N, -1 for infinite respawns 
			"_respawnTime",	//  true/false  when true the swimIndepth will be set to (getPosASL - getPosATL)/2
			"_despawnTime",
			"_patrolTypes"
		];

	private ["_m1","_m2"];

	if (GMSAI_debug > 0) then 
	{
		[format["Adding custom spawn %1 at _pos %2",_name,_pos]] call GMSAI_fnc_log;
		_m1 = createMarker [format["GMSAI_userDefInfantrySpawn%1",_forEachIndex],_pos];
		_m1 setMarkerShape _shape;
		_m1 setMarkerSize _size;
		_m1 setMarkerColor "COLORORANGE";
		if (GMSAI_debug > 1) then 
		{
			_m2 = createMarker [format["GMSAI_userDefSpawnText%1",_forEachIndex],_pos];
			_m2 setMarkerType "hd_dot";
			_m2 setMarkerText format["Custom Spawn %1",_name];
		};
	} else {
		_m1 = createMarkerLocal [format["GMSAI_userDefInfantrySpawn%1",_forEachIndex],_position select 0];		
		_m1 setMarkerShapeLocal _shape;
		_m1 setMarkerSizeLocal _size;
	};

_aiDescriptor = [_units,_difficulty,_chance,_respawns,_respawnTime,_despawnTime,_patrolTypes];
[_m,_aiDescriptor,false] call GMSAI_fnc_addStaticSpawn;

	
