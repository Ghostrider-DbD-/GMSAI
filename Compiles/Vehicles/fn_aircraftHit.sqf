/*
	GMSAI_fnc_vehicleHit 

	Purpose: called when the MPHit EH fires for the vehicle 
		Provides a means for and GMSAI code to be run. 

	Parameters: per https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#MPHit 

	Returns: none 

	Copyright 2020 by Ghostrider-GRG-

	Notes: 		
		GMS provides an EH to handleDamage 
		GMS allerts the vehicle crew and sets it mode to combat 
		TODO: think about whether some hunting logic or other adaptations to GMSAI is needed. 
*/

params["_veh","_causedBy"];  //,"_d","_instigator"];
//[format["GMSAI_fnc_aircraftHit: _vehicle %1 | _causedBy %2 | _damage %3 | _instigator %4",_veh,_causedBy]] call GMSAI_fnc_log;
if !(isPlayer _causedBy) exitWith {};
private _crewMembers = crew _veh select{alive _x};
if (!(_crewMembers isEqualTo []) && {diag_tickTime > 60 + (_vehicle getVariable["GMSAI_lastHitProcessed",0])}) then
{
	[
		(_crewMembers select 0),
		_veh,
		[typeOf _veh] call GMSCore_fnc_isDrone
	] call GMSAI_fnc_spawnParatroops;
	_vehicle setVariable["GMSAI_lastHitProcessed",diag_tickTime];
};

