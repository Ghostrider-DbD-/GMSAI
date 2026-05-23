/*
	GMSAI_fnc_monitorAirPatrols 

	Purpose: ensure that air patrols do not get 'stuck' finding a waypoint 
			and are recalled when the wander too far from the patrol area
	
	Parameters: None 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		Hunting is handled by GMSCore now.
*/

/*
	
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//[format[" _monitorAirPatrols called at %1 for %2 ACTIVE Air Patrols",diag_tickTime, count GMSAI_airPatrols]] call GMSAI_fnc_log;

if (GMSAI_monitorVehiclePatrolsActive) exitWith {};
GMSAI_monitorAircraftPatrolsActive = true; 

for "_i" from 1 to (count GMSAI_airPatrols) do
{
	if (_i > (count GMSAI_airPatrols)) exitWith {};
	private _airPatrol = GMSAI_airPatrols deleteAt 0;
	_airPatrol params["_blacklistedAreas","_group","_aircraft","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availAircraft"];  //,"_spawned"];

	private ["_crewCount","_countUnits","_addBack","_respawn"];

	try {
		private _varNames = ["_blacklistedAreas","_group","_aircraft","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availAircraft"];
		private "_action";

		if (_lastSpawned <= 0) then {
			 _action = 2;
		 } else { // no patrol spawned, so check if conditions for spanwn are met.
			private _numberCrew = {alive _x} count (crew _aircraft);
			private _numberUnits =  ({alive _x} count (units _group));
			if (alive _aircraft && _numberCrew > 0) then {
				_action = 1; // check fuel and continue monitoring 
			} else {
				if (alive _aircraft && _numberCrew == 0 && _numberUnits == 0) then {
					_action = 3;  // Vehicle survived but all crew killed; move vehicle to cue players can claim; set patrol up for respawn. 
				} else {
					if (alive _aircraft && _numberCrew == 0 && _numberUnits > 0) then {
						_action = 4;
					} else {
						if (!alive _aircraft && _numberUnits > 0) then {
							_action = 4; // Vehicle gone but some units survive so set them up as a random patrol with time limits; set for respawn
						} else {
							if (!alive _aircraft && _numberUnits == 0) then {
								_action = 0;
							};  // all crew dead, vehicle destroyed, configure for respawn 
						};
					};
				};
		 	};
		};
		switch (_action) do {
			case 0: { // All crew dead and/or aircraft dead 
				//diag_log format["_monitorAirPatrols(case 0) called"];
				if (_respawns == -1 || _timesSpawned <= _respawns) then
				{
					_airPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_airPatrol set[3,-1];
					GMSAI_airPatrols pushBack _airPatrol;
				};
			};
			case 1: { // an aircraft patrol is acrtive;  check if paratroups should be spawned, check fuel, keep monitoring.
				//diag_log format["_monitorAirPatrols(case 1) called"];

				// Reinforcements code moved to GMSCore 
				// 11/4/2025
				/*
				if (fuel _aircraft < 0.1) then {_aircraft setFuel 1.0};
				#define isUAV false 
				if (!surfaceIsWater (getPosASL _aircraft)) then {[_group,_aircraft,isUAV] call GMSAI_fnc_spawnParatroops};
				*/
				GMSAI_airPatrols pushBack _airPatrol;
			};
			case 2: {  // Test if it is time to spawn a new aircraft
				//  
				//diag_log format["_monitorAirPatrols(case 2) called"];
				// This will spawn an aircraft on server startup because _respawnAt is set to -1 so diag_tickTime is always > _respawnAt at server startup.
				if (diag_tickTime > _respawnAt) then
				{
					_pos = [[] call GMSCore_fnc_getMapMarker, _blacklistedAreas] call GMSAI_fnc_findPositionAirPatrol;

					if !(_pos isEqualTo []) then 
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

						//[format["_monitorAirPatrols: _newPatrol select 0 %1 | _newPatrol select 1 %2", _newPatrol select 0, _newPatrol select 1]] call GMSAI_fnc_log; 
						
						if (!(isNull _group) && !(isNull _aircraft)) then {
							_airPatrol set[1,_group];
							_airPatrol set[2,_aircraft];
							_airPatrol set[3,diag_tickTime];
							_airPatrol set[4,_timesSpawned + 1];
							[format["_monitorAirPatrols: spawned aircraft patrol at %1 using aircraft %2 with _group = %3 and _aircraft = %4",_pos, typeOf _aircraft,_group,_aircraft]] call GMSAI_fnc_log;
							GMSAI_AirPatrolGroups pushBack _group; //  Used only to count the number of active groups serving this function.
														// This list is monitored by _mainThread and empty or null groups are periodically removed.
						} else {
							// Something happened - try again later
							private _action = 0;
							if !(isNull _aircraft) then {
								[_group] call GMSCore_fnc_destroyVehicleAndCrew;
								_action = _action + 1;
							} else {
								if !(isNull _group) then {[_group] call GMSCore_fnc_despawnInfantryGroup};
								_action = _action + 2;
							};

							_airPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
							_airPatrol set[3,-1];
							GMSAI_airPatrols pushBack _airPatrol;
																	
							throw _action; // _group and/or aircraft was null for some reason	
						};
					};
				};
				GMSAI_airPatrols pushBack _airPatrol;
			};
			case 3: {  // Vehicle survived but all crew killed; move vehicle to cue players can claim; set patrol up for respawn. 
						// Vehicle is automatically moved to the cue for empty vehicles and handled according to setting passed when it was spawned  
						// So all we need to do here is set things up to respawn the patrol.
					//diag_log format["_monitorAirPatrols(case 3) called"];						
					_airPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_airPatrol set[3,-1];
					GMSAI_airPatrols pushBack _airPatrol;
			};
			case 4: {  // vehicle empty or crashed with some units surviving so set them up as a random patrol with time limits; set for respawn
					// Vehicle is automatically moved to the cue for empty vehicles and handled according to setting passed when it was spawned  
					//diag_log format["_monitorAirPatrols(case 4) called"];
					private _patrolArea = createMarkerLocal[format["GMSAI_remnant%1",_group],getPosATL _aircraft];
					//{_group reveal[_x,4]} forEach [(getPosATL (leader _group)), 150] call GMSCore_fnc_nearestPlayers; 
					//_group setVariable["target",_nearPlayers select 0];
					_patrolArea setMarkerShapeLocal "RECTANGLE";
					_patrolArea setMarkerSizeLocal [150,150];
					//  	_area params["_patrolAreaMarker","_staticAiDescriptor","_areaActive","_spawnedGroups","_debugMarkers","_respawnAt","_timesSpawned","_lastDetected","_markerDelete","_lastPingedPlayer"];
					//  	_staticAiDescriptor params["_unitsPerGroup","_difficulty","_chance","_maxRespawns","_respawnTime", "_despawnTime","_types"];
					/*
						params[
							["_patrolArea",""],
							["_staticAiDescriptor",[]],
							['_active',true],
							["_groups",[]],
							["_debugMarkers",[]],
							["_respawnAt",-1],
							["_timesSpawned",1],
							["_lastDetected",diag_tickTime],
							["_deleteMarker",false],
							["_respawnTimer",1000000]
						];
					*/
					[
						_patrolArea,
						[0, 0, 0, 0, 10000, 300, ["Infantry"]],  //  _staticAIDescriptor 
						true,
						[_group],
						[],
						-1,
						1,
						diag_tickTime,
						true,
						10000000
					] call GMSAI_fnc_addActiveSpawn; 

					/*
					[
						_group,
						GMSAI_BlacklistedLocations,
						_patrolArea,
						300,  // waypoint timeout
						GMSAI_chanceToGarisonBuilding,
						"Infantry",
						false  // do not delete marker defining patrol area of the group is all dead
					] call GMSCore_fnc_initializeWaypointsAreaPatrol;
					*/
					GMSAI_airPatrols pushBack _airPatrol;					
			};
		};		
	}

	catch {
		switch (_exception) do {
			case 1: {
				// GMSAI_fnc_spawnAircraftPatrol returned grpNull for _group 

				[format["[GMSAI] _monitorAirPatrols: GMSAI_fnc_spawnAircraftPatrol returned grpNull for _group at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
			case 2: {
				// GMSAI_fnc_spawnAircraftPatrol returned objNull for _aircraft 
				
				[format["[GMSAI] _monitorAirPatrols: GMSAI_fnc_spawnAircraftPatrol returned objNull for _aircraft at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
		};
	};	
};
//[format["[GMSAI] _monitorAirPatrols ended at %1 with %2 ACTIVE Air Patrols",diag_tickTime, count GMSAI_airPatrols]] call GMSAI_fnc_log;
GMSAI_monitorAircraftPatrolsActive = false;