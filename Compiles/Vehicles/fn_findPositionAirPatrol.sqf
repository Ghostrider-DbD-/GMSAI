/*
	GMSAI_fnc_findPositionAirPatrol 
*/

params["_patrolMarker","_blacklist"];  // assumed to be GMSCore_mapMarker but best be sure.

private _pos = [];
private _center = markerPos _patrolMarker;
private _markerSize = markerSize _patrolMarker; 
_markerSize = (_markerSize select 0) max (_markerSize select 1);
private _radius = _markerSize/2.5;

while {_pos isEqualTo []} do {
	_pos = [[[_center,_radius]],["water"]] call BIS_fnc_randomPos;
	private _playersNear = [_pos, 100] call GMSCore_fnc_nearestPlayers;
	if !(_playersNear isEqualTo []) then {
		_pos = [];
	} else {
		if ([_pos,_blacklist] call GMSCore_fnc_isBlacklisted) then {
			_pos = [];
		} else {
			private _nearestBases = [_pos,250] call GMSCore_fnc_nearestBases;
			if !(_nearestBases isEqualTo []) then {
				_pos = [];
			};
		};
	};
};
_pos 