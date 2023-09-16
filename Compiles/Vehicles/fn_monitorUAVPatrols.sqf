/*
	GMSAI_fnc_monitorUAVPatrols 

	Purpose: monitor UAV patrols, check if the are stuck or out of bounds, deal with this if so. 

	Parameters: None 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		TODO: consider additional targeting commands as specified in _monitorAirPatrols
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _monitorUAVPatrols called at %1 with count GMSAI_uavPatrols = %2",diag_tickTime,count GMSAI_uavPatrols];
for "_i" from 1 to (count GMSAI_uavPatrols) do
{
	if (_i > (count GMSAI_uavPatrols)) exitWith {};
	private _uavPatrol = GMSAI_uavPatrols deleteAt 0;
	_uavPatrol params["_blacklistedAreas","_crewGroup","_aircraft","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availAircraft"];  //,"_spawned"];

	//diag_log format["[GMSAI] _monitorUAVPatrols _crewGroup %1 | _aircraft %2",_crewGroup,_aircraft];
	private _crewCount = 0;
	private _countUnits = 0;
	
	if !(isNull _crewGroup) then 
	{
		_crewCount = {alive _x} count (crew _aircraft);
		_countUnits = {alive _x} count (units _crewGroup);
	};	
	if (_lastSpawned > 0) then
	{
		if (isNull _crewGroup || isNull _aircraft || _crewCount == 0) then
		{
			_uavPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
			_uavPatrol set[3,-1];
		} else {
			#define isUAV true
			[_crewGroup,_aircraft,isUAV] call GMSAI_fnc_spawnParatroops;
		};
		_aircraft setFuel 1.0;
		//GMSAI_uavPatrols pushBack _uavPatrol;
	} else {
		if (_respawns == -1 || _timesSpawned <= _respawns) then
		{
			if (diag_tickTime > _respawnAt) then
			{
				_pos = [0,0];
				private _gmsMarker = [] call GMSCore_fnc_getMapMarker;
				private _center = markerPos _gmsMarker;
				private _radius = ((markerSize _gmsMarker) select 0)/3;
				private "_newPatrol";
				_pos = [[[_center,_radius]],["water"]] call BIS_fnc_randomPos;
				if !(_pos isEqualTo [0,0]) then 
				{
					_newPatrol = [
						selectRandomWeighted _availDifficulties,
						selectRandomWeighted _availAircraft,
						_pos,
						[] call GMSCore_fnc_getMapMarker,
						_blacklistedAreas,					
						300,
						false
					] call GMSAI_fnc_spawnUAVPatrol;
					_newPatrol params["_group","_uav"];
					if !(isNull _group) then 
					{
						[format["GMSAI_fnc_monitorUAVPatrols: _newPatrol spawned: group %1 : UAV type %2", _newPatrol select 0, typeOf (_newPatrol select 1)]] call GMSAI_fnc_log;
						_uavPatrol set[1,_group];
						_uavPatrol set[2,_uav];
						_uavPatrol set[3,diag_tickTime];
						_uavPatrol set[4,_timesSpawned + 1];
						GMSAI_UAVGroups pushBack _group;
					} else {
						// Something happened - try again later
						_uavPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
						_uavPatrol set[3,-1];	
					};
				};
			};
			GMSAI_uavPatrols pushBack _uavPatrol;
		};
	};
};


