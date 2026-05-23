/*
	General Configurations for GMSAI
	By Ghostrider [GRG]
	Copyright 2020
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

// Use this to check that classnames are valid and match intended category for the various vehicle types used
GMSAI_validateClassnames = true;  
GMSAI_updateInterval = 120;  // update status of everything at this interval in seconds 
GMSAI_maxHeals = 1;  // Maximum # of times the AI can heal. Set to 0 to disable self heals.
GMSAI_minDamageForSelfHeal = 0.4;  // The damage a unit must sustain to self-heal. 
GMSAI_unitSmokeShell = "SmokeShellRed"; // The type of smoke units throw if damaged. Set to "" to disable.
GMSAI_baseSkill = 0.7;  // Base skill level for AI.
GMSAI_baseSkilByDifficulty = [
	0.5,  // blue 
	0.65, // Red 
	0.75, // green 
	0.9 // Orange 
];

// This is the radius within which nearby players will receive any messages regaring AI Kills by other players 
// the location of the killer is the center of this area
GMSAI_killMessagingRadius = 2000; 
GMSAI_killMessageToAllPlayers = [
	/*
		These settings are used by GMSCore to determine what kinds of messages to use to notify players of a kill.
		SystemChat can be broadcast to all players.
		Comment out all options to disable this function (faster)
	*/

	//"toast",  // Exile only 
	//"epochMsg", // Epoch only 
	//"hint",
	//"cutText",
	//"dynamic",  // A display with information about rewards formated in a list on the left side of the screen
				  // Not recommended
	//"systemChat"
]; 
GMSAI_killMessageTypesKiller = [
	/*
		These settings are used by GMSCore to determine what kinds of messages to use to notify players of a kill.
		SystemChat can be broadcast to all players.
		The other notifications will only be viewed by the player reponsible for the kill.
	*/

	//"toast",  // Exile only 
	//"epochMsg", // Epoch only 
	//"hint",
	//"cutText",
	"dynamic",  // A display with information about rewards formated in a list on the left side of the screen
	"systemChat"
];
GMSAI_rewards = [[0,0],[0,0],[0,0],[0,0]];
private _modType = [] call GMSCore_fnc_getModType;
switch (_modType) do 
{
	case "Epoch": {
		// expressed as crypto min, crypto max
		GMSAI_rewardsNotifications = ["dynamicText"];
		
		// expressed as [][tabs min, tabs max],[respect min,respect max]]
		GMSAI_rewardsBlue = [[5,10],[8,12]];
		GMSAI_rewardsRed = [[8,14],12,15];
		GMSAI_rewardsGreen = [[10,18],[15,20]];
		GMSAI_rewardsOrange = [[12,20],20,25];
		GMSAI_rewards = [GMSAI_rewardsBlue,GMSAI_rewardsRed,GMSAI_rewardsGreen,GMSAI_rewardsOrange];
		GMSAI_distanceBonus = 3; // per 100 M, max = 5 * this value;
		GMSAI_killsBonus = 3; // from 2X up, max 6* this value
		GMSAI_killstreakTimeout = 300; // 5 min
		GMSAI_distantIncrementForCalculatingBonus = 100;
	};
	case "Exile": {
		// expressed as [][tabs min, tabs max],[respect min,respect max]]
		GMSAI_rewardsBlue = [[5,10],[8,12]];
		GMSAI_rewardsRed = [[8,14],[12,15]];
		GMSAI_rewardsGreen = [[10,18],[15,20]];
		GMSAI_rewardsOrange = [[12,20],[20,25]];
		GMSAI_rewards = [GMSAI_rewardsBlue,GMSAI_rewardsRed,GMSAI_rewardsGreen,GMSAI_rewardsOrange];
		GMSAI_rewardsNotifications = ["dynamicText"];

		GMSAI_respectBonusForKillstreaks = 3; 
		GMSAI_moneyGainedForKillstreaks = 3; // per kill of the current killstreak 

		GMSAI_killstreakTimeout = 300; // 5 min
		GMSAI_distantIncrementForCalculatingBonus = 100;
	};
	case "default": {
		GMSAI_rewardsNotifications = ["dynamicText"];
		GMSAI_killstreakTimeout = 300; // 5 min
		// expressed as [][tabs min, tabs max],[respect min,respect max]]
		GMSAI_rewardsBlue = [[5,10],[8,12]];
		GMSAI_rewardsRed = [[8,14],12,15];
		GMSAI_rewardsGreen = [[10,18],[15,20]];
		GMSAI_rewardsOrange = [[12,20],20,25];
		GMSAI_rewards = [GMSAI_rewardsBlue,GMSAI_rewardsRed,GMSAI_rewardsGreen,GMSAI_rewardsOrange];		
	};
};

GMSAI_CustomLocations = [
	/*
		Several Examples are listed below 
	*/

	// Example: Military area just north of Pyrgos 
	
	/*
	[	
		"Pyrgos Mil Base",
		[[17439.6,13162.5,0.00155449],250,250,0,true],
		[2,4],  // Units per group 
		[GMSAI_difficultyBlue,0.75,GMSAI_difficultyRed,0.25,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01],		// difficulty 
		1.0,  //0.75,  // CHance 
		-1,  // Respawns 
		[30, 60], //[400,600], // respawn Timer 
		30, //120,  // despawn timer 
		[
			[GMSAI_ugv,[1],[]],	  // if you want to specify which UGV to spawn add the classNames in a weighted array 
			[GMSAI_uav,[1],[]],   // if you want to specify which UAV to spawn add the classNames in a weighted array 
			[GMSAI_air,[1],[]],	   // if you want to specify which aircraft to spawn add the classNames in a weighted array 
			
			[GMSAI_vehicle,[1],[
				//"CUP_C_Golf4_white_Civ",4,
				//"CUP_C_Golf4_whiteblood_Civ",4,
				//"CUP_C_Golf4_yellow_Civ",4,
				//"CUP_C_Octavia_CIV",3

				"C_Offroad_01_F",3,
				////"B_LSV_01_armed_F",2,
				"C_SUV_01_F",2,
				////"I_C_Offroad_02_LMG_F",2,
				//"B_T_LSV_01_armed_black_F",2,
				//"B_T_LSV_01_armed_olive_F",2,
				//"B_T_LSV_01_armed_sand_F",2	
				"C_Hatchback_01_F",4	
			]], 
			
			[GMSAI_infantry,[1,2],[]]				
		]
	]
	*/
	/*,
	[
		"Factory",
		[[12609.4,16417.7,0.0014534],250,250,0,true],
		[2,3],
		[GMSAI_difficultyBlue,0.75,GMSAI_difficultyRed,0.25,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01],		// difficulty 
		1.0,  //0.50,  // CHance 
		-1,  // Respawns 
		[30, 60],  //[450,600], // respawn Timer 
		30,  //120,  // despawn timer 
		[
			//[GMSAI_ugv,[1],[]],	  // if you want to specify which UGV to spawn add the classNames in a weighted array 
			//[GMSAI_uav,[1],[]],   // if you want to specify which UAV to spawn add the classNames in a weighted array 
			//[GMSAI_air,[1],[]],	   // if you want to specify which aircraft to spawn add the classNames in a weighted array 
			[GMSAI_vehicle,[1],[
			//"CUP_C_Golf4_white_Civ",4,
				//"CUP_C_Golf4_whiteblood_Civ",4,
				//"CUP_C_Golf4_yellow_Civ",4,
				//"CUP_C_Octavia_CIV",3

				"C_Offroad_01_F",3,
				"B_LSV_01_armed_F",2,
				"C_SUV_01_F",2,
				"I_C_Offroad_02_LMG_F",2,
				//"B_T_LSV_01_armed_black_F",2,
				//"B_T_LSV_01_armed_olive_F",2,
				//"B_T_LSV_01_armed_sand_F",2	
				"C_Hatchback_01_F",4	
			]], 
			[GMSAI_infantry,[1,2],[]]				
		]
	],
	[
		"Mil Base #2",
		[[23503.3,21124.9,0.00108337],250,250,0,true],
		[2,3],
		[GMSAI_difficultyBlue,0.75,GMSAI_difficultyRed,0.25,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01],		// difficulty 
		0.50,  // CHance 
		-1,  // Respawns 
		[450,600], // respawn Timer 
		120,  // despawn timer 
		[
			//[GMSAI_ugv,[1],[]],	  // if you want to specify which UGV to spawn add the classNames in a weighted array 
			//[GMSAI_uav,[1],[]],   // if you want to specify which UAV to spawn add the classNames in a weighted array 
			//[GMSAI_air,[1],[]],	   // if you want to specify which aircraft to spawn add the classNames in a weighted array 
			[GMSAI_vehicle,[1],[
			//"CUP_C_Golf4_white_Civ",4,
				//"CUP_C_Golf4_whiteblood_Civ",4,
				//"CUP_C_Golf4_yellow_Civ",4,
				//"CUP_C_Octavia_CIV",3

				"C_Offroad_01_F",3,
				"B_LSV_01_armed_F",2,
				"C_SUV_01_F",2,
				"I_C_Offroad_02_LMG_F",2,
				//"B_T_LSV_01_armed_black_F",2,
				//"B_T_LSV_01_armed_olive_F",2,
				//"B_T_LSV_01_armed_sand_F",2	
				"C_Hatchback_01_F",4	
			]], 
			[GMSAI_infantry,[1,2],[]]				
		]
	],
	[
		"Mil Base #3",
		[[12802.3,16663.7,0.00143433],250,250,0,true],
		[2,3],
		[GMSAI_difficultyBlue,0.75,GMSAI_difficultyRed,0.25,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01],		// difficulty 
		0.50,  // CHance 
		-1,  // Respawns 
		[450,600], // respawn Timer 
		120,  // despawn timer 
		[
			//[GMSAI_ugv,[1],[]],	  // if you want to specify which UGV to spawn add the classNames in a weighted array 
			//[GMSAI_uav,[1],[]],   // if you want to specify which UAV to spawn add the classNames in a weighted array 
			//[GMSAI_air,[1],[]],	   // if you want to specify which aircraft to spawn add the classNames in a weighted array 
			[GMSAI_vehicle,[1],[
				//"CUP_C_Golf4_white_Civ",4,
				//"CUP_C_Golf4_whiteblood_Civ",4,
				//"CUP_C_Golf4_yellow_Civ",4,
				//"CUP_C_Octavia_CIV",3

				"C_Offroad_01_F",3,
				"B_LSV_01_armed_F",2,
				"C_SUV_01_F",2,
				"I_C_Offroad_02_LMG_F",2,
				//"B_T_LSV_01_armed_black_F",2,
				//"B_T_LSV_01_armed_olive_F",2,
				//"B_T_LSV_01_armed_sand_F",2	
				"C_Hatchback_01_F",4				
			]], 
			[GMSAI_infantry,[1,2],[]]				
		]
	],
	*/
	/*
	[	// water patrol 
		"Pyrgos Gulf", 
		[[15352, 14127, 0], 300, 300, 0, true],
		[1,3], // Units per group 
		[GMSAI_difficultyBlue,0.75,GMSAI_difficultyRed,0.25,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01],		// difficulty 
		0.50,  // CHance 
		-1,  // Respawns 
		[450,600], // respawn Timer 
		120,  // despawn timer 
		[
			[GMSAI_air,[1],[]],
			[GMSAI_vehicle,[1],[
				"_Boat_Armed_01_minigun_F",
				"B_SDV_01_F"
			]],
			[GMSAI_infantry,[1],[]]
		]
	]	
	*/
];

/*
	GMSAI will try NOT to spawn any assets within these areas
*/
// TODO: Update how these are handled through call to GMSCore
GMSAI_BlacklistedLocations = [
	// These can include location names, markers or arrays formated as [center, a, b, angle, isRectangle]  
	// Some examples are listed below
	// Positions for Exile.Altis Mil server 
    // Note: blacklisted areas should be formated as follows
    //  [[_pos, _sizeA, _sizeB], _name] where name is the name to be assigned to the location
	/*
	[[[11633,11950,0],500,500],"TraderCitySW"],  // TraderCity_SW_Airfield
	[[[14645,16771,0],500,500], TraderCity2"], // Trader 
	[[[20824,7255,0],500,500], "TraderCity3"],  // Trader 
	[[[9189,21651,0],500,500], "TraderCity4"],  // Trader 
	[[[24147,16143,0],500,500, "TraderCity5"], // Trader  
	[[[2998,18175,0],500,500], "TraderCity6"],  // Trader 
	//[[[23334,24188,0],500,500,0,true],
	[[[14281.2,13469.3,0],250,250], "TinyIsland"],  // tiny island
	[[[15420.8,16223.6,-9.61744],500,250], "LargePowerPlant"],  // Power plant - it overlaps with the main trader
	[[[15137.2,17297.8,0],400,200], "MainAirportSW"],  // south end main airport - location of the virtual hangers
	[[[13471.9,12018.5,0],400,250], "ExileRespawnBunker"],  // Player Spawns on Island
	////[[15139,14299,0],300,300,0,true]
	*/
	[[[166733, 13604, 0], 200, 200], "ChelonosiIsland"]  // Chelonosi on Altis which does bad things to roaming vehicles
];

/* 
	Safezones represent areas within any AI that loiter too long are deleted.
	The goal is to prevent AI from hassling players in traders or other places they are not desired.
	NOTE - These safezones are used for GMSAI and GMS_RC 
*/
GMSAI_maxSafeZoneLoiterTime = 30; // assets are deleted if they remain within a safezone longer than this 
								  // Please note, this is an approximate time. Actual times may vary +/- 15 sec
GMSAI_safeZones = [
	// These can include location names, markers or arrays formated as [center, a, b, angle, isRectangle] 
	//[[14644,16772.3,0],3000,3000,0,true] // Main Terminal
	
];

/* these are here in case you want to change them - but there is little reason to fiddle with them */
GMSAI_killstreakTimeout = 300; // 5 min
GMSAI_groupDisengageDistanceInfantry = 500;
GMSAI_groupDisengageDistanceLandvehicle = 500;
GMSAI_groupDisengageDistanceAir = 1000;

/*
	might have to overide GMS on this after the unit is spawned but I think that is OK. 
	consider an option to not add attach to weapons.
*/
gmsai_blacklistedmods = [];  // List root names of mods that should have gear excluded
GMSAI_chancePrimary = 1;
GMSAI_chanceOpticsPrimary = 0.4; // the chance optics will be attached to a units weapon
GMSAI_blackListedOptics = [];  //  List is for both primary and secondary 
GMSAI_chancePointerPrimary = 0.4; 
GMSAI_blackListedPointers = [];  //  List is for both primary and secondary weapons.
GMSAI_chanceBipodPrimary = 0.4; 
GMSAI_chanceMuzzlePrimary = 0.4;
GMSAI_blackListedMuzzles = []; // List for both primary and secondary 
GMSAI_blacklistedPrimary = [
	"nl_auto_xbow",
	"pvcrifle_01_F",
	"ChainSaw",
	"Hatchet",
	"MultiGun",
	"MeleeSledge",
	"MeleeSword",
	"Power_Sword",
	"MeleeRod",
	"CrudeHatchet",
	"MeleeMaul",
	"WoodClub",
	"Plunger",
	"sr25_epoch"		
]; 

GMSAI_chanceSecondary = 0.9;
GMSAI_chanceOpticsSecondary = 0.4; // the chance optics will be attached to a units weapon 
GMSAI_chancePointerSecondary = 0.4; 
GMSAI_chanceMuzzleSecondary = 0.4;

GMSAI_blacklistedSecondary = [
	#ifdef isEpoch 
	"nl_auto_xbow",
	"pvcrifle_01_F",
	"ChainSaw",
	"Hatchet",
	"MultiGun",
	"MeleeSledge",
	"MeleeSword",
	"Power_Sword",
	"MeleeRod",
	"CrudeHatchet",
	"MeleeMaul",
	"WoodClub",
	"Plunger"	
	#endif 
]; 

GMSAI_chanceThrowable = 0.5;  // Grenades, smoke, chemlights, whatever is in the config for this
GMSAI_blackListedThrowables = []; 

GMSAI_chanceHeadgear = 0.5;
GMSAI_blacklistedHeadgear = [
	"H_HelmotO_ViperSP_ghex_F",
	"H_HelmetO_VierSP_hex"	
]; 

GMSAI_chanceUniform = 1;
GMSAI_blacklistedUniforms = [
	"U_I_Protagonist_VR",
	"U_C_Protagonist_VR",			
	"U_O_Protagonist_VR",
	"U_B_Protagonist_VR" 
]; 

GMSAI_chanceVest = 1;
GMSAI_blacklistedVests = []; 

GMSAI_chanceBackpack = 0.6;
GMSAI_blacklistedBackpacks = [
	#ifdef isEpoch 
	"TK_RPG_Backpack_Epoch",
	#endif 
	"I_UAV_01_backpack_F",
	"C_IDAP_UAV_06_backpack_F",
	"C_IDAP_UAV_06_antimine_backpack_F",
	"B_UAV_06_medical_backpack_F",
	""
]; 

GMSAI_chanceLauncher = 0.6;	// Launcer (self-explanatory), set to 0 to diable
GMSAI_blackListedLauncher = [];

GMSAI_chanceNVG = 1;	// NVG (when it is dark), set to 0 to disable
GMSAI_blacklistedNVG = [];

GMSAI_chanceBinoc = 0.8;  // binocs, range finders, laser designators
GMSAI_blacklistedBinocs = [];

GMSAI_chanceFood = 0.8;  // Food and drink
GMSAI_blacklistedFood = [];

GMSAI_chanceMedical = 0.3;  // healing, defibs, etc
GMSAI_blacklistedMedical = [];

GMSAI_chanceLoot = 0.5;  //  Things of value including building parts, gold, gems, or anything else
GMSAI_blacklistedInventoryItems = [];  // Inventory fron NVG to GPS or FAK you want to disallow

GMSAI_money = [8, 12, 16, 20];
GMSAI_defaultAlertDistance = 350;
GMSA_alertDistanceByDifficulty = [200, 300,450,600];
GMSAI_defaultInteligence = 0.5;
GMSAI_intelligencebyDifficulty = [0.1,0.3,0.5,0.8];
GMSAI_maxReloadsInfantry = -1;  // Set to 0 to prevent reloads, 1..N to have a finite # of them
GMSAI_skillBlue = [ 
	// _skills params["_accuracy","_aimingSpeed","_shake","_spotDistance","_spotTime","_courage","_reloadSpeed","_commanding","_general"];
	[0.05,0.08],  // accuracy
	[0.40,0.42],  // aiming speed
	[0.40,0.45],  // aiming shake
	[0.80,0.86], // spot distance
	[0.80,0.86], // spot time
	[0.80,0.86], // courage
	[0.45,0.46], // reload speed
	[0.75,0.80], // commanding
	[0.70,0.80] // general, affects decision making
];
GMSAI_skillRed = [ 
	// _skills params["_accuracy","_aimingSpeed","_shake","_spotDistance","_spotTime","_courage","_reloadSpeed","_commanding","_general"];
	[0.07,0.08],  // accuracy
	[0.50,0.55],  // aiming speed
	[0.50,0.55],  // aiming shake
	[0.84,0.88],// spot distance
	[0.84,0.88], // spot time
	[0.84,0.88], // courage
	[0.50,0.55], // reload speed
	[0.75,0.80], // commanding
	[0.970,0.980] // general, affects decision making
];
GMSAI_skillGreen = [ 
	// _skills params["_accuracy","_aimingSpeed","_shake","_spotDistance","_spotTime","_courage","_reloadSpeed","_commanding","_general"];
	[0.09,0.098],  // accuracy
	[0.55,0.58],  // aiming speed
	[0.55,0.58],   // aiming shake
	[0.86,0.90], // spot distance
	[0.86,0.90],  // spot time
	[0.86,0.90],  // courage
	[0.55,0.58],  // reload speed
	[0.85,0.90], // commanding
	[0.970,0.980] // general, affects decision making
];
GMSAI_skillOrange = [ 
	// _skills params["_accuracy","_aimingSpeed","_shake","_spotDistance","_spotTime","_courage","_reloadSpeed","_commanding","_general"];
	[0.12,0.18],  // accuracy
	[0.60,0.68],   // aiming speed
	[0.60,0.68],   // aiming shake
	[0.90,0.98],  // spot distance
	[0.90,0.98],  // spot time
	[0.90,0.98],  // courage
	[0.60,0.68],  // reload speed
	[0.90,0.98],  // commanding
	[0.970,0.980] // general, affects decision making
];

/*
	NOTE: you can add additional difficulties if you like 
*/

GMSAI_skillbyDifficultyLevel = [GMSAI_skillBlue,GMSAI_skillRed,GMSAI_skillGreen,GMSAI_skillOrange];
GMSAI_side = [] call GMSCore_fnc_getGMSside;
//diag_log format["GMSAI_configs:  GMSAI_side = %1 | GMSCore_side = %2",GMSAI_side,GMSCore_side];
/*********************************
	 Messaging to Clients
*********************************/
GMSAI_useKillMessages = true;
GMSAI_useKilledAIName = true; // when true, the name of the unit killed will be included in the kill message.
/*********************************
	 Patrol Spawn Configs
*********************************/
GMSAI_releaseVehiclesToPlayers = true;  // set to false to disable this feature.
GMSA_removeFuel = 0.1; // Fuel will be set to this value when vehicles are released to players.
GMSAI_vehicleDeleteTimer = 300; // vehicles with no live crew will be deleted at this interval after all crew are killed.
GMSAI_checkClassNames = true; // when true, class names listed in the configs will be checked against CfgVehicles, CfgWeapons, ets.
GMSAI_useCfgPricingForLoadouts = false;
GMSAI_maxPricePerItem = 1000;

// These weapons would cause no damage to AI or vehicles.
// I recommend you set this to [] for militarized servers.
GMSAI_forbidenWeapons = [
	/*
	Examples:
	"HMG_127","HMG_127_APC","HMG_M2","HMG_NSVT","GMG_40mm","autocannon_40mm_CTWS","autocannon_30mm_CTWS","autocannon_35mm","LMG_coax","autocannon_30mm","HMG_127_LSV_01"
	*/
];
GMSAI_forbidenMagazines = [
	/*
	Examples
	"24Rnd_missiles","200Rnd_40mm_G_belt"
	*/
];
GMSAI_disableInfrared = false; 
GMSAI_disabledSensors = [
	/*
	Current Arma Sensor (Arma 2.06)
	"IRSensorComponent",
	NVSensorComponent",
	"LaserSensorComponent",
	"ActiveRadarSensorComponent",
	"VisualSensorComponent",
	"ManSensorComponnet",
	"DataLinkSensorComponent"
	*/
];
/********************************
	Reinforcements (paratroops) Configs 
********************************/
GMSAI_maxParagroups = 10;  // 5;  // maximum number of groups of paratroups spawned at one time.
GMSAI_chanceParatroops = 0.75;  // chace that paratroops are brought in if a player is detected 
GMSAI_chancePlayerDetected = 0.75;  // reinforcements only spawn if a player is detected 
GMSAI_numberParatroops = [2,4]; // can be a single value (1, [1]) or a range
GMSAI_paratroopDifficulty = [GMSAI_difficultyBlue,0.40,GMSAI_difficultyRed,0.40,GMSAI_difficultyGreen,0.15,GMSAI_difficultyOrange,0.05];
GMSAI_paratroopTriggerTimer = 300;  // The time the server must wait before trying to spawn paras on players it detects (not used?)
GMSAI_paratroopRespawnTimer = 300;  //300;  // not used except as a place holder for certain functions that require a value be specified here.
GMSAI_paratroopCooldownTimer = 600; //300;  // Time between paratroop drops for a particular aircraft - this can be shortend based on numbers of players in the area.
GMSAI_paratroopDespawnTimer = 120; // time at which AI are deleted if no players are found within the patrol area assigned when the paratroops are spawned.
GMSAI_paratroopGunship = false;  // Set to true if you want the transport called in by UAVs to act as a gunship patrolling the drop area.
GMSAI_paratroopAircraftTypes = [  // Note: this is a weighted array of vehicles used to carry paratroops in to locations spotted by UAVs or UGVs
	#ifdef isEpoch
	"a2_mi8_EPOCH",3
	#endif 

	"B_Heli_Transport_01_F",5,
	"B_Heli_Light_01_F",1,
	"I_Heli_light_03_unarmed_F",5,
	"B_Heli_Transport_03_unarmed_green_F",5,
	"I_Heli_light_03_F",1,
	"O_Heli_Light_02_F",2,
	//"CUP_B_Mi171Sh_Unarmed_ACR",3,
	"B_Heli_Transport_03_unarmed_F",5
	
];

/*********************************
	Aircraft Patrol Spawn Configs
*********************************/
// TODO: aircraft could be spread out more on the map.
GMSAI_numberOfAircraftPatrols = 5;
GMSAI_aircraftPatrolDifficulty =  [GMSAI_difficultyBlue,0.90,GMSAI_difficultyRed,0.10];
GMSAI_aircraftRespawnTime = 600;  //[600,900];  //  Min, Max respawn time
GMSAI_aircraftDesapwnTime = 120;
GMSAI_aircraftGunners = 3;
GMSAI_airpatrolResapwns = -1;
// treat aircraft types as weighted arrayIntersect
GMSAI_aircraftTypes = [
	/*
	#ifdef isEpoch
	"a2_mi8_EPOCH",3,
	"uh1h_Epoch",3,
	"uh1h_armed_EPOCH",1,
	"uh1h_armed_plus_EPOCH",1,
	"a2_mi8_EPOCH",2,
	"a2_ch47f_EPOCH",3,
	"a2_ch47f_armed_EPOCH",1,
	"a2_ch47f_armed_plus_EPOCH",1,
	#endif 
	*/
	//"CUP_B_AW159_HIL",1,
	//"CUP_B_412_Mil_Transport_HIL",1,
	//"CUP_B_MH6J_OBS_USA",1,
	//"CUP_B_UH1Y_UNA_USMC",1,

	//"B_Heli_Transport_01_F",5,
	///"B_Heli_Light_01_F",1,
	"I_Heli_light_03_unarmed_F",5,
	"B_Heli_Transport_03_unarmed_green_F",5,
	///"I_Heli_light_03_F",1,
	//"I_Plane_Fighter_03_AA_F",1
	///"O_Heli_Light_02_F",2
	//"B_Heli_Attack_01_F",2,
	"B_Heli_Transport_03_unarmed_F",5
];

GMSAI_numberOfUAVPatrols = 3;
GMSAI_UAVTypes = [  //  note that faction may matter here.
	// East 
	//"O_UAV_01_F",2,  // Darter equivalent, unarmed
	//"O_UAV_02_F",2, // Ababil with Scalpel Missels
	//"O_UAV_02_CAS_F",2  // Ababil with Bombx
	//"O_UAV_01_F",2
	// West - see CfgVehicles WEST online or in the editor
	// Independent/GUER
	"I_UAV_01_F",1
];
GMSAI_UAVDifficulty = [GMSAI_difficultyBlue,0.40,GMSAI_difficultyRed,0.40,GMSAI_difficultyGreen,0.15,GMSAI_difficultyOrange,0.05];
GMSAI_UAVPatrolresapwns = -1;
GMSAI_UAVrespawntime = 300;
//GMSAI_UAVdespawnTime = 120;

GMSAI_numberOfUGVPatrols = 3;
GMSAI_UGVtypes = [  // 
	// Stompers
	//"O_UGV_01_rcws_F",5 // east - Use for Exile  
	//"B_UGV_01_rcws_F",5 // west 
	"I_UGV_01_rcws_F",5 // GUER
];
GMSAI_UGVdifficulty = [GMSAI_difficultyBlue,0.60,GMSAI_difficultyRed,0.40,GMSAI_difficultyGreen,0.05,GMSAI_difficultyOrange,0.05];
GMSAI_UGVrespawnTime = [600,900];  // Min, Max
GMSAI_UGVdespawnTime = 120;
GMSAI_UGVPatrolRespawns = -1; 

GMSAI_noVehiclePatrols = 10;
GMSAI_patroVehicleCrewCount = [3,5];
GMSAI_vehiclePatroDifficulty = [GMSAI_difficultyBlue,0.60,GMSAI_difficultyRed,0.40,GMSAI_difficultyGreen,0.05,GMSAI_difficultyOrange,0.05];
GMSAI_vehiclePatrolDeleteTime = 300;  //  Must be an INTEGER, not an array.
GMSAI_vehiclePatrolRespawnTime = [300,600];
GMSAI_vehiclePatrolRespawns = -1;
GMSAI_patrolVehicles = [  // Weighted array of vehicles spawned to patrol roads and cities.

	/*
	#ifdef isEpoch
	//"MBK_01_EPOCH",3,
	"A2_Golf_EPOCH",4,
	"A2_HMMWV_EPOCH",3,
	"A2_HMMWV_load_EPOCH",2,
	"A2_Lada_EPOCH",4,
	"A2_SUV_EPOCH",2,
	//"A2_SUV_load_EPOCH",2,
	//"A2_SUV_armed_EPOCH",0.5,
	"A2_UAZ_EPOCH",4,
	"A2_UAZ_Open_EPOCH",4,
	//"A2_Ural_EPOCH",2,
	//"A2_Vodnik_EPOCH",1,
	"A2_Volha_EPOCH",4
	#endif 
	*/
	/*

		END Testing Block

	*/
	//"CUP_C_Skoda_Red_CIV",4,
	//"CUP_C_Skoda_White_CIV",4,
	//"CUP_C_Skoda_Blue_CIV",4,
	//"CUP_C_Skoda_Green_CIV",4,
	//"CUP_C_SUV_CIV",2,

	//"CUP_B_HMMWV_Transport_USA",3,
	//"CUP_B_HMMWV_Unarmed_USA",3,
	//"CUP_C_SUV_TK",1,
	//"CUP_B_LR_Transport_CZ_D",2,

	//"CUP_C_Datsun_Covered",3,
	//"CUP_C_Datsun_Plain",3,
	//"CUP_C_Datsun_Tubeframe",3,
	//"CUP_C_Datsun_4seat",3,
	//"CUP_C_Datsun",3,
	//"CUP_C_Golf4_green_Civ",4,
	//"CUP_C_Golf4_red_Civ",4,
	//"CUP_C_Golf4_blue_Civ",4,
	//"CUP_C_Golf4_black_Civ",4,
	//"CUP_C_Golf4_kitty_Civ",2,
	//"CUP_C_Golf4_reptile_Civ",4,
	//"CUP_C_Golf4_camodigital_Civ",4,
	//"CUP_C_Golf4_camodark_Civ",4,
	//"CUP_C_Golf4_camo_Civ",4,

	//"CUP_B_M1030",1,

	//"CUP_C_Ural_Civ_03",2,
	//"CUP_C_Ural_Open_Civ_03",2,
	//"CUP_C_Ural_Civ_02",2,
	//"CUP_B_TowingTractor_USMC",0.1,
	//"CUP_C_C47_CIV",
	
	//"CUP_B_LR_Transport_CZ_W",2,

	//"CUP_C_Golf4_white_Civ",4,
	//"CUP_C_Golf4_whiteblood_Civ",4,
	//"CUP_C_Golf4_yellow_Civ",4,
	//"CUP_C_Octavia_CIV",3,
	//"CUP_C_Ural_Civ_01",2,
	//"CUP_C_Ural_Open_Civ_01",2,
	
	//"CUP_B_Ural_CDF",2,
	//"CUP_B_Ural_Open_CDF",2,
	//"CUP_C_Ural_Open_Civ_02",2,
	
	//"CUP_B_HMMWV_Ambulance_USA",3,
	
	//"CUP_C_UAZ_Unarmed_TK_CIV",2,
	//"CUP_C_UAZ_Open_TK_CIV",2,
	//"CUP_B_UAZ_Unarmed_CDF",3,
	//"CUP_B_Ural_Empty_CDF",2

	"C_Offroad_01_F",3,
	//"B_LSV_01_armed_F",2,
	"C_SUV_01_F",2,
	//"I_C_Offroad_02_LMG_F",2,
	//"B_T_LSV_01_armed_black_F",2,
	//"B_T_LSV_01_armed_olive_F",2,
	//"B_T_LSV_01_armed_sand_F",2	
	"C_Hatchback_01_F",4
	
];

/*********************************
	Static Infantry Spawn Configs
*********************************/
GMSAI_LaunchersPerGroup = 1; // set to -1 to disable
GMSAI_launcherCleanup = false;
GMSAI_useNVG = true;
GMSAI_removeNVG = false;

/*
	Settings that determine what to do if a player runs over an AI.
*/
GMSAI_runoverProtection = false;
GMSAI_runoverRespectPenalty = -25;
GMSAI_runoverMoneyPenalty = 0;
GMSAI_runoverPenalties = [];
GMSAI_boostSkillsLastUnits = 2;  // Surviving groups skills will be boosted when number of units alive in the group is <= this value (not yet implemented)
									// TODO: Implement this
GMSAI_NotifyNeighboringGroupLastUnit = [250,500];  // set to [] to disable; otherwise nearbyGroup are notified with the search being for the radius in the second parameter when {alive _x} group <= GMSAI_boostSkillsLastUnit
													// TODO: Implement this?  From player feedback, there is already pretty active huntiing behavior..
GMSAI_patrolTypesToNotifyLastUnit = ["Air","Car","Tank","StaticWeaon","Ship","Man"];  // Select from among these to select the kinds of nearby groups that are alerted.

/*
	you can specify 1 or more penalties 
	1 - unit is revived 
	2. the dead unit is stripped of gear and money 
	3. vehicle hitpoints are randomly damaged. Amounts of damage can be set (see below); player is notified of a sniper with bad aim
	4. A grenade is attached to a random hitpoint; player is notified of an IED
	5. An earthquake occurs under the player causing random damage; player is notified of an IED 
	6. Tabs/Crypto are removed according to the value in  GMSAI_runoverMoneyPenalty
	7.Respect/reputation (coming soon) is removed according to the value in GMSAI_runoverRespectPenalty
*/

GMSAI_bodyDeleteTimer =10 * 60;

GMSAI_useDynamicSpawns = true;
GMSAI_maxLoiterTime = 900;  // 300 - time before a player is considered camping out.
GMSAI_maxActiveDynamicSpawns = 10;  // Max players that have a dynamic spawn targeting them.
GMSAI_maximumDynamicRespawns = -1;  //  Set to 0 to spawn only once. Set to -1 to have infinite respawns (default).
GMSAI_dynamicRespawnTime = 900;
GMSAI_dynamicDespawnTime = 120;
//GMSAI_dynamicTriggerTime = 900;  // How long you have to spend in a sector to trigger these
GMSAI_dynamicUnitsDifficulty = [GMSAI_difficultyBlue,0.50,GMSAI_difficultyRed,0.50,GMSAI_difficultyGreen,0.01,GMSAI_difficultyOrange,0.01];  // Set how are the AI are
GMSAI_dynamicRandomGroups = [1];  //  Presently only 1 group can be spawned; increase number of units to add difficulty here.
GMSAI_dynamicRandomUnits = [2,3];
GMSAI_dynamicRandomChance = 0.5;

GMSAI_minimumLocationDimension = [250,250];
GMSAI_chanceToGarisonBuilding = 0.330;  // determines the chance that units will try to garison the nearest building when they move to a new location.
GMSAI_staticRespawns = -1;  //  Set to -1 to have infinite respawns (default). 
GMSAI_staticRespawnTime = 600;
GMSAI_staticDespawnTime = 120;
GMSAI_staticTriggerTime = 30;  //180;  //  How long you have to spend in a sector / area to trigger them

/*
	SETTINGS FOR VILLAGES 
*/
GMSAI_staticVillageGroups = false;  			//  false to disable
GMSAI_staticVillageUnitsPerGroup = [2,4];  	// This can be an integer or array [min, max] and only applies to infantry
GMSAI_staticVillagePatrolTypes = [
	[GMSAI_vehicle,[1],[
		//"CUP_C_Golf4_white_Civ",4,
		//"CUP_C_Golf4_whiteblood_Civ",4,
		//"CUP_C_Golf4_yellow_Civ",4,
		//"CUP_C_Octavia_CIV",3
		"C_SUV_01_F",2,
		"C_Hatchback_01_F",4
	]], 	// The format for these is [
		// patrolType, 
		// Number of groups/vehicles to spawn as either an integer or range [min,max],
		// [vehicle types as weighed array where applicable] - Note that the default of [] will use the GMSAI_patrolVehicles definded above
		//]
	[GMSAI_infantry,[1,2],[]]
];
// Difficulties are specified using a weighted array. Any number of options is available. The total relative chance does NOT have to add up to 1, but does specify the relative chance an option will be chosen.
GMSAI_staticVillageUnitsDifficulty = [GMSAI_difficultyBlue,0.90,GMSAI_difficultyRed,0.10,GMSAI_difficultyGreen,0.01,GMSAI_difficultyOrange,0.01]; // the value after each difficulty level indicates the relative chance it will be selected from the weighted array.
GMSAI_ChanceStaticVillageGroups = 0.80;

/*
	SETTINGS FOR CITIES
*/
GMSAI_staticCityGroups = false;  //  false to disable
GMSAI_staticCityUnitsPerGroup = [2,4];
GMSAI_staticCityPatrolTypes = [  //  for patrols beyond infantry
	/*
	[GMSAI_vehicle,[1,2],[
		//"C_Offroad_01_F",3,
		//"B_LSV_01_armed_F",2,
		"C_SUV_01_F",2,
		"C_Hatchback_01_F",4		
		//"I_C_Offroad_02_LMG_F",2,
		//"B_T_LSV_01_armed_black_F",2,
		//"B_T_LSV_01_armed_olive_F",2,
		//"B_T_LSV_01_armed_sand_F",2,
		//"CUP_C_Golf4_white_Civ",4,
		//"CUP_C_Golf4_whiteblood_Civ",4,
		//"CUP_C_Golf4_yellow_Civ",4,
		//"CUP_C_Octavia_CIV",3		
		
		//"B_MRAP_01_hmg_F",1,
		//"O_MRAP_02_hmg_F",1,
		//"I_MRAP_03_hmg_F",1			
		
	]],
	*/
	[GMSAI_air,[1],[]],	
	[GMSAI_infantry,[2,3],[]]	
];
GMSAI_staticCityUnitsDifficulty = [GMSAI_difficultyBlue,0.50,GMSAI_difficultyRed,0.5,GMSAI_difficultyGreen,0.01,GMSAI_difficultyOrange,0.01];
GMSAI_ChanceStaticCityGroups = 0.90;

/*
	SETTINGS FOR CAPITAL CITIES
*/
GMSAI_staticCapitalGroups = false;  //  false to disable
GMSAI_staticCapitalUnitsPerGroup = [3,4];
GMSAI_staticCapitalPatrolTypes = [  //  for patrols beyond infantry
	/*

	//[GMSAI_ugv,[1,2],[]],	
	[GMSAI_uav,[1],[]],
	
	[GMSAI_air,[1],[]],
	[GMSAI_infantry,[2,3],[]]  // Add one for every infantry group 	
	*/
	[GMSAI_vehicle,[1,3],[
		//"B_G_Offroad_01_armed_F",3,
		//"O_G_Offroad_01_armed_F",3,
		//"CUP_C_Golf4_white_Civ",4,
		//"CUP_C_Golf4_whiteblood_Civ",4,
		//"CUP_C_Golf4_yellow_Civ",4,
		//"CUP_C_Octavia_CIV",3
			
		//"B_MRAP_01_gmg_F",1,
		//"O_MRAP_02_gmg_F", 1,
		//"I_MRAP_03_gmg_F",1,
		//"B_APC_Wheeled_01_cannon_F",0.5,
		//"I_APC_Wheeled_03_cannon_F",0.5
		
		//"C_SUV_01_F",2,
		//"C_Hatchback_01_F",4		
	]],	
	//[GMSAI_ugv,[1,2],[]],	
	//[GMSAI_air,[1],[]],
	//[GMSAI_uav,[1],[]],
	[GMSAI_infantry,[2,3],[]]  
];
GMSAI_staticCapitalUnitsDifficulty = [GMSAI_difficultyBlue,0.10,GMSAI_difficultyRed,0.50,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01];
GMSAI_ChanceCapitalGroups = 0.90;

/*
	SETTINGS FOR PORTS AND MARINE ARES
*/
GMSAI_staticMarineGroups = false;  //  false to disable
GMSAI_staticMarineUnitsPerGroup = [2,3];
GMSAI_staticMarinelPatrolTypes = [ //  for patrols beyond infantry
	[GMSAI_vehicle,[1],[
		//"CUP_B_RHIB2Turret_USMC",1
		"C_SUV_01_F",2,
		"C_Hatchback_01_F",4		
	]],
	[GMSAI_air,[1],[]]
];
GMSAI_staticMarineUnitsDifficulty = [GMSAI_difficultyBlue,1,GMSAI_difficultyRed,0.50,GMSAI_difficultyGreen,0.01,GMSAI_difficultyOrange,0.01];
GMSAI_ChanceStaticMarineUnits = 0.999;

/*
	SETTINGS FOR MILITARY AND OTHER AREAS NOT SPECIFIED ABOVE
*/
GMSAI_staticOtherGroups = false;  //  false to disable
GMSAI_staticOtherUnitsPerGroup = [2,4]; // as above, this can be an integer or array with a range
GMSAI_staticOtherPatrolTypes = [ //  for patrols beyond infantry
	[GMSAI_vehicle,[1],[
		//"CUP_C_Golf4_white_Civ",4,
		//"CUP_C_Golf4_whiteblood_Civ",4,
		//"CUP_C_Golf4_yellow_Civ",4,
		//"CUP_C_Octavia_CIV",3		
		"C_SUV_01_F",2,
		"C_Hatchback_01_F",4		
	]],
	[GMSAI_infantry,[1,2],[]]
];
GMSAI_staticOtherUnitsDifficulty = [GMSAI_difficultyBlue,0.10,GMSAI_difficultyRed,0.50,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01];
GMSAI_ChanceStaticOtherGroups = 0.90;

/*
	SETTINGS FOR SPAWNS PLACED AT RANDOM LOCATIONS
*/
GMSAI_StaticSpawnsRandom = 0;         // Determines the number of random spans independent of cites, town, military areas, ports, airports and other:  default 25. Set == 0 do have no random spawn areas.
									  // Must be integer, set to 0 to disable
GMSAI_staticRandomGroups = [1];  //[1,3];     // as above, this can be an integer or array with a range
GMSAI_staticRandomUnitsPerGroup = [1]; //[1,3];   // as above, this can be an integer or array with a range
GMSAI_staticRandomPatrolTypes = [  //  for patrols beyond infantry
	[GMSAI_vehicle,[1],[
		//"CUP_C_Golf4_white_Civ",4,
		//"CUP_C_Golf4_whiteblood_Civ",4,
		//"CUP_C_Golf4_yellow_Civ",4,
		//"CUP_C_Octavia_CIV",3		
		"C_SUV_01_F",2,
		"C_Hatchback_01_F",4		
	]],		
	
	[GMSAI_ugv,[1],[]],	
	[GMSAI_uav,[1],[]],
	[GMSAI_air,[1],[]],	
	[GMSAI_infantry,[1,2],[]]	
];
GMSAI_staticRandomUnitsDifficulty = [GMSAI_difficultyBlue,0.75,GMSAI_difficultyRed,0.25,GMSAI_difficultyGreen,0.50,GMSAI_difficultyOrange,0.01];
GMSAI_staticRandomChance = 0.999;

if (GMSAI_debug > 0) then {
	[format["Configuration and Settings Loaded at %1",diag_tickTime]] call GMSAI_fnc_log;
};