/*
	GMSAI_fnc_isBlacklisted

    Purpose: Check if a position/player is in one of the blacklisted locations/positions.
    
    Parameters: _position/object, _list of locations/markers/positions to check

    Returns: _true if the position tested is in one of the blacklisted areas

    Copyright 2020 Ghostrider-GRG-

*/
params[["_position",[0,0,0]],["_list",[]]];

if (_position isEqualTo [0,0,0]) exitWith {false};
if (_list isEqualTo []) exitWith {false};

private _return = false;
{
	if (_position inArea _x) exitWith {_return = true};
} forEach _list;
_return