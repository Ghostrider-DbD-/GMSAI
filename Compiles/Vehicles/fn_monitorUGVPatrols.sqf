/*
	GMSAI_fnc_monitorUGVPatrols 

	Purpose: keep an eye on UGV patrols, unstuck them where needed, return them to the patrol area if needed. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		-May want to take advantage of the setMode commands in GMS for these monitoring script for the case where the thing went outside the patrol area
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _monitorUGVPatrols called at %1 with count GMSAI_UGVPatrols = %2",diag_tickTime, count GMSAI_UGVPatrols];


if (GMSAI_monitorUGVPatrolsActive) exitWith {};
GMSAI_monitorUGVPatrolsActive = true; 

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

//diag_log format["_monitorUGVPatrols: count GMSAI_UGVPatrols = %1",count GMSAI_UGVPatrols];
for "_i" from 1 to (count GMSAI_UGVPatrols) do
{
	if (_i > (count GMSAI_UGVPatrols)) exitWith {};
	private _UGVPatrol = GMSAI_UGVPatrols deleteAt 0;
	_UGVPatrol params["_blacklistedAreas","_crewGroup","_UGV","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availUGV"];  
	//diag_log format["GMSAI _monotirUGVPatrols: _availUGF = %1", _availUGV];
	private ["_crewCount","_countUnits","_addBack","_respawn"];
	
	try {
		private "_action";

		if (_lastSpawned <= 0) then {
			_action = 2;
		} else { // no patrol spawned, so check if conditions for spanwn are met.
			private _numberCrew = {alive _x} count (crew _UGV);
			private _numberUnits =  ({alive _x} count (units _crewGroup));
			//diag_log format["_monitorUGVPatrols(46): _numberCrew %1 | _numberUnits %2 | _crewGroup %3| _UGV %4",_numberCrew, _numberUnits, _crewGroup, _UGV];
			if (alive _UGV && _numberCrew > 0) then {
				_action = 1; // check fuel and continue monitoring 
			} else {
				if (alive _UGV && _numberCrew == 0 && _numberUnits == 0) then {
					_action = 0;  // UGV survived but all crew killed; move UGV to cue players can claim; set patrol up for respawn. 
				} else {
					if (alive _UGV && _numberCrew == 0 && _numberUnits > 0) then {
						_action = 4;  // UGV survived, all crew out of UGV so set up a patrol area for them, set for respawn
					} else {
						if (!alive _UGV && _numberUnits > 0) then {
							{deleteVehicle _x} forEach (units _group);
							_action = 0; // UGV gone but some units survive so set them up as a random patrol with time limits; set for respawn
						} else {
							if (!alive _UGV && _numberUnits == 0) then {
								_action = 0;
							} else {
								_action = 0;
							};  // all crew dead, UGV destroyed, configure for respawn 
						};
					};
				};
			};
		};	

		switch (_action) do {			
			case 0: { // All crew dead and/or UGV dead 
				//diag_log format["_monitorUGVPatrols(case 0) called"];
				if (_respawns == -1 || _timesSpawned <= _respawns) then
				{
					_UGVPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_UGVPatrol set[3,-1];
				};
			};
			case 1: { // a UGV patrol is acrtive; check fuel, keep monitoring.
				//diag_log format["_monitorUGVPatrols(case 1) called"];

				if (fuel _UGV < 0.1) then {_UGV setFuel 1.0};
				private _lastPos = _crewGroup getVariable["lastPosition",[0,0]];
				private _lastTime = _crewGroup getVariable["lastTime",0];
				private _spawnedAt = _crewGroup getVariable["spawnedAt",0];
				if (_spawnedAt == 0) then {_crewGroup setVariable["spawnedAt", diag_tickTime]};			
				/*	
				if (diag_tickTime - _lastTime > 30) then {
					diag_log format["monitoUGVPatrols: _UGV %1 typeOf %2 has moved %3 in %4 sec",_UGV, typeOf _UGV, _UGV distance _lastPos, diag_tickTime - _lastTime];
					diag_log format["monitorUGVPatrols: _UGV %1 typeOf %2 alive for %3 fuel %4 damage %5", _UGV, typeOf _UGV, diag_tickTime - _spawnedAt, fuel _UGV, damage _UGV];
					_crewGroup setVariable["lastPosition", getPosATL _UGV];
					_crewGroup setVariable["lastTime",diag_tickTime];					
					if (_UGV distance _lastPos < 100) then {(leader _crewGroup) call GMSCore_fnc_nextWaypointAreaPatrol};
				};									
				*/
				GMSAI_UGVPatrols pushBack _UGVPatrol;
			};
			case 2: {  // Test if it is time to spawn a new UGV
				//  
				//diag_log format["_monitorUGVPatrols(case 2) called"];
				// This will spawn an UGV on server startup because _respawnAt is set to -1 so diag_tickTime is always > _respawnAt at server startup.

				if (diag_tickTime > _respawnAt) then
				{

					_pos = [[] call GMSCore_fnc_getMapMarker, _blacklistedAreas] call GMSAI_fnc_findPositionLandPatrol; 

					//diag_log format["_monitorUGVPatrols(103): _pos = %1 for position of  anearby road",_pos];	
					/*
						["_difficulty",0],			// Difficulty (integer) of the AI in the UGV
						["_className",""],		// ClassName of the UGV to spawn 
						["_pos",[0,0,0]],					// Random position for patrols that roam the whole map 
												// or center of the area to be patrolled for those that are restricted to a smaller region
						["_patrolArea",GMSAI_patrolRoads],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
						["_markerDelete",false],
						["_spawnOnRoad",true]
					*/
					_newPatrol = [
						(selectRandomWeighted _availDifficulties),
						(selectRandomWeighted _availUGV), 
						_pos,
						[] call GMSCore_fnc_getMapMarker, // The marker for teh whole map 
						false, // deleteMarker 
						false // spawnOnRoads
					] call GMSAI_fnc_spawnUGVPatrol;

					_newPatrol params["_crewGroup","_UGV"];
					
					if ((!isNull _crewGroup) && !(isNull _UGV)) then { 
						_UGVPatrol set[vehCrewGroup,_crewGroup];
						_UGVPatrol set[currVehicle,_UGV];
						_UGVPatrol set[vehLastSpawned,diag_tickTime];
						_UGVPatrol set[vehTimesSpawned,_timesSpawned + 1];

						_UGVPatrol set[1,_crewGroup];
						_UGVPatrol set[2,_UGV];
						_UGVPatrol set[3,diag_tickTime];
						_UGVPatrol set[4,_timesSpawned + 1];
						//  // [format["_monitorAirPatrols: spawned aircraft patrol at %1 using aircraft %2 with _group = %3 and _aircraft = %4",_pos, typeOf _aircraft,_group,_aircraft]] call GMSAI_fnc_log;
						[format["_monitorUGVpatrols:  spawned UGV patrol at %1 using typeOf UGV %2 -> UGV %3 with group %4",_pos, typeOf _UGV, _UGV, _crewGroup]] call GMSAI_fnc_log;						
						GMSAI_UGVPatrolGroups pushBack _crewGroup; //  Used only to count the number of active groups serving this function.
															// This list is monitored by _mainThread and empty or null groups are periodically removed.
					} else {
							// Something happened - try again later
				
							_UGVPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
							_UGVPatrol set[3,-1];
							[_crewGroup] call GMSCore_fnc_destroyVehicleAndCrew; 	
							GMSAI_UGVPatrols pushBack _UGVPatrol;
							if (isNull _crewGroup) then {
								_action = 1;
							} else {;
								if (isNull _UGV) then {_action = 2};
							};
							if (GMSAI_debug > 0) then {[format["GMSAI_fnc_monitorUGVPatrols: GMSAI_fnc_spawnUGVPatrol returned nullGrp %1 : UGV %2", _crewGroup, _UGV]] call GMSAI_fnc_log};
							throw _action; // _crewGroup was null for some reason	
					};

				};
				GMSAI_UGVPatrols pushBack _UGVPatrol;
			};
			case 3: {  // UGV survived but all crew killed; move UGV to cue players can claim; set patrol up for respawn. 
						// UGV is automatically moved to the cue for empty UGVs and handled according to setting passed when it was spawned  
						// So all we need to do here is set things up to respawn the patrol.
					//diag_log format["_monitorUGVPatrols(case 3) called"];						
					_UGVPatrol set[5,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_UGVPatrol set[3,-1];
					GMSAI_UGVPatrols pushBack _UGVPatrol;
			};
			case 4: {  // some units survive so set them up as a random patrol with time limits; set for respawn
					// UGV is automatically moved to the cue for empty UGVs and handled according to setting passed when it was spawned  
					//diag_log format["_monitorUGVPatrols(case 4) called"];
					//private _patrolArea = createMarkerLocal[format["GMSAI_remnant%1",_crewGroup],getPosATL _UGV];
					//{_crewGroup reveal[_x,4]} forEach [(getPosATL (leader _crewGroup)), 150] call GMSCore_fnc_nearestPlayers; 
					//_crewGroup setVariable["target",_nearPlayers select 0];
					//_patrolArea setMarkerShapeLocal "RECTANGLE";
					//_patrolArea setMarkerSizeLocal [150,150];
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
					[
						_crewGroup,
						GMSAI_BlacklistedLocations,
						_patrolArea,
						300,  // waypoint timeout
						GMSAI_chanceToGarisonBuilding,
						"Infantry",
						false  // do not delete marker defining patrol area of the group is all dead
					] call GMSCore_fnc_initializeWaypointsAreaPatrol;
					*/
					GMSAI_UGVPatrols pushBack _UGVPatrol;					
			};		
		};
	}

	catch {
		switch (_exception) do {
			case 1: {
				// GMSAI_fnc_spawnUGVPatrol returned grpNull for _crewGroup 

				[format["[GMSAI] _monitorAirPatrols: GMSAI_fnc_spawnUGVPatrol returned grpNull for _group at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
			case 2: {
				// GMSAI_fnc_spawnUGVPatrol returned objNull for _UGV 
				
				[format["[GMSAI] _monitorAirPatrols: GMSAI_fnc_spawncraftPatrol returned objNull for _UGV at %1",diag_tickTime]] call GMSAI_fnc_log;
			};
		};
	};
};

GMSAI_monitorUGVPatrolsActive = false; 
