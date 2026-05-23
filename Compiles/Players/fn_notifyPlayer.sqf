/*
	GMSAI_fnc_notifyPlayer 

	Purpose: send players notifications about kills, updates to respect or tabs, kill streaks, etc 

	Parameters: 
		_player, the player who made the kill 
		_distance, the distance from which the AI was killed 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		TODO: consider adding a difficulty factor, e.g., kills with a pistol are harder
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_player","_distance"];
//diag_log format["GMSAI] _rewardPlayer:  _player = %1 | _distance = %2",_player,_distance];
if (toLowerANSI(GMSCore_modType) isEqualTo "epoch") then
{
	private _maxReward = 50;
	private _reward = 0;
	if (_distance < 50) then 
	{ 
		_reward = _maxReward - (_maxReward / 1.25);
	} else {
		if (_distance < 100) then 
		{ 
			_reward = _maxReward - (_maxReward / 1.5);
		} else {
			if (_distance < 800) then 
			{ 
				_reward = _maxReward - (_maxReward / 2);
			} else {
				if (_distance > 800) then 
				{ 
					_reward = _maxReward - (_maxReward / 4);
				};
			};
		};
	};
	//private _killstreakReward=+(_kills*2);
	private _killstreakBonus = (_kills * 2);
	//diag_log format["_fnc_rewardPlayer: _killstreakBonus = %1 | _reward = %2",_killstreakBonus,_reward];
	[_player,_killstreakBonus + _reward] call GMSCore_fnc_giveTakeCrypto;
	["showScore",[_reward + _killstreakBonus,_killstreakBonus,_kills],[_player]] call GMSCore_fnc_messageplayers;
} else {
	if (toLowerANSI(GMSCore_modType) isEqualTo "exile") then
	{
		private["_distanceBonus","_overallRespectChange","_newKillerScore","_newKillerFrags","_maxReward","_money","_message"];
		if ( (isPlayer _player) && (_player getVariable["ExileHunger",0] > 0) && (_player getVariable["ExileThirst",0] > 0) ) then
		{
			private _distanceBonus = floor((_distance)/100);
			private _killstreakBonus = 3 * (_player getVariable["blck_kills",0]);
			private _respectGained = 25 + _distanceBonus + _killstreakBonus;
			private _score = _player getVariable ["ExileScore", 0];
			_score = _score + (_respectGained);
			_player setVariable ["ExileScore", _score];
			format["setAccountScore:%1:%2", _score,getPlayerUID _player] call ExileServer_system_database_query_fireAndForget;
			private _newKillerFrags = _player getVariable ["ExileKills", 0];
			private _newKillerFrags = _newKillerFrags + 1;
			_player setVariable ["ExileKills", _newKillerFrags];
			format["addAccountKill:%1", getPlayerUID _player] call ExileServer_system_database_query_fireAndForget;
			_player call ExileServer_object_player_sendStatsUpdate;
			[["showScore",[_respectGained,_distanceBonus,_kills]], [_player]] call GMSCore_fnc_messageplayers;
		};	
	};
};