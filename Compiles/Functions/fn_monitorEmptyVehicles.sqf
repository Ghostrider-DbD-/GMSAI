/*
	GMSAI_fnc_monitorEmptyVehicles 

	Purpose: make sure empty vehicles (those with no vehicle crew) get properly deleted or released from GMSAI control. 

	Parameters: none 

	Returns: none 

	Copyright 2020 Ghostrider-GRG-

	Notes:
		This functionality should probably be part of GMS since it is generic to missions and roamers 
*/

#include "\addons\GMSAI\init\GMSAI_defines.hpp" 
//diag_log format["_monitorEmptyVehicles called at %1 with queue = %2",diag_tickTime,GMSAI_emptyVehicles];
for "_i" from 1 to (count GMSAI_emptyVehicles) do
{
	if (_i > (count GMSAI_emptyVehicles)) exitWith {};
	private _v = GMSAI_emptyVehicles deleteAt 0;
	//diag_log format["_monitorEmptyVehicles: GMSAI_deleteAt = %1 for vehicle %2",_v getVariable "GMSAI_deleteAt",_v];
	if (owner _v == 2) then
	{
		if (diag_tickTime > (_v getVariable "GMSAI_deleteAt")) then
		{
			//private _nearbyPlayers = nearestObjects[position _v,["Man"],150] select {isPlayer _x}; 
			private _nearbyPlayers = (position _v) nearEntities [["Man"],150] select {isPlayer _x};
			//diag_log format["_monitorEmptyVehicles: players near vehicle %1 = %2",_v,_nearbyPlayers];
			if (_nearbyPlayers isEqualTo []) then 
			{
				//diag_log format["_monitorEmptyVehicles: no player near vehicle %1 and it is time to delete it at %2",_v,diag_tickTime];
				deleteVehicle _v;
			} else {
				//diag_log format["_monitorEmptyVehicles: player(s) near vehicle %1 so defering its deletion"];
				_v setVariable["deleteAt",diag_tickTime + GMSAI_vehicleDeleteTimer];
				GMSAI_emptyVehicles pushBack _v;				
			};
		} else {
			GMSAI_emptyVehicles pushBack _v;
		};
	};
};