campaign "JSTestCampaign"
{
#include "..\\Common\\Generic.ech"
#include "..\\Common\\Enums.ech"
#include "..\\Common\\Messages.ech"
#include "..\\Common\\Lock.ech"
#include "..\\Common\\Party.ech"
#include "..\\Common\\Quest.ech"
#include "Levels.ech"

#define USE_SOUNDS

state Initialize;
state Nothing;

string m_strInitializeString;

function void InitializeLevels()
{
    int nLayer;
    string strName, strLevel, strScript, strNum;
    int nIndex, nLevelNum, nMissionNum;
    
    //m_strInitializeString - nazwa levelu bez katalogu i rozszerzenia
    //w miescie mozliwy tylko 1 level
    nMissionNum = 0;
    strLevel = "Levels\\";
    strLevel.Append(m_strInitializeString);
    strLevel.Append(".lnd");
    strScript = "Scripts\\Campaigns\\Missions\\EmptyMission.eco";
    CreateMission(strLevel, strScript, nMissionNum);
    GetMission(nMissionNum).SetPositionOnCampaignTexture(0, 0);
    GetMission(nMissionNum).SetHorizonOffset(0, 0);
        
    for (nMissionNum = 0; nMissionNum < GetMissionsCnt(); nMissionNum++)
    {
        GetMission(nMissionNum).LoadLevel();
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Initialize
{
    unit uHero;
    mission pStartMission;
    global pHeroControl;
    global pScriptMusic;
    int arrMarkers[];
    int nX, nY;        
    UnitValues unVal;
    int i;
    
    LoadRPGComputeScript("Scripts\\RPGCompute\\RPGCompute.eco");
        
    AddGlobalScript("Scripts\\Campaigns\\Missions\\PNames.eco", true);    
    #ifdef USE_SOUNDS
    pScriptMusic = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsMusic.eco", true);
    pScriptMusic.CommandMessage(eMsgSetLevelType, eMultiplayerMapTown);
    if( m_strInitializeString.EqualNoCase("Net_T_01") )
        pScriptMusic.CommandMessage(eMsgSetTownType, eTownTypeTharbakin);
    else if( m_strInitializeString.EqualNoCase("Net_T_02") )
        pScriptMusic.CommandMessage(eMsgSetTownType, eTownTypeCathalon);
    else if( m_strInitializeString.EqualNoCase("Net_T_03") )
        pScriptMusic.CommandMessage(eMsgSetTownType, eTownTypeQudinaar);
    else if( m_strInitializeString.EqualNoCase("Net_T_04") )
        pScriptMusic.CommandMessage(eMsgSetTownType, eTownTypeAshos);
    else
    {
        __ASSERT_FALSE();    
    }
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsSounds.eco", true);
    #endif
    
    SetDayLength(30, 20, 237);

    //town without SetLimitedWorldStepRange
    
    InitializeLevels();
    InitalizePartyForTwoWorldsCampaign();
            
    pStartMission = GetMission(0);
    pStartMission.FillMarkersNums("MARKER", arrMarkers);
    if (arrMarkers.GetSize() > 0)
    {
        pStartMission.GetMarker("MARKER", arrMarkers[Rand(arrMarkers.GetSize())], nX, nY);
    }
    else
    {
        nX = pStartMission.GetWorldWidth()/2;
        nY = pStartMission.GetWorldHeight()/2;
    }
    //losowe przesuniecie zeby wszyscy nie tworzyli sie w tym samym miejscu
    //dookola markera musi byc przynajmiej 4m wolnego miejsca
    nX += -e1m + Rand(e2m);
    nY += -e1m + Rand(e2m);
    uHero = pStartMission.CreateHero(0, nX, nY, 0, 0);
    uHero.SetBlockHeroAttackCommands(true);
    pHeroControl = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsHeroControl.eco", true);
    pHeroControl.CommandMessage(eMsgInitHeroControl, 0);
       
       
    unVal = uHero.GetUnitValues();
    for(i=eFirstNormalSkill;i<eSkillsCnt;i++)if(unVal.GetBasicSkill(i)==0)LockSkill(uHero,i);
    
    AddGlobalScript("Scripts\\Campaigns\\Missions\\PDialogUnits.eco", true);    
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsWeather.eco", true);
    //AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsContainers.eco", true);
                    
    SetDayTime(100);

    GetPlayerInterface(GetLocalPlayerNum()).ResetGraphicFogOfWar(GetMission(0), pStartMission.GetWorldWidth()/2, pStartMission.GetWorldHeight()/2, MAX(pStartMission.GetWorldWidth(), pStartMission.GetWorldHeight())*2);
        
	return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitializeCampaign(int nLevel, string strInitParam)
{
    m_strInitializeString = strInitParam;
	return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event GetDifficultyLevel()
{
    return 1;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command FillNetworkMissionsList(string arrScripts[], string arrScriptParams[], string arrNames[], int arrPointsGame[], int arrGuildsGame[], int arrAllowDynConn[], int arrMinPlayersCnt[], int arrAvailable[])
{
    FillNetworkMissionsList(m_strInitializeString, arrScripts, arrScriptParams, arrNames, arrPointsGame, arrGuildsGame, arrAllowDynConn, arrMinPlayersCnt, arrAvailable);
    
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command FillNetworkMissionModes(string strScriptParam, string arrModeParams[], string arrModeNames[])
{
    int arrModeXDefineNum[];
    FillNetworkMissionModes(strScriptParam, arrModeParams, arrModeNames, arrModeXDefineNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Message(int nMsg, int nParam1)
{
    if (nMsg == eMsgCampaignLevelNum2MissionNum)
    {
        return nParam1;
    }
    else if (nMsg == eMsgCampaignMissionNum2LevelNum)
    {
        return nParam1;
    }
    return 0;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Message(int nMsg, unit uUnit)
{
    int i;
    if (nMsg == eMsgRegisterSingleDoor)
    {
        for (i = 0; i < GetGlobalScriptsCnt(); i++) GetGlobalScript(i).CommandMessage(eMsgRegisterSingleDoor,uUnit);
        return true;
    }
    return 0;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event UsedDynamicTeleport(unit pTeleport)
{
    string strName;
    
    strName = "translate";
    strName.Append(pTeleport.GetObjectIDName());
    pTeleport.ActivateTeleport(true, true, 0, 1, strName);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event RemovedDynamicTeleport(unit pTeleport)
{
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CommandDebug(string strLine)
{
    string strCommand;
    int nValue;
    unit pLocalHero;
    int nX, nY;
    
    strCommand = strLine;
    if (!strnicmp(strCommand, "addcommonattrib", strlen("addcommonattrib")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("addcommonattrib") + 1);
        strCommand.TrimLeft();
        GetPlayerHeroUnit(0).SetPlayersCommonAttribute(strCommand, true);        
    }
    else if (!strnicmp(strCommand, "ResetGraphicFogOfWar", strlen("ResetGraphicFogOfWar")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("ResetGraphicFogOfWar") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d", nValue);

        pLocalHero = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum());
        pLocalHero.GetLocation(nX, nY);
        GetPlayerInterface( GetLocalPlayerNum() ).ResetGraphicFogOfWar( GetMission(0), nX, nY, nValue);
    }
    else if (strCommand.EqualNoCase("unlockallmissions"))
    {
        #define UNLOCK(ID) GetPlayerHeroUnit(0).SetPlayersCommonAttribute(ID, true)
        
        UNLOCK("Net_T_01");
        UNLOCK("Net_M_01");
        UNLOCK("Net_M_02");
        UNLOCK("Net_M_03");
        UNLOCK("Net_M_04");
        UNLOCK("Net_M_05");
        UNLOCK("Net_M_06");
        UNLOCK("Net_A_01");
    
        UNLOCK("Net_T_02");
        UNLOCK("Net_M_07");
        UNLOCK("Net_M_08");
        UNLOCK("Net_M_09");
        UNLOCK("Net_M_10");
        UNLOCK("Net_A_02");
        UNLOCK("Net_A_03");
        UNLOCK("Net_A_04");
    
        UNLOCK("Net_T_03");
        UNLOCK("Net_M_11");
        UNLOCK("Net_M_12");
        UNLOCK("Net_M_13");
        UNLOCK("Net_M_14");
        UNLOCK("Net_M_15");
        UNLOCK("Net_A_05");
        UNLOCK("Net_A_06");

        UNLOCK("Net_T_04");
        UNLOCK("Net_P_01");
        UNLOCK("Net_P_02");
        UNLOCK("Net_P_03");
        UNLOCK("Net_P_04");
        UNLOCK("Net_P_05");
        UNLOCK("Net_P_06");
        
        #undef UNLOCK
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

}
