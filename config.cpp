/*
	By Ghostrider [GRG]
	Copyright 2016
	
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/	
*/
class GMSAI_Build {
	version = "1.01";
	build = "28";
	buildDate = "06-22-22";
};
class CfgPatches {
	class GMSAI {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"GMSCore"};
	};
};
class CfgFunctions {
	class GMSAI {
		class AirVehicles {
			// Everything having do with spawning and monitoring Air/UAV patrols is dealt with by these functions.
			file = "addons\GMSAI\Compiles\AirVehicles";
			class aircraftAddEventHandlers {};
																
		};
		class CustomSpawns {
			// Functions that support adding additional, custom spawns 
			file="addons\GMSAI\Compiles\CustomSpawns";
			class addCustomAircraftSpawn {};
			class addCustomInfantrySpawn {};
			class addCustomMultiSpawn {};
			class addCustomUAVSpawn {};
			class addCustomUGVSpawn {};		
			class addCustomVehicleSpawn {};	
		};
		class dynamicSpawns {
			// Thesee functions monitor and spawn infantry groups in the vicinity of the player
			file = "addons\GMSAI\Compiles\DynamicSpawns";
			class dynamicAIManager {};
			class spawnDynamicPatrols {};			
		};
		class Functions {
			//  Core and generic support functions.
			file = "addons\GMSAI\Compiles\Functions";
			//class isBlacklisted {};  // This is a generic function that could probably be moved to GMSCore
			class mainThread {};  // This is a scheduler for all of the events that must happen for spawns, despawns and such.
		};	
		class Groups {
			file = "addons\GMSAI\Compiles\Groups";
			class addGroupDebugMarker {};
			class deleteGroupDebugMarkers {};
			class getGroupDebugMarker {};
			class monitorGroupDebugMarkers {};
			class spawnInfantryGroup {};			
			class updateGroupDebugMarker {};
		};			
		class Initialization {
			// Initialization of static spawn points is handled by these functions
			file = "addons\GMSAI\Compiles\Initialization";
			class initialize {};
			class initializeCustomSpawns {};
			class initializeStaticSpawnsForLocations {};
			class initializeRandomSpawns {};				
			class initializeAircraftPatrols {};
			class initializeUAVPatrols {};		
			class initializeUGVPatrols {};	
			class initializeVehiclePatrols {};
			class validateConfigs {};
		};	
		class Players {
			// Things that GMSAI does to players.
			file = "addons\GMSAI\Compiles\Players";
			class getKillstreak {};
			//class rewardPlayer {};
			class updateKillstreak {};
		};
		class Reinforcements {
			//  all things related to reinforcements in the form of paratroops 
			file = "addons\GMSAI\Compiles\Reinforcements";
		};
		class startup {
			file = "addons\GMSAI\Compiles\startup";
			class startup {
				postInit = 1;
			};
		};
		class staticSpawns {
			// These functions monitor and spawn infantry groups as fixed locations as players approach or leave these areas.
			file = "addons\GMSAI\Compiles\staticSpawns";
			class addActiveSpawn {};
			//class addBlacklistedArea {};
			class addStaticSpawn {};
			class addCustomStaticSpawn {};
			//class addCustomInfantrySpawn {};
			class monitorStaticPatrolAreas {};
			class spawnPatrolTypes {};
		};			
		class Units {
			// Stuff that happens when events fire on units in GMSAI; some of these are in addition to EH that fire on GMSCore
			file = "addons\GMSAI\Compiles\Units";
			class boostOnNearbyUnitKilled {};
			class unitHit {};
			class unitKilled {};			
		};		
		class Utilities {
			// Utilities such as logging messages for GMSAI
			file = "addons\GMSAI\Compiles\Util";
			class log {};
		};							
		class Vehicles {
			//  Everything related spawning/monitoring land / sea surface / SDV ehicle patrols is handled here.
			file = "addons\GMSAI\Compiles\Vehicles";
			class aircraftHit {};
			class initializeVehicleWaypoints {};
			class monitorVehiclePatrols {};	
			class monitorUGVPatrols {};
			class monitorAirPatrols {};  
			class monitorUAVPatrols {};								
			//class nextWaypointVehicles {};
			//class loiterWaypointVehicles {};
			class processEmptyVehicle {};
			//class processAircraftKilled {};
			//class processAircraftHit {};			
			class spawnVehiclePatrol {};	
			class spawnUGVPatrol {};
			class spawnUAVPatrol {};	
			class spawnAircraftPatrol {};						
			//class vehicleAddEventHandlers {};
			class vehicleCrewGetOut {};	
			//class vehicleCrewHandleDamage {};						
			//class vehicleCrewHit {};
			//class vehicleCrewKilled {};
			class vehicleKilled {};
			//class vehicleHandleDamage {};
			class vehicleHit {};

			class destroyWaypoint {};
			class dropReinforcements {};
			class flyInReinforcements {};						
			class getToDropPos {};
			class monitorParatroopGroups {};	
			class reachedDropPos {};						
			class spawnParatroops {};				
		};
	};
};

