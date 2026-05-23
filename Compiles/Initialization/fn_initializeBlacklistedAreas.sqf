/*
    GMSAI_fnc_initializeBlacklistedAreas

    Purpose: initialize any blacklisted areas in GMSAI_configs 
    Params: None
    Returns: None
    Note: blacklisted areas should be formated as follows
    //  [[_pos, _sizeA, _sizeB], _name] where name is the name to be assigned to the location
*/

{
    // Parameters addBlacklistedLocation 
    // params[["_location", [[0,0,0], 0, 0]],["_name",""]];
    _x params ["_location", "_locationName"];
    [_location, _locationName + "BLZone"] call GMSCore_fnc_addBlacklistedLocation;
    [_location, _locationName + "NAZone"] call GMSCore_fnc_addNoAggroLocation; 
} forEach GMSAI_BlacklistedLocations;