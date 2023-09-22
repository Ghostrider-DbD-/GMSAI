/*
	Purpose: keep an eye on land vehicle patrols, unstuck them where needed, return them to the patrol area if needed. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		-May want to take advantage of the setMode commands in GMS for these monitoring script for the case where the thing went outside the patrol area
*/
#include "\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
//diag_log format["[GMSAI] _monitorVehiclePatrols called at %1 with count GMSAI_vehiclePatrols %2",diag_tickTime, count GMSAI_vehiclePatrols];
for "_i" from 1 to (count GMSAI_vehiclePatrols) do
{
	if (_i > (count GMSAI_vehiclePatrols)) exitWith {};
	private _vehiclePatrol = GMSAI_vehiclePatrols deleteAt 0;
	_vehiclePatrol params["_blacklistedAreas","_crewGroup","_vehicle","_lastSpawned","_timesSpawned","_respawnAt","_respawnTime","_respawns","_availDifficulties","_availVehicles"];  
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
			_crewCount = {alive _x} count (crew _vehicle);
			_countUnits = ({alive _x} count (units _crewGroup)) - _crewCount;  // units on foot
		};
		//[format["GMSAI_fnc_monitorVehiclePatrols: _crewGroup %1 | _crewCount %2 | _countUnits %3 | _vehicle %4",_crewGroup,_crewCount,_countUnits,_vehicle]] call GMSAI_fnc_log;
		/*  crew alive && vehicle alive - see if the crew is stuck */
		if (alive _vehicle && _crewCount > 0) then 
		{
			if ([_crewGroup] call GMSCore_fnc_isStuck) then 
			{
				[format["GMSAI_fnc_monitorVehiclePatrols: unstucking _crewGroup %1 in typoOf _vehicle %2",_crewGroup, typeOf _vehicle]] call GMSAI_fnc_log;
				[leader _crewGroup] call GMSCore_fnc_nextWaypointAreaPatrol; /* Neet to try to get the group moving again if it is not in combat and not reaching its last waypointt */
			};			
		} else {
			/*  All crew Dead or out of vehice but Vehicle Alive */
			if (alive _vehicle && (_crewCount == 0 || isNull _crewGroup)) then 
			{
				//[format["GMSAI_fnc_monitorVehiclePatrols: case of empty vehicle typeOf %1",typeOf _vehicle]] call GMSAI_fnc_log;
				if (!(owner _vehicle == 2) && (ropes _vehicle isEqualTo [])) then
				{
					/* player entered the vehicle, ignore it */
					//[format["GMSAI_fnc_monitorVehiclePatrols: case of empty vehicle typeOf %1 that player has entered",typeOf _vehicle]] call GMSAI_fnc_log;
					[_vehicle] call GMSAI_fnc_processEmptyVehicle;
					_vehicle = objNull;
				} else {
					//[format["GMSAI_fnc_monitorVehiclePatrols: case of empty vehicle typeOf %1 that server still owns",typeOf _vehicle]] call GMSAI_fnc_log;
					private _deleteAt = _vehicle getVariable ["deleteAt",-1];
					if (_deleteAt == -1) then
					{					
						_vehicle setVariable["deleteAt",diag_tickTime + ( [GMSAI_vehiclePatrolDeleteTime] call GMSCore_fnc_getNumberFromRange) ];
					};

					private _nearbyPlayers = allPlayers inAreaArray [getPosATL _vehicle, 300, 300]; 
					/* only delete empty vehicles if no player is nearby and it has been empty more than the requisit time.*/
					if (_nearbyPlayers isEqualTo []) then
					{				
						if (diag_tickTime > _deleteAt) then
						{
							[_vehicle] call GMSCore_fnc_destroyVehicleAndCrew;
						};
					};			
				};
			} else {
				if ( (!alive _vehicle || isNull _vehicle) && (!isNull _crewGroup && !(units _crewGroup isEqualTo [])) ) then 
				{
					//diag_log format["_monitorVehiclePatrols: vehicle gone but Some crew of group %1 alive, setting them up to patrol the area idependently",_crewGroup];
					private _patrolArea = createMarkerLocal[format["GMSAI_remnant%1",_crewGroup],getPosATL _vehicle];
					private _nearPlayers = (getPosATL (leader _crewGroup)) nearEntities[["Man"],150] select {isPlayer _x};
					{
						_crewGroup reveal[_x,4];
					}forEach _nearPlayers;
					_crewGroup setVariable["target",_nearPlayers select 0];
					_patrolArea setMarkerShapeLocal "RECTANGLE";
					_patrolArea setMarkerSizeLocal [150,150];
					_crewGroup setVariable["patrolArea",_patrolArea];
					_crewGroup setVariable["despawnTime",10];
					_crewGroup setVariable["deleteAt",diag_tickTime + 10];
					[
						_crewGroup,
						GMSAI_BlacklistedLocations,
						_patrolArea,
						300,  // waypoint timeout
						GMSAI_chanceToGarisonBuilding,
						"vehicle",
						false  // do not delete marker defining patrol area of the group is all dead
					] call GMSCore_fnc_initializeWaypointsAreaPatrol;
				} else {
					/* if vehicle empty or dead whie there are still live units in the group then set up a patrol area for that group. */
					/* configure a respawn if the vehicle is dead or isEqualTo objNull or the crew is grpNull or the count of units in the group == 0 */
					//[format["GMSAI_fnc_monitorVehiclePatrols: configuring for respawn:: %1",_vehiclePatrol]] call GMSAI_fnc_log;
					_vehiclePatrol set[vehRespawnAt,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
					_vehiclePatrol set[vehLastSpawned,-1];
				};
			};
		};
	} else {  
		if (_respawns == -1 || _timesSpawned < _respawns) then
		{
			if (diag_tickTime > _respawnAt) then
			{
				_pos = [0,0];
				private _gmsMarker = [] call GMSCore_fnc_getMapMarker;
				private _center = markerPos _gmsMarker;
				private _radius = (markerSize _gmsMarker) select 0;
				private "_newPatrol";
				_pos = [[[_center,_radius]],["water"]] call BIS_fnc_randomPos;
				// The idea here is to generate a random position, test that no player is near and that it is not in a blacklisted location. If not, just pass on that location and try again on the next pass through the vehicle spawns.
				if !(_pos isEqualTo [0,0] && !([_pos,GMSAI_BlacklistedLocations] call GMSCore_fnc_isBlacklisted) && (allPlayers select {((_x distance _pos) > 300)} isEqualTo [])) then {
					private _roads = (_pos nearroads 500);
					if !(_roads isEqualTo []) then 
					{
						_pos = (getPosATL (_roads select 0)) getPos[25,random(359)];
						_newPatrol = [
							[selectRandomWeighted _availDifficulties] call GMSCore_fnc_getIntegerFromRange,
							selectRandomWeighted _availVehicles,
							_pos,
							GMSAI_patrolRoads,
							_blacklistedAreas,
							GMSAI_waypointTimeout,
							false,  //  markerDelete 
							false   // spawn on roads - less likely that a vehicle will spawn right by a player
						] call GMSAI_fnc_spawnVehiclePatrol;

						_newPatrol params["_group","_veh"];
						[format["GMSAI_fnc_monitorVehiclePatrols: spawned vehicle patrol at %1 using vehicle %2",_pos, typeOf _veh]] call GMSAI_fnc_log;
						if !(isNull _group) then 
						{
							_vehiclePatrol set[vehCrewGroup,_group];
							_vehiclePatrol set[currVehicle,_veh];
							_vehiclePatrol set[vehLastSpawned,diag_tickTime];
							_vehiclePatrol set[vehTimesSpawned,_timesSpawned + 1];
							GMSAI_vehicleGroups pushBack _group;
						} else {
							// Something happened - try again later
							_vehiclePatrol set[vehRespawnAt,diag_tickTime + ([_respawnTime] call GMSCore_fnc_getNumberFromRange)];
							_vehiclePatrol set[vehLastSpawned,-1];
						};
					};
				};
			};
		} else {
			_addBack = false;
		};
	};
	if (_addBack) then {GMSAI_vehiclePatrols pushBack _vehiclePatrol};
};
