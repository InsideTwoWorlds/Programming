campaign "JSTestCampaign"
{
#include "..\\Common\\Generic.ech"
#include "..\\Common\\Enums.ech"
#include "..\\Common\\Levels.ech"
#include "..\\Common\\Messages.ech"
#include "..\\Common\\Lock.ech"

state Initialize;
state Nothing;

consts
{
eColWidth = 80;
eColStart = 80;
eRowWidth = 80;
eRowStart = 80;
}

enum mapSet
{
    "Map_E03 (no objects)",
    "Map_E03",
multi:
	""
}

int m_arrLevelNum2MissionNum[];
int m_arrMissionNum2LevelNum[];

function void InitializeLevels()
{
    int nRow, nCol, nLayer;
    string strName, strLevel, strScript;
    int nIndex, nLevelNum, nMissionNum, nMissionsCnt;
    mission pMission;
    
    SetLevelsHorizon("Levels\\horizont.hor");
    SetEndOfTheWorldSouthMargin(200*e1m, 205*e1m);
    SetEndOfTheWorldNorthMargin(64*e1m, 69*e1m);
    if (mapSet == 0)
    {
        __DevExecuteConsole("game.CreateEditorObjects 0");
    }

    m_arrLevelNum2MissionNum.SetSize(eLevelColsCnt*eLevelRowsCnt*eLevelLayersCnt);
    for (nIndex = 0; nIndex < m_arrLevelNum2MissionNum.GetSize(); nIndex++)
    {
        m_arrLevelNum2MissionNum[nIndex] = -1;
    }
    m_arrMissionNum2LevelNum.RemoveAll();
    nMissionNum = 0;
    LoadLevelsHeadersCache("Levels\\Map_LevelHeaders.lhc");
    for (nCol = 1; nCol <= eLevelColsCnt; nCol++)
    {
        for (nRow = 1; nRow <= eLevelRowsCnt; nRow++)
        {
            for (nLayer = 0; nLayer < eLevelLayersCnt; nLayer++)
            {
                if (nLayer == 0)
                {
                    strName.Format("%c%02d", 'A' + (nCol - 1), nRow);
                }
                else
                {
                    strName.Format("%c%02d_%d", 'A' + (nCol - 1), nRow, nLayer);
                }
                strLevel = "Levels\\Map_";
                strLevel.Append(strName);
                strLevel.Append(".lnd");
                if (!CheckFileExist(strLevel))
                {
                    continue;
                }
                strScript = "Scripts\\Campaigns\\Missions\\EmptyMission.eco";
                CreateMission(strLevel, strScript, nMissionNum);
                nLevelNum = Level2LevelNum(nCol, nRow, nLayer);
                m_arrLevelNum2MissionNum[nLevelNum] = nMissionNum;
                m_arrMissionNum2LevelNum.Add(nLevelNum);
                
                GetMission(nMissionNum).SetPositionOnCampaignTexture(nCol - 1, nRow - 1);
                GetMission(nMissionNum).SetHorizonOffset(-(nCol - 1)*A2G(GetMission(nMissionNum).GetWorldWidth()), (nRow - 1)*A2G(GetMission(nMissionNum).GetWorldHeight()));
                
                nMissionNum++;
            }
        }
    }
    CleanupLevelsHeadersCache();
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Initialize
{
    unit uHero;
    mission pStartMission;
    int x;
    
    LoadRPGComputeScript("Scripts\\RPGCompute\\RPGCompute.eco");
    
    SetDayLength(30, 20, 237);

    SetLimitedWorldStepRange(e80m);
    
    InitializeLevels();
    
    GetSinglePartyArray(0).GetSize();
    
    pStartMission = MIS(E3);
    pStartMission.LoadLevel();
    uHero = pStartMission.CreateHero(0, pStartMission.GetWorldWidth()/2, pStartMission.GetWorldHeight()/2, 0, 0);
    
    SetDayTime(100);
    
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsHeroControl.eco", true);
	return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Message(int nMsg, int nParam1)
{
    if (nMsg == eMsgCampaignLevelNum2MissionNum)
    {
        if ((nParam1 >= 0) && (nParam1 < m_arrLevelNum2MissionNum.GetSize()))
        {
            return m_arrLevelNum2MissionNum[nParam1];
        }
        else
        {
            return -1;
        }
    }
    else if (nMsg == eMsgCampaignMissionNum2LevelNum)
    {
        if ((nParam1 >= 0) && (nParam1 < m_arrMissionNum2LevelNum.GetSize()))
        {
            return m_arrMissionNum2LevelNum[nParam1];
        }
        else
        {
            return -1;
        }
    }
    return 0;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitializeCampaign(int nLevel, string strInitParam) button mapSet
{
    sscanf(strInitParam, "%d", nLevel);
    mapSet = nLevel;
	return true;
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

event RemovedUnit(unit uUnit, unit pKilledByObject, int nNotifyType)
{
    uUnit.AddObjectsFromParamsToDeadBody(-1);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event EndMessageBox(int nMessageUID, int nResult)
{
    string strMsg;
    if (nMessageUID == 13)
    {
        strMsg = "message box result: ";
        if (nResult == IDYES)
        {
            strMsg.Append("Yes");
        }
        else if (nResult == IDNO)
        {
            strMsg.Append("No");
        }
        else if (nResult == IDCANCEL)
        {
            strMsg.Append("Cancel");
        }
        else if (nResult == -1)
        {
            strMsg.Append("closed somehow else (other dialog popup)");
        }
        else
        {
            strMsg.Append("Unknown");
        }
        GetCampaign().GetPlayerInterface(0).SetLowConsoleText(strMsg);
        
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command BonusCode(string strBonusCode)
{
    GetCampaign().GetPlayerInterface(0).SetConsoleText(strBonusCode);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

unit m_uDlgUnit;
unit m_uChatUnit1, m_uChatUnit2, m_uChatUnit3, m_uChatUnit4;

command CommandDebug(string strLine)
{
    string strCommand, strCmd, strLoad, strUnload, strName, strData;
    mission pMission;
    int nX, nY, nZ, nAlpha;
    unit uObject;
    
    strCommand = strLine;
    if (!strnicmp(strCommand, "load", strlen("load")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("load") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if ((pMission != null) && !pMission.IsLevelLoaded())
        {
            pMission.LoadLevel();
        }
    }
    if (!strnicmp(strCommand, "unload", strlen("unload")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("unload") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if ((pMission != null) && pMission.IsLevelLoaded() && (pMission != GetCampaign().GetPlayerHeroUnit(0).GetMission()))
        {
            pMission.UnloadLevel();
        }
    }
    if (!strnicmp(strCommand, "jump", strlen("jump")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("jump") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, pMission.GetWorldWidth()/2, pMission.GetWorldHeight()/2, 0, 0, true);
        }
    }
    if (strCommand.EqualNoCase("dialog"))
    {
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        GetCampaign().GetPlayerInterface(0).PlayDialog(0, 0, "translateDQ_10", 4, uObject, 1, GetCampaign().GetPlayerHeroUnit(0));
    }
    if (strCommand.EqualNoCase("dialog1"))
    {
        m_uDlgUnit = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        m_uDlgUnit.SetIsDialogUnit(0, 1, 1);
    }
    if (strCommand.EqualNoCase("dialog2"))
    {
        m_uDlgUnit = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        m_uDlgUnit.SetIsDialogUnit(1, 1, 1);
        //GetCampaign().GetPlayerInterface(0).PlayDialog(0, 0, "translateDQ_7", 0xC, m_uDlgUnit, 1, GetCampaign().GetPlayerHeroUnit(0));
    }
    if (strCommand.EqualNoCase("shop"))
    {
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("SHOPUNIT_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        uObject.EnableShop(true);
    }
    if (strCommand.EqualNoCase("ST1"))
    {
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("TELEPORT_01", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        strName.Format("%s at %d,%d", uObject.GetObjectIDName(), A2G(uObject.GetLocationX()), A2G(uObject.GetLocationY()));
        uObject.ActivateTeleport(true, true, 2, 3, strName, -1, -1);
    }
    if (strCommand.EqualNoCase("ST2"))
    {
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("TELEPORT_02", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        strName.Format("%s at %d,%d", uObject.GetObjectIDName(), A2G(uObject.GetLocationX()), A2G(uObject.GetLocationY()));
        uObject.ActivateTeleport(true, false, 2, 3, strName, -1, -1);
    }
    if (strCommand.EqualNoCase("ST3"))
    {
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("TELEPORT_03", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        strName.Format("%s at %d,%d", uObject.GetObjectIDName(), A2G(uObject.GetLocationX()), A2G(uObject.GetLocationY()));
        uObject.ActivateTeleport(false, true, 2, 3, strName, -1, -1);
    }
    if (strCommand.EqualNoCase("createR"))
    {
        m_uDlgUnit = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
    }
    if (strCommand.EqualNoCase("removeR"))
    {
        m_uDlgUnit.RemoveObject();
        m_uDlgUnit = null;
    }
    if (strCommand.EqualNoCase("SearchObjectsInArea"))
    {
        pMission = GetCampaign().GetPlayerHeroUnit(0).GetMission();
        pMission.SearchObjectsInArea(pMission.GetWorldWidth()/2, pMission.GetWorldHeight()/2, pMission.GetWorldWidth(), "PERSONAL_TELEPORT");
        strName.Format("Count == %d", pMission.GetSearchUnitsInAreaCount());
        pMission.ClearSearchUnitsInAreaArray();
        GetCampaign().GetPlayerInterface(0).SetConsoleText(strName);
    }
    if (!strnicmp(strCommand, "music", strlen("music")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("music") + 1);
        strCommand.TrimLeft();
        GetCampaign().GetPlayerInterface(0).PlayGameMusic(strCommand);
    }
    if (strCommand.EqualNoCase("StopMusic"))
    {
        GetCampaign().GetPlayerInterface(0).StopGameMusic();
    }
    if (strCommand.EqualNoCase("PrepareChat"))
    {
        m_uChatUnit1 = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("CITIZEN_01_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        m_uChatUnit2 = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("CITIZEN_01_05", GetCampaign().GetPlayerHeroUnit(0).GetLocationX() + 128, GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + G2A(1), 0, 0);
        m_uChatUnit3 = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("CITIZEN_F_05", GetCampaign().GetPlayerHeroUnit(0).GetLocationX() + G2A(1), GetCampaign().GetPlayerHeroUnit(0).GetLocationY(), 0, 0);
        m_uChatUnit4 = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("CITIZEN_02_04#WP_AXE_3", GetCampaign().GetPlayerHeroUnit(0).GetLocationX() + G2A(1), GetCampaign().GetPlayerHeroUnit(0).GetLocationY() + 128, 0, 0);
    }
    if (strCommand.EqualNoCase("Chat1"))
    {
        m_uChatUnit1.GetMission().PlayChatDialog(0, 0, "translateTALK_1_21_1", 100, m_uChatUnit1, 102, m_uChatUnit2);
    }
    if (strCommand.EqualNoCase("Chat2"))
    {
        m_uChatUnit3.GetMission().PlayChatDialog(0, 0, "translateTALK_1_21_3", 100, m_uChatUnit3, 102, m_uChatUnit4);
    }
    if (strCommand.EqualNoCase("hide1"))
    {
        GetCampaign().GetPlayerHeroUnit(0).SetNotRenderObjectNow(1);
    }
    if (strCommand.EqualNoCase("hide0"))
    {
        GetCampaign().GetPlayerHeroUnit(0).SetNotRenderObjectNow(0);
    }
    if (strCommand.EqualNoCase("testMT"))
    {
        GetCampaign().GetPlayerHeroUnit(0).GetMission().HaveMarker("MARKER_TAVERN", 1);
        GetCampaign().GetPlayerHeroUnit(0).GetMission().GetObjectMarker("MARKER_TAVERN", 1);
    }
    if (strCommand.EqualNoCase("AddCTa"))
    {
        GetCampaign().GetPlayerInterface(0).SetConsoleText("asdlfj asdfl",120,true,true);
    }
    if (strCommand.EqualNoCase("AddCTb"))
    {
        GetCampaign().GetPlayerInterface(0).SetConsoleText("asdlf ;erfjasdfl;kj j asdfl",120,true);
    }
    if (strCommand.EqualNoCase("IsFreePlace"))
    {
        if (GetCampaign().GetPlayerHeroUnit(0).IsFreePlaceForObjectInInventory("WP_SWORD_1"))
        {
            GetCampaign().GetPlayerInterface(0).SetConsoleText("IsFreePlace",120,true,true);
        }
    }
    if (strCommand.EqualNoCase("Pentagram"))
    {
        GetCampaign().SetPentagram("30 4   18240 -17600 9000 250 34160 -29520 9000 250 28360 -48000 9000 250 8800 -48000 9000 250 2720 -29520 9000 250");
    }
    if (strCommand.EqualNoCase("dream1"))
    {
        GetCampaign().GetPlayerInterface(0).SetDreamlandEntranceState(100);
    }
    if (strCommand.EqualNoCase("dream0"))
    {
        GetCampaign().GetPlayerInterface(0).SetDreamlandEntranceState(0);
    }
    if (strCommand.EqualNoCase("DrawPentagram1"))
    {
        GetCampaign().SetDrawPentagramStrength(100);
    }
    if (strCommand.EqualNoCase("DrawPentagram0"))
    {
        GetCampaign().SetDrawPentagramStrength(0);
    }
    if (!strnicmp(strCommand, "PlayVideo", strlen("PlayVideo")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("PlayVideo") + 1);
        strCommand.TrimLeft();
        GetCampaign().GetPlayerInterface(0).PlayVideoCutscene(strCommand, true,false);
    }
    if (strCommand.EqualNoCase("PE"))
    {
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY(), 0, 0);
        uObject.SetPartyNum(1);
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY(), 0, 0);
        uObject.SetPartyNum(1);
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY(), 0, 0);
        uObject.SetPartyNum(1);
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY(), 0, 0);
        uObject.SetPartyNum(1);
        uObject = GetCampaign().GetPlayerHeroUnit(0).GetMission().CreateObject("GOBLIN_01#WP_SWORD_1", GetCampaign().GetPlayerHeroUnit(0).GetLocationX(), GetCampaign().GetPlayerHeroUnit(0).GetLocationY(), 0, 0);
        uObject.SetPartyNum(1);
    }
    if (strCommand.EqualNoCase("mb1"))
    {
        GetCampaign().GetPlayerInterface(0).MessageBox("test message box", MB_OK, true, 0, 0);
    }
    if (strCommand.EqualNoCase("mb2"))
    {
        GetCampaign().GetPlayerInterface(0).MessageBox("test message box question", MB_YESNOCANCEL, true, GetScriptUID(), 13);
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

}
