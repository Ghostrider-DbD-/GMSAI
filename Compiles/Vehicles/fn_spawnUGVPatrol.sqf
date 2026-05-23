/*
	GMSAI_fnc_spawnUGVPatrol 
	
	Purpose: spawn a UGV patrol that will go from location to location on the map hunting for players 

	Parameters: 
		_difficulty
		_classname
		_pos,  			center of the region in which the group will operate 
		_patrolArea 	"Map" or Region, where region would be am area proscribed by a marker defined by center, size and shape 
		_markerDelete 
		_spawnOnRoad 

	Returns: [_group,_ugv]
		_group ( the group spawned) 
		_ugv (the vehicle spawned)

	Copywrite 2020 by Ghostrider-GRG- 

	Notes:
		Locations: are any town, city etc defined at startup. 
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
		["_difficulty",0],			// Difficulty (integer) of the AI in the UGV
		["_className",""],		// ClassName of the UGV to spawn 
		["_pos",[0,0,0]],					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea",GMSAI_patrolRoads],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_markerDelete",false],
		["_spawnOnRoad",true]
];  	

//[format["_spawnUGVPatrol: _spawnonRoad %1 | _markerDelete %2 | _patrolArea %3 | _pos %4 | _className %5", _spawnonRoad, _markerDelete, _patrolArea, _pos, _className]] call GMSAI_fnc_log; 

private _group = grpNull;
private _vehicle = objNull;

try {

	if !(isClass(configFile >> "CfgVehicles" >> _className)) throw -3; 

/*
params[
	["_className",""],
	["_spawnPos", []],	
	["_patrolAreaMarker",GMSCore_mapMarker],
	["_markerDelete",false],
	["_disable",0],  // damage value set to this value if less than this value when all crew are dead
	["_removeFuel",0.2],  // uel set to this value when all crew dead
	["_releaseToPlayers",true],
	["_deleteTimer",300],
	["_vehHitCode",[]],
	["_vehKilledCode",[]]	
*/
	private _ugvData = [
		_className,
		_pos, 
		_patrolArea,
		_markerDelete,
		_spawnOnRoad 
	] call GMSCore_fnc_spawnPatrolUGV;
	//[format["_spawnUGVPatrol: _ugvData = %1", _ugvData]] call GMSAI_fnc_log;
	_group = _ugvData select 0; 
	_vehicle = _ugvData select 1;
	
	if (isNull _group) throw -2;
	if (isNull 	_vehicle) throw -1;

	[_group,GMSAI_unitDifficulty select _difficulty] call GMSCore_fnc_setupGroupSkills;

	//diag_log format["GMSAI_fnc_spawnUGVPatrol(109): _patrolArea = %1",_patrolArea];

	if (_spawnOnRoad) then {
		private _road = objNull;
		private _radius = 50;
		while {isNull _road} do {
			_radius = _radius + 50;
			_road = [_pos, _radius,[]] call BIS_fnc_nearestRoad;
		};
		private _info = getRoadInfo _road;
		private _segmentPos = _info select 7;
		_vehicle setPos [_segmentPos select 0, _segmentPos select 1, 0];  // road segment start
	};

	// Note: the group is added to the list of groups monitored by GMSCore. Empty groups are deleted, 'stuck' groups are identified.

	[_vehicle,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
	[_vehicle,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
	if (GMSAI_disableInfrared) then {_vehicle disableTIEquipment true};
	//[format["GMSAI_fnc_spawnUGVPatrol(137): _group %1 | _vehicle %2 | assignedVehicle driver _vehicle = %3",_group, _vehicle, assignedVehicle (driver _vehicle)]];
	//_vehicle addEventHandler ["GetOut", GMSAI_fnc_vehicleGetOut];  // Could be  handy for moving a new driver or gunnner into position
	// TODO - add any event handlers or other things not hanled by SpawnAircraftPatrol by default
	_group addVehicle _vehicle;		
}

catch {
	switch (_exception) do {
		case -3: {
			[format["_spawnVehicletPatrol: invalid classname %1 passed",_className],'warning'] call GMSAI_fnc_log;
		};

		case -2: {
			[format["_spawnVehicletPatrol: grpNull"],'warning'] call GMSAI_fnc_log;
			deleteVehicle _vehicle;
		};

		case -1: {
			[format["_spawnVehicletPatrol:  GMSCore_fnc_spawnPatroVehiclereturn objNull"],'warning'] call GMSAI_fnc_log;
			[_group] call GMSCore_fnc_despawnInfantryGroup;
			_group = grpNull;			
		};
	};
};
//[format["_spawnUGVPatrol: _group %1 | _vehicle %2", _group, _vehicle]] call GMSAI_fnc_log;
[_group,_vehicle]

