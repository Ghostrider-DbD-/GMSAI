/*
	GMSAI_fnc_log 

	Purpose: provide mod specific loging 

	Parameters:	
		_msg, the message to log 
		_type, an optional code that can be warning, error or "" if included 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes: 
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_msg",["_type",""]];
switch (toLowerANSI _type) do 
{
	case "warning": {_msg = format["[GMSAI] <WARNING>  %1",_msg]};
	case "error": {_msg = format["[GMSAI] <ERROR>  %1",_msg]};
	case "information": {_msg = format["[GMSAI] <INFORMATION> %1",_msg]};
	default {_msg = format["[GMSAI]  %1",_msg]};
};
diag_log _msg;
