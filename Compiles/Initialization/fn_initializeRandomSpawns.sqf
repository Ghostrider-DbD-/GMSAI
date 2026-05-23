/*
	GMSAI_fnc_initializeRandomSpawnLocations 

	Purpose: set up random spawn locations around the map between capitals, cities, towns etc 

	Parameters: _locations, the list of locations used for location-based static spawns (I think)

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] initialized %1 RandomSpawnLocations",GMSAI_StaticSpawnsRandom];
if (GMSAI_StaticSpawnsRandom <= 0) exitWith 
{
	if (GMSAI_debug > 0) then {[" Random Static Spawns disabled"] call GMSAI_fnc_log};
};
params[["_locations",[]]];
for "_i" from 1 to GMSAI_StaticSpawnsRandom do
{
	private _pos = [nil,["water"]] call BIS_fnc_randomPos;
	if !(_pos isEqualTo [0,0]) then
	{
		private _m = "";
		if (GMSAI_debug > 0) then
		{
			_m = createMarker[format["GMSAI_Random%1",_i],_pos];
			_m setMarkerShape "RECTANGLE";
			_m setMarkerSize [250,250];
			_m setMarkerColor "COLORORANGE";							
		} else {
			_m = createMarkerLocal[format["GMSAI_Random%1",_i],_pos];
			_m setMarkerShapeLocal "RECTANGLE";
			_m setMarkerSizeLocal [250,250];			
		};
		[_m,GMSAI_staticRandomSettings,false] call GMSAI_fnc_addStaticSpawn;
	};
};
[format[" Initialized %1 Random Spawn locations at %2",GMSAI_StaticSpawnsRandom,diag_tickTime]] call GMSAI_fnc_log;