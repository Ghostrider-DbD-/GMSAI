

params ["_vehicle", "_role", "_unit", "_turret"];
private _onFootGroup = _vehicle getVariable["GMSAI_onFoot",grpNull];
if (isNull _onFoot) then 
{
	_onFoot = createGroup GMSCore_side;
	_vehicle setVariable["GMSAI_onFoot",_onFoot];
};
_unit joinSilent _onFootGroup;