/*
	GMSAI_fnc_validateConfigs 

	Purpose: 
		Perform checks to ensure that all class names listed in GMSAI_config.sqf are:
		1. Valid 
		2. are of the expected type (Aircraft, drone, Car/Tank, Weapon, etc)

	Returns: None 

	Copyright 2021 Ghostrider-GRG-
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

for "_i" from 1 to (count GMSAI_paratroopAircraftTypes) do 
{
	if (_i > (count GMSAI_paratroopAircraftTypes)) exitWith {};
	private _cn = GMSAI_paratroopAircraftTypes deleteAt 0;
	private _wt = GMSAI_paratroopAircraftTypes deleteAt 0;
	private _isClass = isClass(configFile >> "CfgVehicles" >> _cn);
	private _isAir = (_cn isKindOf "Air");
	private _isDrone = [_cn] call GMSCore_fnc_isDrone;	
	if !(_isClass) then 
	{
		[format["Error in GMSAI_config GMSAI_paratroopAircraftTypes: %1 is not a valid className and was removed from GMSAI_paratroopAircraftTypes",_cn]] call GMSAI_fnc_log;
	} else {
		if !(_isAir) then 
		{
			[format["Error in GMSAI_config GMSAI_paratroopAircraftTypes: %1 is not an aircraft and was removed from GMSAI_paratroopAircraftTypes",_cn]] call GMSAI_fnc_log;
		} else {
			if ([_cn] call GMSCore_fnc_isDrone) then 
			{
				[format["Error in GMSAI_config GMSAI_paratroopAircraftTypes: %1 is a Drone and  and was removed from GMSAI_paratroopAircraftTypes",_cn]] call GMSAI_fnc_log;
			} else {
				GMSAI_paratroopAircraftTypes pushBack _cn;
				GMSAI_paratroopAircraftTypes pushBack _wt;
			};
		};
	};
};

for "_i" from 1 to (count GMSAI_aircraftTypes) do 
{
	if (_i > (count GMSAI_aircraftTypes)) exitWith {};
	private _cn = GMSAI_aircraftTypes deleteAt 0;
	private _wt = GMSAI_aircraftTypes deleteAt 0;
	private _isClass = isClass(configFile >> "CfgVehicles" >> _cn);
	private _isAir = (_cn isKindOf "Air");
	private _isDrone = [_cn] call GMSCore_fnc_isDrone;
	if !(_isClass) then 
	{
		[format["Error in GMSAI_config GMSAI_aircraftTypes: %1 is not a valid className and was removed from GMSAI_aircraftTypes",_cn]] call GMSAI_fnc_log;
	} else {
		if !(_isAir) then 
		{
			[format["Error in GMSAI_config GMSAI_aircraftTypes: %1 is not an aircraft and was removed from GMSAI_aircraftTypes",_cn]] call GMSAI_fnc_log;
		} else {
			if (_isDrone) then 
			{
				[format["Error in GMSAI_config GMSAI_aircraftTypes: %1 is a Drone and was removed from GMSAI_aircraftTypes",_cn]] call GMSAI_fnc_log;
			} else {
				GMSAI_aircraftTypes pushBack _cn;
				GMSAI_aircraftTypes pushBack _wt;
			};
		};
	};
};

for "_i" from 1 to (count GMSAI_UAVTypes) do 
{
	if (_i > (count GMSAI_UAVTypes)) exitWith {};
	private _cn = GMSAI_UAVTypes deleteAt 0;
	private _wt = GMSAI_UAVTypes deleteAt 0;
	private _isClass = isClass(configFile >> "CfgVehicles" >> _cn);
	private _isAir = (_cn isKindOf "Air");
	private _isDrone = [_cn] call GMSCore_fnc_isDrone;
	if !(_isClass) then 
	{
		[format["Error in GMSAI_config GMSAI_UAVTypes: %1 is not a valid classname and was removed from GMSAI_UAVTypes",_cn]] call GMSAI_fnc_log;
	} else {
		if !(_isAir) then 
		{
			[format["Error in GMSAI_config GMSAI_UAVTypes: %1 is not an aircraft and was removed from GMSAI_UAVTypes",_cn]] call GMSAI_fnc_log;
		} else {
			if !(_isDrone) then 
			{
				[format["Error in GMSAI_config GMSAI_UAVTypes: %1 is not a Drone and was removed from GMSAI_UAVTypes",_cn]] call GMSAI_fnc_log;
			} else {
				GMSAI_UAVTypes pushBack _cn;
				GMSAI_UAVTypes pushBack _wt;
			};
		};
	};
};

[format["_validateConfigs: GMSAI_UGVtypes = %1", GMSAI_UGVtypes]] call GMSAI_fnc_log;
for "_i" from 1 to (count GMSAI_UGVtypes) do 
{
	if (_i > (count GMSAI_UGVtypes)) exitWith {};
	private _cn = GMSAI_UGVtypes deleteAt 0;
	private _wt = GMSAI_UGVtypes deleteAt 0;
	private _isClass = isClass(configFile >> "CfgVehicles" >> _cn);
	private _isCar = (_cn isKindOf "LandVehicle");
	private _isDrone = [_cn] call GMSCore_fnc_isDrone;	
	if !(_isClass) then 
	{
		[format["Error in GMSAI_config GMSAI_UGVtypes: %1 is not a valid classname and was removed from GMSAI_UGVtypes",_cn]] call GMSAI_fnc_log;
	} else {
		if !(_isCar) then 
		{
			[format["Error in GMSAI_config GMSAI_UGVtypes: classname %1 is not a UGV and was removed from GMSAI_UGVtypes",_cn]] call GMSAI_fnc_log;
		} else {
			if !(_isDrone) then 
			{
				[format["Error in GMSAI_config GMSAI_UGVtypes: classname %1 is not a Drone and was removed from GMSAI_UGVtypes",_cn]] call GMSAI_fnc_log;
			} else {
				//GMSAI_UGVtypes pushBack _cn;
				//GMSAI_UGVtypes pushBack _wt;
			};
		};
	};
};
[format["_validateConfigs: after classname validation, GMSAI_UGVtypes = %1", GMSAI_UGVtypes]] call GMSAI_fnc_log;
for "_i" from 1 to (count GMSAI_patrolVehicles) do 
{
	if (_i > (count GMSAI_patrolVehicles)) exitWith {};
	private _cn = GMSAI_patrolVehicles deleteAt 0;
	private _wt = GMSAI_patrolVehicles deleteAt 0;
	private _isClass = isClass(configFile >> "CfgVehicles" >> _cn);
	private _isCar = (_cn isKindOf "LandVehicle");
	private _isDrone = [_cn] call GMSCore_fnc_isDrone;	
	if !(_isClass) then 
	{
		[format["Error in GMSAI_config GMSAI_patrolVehicles: %1 is not a valid className GMSAI_patrolVehicles",_cn]] call GMSAI_fnc_log;
	} else {
		if !(_isCar) then 
		{
			[format["Error in GMSAI_config GMSAI_patrolVehicles: %1 is not a car or tank GMSAI_patrolVehicles",_cn]] call GMSAI_fnc_log;
		} else {
			if (_isDrone) then 
			{
				[format["Error in GMSAI_config GMSAI_patrolVehicles: %1 is a Drone GMSAI_patrolVehicles",_cn]] call GMSAI_fnc_log;
			} else {
				GMSAI_patrolVehicles pushBack _cn;
				GMSAI_patrolVehicles pushBack _wt;
			};
		};
	};
};
[format["Completed validation of GMSAI_configs.sqf at %1",diag_tickTime]] call GMSAI_fnc_log;