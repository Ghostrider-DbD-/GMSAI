/*
	GMSAI_fnc_initializeStaticSpawnsForLocations 

	Purpose: set up the static spawns at capitals, cities towns and others .

	Parameters: None 

	Returns: the list of locations for which static spawns were defined. 

	Copyright 2020 Ghostrider-GRG-
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _initializeStaticSpawnsForLocations: GMSAI_useStaticSpawns = %1",GMSAI_StaticSpawnsRandom];

_fn_createMarker = {
	params[
		"_location", // a location pulled from the map configs
		"_markerIndex", // a number used to ensure marker names are not duplicated
		"_markerColor"];
	private _m ="";
	private _locationSize = size _location;

	// Handle the case of small locations which can result in crowding such that AI are spawned near players
	if ((_locationSize select 0) < (GMSAI_minimumLocationDimension select 0)) then {_locationSize set[0, (GMSAI_minimumLocationDimension select 0)]};
	if ((_locationSize select 1) < (GMSAI_minimumLocationDimension select 1)) then {_locationSize set[0, (GMSAI_minimumLocationDimension select 1)]};	
	private _adjustedSize = [(_locationSize select 0) + 200, (_locationSize select 1) + 200];
	if (GMSAI_debug > 0) then
	{	
		_m = createMarker [format["GMSAI_StaticSpawn%1%2",(text _location),_markerIndex],(locationPosition _location)];
		_m setMarkerShape "RECTANGLE";
		_m setMarkerSize _adjustedSize;
		_m setMarkerDir (direction _location);
		_m setMarkerColor _markerColor;
		if (GMSAI_debug > 1) then 
		{
			private _m2 = createMarker [format["GMSAI_StaticSpawnLabel%1%2",(text _location),_markerIndex],(locationPosition _location)];
			_m2 setMarkerType "hd_dot";
			_m2 setMarkerText format["%1 : %2",(name _location),(locationPosition _location)];
			//[format["Added location %1 | position %2 : size %3",name _location,(locationPosition _location), size _location]] call GMSAI_fnc_log;
		};
	} else {
		_m = createMarkerLocal [format["GMSAI_StaticSpawn%1%2",(text _location),_markerIndex],(locationPosition _location)];
		_m setMarkerShapeLocal "RECTANGLE";
		_m setMarkerSizeLocal _adjustedSize;
		_m setMarkerDirLocal (direction _location);
		//_m setMarkerColorLocal _markerColor;
	};
	_m  
};

private _markerIndex = 0;

_fn_setupLocationType = {
	params[
		"_locationType",
		"_aiDescriptor",
		"_markerColor"];

	//diag_log format["_fn_setupLocationType: _locationType %1 | _aiDescriptor %2",_locationType,_aiDescriptor];

	private _configuredAreas = [];
	{	
		private _blacklisted = false;
		private _loc = _x; 

		{
			//[format["Testing if location %1 at position %2 is inArea of blacklisted location %3",_loc,locationPosition _loc,_x]] call GMSAI_fnc_log;
			if ((locationPosition _loc) inArea _x) exitWith {_blacklisted = true};
		}forEach GMSAI_BlacklistedLocations;
		
		if !(_blacklisted) then 
		{
			_marker = [_x,_markerIndex,_markerColor] call _fn_createMarker;
			_markerIndex = _markerIndex + 1;
			[_marker,_aiDescriptor,false] call GMSAI_fnc_addStaticSpawn;
			_configuredAreas pushBack _marker;
		} else {
			if (GMSAI_debug > 0) then 
			{
				[format[" Location %1 at %2 is in a blacklisted area and was excluded",name _loc,locationPosition _loc]] call GMSAI_fnc_log;
			};
		};

	} forEach nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), [_locationType], worldSize];	
	_configuredAreas	
};

private _return = [];
if (GMSAI_staticVillageGroups) then 
{
	_return append (["NameVillage",GMSAI_staticVillageSettings,"COLORCIVILIAN"] call _fn_setupLocationType);
} else {
	if (GMSAI_debug > 0) then {
		[format["Static Spawns for Villages Disabled"]] call GMSAI_fnc_log;
	};
};
if (GMSAI_staticCityGroups) then 
{
	_return append ( ["NameCity",GMSAI_staticCitySettings,"COLORKHAKI"] call _fn_setupLocationType);
} else {
	if (GMSAI_debug > 0) then {	
		[format["Static Spawns for Cities Disabled"]] call GMSAI_fnc_log;
	};
};
if (GMSAI_staticCapitalGroups) then 
{
	_return append (["NameCityCapital",GMSAI_staticCapitalSettings,"COLORGREY"] call _fn_setupLocationType);
} else {
	if (GMSAI_debug > 0) then {	
		[format["Static Spawns for Capital Cities Disabled"]] call GMSAI_fnc_log;
	};
};
if (GMSAI_staticMarineGroups) then 
{
	_return append (["NameMarine",GMSAI_staticMarineSettings,"COLORBLUE"] call _fn_setupLocationType);
} else {
	if (GMSAI_debug > 0) then {
		[format["Static Spawns for Marine Areas Disabled"]] call GMSAI_fnc_log;
	};
};
if (GMSAI_staticOtherGroups) then 
{
	_return append (["NameLocal",GMSAI_staticOtherSettings,"COLORYELLOW"] call _fn_setupLocationType);
} else {
	if (GMSAI_debug > 0) then {	
		[format["Static Spawns for Other Areas Disabled"]] call GMSAI_fnc_log;
	};
};
if (GMSAI_staticOtherGroups) then 
{
	_return append (["Airport",GMSAI_staticOtherSettings,"COLORGREEN"] call _fn_setupLocationType);
} else {
	if (GMSAI_debug > 0) then {	
		[format["Static Spawns for Airports Disabled"]] call GMSAI_fnc_log;
	};
};

if (GMSAI_debug > 0) then {
	[format[" Initialized Static Spawns for locations at %1",diag_tickTime]] call GMSAI_fnc_log;
};
_return