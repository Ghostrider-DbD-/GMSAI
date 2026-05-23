/*
	GMSAI_fnc_spawnVehiclePatrol 
	Purpose: spawn a vehicle patrol that will go from location to location on the map or patrols a proscribed area hunting for players 
	
		Parameters: 
			_difficulty,
			_className,
			_pos,  			center of the region in which the group will operate 
			_patrolArea, 	"Map" or Region, where region would be am area proscribed by a marker defined by center, size and shape 
			_isSubmersible  true/false  When true, and if the vehicle is on or in water, it will be set to move below the surface 
			_markerDelete 
			_spawnOnRoad
		
	Returns: [_group,_vehicle]
		_group ( the group spawned) 
		_vehicle (the vehicle spawned)

	Copywrite 2020 by Ghostrider-GRG- 

	Notes:
		Locations: are any town, city etc defined at startup.
		when '_isSubmersible == true the script will assume it should set swimInDepth as well
		Locations: are any town, city etc defined at startup. 
 
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
params[
		"_difficulty",
		"_classname",			// className of vehicle to spawn
		"_pos",					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea", [] call GMSCore_fnc_getMapMarker],  // "Map" will direct the vehicle to patrol the entire map, "Region", a smaller portion of the map.
		["_markerDelete",false]
	];  

private _group = grpNull;
private _vehicle = objNull;
//[format["_spawnVehiclePatrol: _classname %1 | _pos %2 | _patrolArea %3", _className, _pos, _patrolArea]] call GMSAI_fnc_log;

try {

	if !(isClass(configFile >> "CfgVehicles" >> _className)) throw -3; 

	private _calcCrewCount = [GMSAI_patroVehicleCrewCount] call GMSCore_fnc_getIntegerFromRange;
	private _vehCrewLimit = ([_className,true]  call BIS_fnc_crewCount);
	private _crewCount = _calcCrewCount min _vehCrewLimit;

/*
params[
		["_className",""], // Clasname of vehicle to be spawned
		["_spawnPos",[0,0,0]],  //  selfevident		
		["_patrolArea", GMSCore_mapMarker],
		["_disable",0],  // damage value set to this value if less than this value when all crew are dead
		["_removeFuel",0.2],  // fuel set to this value when all crew dead
		["_releaseToPlayers",true],
		["_deleteTimer",300],
		["_vehHitCode",[]],
		["_vehKilledCode",[]]
	];
*/
	
	private _temp = [
		_className,
		_pos,		
		_patrolArea,
		_markerDelete,
		0.5,	// value for damage applied to vehicle - leave for now at 0
		GMSA_removeFuel,
		GMSAI_releaseVehiclesToPlayers, 
		GMSAI_vehicleDeleteTimer,
		[GMSAI_fnc_vehicleHit],
		[GMSAI_fnc_vehicleKilled]	   
	] call GMSCore_fnc_spawnPatrolLand;  // this removes inventory, sets all key variables and adds event handlers	
	_group = _temp select 0;
	_vehicle = _temp select 1; 
	//diag_log format["_spawnVehiclePatrol: _vehicle %1 spawned",_vehicle];
	
	if (isNull _group) throw -2;
	if (isNull _vehicle) throw -1;

	#define maxVehGunners 5 // These just force the script to fill all turrets before filling crew cargo seats
	#define maxVehCrew 5 

	//diag_log format["GMSAI_fnc_spawnVehiclePatrol: _group %1 | _vehicle = %2 ", _group, _vehicle];

	//  params[["_group",grpNull], ["_veh", objNull],["_maxGunner",0],["_maxCargo", 0]];
	[_group, _vehicle, maxVehGunners, maxVehCrew] call GMSCore_fnc_addVehicleCrew;
	//diag_log format["GMSAI_fnc_spawnVehiclePatrol: crew _vehicle = %1 ", crew _vehicle];
		
	[_group, GMSAI_baseSkill] call GMSCore_fnc_setGroupBaseSkill;
	[_group,GMSAI_unitDifficulty select _difficulty] call GMSCore_fnc_setupGroupSkills;
	[_group, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
	[_group,_difficulty,GMSAI_money select _difficulty] call GMSCore_fnc_setupGroupMoney;

	
	if ([_vehicle] call GMSCore_fnc_isSubmersible) then {
		// set the swimindept to 1/2 the height of surface level above ground leve of the driver of the vehicle
		_driver swimInDepth (((getPosATL(ASLtoATL(getPosASL(driver _vehicle))) ) select 2)/2);
	};
	//diag_log format["GMSAI_fnc_spawnVehiclePatrol(109): _patrolArea = %1",_patrolArea];
	if (_patrolArea isEqualTo ([] call GMSCore_fnc_getMapMarker)) then {
		private _road = objNull;
		private _radius = 50;
		while {isNull _road} do {
			_radius = _radius + 50;
			_road = [_pos, _radius,[]] call BIS_fnc_nearestRoad;
		};
		private _info = getRoadInfo _road;
		private _segmentPos = _info select 7;
		_vehicle setPos [_segmentPos select 0, _segmentPos select 1, 0];  // road segment start
		_vehicle setDir (_vehicle getRelDir (_info select 6));	
	};

	// Note: the group is added to the list of groups monitored by GMSCore. Empty groups are deleted, 'stuck' groups are identified.

	[_vehicle,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
	[_vehicle,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
	if (GMSAI_disableInfrared) then {_vehicle disableTIEquipment true};

}
catch {
	switch (_exception) do {
		case -3: {
			[format["_spawnVehicletPatrol: invalid classname %1 passed",_className],'warning'] call GMSAI_fnc_log;
		};

		case -2: {
			[format["_spawnVehicletPatrol: GMSCore_fnc_spawnInfantryGroup returned grpNull"],'warning'] call GMSAI_fnc_log;
		};

		case -1: {
			[format["_spawnVehicletPatrol:  GMSCore_fnc_spawnPatroVehicle returned objNull"],'warning'] call GMSAI_fnc_log;
			[_group] call GMSCore_fnc_despawnInfantryGroup;
			_group = grpNull;			
		};
	};
};

[_group,_vehicle]
