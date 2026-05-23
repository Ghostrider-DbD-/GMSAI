/*
	Purpose: keep an eye on land vehicle patrols, unstuck them where needed, return them to the patrol area if needed. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		-May want to take advantage of the setMode commands in GMS for these monitoring script for the case where the thing went outside the patrol area
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _monitorVehiclePatrols called at %1 with count GMSAI_vehiclePatrols %2",diag_tickTime, count GMSAI_vehiclePatrols];

if (GMSAI_monitorVehiclePatrolsActive) exitWith {};
GMSAI_monitorVehiclePatrolsActive = true; 

#define vehCrewGroup 1
#define currVehicle 2
#define vehLastSpawned 3
#define vehTimesSpawned 4 
#define vehRespawnAt 5 
#define vehRespawns 6 
#define availDifficultiy 7
#define availVehicles 8 
#define crewGroupOnFood 9
#define spawnVehicleOnRoad true 

//diag_log format["_monitorVehiclePatrols: count GMSAI_vehiclePatrols = %1",count GMSAI_vehiclePatrols];
for "_i" from 1 to (count GMSAI_vehiclePatrols) do {

	if (_i > (count GMSAI_vehiclePatrols)) exitWith {};
	private _vehiclePatrol = GMSAI_vehiclePatrols deleteAt 0;
	_vehiclePatrol params["_blacklistedAreas","_crewGroup","_vehicle","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availVehicles"];  

	private ["_crewCount","_countUnits","_addBack","_respawn"];
	
	try {
		private "_action";

		if (_lastSpawned <= 0) then {
			_action = 2;
		} else { // no patrol spawned, so check if conditions for spanwn are met.
			private _numberCrew = {alive _x} count (crew _vehicle);
			private _numberUnits =  ({alive _x} count (units _crewGroup));
			//diag_log format["_monitorVehiclePatrols(46): _numberCrew %1 | _numberUnits %2 | _crewGroup %3| _vehicle %4",_numberCrew, _numberUnits, _crewGroup, _vehicle];
			if (alive _vehicle && _numberCrew > 0) then {
				_action = 1; // check fuel and continue monitoring 
			} else {
				if (alive _vehicle && _numberCrew == 0 && _numberUnits == 0) then {
					_action = 3;  // Vehicle survived but all crew killed; move vehicle to cue players can claim; set patrol up for respawn. 
				} else {
					if (alive _vehicle && _numberCrew == 0 && _numberUnits > 0) then {
						_action = 4;  // vehicle survived, all crew out of vehicle so set up a patrol area for them, set for respawn
					} else {
						if (!alive _vehicle && _numberUnits > 0) then {
							_action = 4; // Vehicle gone but some units survive so set them up as a random patrol with time limits; set for respawn
						} else {
							if (!alive _vehicle && _numberUnits == 0) then {
								_action = 0;
							};  // all crew dead, vehicle destroyed, configure for respawn 
						};
					};
				};
			};
		};	

		switch (_action) do {			
			case 0: { // All crew dead and/or vehicle dead 
				//diag_log format["_monitorVehiclePatrols(case 0) called"];
				if (_respawns == -1 || _timesSpawned <= _respawns) then
				{
					_vehiclePatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_vehiclePatrol set[3,-1];
				};
			};
			case 1: { // a vehicle patrol is active; check fuel, keep monitoring.
				//diag_log format["_monitorVehiclePatrols(case 1) called"];

				if (fuel _vehicle < 0.1) then {_vehicle setFuel 1.0};
				private _lastPos = _crewGroup getVariable["lastPosition",[0,0]];
				private _lastTime = _crewGroup getVariable["lastTime",0];
				private _spawnedAt = _crewGroup getVariable["spawnedAt",0];
				if (_spawnedAt == 0) then {_crewGroup setVariable["spawnedAt", diag_tickTime]};
				GMSAI_vehiclePatrols pushBack _vehiclePatrol;
			};
			case 2: {  // Test if it is time to spawn a new Vehicle  
				//diag_log format["_monitorVehiclePatrols(case 2) called"];
				// This will spawn an Vehicle on server startup because _respawnAt is set to -1 so diag_tickTime is always > _respawnAt at server startup.

				if (diag_tickTime > _respawnAt) then
				{

					_pos = [[] call GMSCore_fnc_getMapMarker, _blacklistedAreas] call GMSAI_fnc_findPositionLandPatrol; 

					//diag_log format["_monitorVehiclePatrols(103): _pos = %1 for position of  anearby road",_pos];	
					/*
						params[
						"_difficulty",
						"_classname",			// className of vehicle to spawn
						"_pos",					// Random position for patrols that roam the whole map 
												// or center of the area to be patrolled for those that are restricted to a smaller region
						["_patrolArea", [] call GMSCore_fnc_getMapMarker],  // "Map" will direct the vehicle to patrol the entire map, "Region", a smaller portion of the map.
						["_markerDelete",false]
					];  
					*/
					// TODO: Need to adopt new system for spawning 
					private _newPatrol = [
						[selectRandomWeighted _availDifficulties] call GMSCore_fnc_getIntegerFromRange,
						selectRandomWeighted _availVehicles,
						_pos,
						[] call GMSCore_fnc_getMapMarker,  //  The marker for teh whole map
						false, // deleteMarker 
						false // spawnOnRoads							
					] call GMSAI_fnc_spawnVehiclePatrol;

					_newPatrol params["_crewGroup","_vehicle"];
										
					if ((!isNull _crewGroup) && !(isNull _vehicle)) then { 
						_vehiclePatrol set[vehCrewGroup,_crewGroup];
						_vehiclePatrol set[currVehicle,_vehicle];
						_vehiclePatrol set[vehLastSpawned,diag_tickTime];
						_vehiclePatrol set[vehTimesSpawned,_timesSpawned + 1];

						_vehiclePatrol set[1,_crewGroup];
						_vehiclePatrol set[2,_vehicle];
						_vehiclePatrol set[3,diag_tickTime];
						_vehiclePatrol set[4,_timesSpawned + 1];
						[format["_monitorVehiclePatrols: spawned vehicle patrol at %1 using typeOf vehicle %2  vehicle %3 with group %4",_pos, typeOf _vehicle, _vehicle, _crewGroup]] call GMSAI_fnc_log;
						GMSAI_vehiclePatrolGroups pushBack _crewGroup; //  Used only to count the number of active groups serving this function.
															// This list is monitored by _mainThread and empty or null groups are periodically removed.
					} else {
							// Something happened - try again later
				
							_vehiclePatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
							_vehiclePatrol set[3,-1];
							[_crewGroup] call GMSCore_fnc_destroyVehicleAndCrew; 	
							GMSAI_vehiclePatrols pushBack _vehiclePatrol;
							if (isNull _crewGroup) then {
								_action = 1;
							} else {;
								if (isNull _vehicle) then {_action = 2};
							};
							if (GMSAI_debug > 0) then {[format["GMSAI_fnc_monitorVehiclePatrols: GMSAI_fnc_spawnVehiclePatrol returned nullGrp %1 : Vehicle %2", _crewGroup, _vehicle]] call GMSAI_fnc_log};
							throw _action; // _crewGroup was null for some reason	
					};

				};
				GMSAI_vehiclePatrols pushBack _vehiclePatrol;
			};
			case 3: {  // Vehicle survived but all crew killed; move vehicle to cue players can claim; set patrol up for respawn. 
						// Vehicle is automatically moved to the cue for empty vehicles and handled according to setting passed when it was spawned  
						// So all we need to do here is set things up to respawn the patrol.
					//diag_log format["_monitorVehiclePatrols(case 3) called"];						
					_vehiclePatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_vehiclePatrol set[3,-1];
					GMSAI_vehiclePatrols pushBack _vehiclePatrol;
			};
			case 4: {  // some units survive so set them up as a random patrol with time limits; set for respawn
					// Vehicle is automatically moved to the cue for empty vehicles and handled according to setting passed when it was spawned  
					//diag_log format["_monitorVehiclePatrols(case 4) called"];
					////////private _patrolArea = createMarkerLocal[format["GMSAI_remnant%1",_crewGroup],getPosATL _vehicle];
					//{_crewGroup reveal[_x,4]} forEach [(getPosATL (leader _crewGroup)), 150] call GMSCore_fnc_nearestPlayers; 
					//_crewGroup setVariable["target",_nearPlayers select 0];
					////////_patrolArea setMarkerShapeLocal "RECTANGLE";
					////////_patrolArea setMarkerSizeLocal [150,150];
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

					/*
					[
						_patrolArea,
						[0, 0, 0, 0, 10000, 300, ["Infantry"]],  //  _staticAIDescriptor 
						true,
						[_crewGroup],
						[],
						-1,
						1,
						diag_tickTime,
						true,
						10000000
					] call GMSAI_fnc_addActiveSpawn; 
					*/
					/*
					params[
					["_group",grpNull],  // group for which to configure / initialize waypoints
					["_patrolAreaMarker",""],  // a marker or array defining the patrol area center, size and shape
					["_deletemarker",false],
					["_garrisonChance",0]  // chance that an infantry group will garison an building of type house - ignored for vehicles.
					];  
					*/

					/*
					[
						_crewGroup,
						_patrolArea,  
						false, // do not delete marker defining patrol area of the group is all dead// waypoint timeout
						GMSAI_chanceToGarisonBuilding
					] call GMSCore_fnc_initializeWaypointsAreaPatrolInfantry;
					*/
					GMSAI_vehiclePatrols pushBack _vehiclePatrol;					
			};		
		};
	}

	catch {
		switch (_exception) do {
			case 1: {
				// GMSAI_fnc_spawnVehiclePatrol returned grpNull for _crewGroup 

				[format["[GMSAI] _monitorAirPatrols: GMSAI_fnc_spawnVehiclePatrol returned grpNull for _group at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
			case 2: {
				// GMSAI_fnc_spawnVehiclePatrol returned objNull for _vehicle 
				
				[format["[GMSAI] _monitorAirPatrols: GMSAI_fnc_spawncraftPatrol returned objNull for _vehicle at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
		};
	};
};

GMSAI_monitorVehiclePatrolsActive = false; 