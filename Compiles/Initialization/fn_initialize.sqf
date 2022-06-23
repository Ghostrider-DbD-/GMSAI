/*
	purpose: initilize GMSAI
	Copyright 2020 Ghostrider-GRG-
*/

if (!(isServer) || hasInterface) exitWith {diag_log "[GMSAI] ERROR: GMSAI SHOULD NOT BE RUN ON A CLIENT PC";};
if (!isNil "GMSAI_Initialized") exitWith {diag_log "[GMSAI] 	ERROR: GMSAI AREADY LOADED";};
while {isNil "GMSCore_Initialized"} do {uiSleep 5};
while {isNil "GMSCore_Side"} do {uisleep 5};
while {isNil "GMSCore_modType"} do {uiSleep 5};

GMSAI_world = worldname;
GMSAI_worldSize = worldSize;
GMSAI_axis = GMSAI_worldSize / 2;
GMSAI_mapCenter = [GMSAI_axis, GMSAI_axis, 0];
GMSAI_mapRadius = sqrt 2 * GMSAI_axis;
GMSAI_maxRangePatrols =  GMSAI_axis * 2 / 3;
// Defines that are used for configuration of units and other things 
#include "\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp"

// configs for static and dynamic patrols, as well as vehicle, air, UGV and UAV patrols. 
// Load before variables to be sure debug settings are available.
#include "\addons\GMSAI\Configs\GMSAI_configs.sqf";
#include "\addons\GMSAI\Configs\GMSAI_playerMessages.sqf";

// variables in which lists of areas, groups, etc are stored 
#include "\addons\GMSAI\Compiles\initialization\GMSAI_Variables.sqf";

// configs for units based on the type of mod or use a default setting if no mod specified.

private["__GMSAI_moneyBlue","_GMSAI_moneyRed","_GMSAI_moneyGreen","_GMSAI_moneyOrange",
	"_headgear","_uniforms","_vests","_backpacks","_primary","_handguns","_throwableExplosives",
	"_food","_meds","_partsandvaluables","_medicalItems","_items","_launchers",
	"_nvg","_binoculars"
];

switch (toLowerANSI(GMSCore_modType)) do 
{
	case "exile": {	
		#include "\addons\GMSAI\Configs\GMSAI_unitLoadoutExile.sqf"
	};
	case "epoch": {	
		#include "\addons\GMSAI\Configs\GMSAI_unitLoadoutEpoch.sqf"
	};

	default { 
		#include "\addons\GMSAI\Configs\GMSAI_unitLoadoutDefault.sqf"
	};
};

if (GMSAI_validateClassnames) then 
{
	[format["GMSAI_fnc_initialize: Checking classnames for %1",'GMSAI_paratroopAircraftTypes']] call GMSAI_fnc_log;
	[GMSAI_paratroopAircraftTypes,true] call GMSCore_fnc_checkClassnamesArray;
	[GMSAI_paratroopAircraftTypes,true] call GMSCore_fnc_checkClassNamePrices;
	[format["GMSAI_fnc_initialize: Checking classnames for %1",'GMSAI_aircraftTypes']] call GMSAI_fnc_log;
	[GMSAI_aircraftTypes,true] call GMSCore_fnc_checkClassnamesArray;
	[GMSAI_aircraftTypes,true] call GMSCore_fnc_checkClassNamePrices;	
	[format["GMSAI_fnc_initialize: Checking classnames for %1",'GMSAI_UAVTypes']] call GMSAI_fnc_log;
	[GMSAI_UAVTypes,true] call GMSCore_fnc_checkClassnamesArray;
	[GMSAI_UAVTypes,true] call GMSCore_fnc_checkClassNamePrices;	
	[format["GMSAI_fnc_initialize: Checking classnames for %1",'GMSAI_UGVtypes']] call GMSAI_fnc_log;
	[GMSAI_UGVtypes,true] call GMSCore_fnc_checkClassnamesArray;	
	[GMSAI_UGVtypes,true] call GMSCore_fnc_checkClassNamePrices;	
	[format["GMSAI_fnc_initialize: Checking classnames for %1",'GMSAI_patrolVehicles']] call GMSAI_fnc_log;
	[GMSAI_patrolVehicles,true] call GMSCore_fnc_checkClassnamesArray;
	[GMSAI_patrolVehicles,true] call GMSCore_fnc_checkClassNamePrices;		
};

/*
	Configure the more complex arrays used to describe the configuration parameters 
	by GMSAI once it is running 
*/
private _blacklistedGear = [];
{
	_blacklistedGear append _x;
} forEach [
	GMSAI_blackListedOptics,
	GMSAI_blackListedPointers,
	GMSAI_blackListedMuzzles,
	GMSAI_blacklistedBackpacks,
	GMSAI_blacklistedVests,
	GMSAI_blacklistedUniforms,
	GMSAI_blacklistedHeadgear,
	GMSAI_blacklistedPrimary,
	GMSAI_blacklistedSecondary,
	GMSAI_blackListedLauncher,
	GMSAI_blackListedThrowables,
	GMSAI_blacklistedMedical,
	GMSAI_blacklistedFood,
	GMSAI_blacklistedBinocs,
	GMSAI_blacklistedNVG
];

if (GMSAI_useCfgPricingForLoadouts && !(GMSCore_modType isEqualTo "default")) then
{
	diag_log "[GMSAI] _unitLoadoutExile: running dynamically determined loadouts";
	
	private _gearBlue = [GMSAI_maxPricePerItem,_blacklistedGear,[/* blacklisted categories*/],[ /*GMSAI_blacklistedMods*/]] call GMSCore_fnc_dynamicConfigs;
	
	// to illustrate the weapons lists returned ... Note that wpnLMG includes the MMGs
	private _wpnPrimary = (_gearBlue select wpnAR) + (_gearBlue select wpnLMG) + (_gearBlue select wpnSMG) + (_gearBlue select wpnShotGun) + (_gearBlue select wpnSniper);	
	GMSAI_gearBlue = [
		[_wpnPrimary,GMSAI_chancePrimary,
			GMSAI_chanceOpticsPrimary,
			GMSAI_chanceMuzzlePrimary,
			GMSAI_chancePointerPrimary,
			GMSAI_blacklistedPrimary
		], // Just adding together all the subclasses of primary weaponss
		[_gearBlue select wpnHandGun, 
			GMSAI_chanceSecondary, 
			GMSAI_chanceOpticsSecondary, 
			GMSAI_chanceMuzzleSecondary, 
			GMSAI_chancePointerSecondary,
			GMSAI_blacklistedSecondary
		],
		[_gearBlue select wpnThrow, GMSAI_chanceThrowable,GMSAI_blackListedThrowables],
		[_gearBlue select headgearItems, GMSAI_chanceHeadgear,GMSAI_blacklistedHeadgear],
		[_gearBlue select uniforms, GMSAI_chanceUniform,GMSAI_blacklistedUniforms],
		[_gearBlue select vests, GMSAI_chanceVest,GMSAI_blacklistedVests],
		[_gearBlue select backpacks, GMSAI_chanceBackpack,GMSAI_blacklistedBackpacks],
		[_gearBlue select wpnLauncher, GMSAI_chanceLauncher,GMSAI_blackListedLauncher],  // this is determined elsewhere for GMSAI
		[_gearBlue select NvgItems, GMSAI_chanceNVG,GMSAI_blacklistedNVG],  // this is determined elsewhere for GMSAI
		[_gearBlue select BinocularItems,GMSAI_chanceBinoc,GMSAI_blacklistedBinocs],
		[_gearBlue select foodAndDrinks, GMSAI_chanceFood,GMSAI_blacklistedFood],
		[_gearBlue select medicalItems, GMSAI_chanceMedical,GMSAI_blacklistedMedical],
		[_gearBlue select lootItems, GMSAI_chanceLoot,GMSAI_blacklistedInventoryItems]
	];

	GMSAI_gearRed = GMSAI_gearBlue;
	GMSAI_gearGreen = GMSAI_gearBlue;
	GMSAI_gearOrange = GMSAI_gearBlue;	
	
	diag_log "[GMSAI] CfgPricing-based loadouts used";
} else {
	diag_log "[GMSAI] Config-based loadouts used";

	if (GMSAI_validateClassnames) then 
	{
		{
			//[format["GMSAI_fnc_initialize: checking classnames and pricing and removing blacklisted items for %1",_x]] call GMSAI_fnc_log;
			private _returnCNA = [_x,true] call GMSCore_fnc_checkClassnamesArray;
			//[format["_fn_initialize: _returnCNA = %1",_returnCNA]] call GMSAI_fnc_log;
			private _returnCNPriceCheck = [_x,true] call GMSCore_fnc_checkClassNamePrices;
			//[format["_fn_initialize: _returnCNPriceCheck = %1",_returnCNPriceCheck]] call GMSAI_fnc_log;
			private _returnFilterBLGear = [_x,_blacklistedGear] call GMSCore_fnc_removeBlacklistedItems;
			//[format["_fn_initialize: _returnFilterBLGear = %1",_returnFilterBLGear]] call GMSAI_fnc_log;			
		} forEach [
			_headgear,
			_uniforms,
			_vests,
			_backpacks,
			_primary,
			_handguns,
			_throwableExplosives,
			_food,
			_meds,
			_partsAndValuables,
			_launchers,
			_nvg,
			_binoculars
		];
	};

	uiSleep 10;
	// Lets remove any blacklisted items that might have crept in here by accident
	diag_log format["fn_initialize: _blacklistedGear = %1",_blacklistedGear];

	GMSAI_gearBlue = [
		[_primary,
			GMSAI_chancePrimary,
			GMSAI_chanceOpticsPrimary,
			GMSAI_chanceMuzzlePrimary,
			GMSAI_chancePointerPrimary,
			GMSAI_chanceBipodPrimary
		],  //[]  primary weapons
		[_handguns, 
			GMSAI_chanceSecondary, 
			GMSAI_chanceOpticsSecondary, 
			GMSAI_chanceMuzzleSecondary, 
			GMSAI_chancePointerSecondary
		], 	// [] secondary weapons
		[_throwableExplosives,GMSAI_chanceThrowable],																			 // [] throwables
		[_headgear, GMSAI_chanceHeadgear],																					//[] headgear
		[_uniforms, GMSAI_chanceUniform],																						// [] uniformItems
		[_vests, GMSAI_chanceVest],																							//[] vests
		[_backpacks, GMSAI_chanceBackpack],																					//[] backpacks
		[_launchers, GMSAI_chanceLauncher],	
		[_nvg, GMSAI_chanceNVG],																										//  launchers
		[_binoculars, GMSAI_chanceBinoc],
		[_food, GMSAI_chanceFood],
		[_meds, GMSAI_chanceMedical],
		[_partsAndValuables, GMSAI_chanceLoot]
	];
	
	GMSAI_gearRed = GMSAI_gearBlue;
	GMSAI_gearGreen = GMSAI_gearBlue;
	GMSAI_gearOrange = GMSAI_gearBlue;	
	{
		//diag_log format["[GMSAI] gearBlue %1 contains %2 categories",_forEachIndex, GMSAI_gearBlue select _forEachIndex];
	} forEach GMSAI_gearBlue;
	//diag_log "[GMSAI] classnames checked and invalid names excluded";
};

{
	private _array = _x;
	if (count (_array select 0) == 1) then 
	{
		_x = [_array] call GMSCore_fnc_checkClassNamesArray;
	};
	if (count (_array select 0) == 1) then 
	{
		_x = [_array] call GMSCore_fnc_checkClassNamesArray;
	};
} forEach [GMSAI_patrolVehicles,GMSAI_paratroopAircraftTypes,GMSAI_UAVTypes,GMSAI_UAVTypes];

GMSAI_unitDifficulty = [GMSAI_skillBlue, GMSAI_skillRed, GMSAI_skillGreen, GMSAI_skillOrange];
GMSAI_unitLoadouts = [GMSAI_gearBlue, GMSAI_gearRed, GMSAI_gearGreen, GMSAI_gearOrange];
//  [groups, unitsPerGroup, difficulty, chance, respawns, respawnTime, despawnTime, patrolTypes]
GMSAI_staticVillageSettings = [GMSAI_staticVillageUnitsPerGroup,GMSAI_staticVillageUnitsDifficulty,GMSAI_ChanceStaticCityGroups,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_staticVillagePatrolTypes];
GMSAI_staticCitySettings = [GMSAI_staticCityUnitsPerGroup,GMSAI_staticCityUnitsDifficulty,GMSAI_ChanceStaticCityGroups,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_staticCityPatrolTypes];
GMSAI_staticCapitalSettings = [GMSAI_staticCapitalUnitsPerGroup,GMSAI_staticCapitalUnitsDifficulty,GMSAI_ChanceCapitalGroups,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_staticCapitalPatrolTypes];
GMSAI_staticMarineSettings = [GMSAI_staticMarineUnitsPerGroup,GMSAI_staticMarineUnitsDifficulty,GMSAI_ChanceStaticMarineUnits,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_staticMarinelPatrolTypes];
GMSAI_staticOtherSettings = [GMSAI_staticOtherUnitsPerGroup,GMSAI_staticOtherUnitsDifficulty,GMSAI_ChanceStaticOtherGroups,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_staticOtherPatrolTypes];
GMSAI_staticRandomSettings = [GMSAI_staticrandomunitsPerGroup,GMSAI_staticRandomUnitsDifficulty,GMSAI_staticRandomChance,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_staticRandomPatrolTypes];
GMSAI_dynamicSettings = [GMSAI_dynamicRandomGroups,GMSAI_dynamicRandomUnits,GMSAI_dynamicUnitsDifficulty,GMSAI_dynamicRandomChance,GMSAI_staticRespawns, GMSAI_staticRespawnTime, GMSAI_staticDespawnTime,GMSAI_infantry];
GMSAI_paratroopSettings = [GMSAI_numberParatroops,GMSAI_paratroopDifficulty,GMSAI_chanceParatroops,0,GMSAI_paratroopCooldownTimer,GMSAI_paratroopDespawnTimer,GMSAI_infantry];

// These locations are used as spawn points for aircraft
GMSAI_aircraftPatrolDestinations = [] call GMSCore_fnc_getLocationsForWaypoints;
//diag_log format["[GMSAI] Initializing Static and Vehicle Spawns at %1",diag_tickTime];
[] call GMSAI_fnc_initializeStaticSpawnsForLocations;
[] call GMSAI_fnc_initializeRandomSpawns;
[] call GMSAI_fnc_initializeAircraftPatrols;
[] call GMSAI_fnc_initializeUAVPatrols;
[] call GMSAI_fnc_initializeUGVPatrols;
[] call GMSAI_fnc_initializeVehiclePatrols;
[] call GMSAI_fnc_initializeCustomSpawns;
[] spawn GMSAI_fnc_mainThread;

private _build = getText(configFile >> "GMSAI_Build" >> "build");
private _buildDate = getText(configFile >> "GMSAI_Build" >> "buildDate");
private _version = getText(configFile >> "GMSAI_Build" >> "version");
GMSAI_Initialized = true;

[] call compileFinal preprocessFileLineNumbers "\addons\GMSAI\Configs\GMSAI_custom.sqf";
[format[" Version %1 Build %2 Date %3 Initialized at %4",_version,_build,_buildDate,diag_tickTime]] call GMSAI_fnc_log;

/*
private _patrolZone = createMarker["testZone1",[23500,17900,0]];
_patrolZone setMarkerShape "ELLIPSE";
_patrolZone setMarkerColor "COLORBLUE";
private _pzGroups = [1];
private _pzUnitsPerGroup = [2,3];




