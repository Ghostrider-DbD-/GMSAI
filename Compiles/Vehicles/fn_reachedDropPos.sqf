/*
	GMSAI_fnc_reachedDropPos
	
	Purpose: drop paratroops then either patrol as a gunship or leave for destruction elsewhere. 
			Used to call in reinforcements by drones exclusively 
			
	Parameters: _this is the leader of the group crewing the aircraft. 

	Returns: none 
	
	Copyright 2020 Ghostrider-GRG-

	Notes: 

*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"
private _leader = _this select 0;
private _group = group _leader; // where _this is the leader of the group 
//diag_log format["GMSAI_fnc_reachedDropPos: _this = %1 typename thie %2 | _leader %3 | _group %4",_this,typeName _this,_leader,_group];
// params["_group","_aircraft","_target","_dropPos"];
[
	_group,
	vehicle(_leader),
	[_group] call GMSCore_fnc_getHunt,
	getWPPos [_group,0]
] call GMSAI_fnc_dropReinforcements;





