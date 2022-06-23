/*
	GMSAI_fnc_monitorAirPatrols 

	Purpose: ensure that air patrols do not get 'stuck' finding a waypoint 
			and are recalled when the wander too far from the patrol area
	
	Parameters: None 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-
*/

#include "\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//[format["[GMSAI] _monitorAirPatrols called at %1 for %2 ACTIVE Air Patrols",diag_tickTime, count GMSAI_airPatrols]] call GMSAI_fnc_log;
for "_i" from 1 to (count GMSAI_airPatrols) do
{
	if (_i > (count GMSAI_airPatrols)) exitWith {};
	private _airPatrol = GMSAI_airPatrols deleteAt 0;
	_airPatrol params["_blacklistedAreas","_crewGroup","_aircraft","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availAircraft"];  //,"_spawned"];

	#define vehCrewGroup 1
	#define currVehicle 2
	#define vehLastSpawned 3
	#define vehTimesSpawned 4 
	#define vehRespawnAt 5 
	#define vehRespawns 6 
	#define availDifficultiy 7
	#define availVehicles 8 
	#define crewGroupOnFood 9

	private ["_crewCount","_countUnits","_addBack","_respawn"];
	_addBack = true;
	if (_lastSpawned > 0) then
	{
		if (isNull _crewGroup) then 
		{
			_crewCount = 0;
			_countUnits = 0;
		} else {
			_crewCount = {alive _x} count (crew _aircraft);
			_countUnits = ({alive _x} count (units _crewGroup)) - _crewCount;  // units on foot
		};
		//[format["GMSAI_fnc_monitorAirPatrols: _aircraft %1 | _crewGroup %2 | _crewCount %3 | _countUnits %4",_aircraft,_crewGroup,_crewCount,_countUnits]] call GMSAI_fnc_log;
		if ( !isNull _aircraft && !isNull _crewGroup && !(_crewCount == 0) ) then 
		{
			if ((fuel _aircraft < -0.1)) then 
			{
				// Refresh patrols when low on fuel and there are no players around to see the despawn occur.
				if ([getPosATL _aircraft,500] call GMSCore_fnc_nearestPlayers isEqualTo []) then {[_group] call GMSCore_fnc_destroyVehicleAndCrew};
			} else {
				#define isUAV false
				if (_aircraft distance GMSAI_mapCenter > GMSAI_mapRadius || surfaceIsWater (position _aircraft)) then 
				{
					[leader _crewGroup] call GMSCore_fnc_nextWaypointAreaPatrol;
					//[format["GMSA_fnc_monitorairPatrols: _aircraft %1 outside GMSAI_mapRadius %2 at distance %3",_aircraft,GMSAI_mapRadius,_aircraft distance GMSAI_mapCenter]] call GMSAI_fnc_log;
				} else {
					private _spawned = [_crewGroup,_aircraft,isUAV] call GMSAI_fnc_spawnParatroops;
				};
			};
		} else {		
			// handle the case where aircraft has been destroyed or crew killed.
			//[format["_monitorAirPatrols: configuring patrol for respawning: _airpatrol %1",_airpatrol]] call GMSAI_fnc_log;
			_airPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
			_airPatrol set[3,-1];
		
		};
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
					//[format["GMSAI_fnc_monitorAircraftPatrols: respawned aircraft patrol at %1 using aircraft %2",_pos,typeOf _aircraft]] call GMSAI_fnc_log;
					if !(isNull _group) then 
					{
						if (GMSAI_debug > 0) then {[format["GMSAI_fnc_monitorAircraftPatrols: _newPatrol spawned: group %1 : aircraft type %2", _newPatrol select 0, typeOf (_newPatrol select 1)]] call GMSAI_fnc_log};
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

		} else {
			_addBack = false;
		};
	};
	if (_addBack) then {GMSAI_airPatrols pushBack _airPatrol};
};
