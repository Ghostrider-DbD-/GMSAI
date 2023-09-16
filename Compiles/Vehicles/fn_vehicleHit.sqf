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

//params["_vehicle","_causedBy","_damage","_instigator"];
//[format["GMSAI_fnc_vehicleHit: _vehicle %1 | _causedBy %2 | _damage %3 | _instigator %4",_vehicle,_causedBy,_damage,_instigator]] call GMSAI_fnc_log;

