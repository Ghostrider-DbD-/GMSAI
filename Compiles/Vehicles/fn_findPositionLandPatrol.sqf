/*
	GMSAI_fnc_findPositionLandPatrol 
*/

params["_patrolMarker","_blacklist"];

private _pos = [0,0,0];
diag_log format["_findPositionLandPatrol: called with _patrolMarker %1 | _pos initialized as %2 | _blacklist = %3", _patrolMarker, _pos, _blacklist];

while {_pos isEqualTo [0,0,0]} do {

	_pos = _patrolMarker call BIS_fnc_randomPosTrigger;
	if (surfaceIsWater _pos) then {
		_pos = [0,0,0];
	} else {
		private _radius =200;					
		private _nearRoads = [];
		while {_nearRoads isEqualTo []} do {
			_radius = _radius + 100;
			_nearRoads = _pos nearRoads _radius;
			diag_log format["_findPositionLandPatrol: search for nearRoads with _pos %1 | _radius %2 | _pos nearRoads _radius returned %3",_pos, _radius, _nearRoads];
		};		
		private _nextRoads = roadsConnectedTo (_nearRoads select 0);
		private _roadInfo = getRoadInfo (_nextRoads select 0); 
		_pos = ASLtoAGL (_roadInfo select 6);  // Position in ASL 
		diag_log format["_findPositionLandPatrol: _nextRoads = %1", _nextRoads];
		diag_log format["_findPositionLandPatrol: _roadInfo = %1", _roadInfo];		
		private _playersNear = [_pos, 100] call GMSCore_fnc_nearestPlayers;
		if !(_playersNear isEqualTo []) then {
			_pos = [0,0,0];
		} else {
			if ([_pos,_blacklist] call GMSCore_fnc_isBlacklisted) then {
				_pos = [0,0,0];
			} else {
				private _nearestBases = [_pos,250] call GMSCore_fnc_nearestBases;
				if !(_nearestBases isEqualTo []) then {
					_pos = [0,0,0];
				};
			};
		};
	};
};
diag_log format["_findPositionLandPatrol: called with _patrolMarker %1 returning _pos = %2", _patrolMarker, _pos];
_pos 