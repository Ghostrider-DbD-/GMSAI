/*
	GMSAI_fnc_getKillstreak 

	Purpose:
		Get player data regarding killstreaks

	Return 
		Kills in current killstreak 

	Notes 

	#define GMSAI_killstreak "kills"
	#define GMSAI_lastKill "lastKill"
	#define GMSAI_killstreakTimout 300
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

params["_player"];
_player getVariable[GMSAI_killstreak,0];