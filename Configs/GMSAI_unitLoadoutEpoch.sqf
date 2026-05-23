/*
	GMSAI Unit loadouts for Epoch 

	Edit, supplement or otherwise modify to suit your needs.
	See GMSAI_unitLoadoutDefault for more information on options for setting these up as either simple arrays or weighted arrays.

	Copyright 2020 Ghostrider-GRG-	
*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 

/*
	CONFIGUREATIONS BEGIN HERE
*/
_GMSAI_moneyBlue = 30;
_GMSAI_moneyRed = 45;
_GMSAI_moneyGreen = 60;
_GMSAI_moneyOrange = 75;

/*   DO NOT TOUCH GMSAI_money  */
GMSAI_money = [_GMSAI_moneyBlue,_GMSAI_moneyRed,_GMSAI_moneyGreen,_GMSAI_moneyOrange];
/*******************************/


/*  These are default settings. Note that they are overridden if you pull configs from the CfgPricing for Epoch  */ 

_headgear = ["H_Shemag_khk","H_Shemag_olive","H_Shemag_olive_hs","H_Shemag_tan","H_ShemagOpen_khk","H_ShemagOpen_tan","H_TurbanO_blk"];
_uniforms = ["U_IG_Guerilla1_1","U_IG_Guerilla2_1","U_IG_Guerilla2_2","U_IG_Guerilla2_3","U_IG_Guerilla3_1","U_IG_Guerilla3_2","junk3"];
_vests = [
    "V_1_EPOCH","V_2_EPOCH","V_3_EPOCH","V_4_EPOCH","V_5_EPOCH","V_6_EPOCH","V_7_EPOCH","V_8_EPOCH","V_9_EPOCH","V_10_EPOCH","V_11_EPOCH","V_12_EPOCH","V_13_EPOCH","V_14_EPOCH","V_15_EPOCH","V_16_EPOCH","V_17_EPOCH","V_18_EPOCH","V_19_EPOCH","V_20_EPOCH",
    "V_21_EPOCH","V_22_EPOCH","V_23_EPOCH","V_24_EPOCH","V_25_EPOCH","V_26_EPOCH","V_27_EPOCH","V_28_EPOCH","V_29_EPOCH","V_30_EPOCH","V_31_EPOCH","V_32_EPOCH","V_33_EPOCH","V_34_EPOCH","V_35_EPOCH","V_36_EPOCH","V_37_EPOCH","V_38_EPOCH","V_39_EPOCH","V_40_EPOCH",
    // DLC Vests
    "V_PlateCarrierSpec_blk","V_PlateCarrierSpec_mtp","V_PlateCarrierGL_blk","V_PlateCarrierGL_mtp","V_PlateCarrierIAGL_oli","junk2" 
];
_backpacks = ["B_Carryall_ocamo","B_Carryall_oucamo","B_Carryall_mcamo","B_Carryall_oli","B_Carryall_khk","B_Carryall_cbr","junk1" ]; 
_primary = [
	// sniper
		"srifle_EBR_F","srifle_GM6_F","srifle_LRR_F","srifle_DMR_01_F","junk4",
	//  LMG
		"LMG_Mk200_F","LMG_Zafir_F",
	// 556
		"arifle_SDAR_F","arifle_TRG21_F","arifle_TRG20_F","arifle_TRG21_GL_F","arifle_Mk20_F","arifle_Mk20C_F","arifle_Mk20_GL_F","arifle_Mk20_plain_F","arifle_Mk20C_plain_F","arifle_Mk20_GL_plain_F","arifle_SDAR_F",
	// 650 
		"arifle_Katiba_F","arifle_Katiba_C_F","arifle_Katiba_GL_F","arifle_MXC_F","arifle_MX_F","arifle_MX_GL_F","arifle_MXM_F",
	// MMG					
		"MMG_01_hex_F","MMG_02_sand_F","MMG_01_tan_F","MMG_02_black_F","MMG_02_camo_F",
	// DLC Sniper		
		"srifle_DMR_02_camo_F","srifle_DMR_02_F","srifle_DMR_02_sniper_F","srifle_DMR_03_F","srifle_DMR_03_tan_F","srifle_DMR_04_F","srifle_DMR_04_Tan_F","srifle_DMR_05_blk_F","srifle_DMR_05_hex_F","srifle_DMR_05_tan_F","srifle_DMR_06_camo_F","srifle_DMR_06_olive_F",
	// Other DLC weapons
		"arifle_AK12_F","arifle_AK12_GL_F","arifle_AKM_F","arifle_AKM_FL_F","arifle_AKS_F","arifle_ARX_blk_F","arifle_ARX_ghex_F","arifle_ARX_hex_F","arifle_CTAR_blk_F","arifle_CTAR_hex_F",
		"arifle_CTAR_ghex_F","arifle_CTAR_GL_blk_F","arifle_CTARS_blk_F","arifle_CTARS_hex_F","arifle_CTARS_ghex_F","arifle_SPAR_01_blk_F","arifle_SPAR_01_khk_F","arifle_SPAR_01_snd_F",
		"arifle_SPAR_01_GL_blk_F","arifle_SPAR_01_GL_khk_F","arifle_SPAR_01_GL_snd_F","arifle_SPAR_02_blk_F","arifle_SPAR_02_khk_F","arifle_SPAR_02_snd_F","arifle_SPAR_03_blk_F",
		"arifle_SPAR_03_khk_F","arifle_SPAR_03_snd_F","arifle_MX_khk_F","arifle_MX_GL_khk_F","arifle_MXC_khk_F","arifle_MXM_khk_F"	
];
_handguns = ["hgun_PDW2000_F","hgun_ACPC2_F","hgun_Rook40_F","hgun_P07_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","hgun_Pistol_Signal_F"];
_throwableExplosives = ["HandGrenade","MiniGrenade","1Rnd_HE_Grenade_shell","3Rnd_HE_Grenade_shell"];
_drinks = ["WhiskeyNoodle","ItemSodaAlpineDude","ItemSodaOrangeSherbet","ItemSodaPurple","ItemSodaMocha","ItemSodaBurst","ItemSodaRbull","FoodWalkNSons"];
_food = [
	"HotAxeSauce_epoch","gyro_wrap_epoch","icecream_epoch","redburger_epoch","bluburger_epoch","krypto_candy_epoch","ItemBakedBeans","ItemRiceBox","ItemPowderMilk","ItemCereals",
	"FoodBioMeat","FoodMeeps","FoodSnooter","sardines_epoch","meatballs_epoch","scam_epoch","sweetcorn_epoch","honey_epoch","CookedSheep_EPOCH","CookedGoat_EPOCH","SnakeMeat_EPOCH",
    "CookedRabbit_EPOCH","CookedChicken_EPOCH","CookedDog_EPOCH","ItemTroutCooked","ItemSeaBassCooked","ItemTunaCooked","TacticalBacon"
];
_meds = [
	"FAK", "ItemVitamins", "morphine_epoch", "iodide_pills_epoch", "adrenaline_epoch","caffeinepills_epoch", "orlistat_epoch", "ItemCanteen_Empty", "ItemCanteen_Clean", 
	"ItemBottlePlastic_Empty","ItemBottlePlastic_Clean","atropine_epoch","ItemWaterPurificationTablets","ItemPainKillers","ItemDefibrillator","ItemBloodBag_Empty","ItemBloodBag_Full","ItemAntibiotic","nanite_cream_epoch","nanite_pills_epoch"
];
_partsAndValuables = [
	"PartOreGold","PartOreSilver","PartOre","ItemGoldBar","ItemSilverBar","ItemGoldBar10oz","ItemTopaz","ItemOnyx","ItemSapphire","ItemAmethyst","ItemEmerald","ItemCitrine","ItemRuby","ItemQuartz","ItemJade","ItemGarnet","ItemKiloHemp",
	"PartPlankPack","ItemPlywoodPack","CinderBlocks","MortarBucket","ItemScraps","ItemCorrugated","ItemCorrugatedLg","CircuitParts","WoodLog_EPOCH","ItemRope","ItemStick","ItemRock","ItemBurlap","ItemBulb","ItemSolar","ItemCables","ItemBattery","Pelt_EPOCH","JackKit","ItemCanvas","ItemSeedBag","ItemPipe",
	"EngineParts","FuelTank","SpareTire","ItemGlass","ItemDuctTape","VehicleRepair"
];
_items = _drinks + _food + _meds + _partsAndValuables;
// available launchers include: ["launch_NLAW_F","launch_RPG32_F","launch_B_Titan_F","launch_I_Titan_F","launch_O_Titan_F","launch_B_Titan_short_F","launch_I_Titan_short_F","launch_O_Titan_short_F"];
_launchers = ["launch_RPG32_F"];
_binoculars = ["Binocular","Rangefinder"];
_nvg =  ["NVG_EPOCH"];

/*
	CONFIGURATIONS END HERE
*/
/*
	please do not touch below this line 
*/

[format[" Loaded GMSAI_unitLoadoutEpoch.sqf at %1",diag_tickTime]] call GMSAI_fnc_log;
