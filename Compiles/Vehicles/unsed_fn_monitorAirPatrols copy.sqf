/*
	GMSAI_fnc_monitorAirPatrols 

	Purpose: ensure that air patrols do not get 'stuck' finding a waypoint 
			and are recalled when the wander too far from the patrol area
	
	Parameters: None 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-
*/

#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
[format["[GMSAI] _monitorAirPatrols called at %1 for %2 ACTIVE Air Patrols",diag_tickTime, count GMSAI_airPatrols]] call GMSAI_fnc_log;
for "_i" from 1 to (count GMSAI_airPatrols) do
{
	if (_i > (count GMSAI_airPatrols)) exitWith {};
	private _airPatrol = GMSAI_airPatrols deleteAt 0;
	_airPatrol params["_blacklistedAreas","_crewGroup","_aircraft","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availAircraft"];  //,"_spawned"];

	if (_lastSpawned > 0) then
	{
		private _crewCount = 0;
		private _countUnits = 0;
		
		if !(isNull _crewGroup) then 
		{
			_crewCount = {alive _x} count (crew _aircraft);
			_countUnits = {alive _x} count (units _crewGroup);
		};
		
		if (isNull _aircraft || isNull _crewGroup || _crewCount == 0) then 
		{
			// handle the case where aircraft has been destroyed or crew killed.
			[format["_monitorAirPatrols: configuring respawn parameters for _airpatrol %1",_airpatrol]] call GMSAI_fnc_log;
			_airPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
			_airPatrol set[3,-1];
		} else {
			#define isUAV false
			//[format["GMSA_fnc_monitorairPatrols: calling GMSAI_fnc_spawnParatroops at %1",diag_tickTime]] call GMSAI_fnc_log;
			/*
				GMSAI_world = worldname;
				GMSAI_worldSize = worldSize;
				GMSAI_axis = GMSAI_worldSize / 2;
				GMSAI_mapCenter = [GMSAI_axis, GMSAI_axis, 0];
				GMSAI_mapRadius = sqrt 2 * GMSAI_axis;
				GMSAI_maxRangePatrols =  GMSAI_axis * 2 / 3;			
			*/

			/*
			if (_aircraft distance GMSAI_mapCenter > GMSAI_mapRadius || surfaceIsWater (position _aircraft)) then 
			{
				[leader _crewGroup] call GMSCore_fnc_nextWaypointAreaPatrol;
				[format["GMSA_fnc_monitorairPatrols: _aircraft %1 outside GMSAI_mapRadius %2 at distance %3",_aircraft,GMSAI_mapRadius,_aircraft distance GMSAI_mapCenter]] call GMSAI_fnc_log;
			} else {
				*/
				private _spawned = [_crewGroup,_aircraft,isUAV] call GMSAI_fnc_spawnParatroops;
			
		};
		_airCraft setFuel 1.0;
		GMSAI_airPatrols pushBack _airPatrol;		
	} else {
		// check if further spawns / respans are allowed
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
						[selectRandomWeighted _availDifficulties] call GMSCore_fnc_getIntegerFromRange,
						selectRandomWeighted _availAircraft,
						_pos,
						[] call GMSCore_fnc_getMapMarker,
						_blacklistedAreas,
						GMSAI_waypointTimeout,
						GMSAI_aircraftFlyinHeight
					] call GMSAI_fnc_spawnAircraftPatrol;
					_newPatrol params["_group","_aircraft"];
			
					if !(isNull _group) then 
					{
						if (GMSAI_debug > 0) then {[format["monitorAirPatrols: _newPatrol spawned: group %1 : aircraft type %2", _newPatrol select 0, typeOf (_newPatrol select 1)]] call GMSAI_fnc_log};
						_airPatrol set[1,_group];
						_airPatrol set[2,_aircraft];
						_airPatrol set[3,diag_tickTime];
						_airPatrol set[4,_timesSpawned + 1];
						GMSAI_AirPatrolGroups pushBack _group;
					} else {
						// Something happened - try again later
						_airPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
						_airPatrol set[3,-1];						
					};
				};
			};
			GMSAI_airPatrols pushBack _airPatrol;
		};
	};
};
