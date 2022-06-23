/*
	GMSAI_fnc_vehicleKilled 

	Purpose: called whent the MPKilled EH fires for the vehicle. 
		provides a means for any GMSAI actions needed when a vehicle is killed such as allerting nearby groups. 

	Parameters: per https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#MPKilled 

	Returns: none 
	
	Copyright 2020 by Ghostrider-GRG-

	Notes:
		GMS handles all the basics including cleaning up the wreck. 
		Nothing is done by GMS about alerting nearby groups
		TODO: think about increasing alertness or bumping skills of nearby groups when this happens.
*/

//params["_vehicle","_killer","_instigator"];
//[format["GMSAI_fnc_vehicleKilled: _vehicle %1 | _killer %2 | _instigator %3",_vehicle,_killer,_instigator]] call GMSAI_fnc_log;