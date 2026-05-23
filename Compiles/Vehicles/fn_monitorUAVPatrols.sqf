/*
	GMSAI_fnc_monitorUAVPatrols 

	Purpose: monitor UAV patrols

	Parameters: None 

	Returns: None 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		Hunting is handled by GMSCore now.
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _monitorUAVPatrols called at %1 with count GMSAI_UAVPatrols = %2",diag_tickTime,count GMSAI_UAVPatrols];

if (GMSAI_monitorUAVPatrolsActive) exitWith {};
GMSAI_monitorUAVPatrolsActive = true; 

for "_i" from 1 to (count GMSAI_UAVPatrols) do
{
	if (_i > (count GMSAI_UAVPatrols)) exitWith {};
	private _uavPatrol = GMSAI_UAVPatrols deleteAt 0;
	_uavPatrol params["_blacklistedAreas","_crewGroup","_aircraft","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availAircraft"];  //,"_spawned"];
	private ["_crewCount","_countUnits","_addBack","_respawn"];
	try {
		private "_action";
		if (_lastSpawned <= 0) then {
			_action = 2;
		} else { // no patrol spawned, so check if conditions for spanwn are met.
			private _numberCrew = {alive _x} count (crew _aircraft);
			private _numberUnits =  ({alive _x} count (units _crewGroup));
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
							_action = 0; // Vehicle gone but some units survive so set them up as a random patrol with time limits; set for respawn
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
				//diag_log format["_monitorUAVPatrols(case 0) called"];
				if (_respawns == -1 || _timesSpawned <= _respawns) then
				{
					_uavPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_uavPatrol set[3,-1];
					GMSAI_UAVPatrols pushBack _uavPatrol;
				};
			};
			case 1: { // an aircraft patrol is acrtive;  check if paratroups should be spawned, check fuel, keep monitoring.
				//diag_log format["_monitorUAVPatrols(case 1) called"];
				if (fuel _aircraft < 0.1) then {_aircraft setFuel 1.0};
				#define isUAV false 
				//if (!surfaceIsWater (getPosASL _aircraft)) then {[_crewGroup,_aircraft,isUAV] call GMSAI_fnc_spawnParatroops};
				GMSAI_UAVPatrols pushBack _uavPatrol
			};
			case 2: {  // Test if it is time to spawn a new aircraft
				//diag_log format["_monitorUAVPatrols(case 2) called"];
				// This will spawn an aircraft on server startup because _respawnAt is set to -1 so diag_tickTime is always > _respawnAt at server startup.
				if (diag_tickTime > _respawnAt) then
				{
					_pos = [[] call GMSCore_fnc_getMapMarker, _blacklistedAreas] call GMSAI_fnc_findPositionAirPatrol;

					if !(_pos isEqualTo [0,0]) then 
					{
						/*
						params[
							"_difficulty",
							"_className",				// classname of the drone to use
							"_pos",					// Random position for patrols that roam the whole map 
													// or center of the area to be patrolled for those that are restricted to a smaller region
							["_patrolArea","Map"],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
							["_markerDelete",false]
						];
						*/
						
						_newPatrol = [
							selectRandomWeighted _availDifficulties,
							selectRandomWeighted _availAircraft,
							_pos,
							[] call GMSCore_fnc_getMapMarker,
							false
						] call GMSAI_fnc_spawnUAVPatrol;
						
						_newPatrol params["_group","_aircraft"];

						//[format["_monitorUAVPatrols: _newPatrol = %1", _newPatrol]] call GMSAI_fnc_log;
						if (!(isNull _group) && !(isNull _aircraft)) then {
							_uavPatrol set[1,_group];
							_uavPatrol set[2,_aircraft];
							_uavPatrol set[3,diag_tickTime];
							_uavPatrol set[4,_timesSpawned + 1];
							GMSAI_UAVPatrolGroups pushBack _group;//  Used only to count the number of active groups serving this function.
														// This list is monitored by _mainThread and empty or null groups are periodically removed.
							[format["_monitorUAVPatrols: spawned aircraft patrol at %1 using aircraft %2 with _group = %3 and _aircraft = %4",_pos, typeOf _aircraft,_group,_aircraft]] call GMSAI_fnc_log;														
						} else {
							// Something happened - try again later
							_uavPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
							_uavPatrol set[3,-1];
							if (isNull _group) then {
								_action = 1;
							} else {;
								if (isNull _aircraft) then {_action = 2};
							};
							[_group] call GMSCore_fnc_destroyVehicleAndCrew; 
							if (GMSAI_debug > 0) then {[format["_monitorUGAPatrols: GMSAI_fnc_spawnUAVPatrol returned nullGrp %1 : UGV %2", _crewGroup, _UGV]] call GMSAI_fnc_log};
							GMSAI_UAVPatrols pushBack _uavPatrol;
							throw _action; // _group was null for some reason	
						};
					};
				};
				GMSAI_UAVPatrols pushBack _uavPatrol;
			};
			case 3: {  // Vehicle survived but all crew killed; move vehicle to cue players can claim; set patrol up for respawn. 
						// Vehicle is automatically moved to the cue for empty vehicles and handled according to setting passed when it was spawned  
						// So all we need to do here is set things up to respawn the patrol.
					//diag_log format["_monitorUAVPatrols(case 3) called"];						
					_uavPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_uavPatrol set[3,-1];
					GMSAI_UAVPatrols pushBack _uavPatrol;
			};
			case 4: {  // some units survive so set them up as a random patrol with time limits; set for respawn
					// Vehicle is automatically moved to the cue for empty vehicles and handled according to setting passed when it was spawned  
					//diag_log format["_monitorUAVPatrols(case 4) called"];
					// UAV units are not great combatants so let's get rid of them
					{deleteVehicle _x} forEach (units _group);
					GMSAI_UAVPatrols pushBack _uavPatrol;
			};
		};			
	}

	catch {
		switch (_exception) do {
			case 1: {
				// GMSAI_fnc_spawnAircraftPatrol returned grpNull for _group 				

				[format["[GMSAI] _monitorUAVPatrols: GMSAI_fnc_spawnAircraftPatrol returned grpNull for _group at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
			case 2: {
				// GMSAI_fnc_spawnAircraftPatrol returned objNull for _aircraft 				
				
				[format["[GMSAI] _monitorUAVPatrols: GMSAI_fnc_spawnAircraftPatrol returned objNull for _aircraft at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
		};
	};
};

GMSAI_monitorUAVPatrolsActive = false;
