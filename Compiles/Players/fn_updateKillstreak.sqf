/*
	GMSAI_fnc_updateKillstreak 

	Purpose:
		Update player data regarding killstreaks

	Return 
		Kills in current killstreak 

	Notes 

	#define GMSAI_killstreak "kills"
	#define GMSAI_lastKill "lastKill"
	#define GMSAI_killstreakTimout 300
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

params["_player","_kills"];

private _lastKill = _player getVariable[GMSAI_lastKill,0];
private _killstreak = _player getVariable[GMSAI_killstreak,0];
//diag_log format["_updateKillstreak: _player %1 | _kills prior to update %2",_player,_kills];
if ((diag_tickTime - _lastKill) > GMSAI_killstreakTimeout) then 
{
	_killstreak = _kills;
} else {
	_killstreak = _killstreak + _kills;
};
_lastKill = diag_tickTime;
_player setVariable[GMSAI_lastKill,_lastKill];
_player setVariable[GMSAI_killstreak,_killstreak];
_killstreak
