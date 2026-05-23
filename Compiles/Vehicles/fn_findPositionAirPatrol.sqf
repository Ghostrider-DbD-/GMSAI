/*
	GMSAI_fnc_findPositionAirPatrol 
*/

params["_patrolMarker"];  // assumed to be GMSCore_mapMarker but best be sure.

private _pos = [];
private _center = markerPos _patrolMarker;
private _markerSize = markerSize _patrolMarker; 
_markerSize = (_markerSize select 0) max (_markerSize select 1);
private _radius = _markerSize/2.5;

while {_pos isEqualTo []} do {
	private _positionsToFind = 1;

	// Note that _pos is returned as an array of positions
	//params[["_areaMarker",""],["_noPositionsToFind",0],["_testIsAllowed", true],["_allowWater", false]];
	_pos = [_patrolMarker, _positionsToFind] call GMSCore_fnc_findRandomPosWithinArea;
	//[format["_findPositionAirPatrol: _pos = %1",_pos]] call GMSAI_fnc_log;
	_pos = _pos select 0;
	if !(_pos isEqualTo []) then {
		private _playersNear = [_pos, 100] call GMSCore_fnc_nearestPlayers;
		if !(_playersNear isEqualTo []) then {
			_pos = [];
		} else {
			if !([_pos, 150] call GMSCore_fnc_inAllowedLocation) then {
				_pos = [];
			} else {
				private _nearestBases = [_pos,250] call GMSCore_fnc_nearestBases;
				if !(_nearestBases isEqualTo []) then {
					_pos = [];
				};
			};
		};
	};
};
_pos 