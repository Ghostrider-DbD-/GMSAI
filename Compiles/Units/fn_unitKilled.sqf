/*
	GMSAI_fnc_infantryKilled 

	Purpose: execute GMSAI specific functions when a unit is killed 

	Parameters: per https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#MPKilled 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
*/

/*

*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_unit","_killer","_instigator"];
if (isNull _killer || isNull _instigator) exitWith {};
//[format["GMSAI_fnc_unitKilled: vehicle killer = %1", typeOf (vehicle _killer),_killerIsMan]] call GMSAI_fnc_log;
private _role = assignedVehicleRole _instigator;
//[format["GMSAI_fnc_unitKilled: _role killer = %1", _role]] call GMSAI_fnc_log;
private _cf = 1;
private _wep = currentWeapon _instigator;
private _creditKill = true;
private _isRunover = false;
if !(_role isEqualTo []) then // _instigator was in a vehicle of some sort
{
	//[format["GMSAI_fnc_unitKilled: vehRole killer = %1", _role select 0]] call GMSAI_fnc_log;
	switch (_role select 0) do 
	{
		case "driver": 
		{
			/*
				GMSAI_runoverProtection = true;
				GMSAI_runoverRespectPenalty = 25;
				GMSAI_runoverMoneyPenalty = 0;
			*/
			if (GMSAI_runoverProtection) then 
			{
				_cf = 0;
				_creditKill = false;			
				_isRunover = true;
				[_unit] call GMSCore_fnc_unitRemoveAllGear;	
				{
					deleteVehicle _x;
				} forEach nearestObject[_unit,["WeaponHolderSimulated","groundWeaponHolder"],2];
			};
			//[["GMSAI_fnc_unitKilled: unit %1 run over by %2 with %3",_unit,_instigator,vehicle _instigator]] call GMSAI_fnc_log;
		};
		case "turret":
		{
			_cf = 0.3;
			_wep = (vehicle _instigator) currentWeaponTurret (_role select 1);
			if (_wep in GMSAI_forbidenWeapons) then 
			{
				_cf = 0;
				_creditKill = false;
				[_unit] call GMSCore_fnc_unitRemoveAllGear;	
				{
					deleteVehicle _x;
				} forEach nearestObject[_unit,["WeaponHolderSimulated","groundWeaponHolder"],2];
			};
			//[format["GMSAI_fnc_unitKilled: _unit %1 | killed from vehicle %2 | by %3 | using %4",_unit, vehicle _instigator,name _instigator,_wep]] call GMSAI_fnc_log;
		};
		case "cargo": {};
	};
};
//[format["GMSAI_fnc_unitKilled: _unit %1 | _killer %2 | _instigator %3 | vehicle _killer %4",_unit,_killer,_instigator,vehicle _killer]] call GMSAI_fnc_log;
//diag_log format["GMSAI_fnc_unitKilled: _unit %1 | _killer %2 | | weapon = %3 | doing all that stuff now", _unit,_killer, currentWeapon _killer];
private _difficulty = (group _unit) getVariable [GMSAI_groupDifficulty,2];
private _rewards = GMSAI_rewards select _difficulty;
private _distance = _unit distance _killer;
_baseReward = round([_rewards select 0] call GMSCore_fnc_getNumberFromRange);
_baseExperience = round([_rewards select 0] call GMSCore_fnc_getNumberFromRange);
private _reward = 0;
private _experience = 0;
private _killstreak = 0;

if (_isRunover) then 
{
	_reward = GMSAI_runoverMoneyPenalty; 
	_experience = GMSAI_runoverRespectPenalty;
} else {
	private _distanceBonus = round(_distance / 100) max 5;
	private _killsBonus = _killstreak max 10;	
	_killstreak = [_instigator,1] call GMSAI_fnc_updateKillstreak;
	_reward = round((_baseReward + _killsBonus) * _cf);  //  Crypto in Epoch, Tabs in Exile
	_experience = round((_baseExperience + _distanceBonus) * _cf); // Karma in Epoch, Respect in Exile
};

switch toLowerANSI((GMSCore_modType)) do {
	case "epoch": {
		[_instigator, _reward] call GMSCore_fnc_giveTakeCrypto;
		[_instigator,_experience,false] call GMSCore_fnc_setKarma;
	};
	case "exile": {
		[_instigator, _reward] call GMSCore_fnc_giveTakeTabs;
		[_instigator, _experience] call GMSCore_fnc_giveTakeRespect;
	};
};
//diag_log format["GMSAI_fnc_unitKilled: _mod %3 | _reward %1 | _experience %2",_reward,_experience,GMSCore_modType];

if (_creditKill) then 
{
	[_instigator,1] call GMSCore_fnc_updatePlayerKills;
	private _msg = format[
		"%1 killed %2 with %3 at %4 meters %5X KILLSTREAK",
		name _instigator, 
		name _unit, 
		getText(configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName"), 
		_unit distance _instigator,
		_killstreak
	];
	
	[_instigator, _reward, _experience, name _unit, _unit distance _instigator, getText(configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName"), _killstreak, GMSAI_killMessageToAllPlayers,GMSAI_killMessageTypesKiller,GMSAI_killMessagingRadius] remoteExec ["GMSCore_fnc_killedMessages",allPlayers];	
};
