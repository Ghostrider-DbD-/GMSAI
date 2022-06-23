
#include "\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_aircraft"];

_aircraft addMPEventHandler["MPHit",{_this call GMSAI_fnc_processAircraftHit}];
_aircraft addMPEventHandler["MPKilled",{_this call GMSAI_fnc_processVehicleKilled}];
_aircraft addEventHandler["HandleDamage",{_this call GMSAI_fnc_vehicleHandleDamage}];
{
	_x addMPEventHandler ["MPKilled", {_this call GMSAI_fnc_processAircraftCrewKilledi;}];
	_x addMPEventHandler ["MPHit", {_this call GMSAI_fnc_processAircraftCrewHit;}];
	_x addEventHandler ["GetOut",{_this call GMSAI_fnc_processVehicleCrewGetOut;}]	
} forEach (crew _aircraft);