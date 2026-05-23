/*

*/
#include "\x\addons\GMSAI\Compiles\initialization\GMSAI_defines.hpp" 
diag_log format["[GMSAI] <BEGIN> GMSAI_playerRewards.sqf at %1",diag_tickTime];

GMSAI_respectGainedPerKillBase = 5;
GMSAI_respectBonusForDistance = 5;
GMSAI_respectBonusForSecondaryKill = 25;
GMSAI_respectBonusForKillstreaks = 5; 

GMSAI_moneyGainedPerKillBase = 5;
GMSAI_moneyGainedPerKillForDistance = 5;
GMSAI_moneyGainedForSecondaryKill = 25;
GMSAI_moneyGainedForKillstreaks = 5; // per kill of the current killstreak 

GMSAI_killstreakTimeout = 300; // 5 min
GMSAI_distantIncrementForCalculatingBonus = 100;

diag_log format["[GMSAI] <END> GMSAI_playerRewards.sqf at %1",diag_tickTime];