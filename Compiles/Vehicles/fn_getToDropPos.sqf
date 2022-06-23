/*

	GMSAI_fnc_getToDropPos
	
	Purpose: have the aircraft fly to the dropoff then come to a slow loiter 

	Parameters: _this is the leader of the group crewing the aircraft 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 	

*/
//diag_log format["GMSAI_fnc_getToDropPos: _this = %1",_this];
params["_group","_target","_dropPos","_vehicle"];
[_group,_target] call GMSCore_fnc_setHunt;
//diag_log format["GMSAI_fnc_getToDropPos: _group pos %2 | _dropPos = %1 | distance to _dropPos %3",_dropPos, position (leader _group), _vehicle distance _dropPos];
[_group,"disengage"] call GMSCore_fnc_setGroupBehaviors;
_group setSpeedMode "LIMITED";
private _wp = [_group,0];
if (_vehicle distance _dropPos < 125) then 
{
	//[format["GMSAI_fnc_getToDropPos: dropPos %1 within range, droping reinforcements",_dropPos]] call GMSCore_fnc_log;
	_this spawn GMSAI_fnc_reachedDropPos;	
} else {
	//[format["GMSAI_fnc_getToDropPos: configuring for travel to dropos %1 | time %2",_group,diag_tickTime]] call GMSAI_fnc_log;
	_wp setWaypointPosition  [_dropPos getPos[100,random(359)],0];	
	_wp setWaypointCompletionRadius 0;
	_wp setWaypointBehaviour "AWARE";
	_wp setWaypointCombatMode "YELLOW";
	_wp setWaypointSpeed "Normal";
	_wp setWaypointTimeout [0,0.5,1];
	_wp setWaypointType "MOVE";		
	_wp setWaypointStatements ["true","[this] spawn GMSAI_fnc_reachedDropPos;"];
	_group setCurrentWaypoint _wp;
	//diag_log format["GMSAI_fnc_getToDropWaypoint: will activate GMSAI_fnc_dropParatroops upon waypoint completion"];	
};

