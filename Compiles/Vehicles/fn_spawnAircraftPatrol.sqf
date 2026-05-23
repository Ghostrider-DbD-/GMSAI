/*
	GMSAI_fnc_spawnAircraftPatrol 
	
	Purpose: spawn a helicopter patrol that will go from location to location on the map hunting for players 
			Locations: are any town, city etc defined at startup. 

	Parameters: 
		_difficulty 
		_className
		_pos, position to spawn chopper 
		_patrolArea 
		_marderDelete 


	Returns: [
		_group, the group spawned to man the heli 
		_heli, the chopper spawned selected by selectRandomWeighted GMSAI_aircraftTypes,  
	]

	Copywrite 2020 by Ghostrider-GRG- 

	Notes: 
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

params[
		["_difficulty",0],
		["_className",""],			// className of the aircraft to spawn
		["_pos",[0,0,0]],					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea","Map"],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_markerDelete",false]
	];	

private _group = grpNull;
private _aircraft = objNull;

try {

	if !(isClass(configFile >> "CfgVehicles" >> _className)) throw -3; 

	/*
		params[
			["_className",""],
			["_patrolArea",GMSCore_mapMarker],
			["_markerDelete",false],
			["_disable",0],  // damage value set to this value if less than this value when all crew are dead
			["_removeFuel",0.2],  // uel set to this value when all crew dead
			["_releaseToPlayers",true],
			["_deleteTimer",300]
		];
	*/
	//[format["_spawnAircraftPatrol: _pos = %1",_pos]] call GMSAI_fnc_log;

	private _patrol = [
		_classname,
		_pos,
		_patrolArea,
		_markerDelete,
		0.5,  	// Disable  
		GMSA_removeFuel,  // what level to set fuel when released to players
		GMSAI_releaseVehiclesToPlayers,
		GMSAI_vehicleDeleteTimer	
	] call GMSCore_fnc_spawnPatrolAir;

	_group = _patrol select 0;
	_aircraft = _patrol select 1;

	//[format["_spawnAircraftPatrol: _group %1 | _aircraft %2 | _pos %3 | getPosATL _aircraft %4", _group, _aircraft, _pos, getPosATL _aircraft]] call GMSAI_fnc_log; 
	
	if (isNull _group) throw -2;
	if (isNull _aircraft) throw -1;

	[_group,GMSAI_unitDifficulty select (_difficulty)] call GMSCore_fnc_setupGroupSkills;
	[_group, GMSAI_unitLoadouts select _difficulty, 0 /* launchers per group */, GMSAI_useNVG] call GMSCore_fnc_setupGroupGear;
	[_group,_difficulty,GMSAI_money select _difficulty] call GMSCore_fnc_setupGroupMoney;
		
	[_aircraft,GMSAI_forbidenWeapons,GMSAI_forbidenMagazines] call GMSCore_fnc_disableVehicleWeapons;
	[_aircraft,GMSAI_disabledSensors] call GMSCore_fnc_disableVehicleSensors;
	if (GMSAI_disableInfrared) then {_heli disableTIEquipment true};
	[_group, GMSAI_chanceParatroops] call GMSCore_fnc_setChanceParaDrop; 
	[_group, GMSAI_chancePlayerDetected] call GMSCore_fnc_setChanceDetectedAir; 
	[_group, GMSAI_paratroopCooldownTimer] call GMSCore_fnc_setParaInterval;
	// TODO - add any event handlers or other things not hanled by SpawnAircraftPatrol by default
}

catch {
	switch (_exception) do {
		case -3: {
			[format["_spawnAircraftPatrol: invalid classname %1 passed",_className],'warning'] call GMSAI_fnc_log;
		};

		case -2: {
			[format["_spawnAircraftPatrol: grpNull"],'warning'] call GMSAI_fnc_log;
		};

		case -1: {
			[format["_spawnAircraftPatrol:  GMSCore_fnc_spawnPatrolAircraft return objNull"],'warning'] call GMSAI_fnc_log;
			[_group] call GMSCore_fnc_despawnInfantryGroup;
			_group = grpNull;			
		};
	};
};
//[format["_spawnAircraftPatrol:  returning _group %1 | _aircraft %2 | typeOf _aircraft %3",_group, _aircraft, typeOf _aircraft],''] call GMSAI_fnc_log;
[_group,_aircraft]

