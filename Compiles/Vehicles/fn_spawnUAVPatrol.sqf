	
/*
	GMSAI_fnc_spawnUAVPatrol 
	Purpose: spawn a UAV patrol that will go from location to location on the map hunting for players 

	Parameters: 
		_difficulty
		_className 
		_pos, position to spawn chopper 
		_patrolArea - can be "Map" or "Region". "Region will respect the boundaries of a map marker while Map will patrol the entire map. 
		_markerDelete 

	Returns: [
		_group, the group spawned to man the heli 
		_aircraft, the UAV spawned selected by selectRandomWeighted GMSAI_aircraftTypes,  
	]

	Copywrite 2020 by Ghostrider-GRG-

	Notes: 
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"  

params[
		"_difficulty",
		"_className",				// classname of the drone to use
		"_pos",					// Random position for patrols that roam the whole map 
								// or center of the area to be patrolled for those that are restricted to a smaller region
		["_patrolArea","Map"],  // "Map" will direct the chopper to patrol the entire map, "Region", a smaller portion of the map.
		["_markerDelete",false]
];

private _aircraft = objNull;
private _group = grpNull; 

try {
	if !(isClass(configFile >> "CfgVehicles" >> _className)) throw -3;

	private _patrol = [
		_className,
		_pos, 		
		_patrolArea,
		_markerDelete,	
		0.5,			// disable 
		GMSA_removeFuel,		// remove fuel
		GMSAI_releaseVehiclesToPlayers,
		GMSAI_vehicleDeleteTimer	
	] call GMSCore_fnc_spawnPatrolUAV;	

	_group = _patrol select 0;
	_aircraft = _patrol select 1;

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
}

catch 
{ 
	switch (_exception) do {
		case -3: {
			[format["_spawnUAVPatrol: invalid classname %1 passed",_className],'warning'] call GMSAI_fnc_log;
		};

		case -2: {
			[format["_spawnUAVPatrol: grpNull"],'warning'] call GMSAI_fnc_log;
		};

		case -1: {
			[format["_spawnUAVPatrol:  GMSCore_fnc_spawnPatrolUAV return objNull"],'warning'] call GMSAI_fnc_log;
			[_group] call GMSCore_fnc_despawnInfantryGroup;
			_group = grpNull;			
		};
	};
}; 
//[format["_spawnUAVPatrol:  GMSCore_fnc_spawnPatrolUAV returning _group %1 | _aircraft %2",_group, _aircraft]] call GMSAI_fnc_log;
[_group,_aircraft]
