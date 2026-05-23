/*
	GMSAI_fnc_checkClassNames  

    Purpose: check classNames in an array, remove invalid ones, and return the cleaned up array. 
    
    Parameters: _classnameInfo, an array of classnames 

    Returns: _classnameInfo after being filtered for illeagal classnames 

    Copyright 2020 Ghostrider-GRG-

    Notes: 
        GMSAI_fnc_checkClassnNmesArray does the same thing 
        Why have two of these - run search and replace ?
*/

#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
params["_classnameInfo"];  //  Assumes an array of arrays, where for each subarray, the first element is an array of classnames to be checked.
for "_i" from 1 to (count _classnameInfo) do
{
    private _cni = _classnameInfo deleteAt 0;
	//diag_log format["[GMSAI] fn_checkClassnames: _cnl = %1",_cnl];
    private _cn = [_cnl select 0 select 0] call GMSAI_fnc_checkClassnames;
	_cnl set[0,_cn];
    _classnameInfo pushBack _cnl;
};
_classnameInfo