/*
	GMSAI_fnc_rewardPlayer 

	Purpose: send a player a rewaard for a kill or other success 

	Parameters: 
		_player, the player to _reward 
		_distance, distance for the kill or other rewardable activity 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 
		TODO: add a check for difficulty, e.g., the weapon used.
*/

#include "\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_unit","_killer"];
private _difficulty = (group _unit) getVariable ["difficulty",2];
private _rewards = GMSAI_rewards select _difficulty;
private _distance = _unit distance _killer;
private _mod = call GMSCore_fnc_getModType;
_baseReward = round([_rewards select 0] call GMSCore_fnc_getNumberFromRange);
_baseExperience = round([_rewards select 0] call GMSCore_fnc_getNumberFromRange);
private _money = 0;
private _experience = 0;
private _kills = [_killer] call GMSAI_fnc_updateKillstreak;
private _distanceBonus = round(_distance / 100) max 5;
private _killsBonus = _kills max 5;
private _reward = _baseReward + _killsBonus;
private _experience = _baseExperience + _distanceBonus;
switch (_mod) do {
	case "Epoch": {
		[_killer, _reward] call GMSCore_fnc_giveTakeCrypto;
		[_killer,_experience,false] call GMSCore_fnc_setKarma;
		[_killer,1] call GMSCore_fnc_updatePlayerKills;
	};
	case "Exile": {
		private _tabsEarned = _baseReward + _killsBonus;
		[_killer, _reward] call GMSCore_fnc_giveTakeTabs;
		[_killer, _experience] call GMSCore_fnc_giveTakeRespect;
		[_killer, 1] call GMSCore_fnc_updatePlayerKills;
	};
};

[_baseReward + _killsBonus, _baseExperience + _distanceBonus];


