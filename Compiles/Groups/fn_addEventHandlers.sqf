/*
	This could help with player rewards and player stats tracking.
	But we could also tie rewards to the EH on GMSCore
*/
private _group = _this;
{
	_x addMPEventHandler["MPKilled",{_this call GMSAI_fnc_unitKilled;}];
	[format["adding GMSAI_fnc_unitKilled MP_HE to unit %1 of group %2",_x,_group]] call GMSAI_fnc_log;
}forEach (units _group);