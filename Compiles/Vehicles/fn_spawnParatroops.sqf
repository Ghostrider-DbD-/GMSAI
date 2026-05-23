/*
	GMSAI_fnc_spawnParatroops 

	Purpose: Check whether conditions for spawning reinforcements are met and if so call them in. 

	Parameters: 
		_group, the group for the crew for that heli 
		_aircraft, the aircraft patroling 

	Returns: None 

	Copywrite 2020 by Ghostrider-GRG- 

	Notes: 

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_group","_aircraft","_isUAV"];
[format["spawnParatroops: _group %1 | _aircraft %2 | _isUAV %3 | time %4",_group,_aircraft,_isUAV,diag_tickTime]] call GMSAI_fnc_log;
// Basic conditions for spawns must be met



if (count GMSAI_paratroopGroups >= GMSAI_maxParagroups) exitWith {["spawnParatroops: maximum number of active reinforments reached"] call GMSAI_fnc_log};

private _respawnAt = _group getVariable [GMSAI_paratroopNextDropTime,-1];
if (_respawnAt == -1) then 
{
	_respawnAt = diag_tickTime + ([GMSAI_paratroopCooldownTimer] call GMSCore_fnc_getNumberFromRange);
	_group setVariable[GMSAI_paratroopNextDropTime, _respawnAt];
};

if (diag_tickTime < _respawnAt) exitWith {/* [format["spawnParatroops: group %1 still cooling down with respawnAt = %2 with current time = %3",_group,_respawnAt,diag_tickTime]] call GMSAI_fnc_log */};

//[format["spawnParatroops: group %1 passed respawn timer check with respawnAt = %2 with current time = %3",_group,_respawnAt,diag_tickTime]] call GMSAI_fnc_log;

if (random(1) >= GMSAI_chanceParatroops) exitWith { /*[format["spawnParatroops: group %1 failed chance of reinforcements check at %2 with no reinforcement = %3",_group, diag_tickTime, GMSAI_paratroopGroups]] call GMSAI_fnc_log */};

private _target = [_group] call GMSCore_fnc_getHunt;
if (isNull _target) then {_target = [_group,300, 0.1] call GMSCore_fnc_nearestTarget};

if (isNull _target) exitWith { /*[format["spawnParatroops: no target found for reinforcements to attack for group %1",_group]] call GMSAI_fnc_log */};

[_group,_target] call GMSCore_fnc_setHunt; 
_group setVariable[GMSAI_lastKnownTargetLocation,getPosATL _target];
_group setVariable[GMSAI_targetLocationTimeout,diag_tickTime + GMSAI_targetLocationTimoutInterval];

#define GMSAI_paradropMode "paradropMode"
#define droppedbyPatrolHeli 1 
#define calledInByUAV 2 
#define calledByUAVGroup "calledByGroup"

//[format["spawnParatroops: target for group %1 is %2 at %3",_group,_target,diag_tickTime]] call GMSAI_fnc_log;
private _inbound = _group getVariable[GMSAI_paraInbound,false];

if (_isUAV) then // Bring in a heli and drop some paras
{
	if !(_inbound) then 
	{
		//[format["spawnParatroops: will call in reinforcements for _group %1 in _UAV %2 near _target %3 at position %4 at time = %5",_group,_aircraft,_target,getPosATL _aircraft,diag_tickTime]] call GMSAI_fnc_log;	

		private _msg = selectRandom GMSAI_playerTargeted;
		private _nearby = allPlayers select {(_target distance _x) < 300};
		{[format[_msg,_target]] remoteExec ["GMSCore_fnc_huntedMessages", _x]} forEach _nearby;
		
		// params["_dropPos","_group",["_targetedPlayer",ObjNull]];
		_group setVariable[GMSAI_paraInbound,true];
		_group setVariable["paradropMode", calledInByUAV];
		_group setVariable[calledByUAVGroup,_group];
		[[format["spawnParatroops: UAV has called in reinforcements at %1",diag_tickTime]]] call GMSAI_fnc_log;			
		[getPosATL _target,_group,_target] spawn GMSAI_fnc_flyInReinforcements; 
		private _respawnAt = diag_tickTime + ([GMSAI_paratroopCooldownTimer] call GMSCore_fnc_getNumberFromRange);
		_group setVariable[GMSAI_paratroopNextDropTime, _respawnAt];
	};
} else {	// we can use that aircraft to drop some AI 
	//[format["spawnParatroops (74): _group %1 in _aircraft %2 near _target %3 at position %4 at time = %5 with _inbound %6",_group,_aircraft,_target,getPosATL _aircraft,diag_tickTime,_inbound]] call GMSAI_fnc_log;
	if !(_inbound) then 
	{
		_group setVariable[GMSAI_paraInbound,true];		
		private _leader = leader _group;
		private _vehicle = vehicle _leader;
		private _dropPos = getPosATL _target;
		//[format["spawnParatroops: aircraft patrol called in reinforcements: _leader = %1 | _vehicle = %2 | _target = %3 | _dropPos = %4 | flyInHeight %5",_leader,typeOf _vehicle,_target,_dropPos,(getPosATL _vehicle) select 2]] call GMSAI_fnc_log;

		private _msg = selectRandom GMSAI_playerTargeted;
		private _nearby = allPlayers select {(_target distance _x) < 300};
		{[format[_msg,_target]] remoteExec ["GMSCore_fnc_huntedMessages", _x]} forEach _nearby;
		
		_group setVariable[GMSAI_paraInbound,true];
		_group setVariable["paradropMode", droppedbyPatrolHeli];		
		[_group,_target,_dropPos, _vehicle] spawn GMSAI_fnc_getToDropPos;
		private _respawnAt = diag_tickTime + ([GMSAI_paratroopCooldownTimer] call GMSCore_fnc_getNumberFromRange);
		_group setVariable[GMSAI_paratroopNextDropTime, _respawnAt];		
	};
};

_respawnAt = diag_tickTime + ([GMSAI_paratroopCooldownTimer] call GMSCore_fnc_getNumberFromRange);
_group setVariable[GMSAI_paratroopNextDropTime, _respawnAt];

//[format["spawnParatroops: <END> with current time = %3",_group,_respawnAt,diag_tickTime]] call GMSAI_fnc_log;
