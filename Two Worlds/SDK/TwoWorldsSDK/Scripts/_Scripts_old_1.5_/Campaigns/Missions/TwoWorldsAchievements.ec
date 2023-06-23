global "Achievements Script"
{

#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Enums.ech"
#include "..\\..\\Common\\Quest.ech"
#include "..\\..\\Common\\Levels.ech"
#include "..\\..\\Common\\CreateStrings.ech"
#include "..\\..\\Common\\Enemies.ech"

#ifdef _XBOX

//get actual defines
#include "../../../Achievements.spa.h"

#else

//doesn't matter what values

// For rich presence
#define CONTEXT_GAMESTATE_IDLE_GAME                 0
#define CONTEXT_GAMESTATE_EXPLORING_WORLD           1
#define CONTEXT_GAMESTATE_EXPLORING_DUNGEON         2
#define CONTEXT_GAMESTATE_TRADING_IN_THE_SHOP       3
#define CONTEXT_GAMESTATE_EXPLORING_THARBAKIN       4
#define CONTEXT_GAMESTATE_EXPLORING_CATHALON        5
#define CONTEXT_GAMESTATE_EXPLORING_QUDINAAR        6
#define CONTEXT_GAMESTATE_EXPLORING_ASHOS           7
#define CONTEXT_GAMESTATE_EXPLORING_GORGAMMAR       8
#define CONTEXT_GAMESTATE_EXPLORING_OSWAROTH        9
#define CONTEXT_GAMESTATE_PLAYING_RPG               10
#define CONTEXT_GAMESTATE_PLAYING_PVP               11

// For achievements
#define ACHIEVEMENT_ACH_01                          69
#define ACHIEVEMENT_ACH_02                          78
#define ACHIEVEMENT_ACH_03                          79
#define ACHIEVEMENT_ACH_04                          80
#define ACHIEVEMENT_ACH_05                          81
#define ACHIEVEMENT_ACH_06                          82
#define ACHIEVEMENT_ACH_07                          83
#define ACHIEVEMENT_ACH_08                          84
#define ACHIEVEMENT_ACH_09                          85
#define ACHIEVEMENT_ACH_10                          86
#define ACHIEVEMENT_ACH_11                          87
#define ACHIEVEMENT_ACH_12                          88
#define ACHIEVEMENT_ACH_13                          89
#define ACHIEVEMENT_ACH_14                          90
#define ACHIEVEMENT_ACH_15                          91
#define ACHIEVEMENT_ACH_16                          92
#define ACHIEVEMENT_ACH_17                          93
#define ACHIEVEMENT_ACH_18                          94
#define ACHIEVEMENT_ACH_19                          95
#define ACHIEVEMENT_ACH_20                          96
#define ACHIEVEMENT_ACH_21                          97
#define ACHIEVEMENT_ACH_22                          98
#define ACHIEVEMENT_ACH_23                          99
#define ACHIEVEMENT_ACH_24                          100
#define ACHIEVEMENT_ACH_25                          101
#define ACHIEVEMENT_ACH_26                          102
#define ACHIEVEMENT_ACH_27                          103
#define ACHIEVEMENT_ACH_28                          104
#define ACHIEVEMENT_ACH_29                          105
#define ACHIEVEMENT_ACH_30                          106
#define ACHIEVEMENT_ACH_31                          107
#define ACHIEVEMENT_ACH_32                          108
#define ACHIEVEMENT_ACH_33                          109
#define ACHIEVEMENT_ACH_34                          110
#define ACHIEVEMENT_ACH_35                          111
#define ACHIEVEMENT_ACH_36                          112
#define ACHIEVEMENT_ACH_37                          113
#define ACHIEVEMENT_ACH_38                          114
#define ACHIEVEMENT_ACH_39                          115
#define ACHIEVEMENT_ACH_40                          116
#define ACHIEVEMENT_ACH_41                          117

#endif

/*
+ zrobione i sprawdzone
- zrobione i niekoniecznie sprawdzone

-  eAchievementLearn5Skills
-  eAchievementLearn10Skills
-  eAchievementLearn20Skills
-  eAchievementLearnAllSkills
-  eAchievementReachLevel10ForASkill
-  eAchievementReachLevel5
-  eAchievementReachLevel10
-  eAchievementReachLevel20
-  eAchievementReachLevel35
-  eAchievementReachLevel50
+  eAchievementDiscover10Locations
+  eAchievementDiscover20Locations
+  eAchievementDiscover50Locations
+  eAchievementVisitAllBlackTowers
+  eAchievementFindAllGraveyards
+  eAchievementVisit10DungeonsOrCaves
+  eAchievementVisit20DungeonsOrCaves
+  eAchievementVisitAllDungeonsOrCaves
+  eAchievementFindAllLocationsInTheGame
+  eAchievementRideAHorse
+  eAchievementMakeASuccessfulTeleportation
+  eAchievementUseAlchemyToCreateAPotion
+  eAchievementUseAlchemyToCreateAPermanentPotion
+  eAchievementUseAlchemyToCreateABomb
+  eAchievementUseAlchemyToCreateAWeaponEnchancer
+  eAchievementUseMetalurgyToCreateClass2Object
+  eAchievementUseMetalurgyToCreateClass10Object
+  eAchievementOpenMasterLock
+  eAchievementKillADragon
+  eAchievementKillAStoneGolem
+  eAchievementUseABoostedSpell
+  eAchievementCastChamber5Spell
+  eAchievementSummonAMonster
-  eAchievementFindARelic
-  eAchievementFindWaterElement
-  eAchievementFindAirElement
-  eAchievementFindFireElement
-  eAchievementFindEarthElement
-  eAchievementDeliverAllElementsToQudinaar
-  eAchievementDestroyThePentagram
-  eAchievementKillGandohar
*/

int    arrAchievementID[];
int    nIsTrading;
int    nGameMode;

state Initialize;
state Nothing;

function void InitArrays();
function void InitGameState();
function void CheckGameState();
function int  ProcessAchievement(int nIndex);
function int  IsAchievementSet(int nIndex);
function void SetAchievement(int nIndex);
function void SetGameState(int nIndex);

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

function void InitArrays()
{
    arrAchievementID.Add(ACHIEVEMENT_ACH_01);
    arrAchievementID.Add(ACHIEVEMENT_ACH_02);
    arrAchievementID.Add(ACHIEVEMENT_ACH_03);
    arrAchievementID.Add(ACHIEVEMENT_ACH_04);
    arrAchievementID.Add(ACHIEVEMENT_ACH_05);
    arrAchievementID.Add(ACHIEVEMENT_ACH_06);
    arrAchievementID.Add(ACHIEVEMENT_ACH_07);
    arrAchievementID.Add(ACHIEVEMENT_ACH_08);
    arrAchievementID.Add(ACHIEVEMENT_ACH_09);
    arrAchievementID.Add(ACHIEVEMENT_ACH_10);
    arrAchievementID.Add(ACHIEVEMENT_ACH_11);
    arrAchievementID.Add(ACHIEVEMENT_ACH_12);
    arrAchievementID.Add(ACHIEVEMENT_ACH_13);
    arrAchievementID.Add(ACHIEVEMENT_ACH_14);
    arrAchievementID.Add(ACHIEVEMENT_ACH_15);
    arrAchievementID.Add(ACHIEVEMENT_ACH_16);
    arrAchievementID.Add(ACHIEVEMENT_ACH_17);
    arrAchievementID.Add(ACHIEVEMENT_ACH_18);
    arrAchievementID.Add(ACHIEVEMENT_ACH_19);
    arrAchievementID.Add(ACHIEVEMENT_ACH_20);
    arrAchievementID.Add(ACHIEVEMENT_ACH_21);
    arrAchievementID.Add(ACHIEVEMENT_ACH_22);
    arrAchievementID.Add(ACHIEVEMENT_ACH_23);
    arrAchievementID.Add(ACHIEVEMENT_ACH_24);
    arrAchievementID.Add(ACHIEVEMENT_ACH_25);
    arrAchievementID.Add(ACHIEVEMENT_ACH_26);
    arrAchievementID.Add(ACHIEVEMENT_ACH_27);
    arrAchievementID.Add(ACHIEVEMENT_ACH_28);
    arrAchievementID.Add(ACHIEVEMENT_ACH_29);
    arrAchievementID.Add(ACHIEVEMENT_ACH_30);
    arrAchievementID.Add(ACHIEVEMENT_ACH_31);
    arrAchievementID.Add(ACHIEVEMENT_ACH_32);
    arrAchievementID.Add(ACHIEVEMENT_ACH_33);
    arrAchievementID.Add(ACHIEVEMENT_ACH_34);
    arrAchievementID.Add(ACHIEVEMENT_ACH_35);
    arrAchievementID.Add(ACHIEVEMENT_ACH_36);
    arrAchievementID.Add(ACHIEVEMENT_ACH_37);
    arrAchievementID.Add(ACHIEVEMENT_ACH_38);
    arrAchievementID.Add(ACHIEVEMENT_ACH_39);
    arrAchievementID.Add(ACHIEVEMENT_ACH_40);
    arrAchievementID.Add(ACHIEVEMENT_ACH_41);
    ASSERT(arrAchievementID.GetSize() == eAchievementsCnt);
}//--------------------------------------------------------------------------------------|

function void InitGameState()
{
    nIsTrading = false;
}//--------------------------------------------------------------------------------------|

function int IsAchievementSet(int nIndex)
{
    return GetPlayerInterface(GetLocalPlayerNum()).XBOXGetAchievement( arrAchievementID[nIndex] );
}//--------------------------------------------------------------------------------------|

function void SetAchievement(int nIndex)
{
    GetPlayerInterface(GetLocalPlayerNum()).XBOXSetAchievement( arrAchievementID[nIndex] );
}//--------------------------------------------------------------------------------------|

function void SetGameState(int nIndex)
{
    GetPlayerInterface(GetLocalPlayerNum()).XBOXSetRichPresence( nIndex );
}//--------------------------------------------------------------------------------------|

function int ProcessAchievement(int nIndex)
{
    if (nGameMode != eGameSingleplayer) // achievementy tylko w singlu, bo czesc z nich juz jest spelniona
    {                                   // przez np bohaterow PvP
        return 0;
    }
    if( IsAchievementSet(nIndex) )
    {
        return 0;
    }
    SetAchievement(nIndex);
    return 1;
}//--------------------------------------------------------------------------------------|

function void CheckGameState()
{
    mission pMission;
    int nGameState;
    
    pMission = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetMission();

    if( nGameMode == eGameSingleplayer )
    {
        if( pMission.IsUndergroundLevel() )      nGameState = CONTEXT_GAMESTATE_EXPLORING_DUNGEON; 
        else if( pMission == MIS(F7)  )          nGameState = CONTEXT_GAMESTATE_EXPLORING_CATHALON;
        else if( pMission == MIS(E3)  )          nGameState = CONTEXT_GAMESTATE_EXPLORING_THARBAKIN;
        else if( pMission == MIS(B10) )          nGameState = CONTEXT_GAMESTATE_EXPLORING_ASHOS;
        else if( pMission == MIS(D8)  )          nGameState = CONTEXT_GAMESTATE_EXPLORING_QUDINAAR;
        else if( pMission == MIS(F12) )          nGameState = CONTEXT_GAMESTATE_EXPLORING_GORGAMMAR;
        else if( pMission == MIS(H7)  )          nGameState = CONTEXT_GAMESTATE_EXPLORING_OSWAROTH;
        else                                     nGameState = CONTEXT_GAMESTATE_EXPLORING_WORLD;
    }
    else if( nGameMode == eGameMultiplayerRPG )
    {
        if( nIsTrading )  nGameState = CONTEXT_GAMESTATE_TRADING_IN_THE_SHOP;//trading with player
        else              nGameState = CONTEXT_GAMESTATE_PLAYING_RPG;
    }
    else if( nGameMode == eGameMultiplayerPvP )
    {
        if( nIsTrading )  nGameState = CONTEXT_GAMESTATE_TRADING_IN_THE_SHOP;//trading with player
        else              nGameState = CONTEXT_GAMESTATE_PLAYING_PVP;
    }
    else
    {
        __ASSERT_FALSE();
        nGameState = CONTEXT_GAMESTATE_IDLE_GAME;
    }

    SetGameState(nGameState);
}//--------------------------------------------------------------------------------------|

event OnStartedTrading(unit uHero)
{
    if ( uHero == GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()) )
    {
        nIsTrading = true;
    }
    return true;    
}//--------------------------------------------------------------------------------------|

event OnEndedTrading(unit uHero)
{
    if ( uHero == GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()) )
    {
        nIsTrading = false;
    }
    return true;    
}//--------------------------------------------------------------------------------------|

event RemovedUnit(unit uKilled, unit uAttacker, int a)
{
    unit uHero;
    int nEnemyClass;
    
    if ( uAttacker == GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()) )
    {
        if( !uKilled.GetAttribute("EnemyClass", nEnemyClass) )
        {
            return false;
        }
        if( (nEnemyClass == eDragon)      ||
            (nEnemyClass == eWhiteDragon) ||
            (nEnemyClass == eStoneDragon) ||
            (nEnemyClass == eLavaDragon) )
            ProcessAchievement(eAchievementKillADragon);
        if( nEnemyClass == eGolemStone )
            ProcessAchievement(eAchievementKillAStoneGolem);
    }
    return false;
}//--------------------------------------------------------------------------------------|

state Initialize
{
    InitGameState();
    InitArrays();
    nGameMode = eGameSingleplayer;
    return Nothing, 1;
}//--------------------------------------------------------------------------------------|

state Nothing
{
    CheckGameState();
    return Nothing, 1 * 30;
}//--------------------------------------------------------------------------------------|

command Message(int nMsgType, int nParam)
{
    if( nMsgType == eMsgAchievement )
    {
        ProcessAchievement(nParam);
        return true;
    }
    else if( nMsgType == eMsgGameMode )
    {
        nGameMode = nParam;
        return true;
    }
    return 0;
}//--------------------------------------------------------------------------------------|

command Message(int nMsgType, int nParam, unit pUnit)
{
    if( nMsgType == eMsgAchievement )
    {
        if( pUnit == GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()) )
        {
            ProcessAchievement(nParam);
            return true;
        }
    }
    return 0;
}//--------------------------------------------------------------------------------------|

command CommandDebug(string strLine)
{
    string strCommand;
    unit uUnit;
    mission pMission;
    int nSkillStart, nSkillEnd;
    int nIndex;
    int nLevel;
    
    strCommand = strLine;
    if (!strCommand.CompareNoCase("achieveTraceOn"))
    {
        ENABLE_TRACE(true);
    }
    else if (!strCommand.CompareNoCase("achieveTraceOff"))
    {
        ENABLE_TRACE(false);
    }
    else if (!strnicmp(strCommand, "jump", strlen("jump")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("jump") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).SetImmediatePosition(pMission, pMission.GetWorldWidth()/2, pMission.GetWorldHeight()/2, 0, 0, true);
        }
    }    
    else if (!strnicmp(strCommand, "konik", strlen("konik")))
    {
        GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetMission().CreateObject("MO_HORSE_04", GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetLocationX(), GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetLocationY() + (2<<8), 0, 0);
    }    
    else if (!strnicmp(strCommand, "allskills", strlen("allskills")))
    {
        for(nIndex = eFirstNormalSkill; nIndex < eSkillsCnt; nIndex++)
        {
            GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().SetSkill(nIndex, 1);
        }
    }    
    else if (!strnicmp(strCommand, "skills", strlen("skills")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("skills") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d %d", nSkillStart, nSkillEnd);
        for(nIndex = nSkillStart; nIndex <= nSkillEnd; nIndex++)
        {
            GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().SetSkill(nIndex, 1);
        }
    }    
    else if (!strnicmp(strCommand, "skill10", strlen("skill10")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("skill10") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d", nSkillStart);
        GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().SetSkill(nSkillStart, 10);
    }    
    else if (!strnicmp(strCommand, "skill", strlen("skill")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("skill") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d", nSkillStart);
        GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().SetSkill(nSkillStart, 1);
    }    
    else if (!strnicmp(strCommand, "levelup", strlen("levelup")))
    {
        nLevel = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().GetLevel();
        GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().SetLevel(nLevel + 1);
    }    
    else if (!strnicmp(strCommand, "level", strlen("level")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("level") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d", nLevel);
        GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetUnitValues().SetLevel(nLevel);
    }    
    else if( !strCommand.CompareNoCase("tele") )
    {
       uUnit = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum());
       uUnit.AddInventory("TELEPORT_ACTIVATOR", true);
    }
    else if( !strCommand.CompareNoCase("ptele") )
    {
       uUnit = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum());
       uUnit.AddInventory("PERSONAL_TELEPORT", true);
    }
    else
    {
        return false;    
    }
    return true;    
}//--------------------------------------------------------------------------------------|

}
