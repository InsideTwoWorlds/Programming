campaign "JSTestCampaign"
{
#include "..\\Common\\Generic.ech"
#include "..\\Common\\Enums.ech"
#include "..\\Common\\Messages.ech"
#include "..\\Common\\Lock.ech"
#include "..\\Common\\Party.ech"
#include "..\\Common\\Stealing.ech"
#include "..\\Common\\Levels.ech"
#include "..\\Common\\Quest.ech"
#include "Levels.ech"

#define USE_SOUNDS

state Initialize;
state Nothing;

string m_strInitializeLevel;
string m_strInitializeMode;
int m_bInitializeGuildsGame;
int m_bInitializeRankedGame;
int m_nMusicScriptUID;
int m_nAchievementsScriptUID;
int m_nGameType;   // eGameRPG eGameRPGArena eGamePvP
int m_bUseRPG16;

int m_arrLevelNum2MissionNum[];
int m_arrMissionNum2LevelNum[];

string m_arrLevelInfoAttribs[];
string m_arrLevelInfoValues[];

consts
{
    ePvPStartMarkersCount = 8,
}

function void InitializeTownScript(mission pMission,int nTownType,int nTownParty,int nX1,int nY1,int nX2,int nY2, int nSendToMusicScript)
{
    mission pTown;
    global pMusicScript;
    
    pTown = pMission.AddMissionScript("Scripts\\Campaigns\\Missions\\PTown.eco");  
    pTown.CommandMessage(eMsgSetTownType,nTownType);
    pTown.CommandMessage(eMsgSetTownX1,nX1);
    pTown.CommandMessage(eMsgSetTownX2,nX2);
    pTown.CommandMessage(eMsgSetTownY1,nY1);
    pTown.CommandMessage(eMsgSetTownY2,nY2);
    pTown.CommandMessage(eMsgSetTownParty,nTownParty);

    if( nSendToMusicScript )
    {
        pMusicScript = FindGlobalScript(m_nMusicScriptUID);
        if (!pMusicScript) return;
        pMusicScript.CommandMessage(eMsgSetMissionNum, pMission.GetMissionNum() );
        pMusicScript.CommandMessage(eMsgSetTownType,   nTownType );
        pMusicScript.CommandMessage(eMsgSetTownX1,     nX1 );
        pMusicScript.CommandMessage(eMsgSetTownX2,     nX2 );
        pMusicScript.CommandMessage(eMsgSetTownY1,     nY1 );
        pMusicScript.CommandMessage(eMsgSetTownY2,     nY2 );
        pMusicScript.CommandMessage(eMsgSetPlayInsideTown, true );
    }
    
}

function void InitializeCustomPlace(mission pMission,int nTownType, int nX1,int nY1,int nX2,int nY2)
{
    global pMusicScript;

    pMusicScript = FindGlobalScript(m_nMusicScriptUID);
    if (!pMusicScript) return;
    pMusicScript.CommandMessage(eMsgSetMissionNum, pMission.GetMissionNum() );
    pMusicScript.CommandMessage(eMsgSetTownType,   nTownType );
    pMusicScript.CommandMessage(eMsgSetTownX1,     nX1 );
    pMusicScript.CommandMessage(eMsgSetTownX2,     nX2 );
    pMusicScript.CommandMessage(eMsgSetTownY1,     nY1 );
    pMusicScript.CommandMessage(eMsgSetTownY2,     nY2 );
    pMusicScript.CommandMessage(eMsgSetPlayInsideTown, false );
    
}

function void InitializeTownsAndCustomPlaces() 
{
    string strTownDef, strVal;
    int nIndex;
    int arrParams[];
        
    nIndex = 0;
    for (nIndex = 0; nIndex < 10; nIndex++)
    {
        strTownDef.Format("TownScript%d", nIndex);
        strVal = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, strTownDef);
        if (!strVal.GetLength())
        {
            break;
        }
        ScanIntValues(strVal, arrParams);
        InitializeTownScript(GetMission(arrParams[0]),arrParams[1],arrParams[2],arrParams[3],arrParams[4],arrParams[5],arrParams[6],arrParams[7]);
    }  
}

function void InitQuestsMulti(global pScript)
{
    string strVal;
    string arrParams[];
    
    strVal = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, "QuestsInit");
    if (strVal.GetLength() == 0)
    {
        return;
    }
    ScanStringValues(strVal, arrParams);
    pScript.CommandMessage(eMsgInitQuestsMulti,ScanInt(arrParams[0]),ScanInt(arrParams[1]),ScanInt(arrParams[2]));
    if (arrParams.GetSize() > 3)
    {
        pScript.CommandMessage(eMsgInitQuestsMulti,arrParams[3]);
    }
    else
    {
        pScript.CommandMessage(eMsgInitQuestsMulti,"");
    }
}

function void LoadGlobalScripts() 
{

    global pMusicScript;
    global pAchievementsScript;
    global pScript;
    string strScript, strWorldConf;
    
    pMusicScript = FindGlobalScript(m_nMusicScriptUID);
    ASSERT(pMusicScript != null);
    
    if( (m_nGameType == eGamePvP) || (m_nGameType == eGameRPGArena) )
    {
        if (m_strInitializeMode.GetLength() > 0)
        {
            strScript = "Scripts\\Network\\Mission";
            strScript.Append(m_strInitializeMode);
            strScript.Append(".eco");
            AddGlobalScript(strScript, true);  
        }

        pScript = AddGlobalScript("Scripts\\Campaigns\\Missions\\PDialogUnits.eco", true);    
        pScript.CommandMessage(eMsgSetMultiplayer,true);
//        AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsTeleports.eco", true);
        AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsEnemies.eco", true);
        AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsContainers.eco", true);
        pAchievementsScript = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsAchievements.eco", true);
        pAchievementsScript.CommandMessage(eMsgGameMode, eGameMultiplayerPvP);
        m_nAchievementsScriptUID = pAchievementsScript.GetScriptUID();
        strWorldConf = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, "ReplaceWorldConf");
        if(strWorldConf.GetLength())
        {    
            GetCampaign().LoadLevelConfiguration(strWorldConf, true, true, 1);
        }
    }
    else // tutaj laduja skrypty dla trybu Adventure
    {
        pScript = AddGlobalScript("Scripts\\Campaigns\\Missions\\PDialogUnits.eco", true);    
        pScript.CommandMessage(eMsgSetMultiplayer,true);
//        AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsTeleports.eco", true);
        if (m_bUseRPG16)
        {
            AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsEnemies16.eco", true);
        }
        else
        {
            AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsWeather.eco", true);
            AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsEnemies.eco", true);
        }
        AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsContainers.eco", true);
        AddGlobalScript("Scripts\\Campaigns\\Missions\\PBandits.eco", true);
        if (m_bUseRPG16)
        {
            InitQuestsMulti(AddGlobalScript("Scripts\\Campaigns\\Missions\\PQuestsMulti16.eco",true));
        }
        else
        {
            InitQuestsMulti(AddGlobalScript("Scripts\\Campaigns\\Missions\\PQuestsMulti.eco",true));
        }
        pAchievementsScript = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsAchievements.eco", true);
        pAchievementsScript.CommandMessage(eMsgGameMode, eGameMultiplayerRPG);
        m_nAchievementsScriptUID = pAchievementsScript.GetScriptUID();
    }
    
}

function void AddLevelDistantLand(mission pMission, int nCol, int nRow, int nDx, int nDy)
{
    string strLevel;
    
    strLevel.Format("Levels\\Map_%c%02d.lnd", nCol, nRow);
    pMission.AddNeighbourDistantLandLevel(strLevel, nDx, nDy);
}

//dodanie distantLandow - zakladamy ze mapa pMission ma 256x256 a sasiednie (z kampanii) 128x128
function void SetupCampaignLevelDistantLands(mission pMission, int nCol, int nRow)
{
    if ((nCol > 'A') && (nRow > 1))//left-top
    {
        AddLevelDistantLand(pMission, nCol - 1, nRow - 1, -128, 256);
    }
    if (nCol > 'A')//left
    {
        AddLevelDistantLand(pMission, nCol - 1, nRow, -128, 128);
        AddLevelDistantLand(pMission, nCol - 1, nRow + 1, -128, 0);
    }
    if ((nCol > 'A') && (nRow < (eLevelRowsCnt - 1)))//left-bottom
    {
        AddLevelDistantLand(pMission, nCol - 1, nRow + 2, -128, -128);
    }
    if (nRow > 1)//top
    {
        AddLevelDistantLand(pMission, nCol, nRow - 1, 0, 256);
        AddLevelDistantLand(pMission, nCol + 1, nRow - 1, 128, 256);
    }
    if (((nCol - 'A') < (eLevelColsCnt - 2)) && (nRow > 1))//right-top
    {
        AddLevelDistantLand(pMission, nCol + 2, nRow - 1, 256, 256);
    }
    if ((nCol - 'A') < (eLevelColsCnt - 2))//right
    {
        AddLevelDistantLand(pMission, nCol + 2, nRow, 256, 128);
        AddLevelDistantLand(pMission, nCol + 2, nRow + 1, 256, 0);
    }
    if (((nCol - 'A') < (eLevelColsCnt - 2)) && (nRow < (eLevelRowsCnt - 1)))//right-bottom
    {
        AddLevelDistantLand(pMission, nCol + 2, nRow + 2, 256, -128);
    }
    if (nRow < (eLevelRowsCnt - 1))//bottom
    {
        AddLevelDistantLand(pMission, nCol, nRow + 2, 0, -128);
        AddLevelDistantLand(pMission, nCol + 1, nRow + 2, 128, -128);
    }
}

function void SetupCustomLevelDistantLands(mission pMission)
{
    int nIndex;
    string strAttrib, strVal;
    string arrParams[];
    
    for (nIndex = 0; nIndex < 100; nIndex++)
    {
        strAttrib.Format("DistantLand%d", nIndex);
        strVal = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, strAttrib);
        if (strVal.GetLength() == 0)
        {
            break;
        }
        ScanStringValues(strVal, arrParams);
        pMission.AddNeighbourDistantLandLevel(arrParams[0], ScanInt(arrParams[1]), ScanInt(arrParams[2]));
    }
}

function void InitializeLevels()
{
    int nLayer;
    string strName, strLevel, strScript, strNum, strHorizon;
    int nIndex, nLevelNum, nMissionNum;
    int nCol, nRow;
    int bCampaignMap;
     
    //m_strInitializeLevel - nazwa levelu bez katalogu i rozszerzenia
    strName = m_strInitializeLevel;

    strHorizon = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, "Horizon");    
    if (strHorizon.GetLength())
    {
        SetLevelsHorizon(strHorizon);
    }
    bCampaignMap = GetMultiSinglePlayerMission(nCol, nRow);
    nMissionNum = 0;
    for (nLayer = 0; nLayer < 2; nLayer++)
    {
        strLevel = "Levels\\";
        strLevel.Append(strName);
        if (nLayer > 0)
        {
            strNum.Format("_%d", nLayer);
            strLevel.Append(strNum);
        }
        strLevel.Append(".lnd");
        if (!CheckFileExist(strLevel))
        {
            continue;
        }
        strScript = "Scripts\\Campaigns\\Missions\\EmptyMission.eco";
        CreateMission(strLevel, strScript, nMissionNum);
        GetMission(nMissionNum).SetPositionOnCampaignTexture(0, 0);
        
        if (strHorizon.GetLength())
        {
            if (bCampaignMap) GetMission(nMissionNum).SetHorizonOffset(-(nCol - 'A')*A2G(GetMission(nMissionNum).GetWorldWidth() / 2), (nRow)*A2G(GetMission(nMissionNum).GetWorldHeight() / 2));
            else GetMission(nMissionNum).SetHorizonOffset(0,0);
        }
        
        if (nLayer == 0)
        {
            if (bCampaignMap)
            {
                SetupCampaignLevelDistantLands(GetMission(nMissionNum), nCol, nRow);
            }
            else
            {
                SetupCustomLevelDistantLands(GetMission(nMissionNum));
            }
        }
        
        nMissionNum++;
    }
    
    for (nMissionNum = 0; nMissionNum < GetMissionsCnt(); nMissionNum++)
    {
        GetMission(nMissionNum).LoadLevel();
    }
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

function void CreateHero(int nPlayerNum, int nMissionNum, int nX, int nY)
{
    unit uHero;
    mission pStartMission;
    global pHeroControl;
    UnitValues unVal;
    int i;
    string strVal;
    
    pStartMission = GetMission(nMissionNum);
    uHero = pStartMission.CreateHero(nPlayerNum, nX, nY, 0, 0);
    uHero.SetPartyNum(ePartyPlayer1 + nPlayerNum);
    strVal = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, "BlockHeroAttackCommands");
    if (strVal.EqualNoCase("true"))
    {
        uHero.SetBlockHeroAttackCommands(true);
    }
    
    unVal = uHero.GetUnitValues();
    for(i=eFirstNormalSkill;i<eSkillsCnt;i++)if(unVal.GetBasicSkill(i)==0)LockSkill(uHero,i);
    
    if( m_nGameType == eGameRPG )
    {
        uHero.SetIsInParty(ePartyPlayerCommon, true); // 07-09-13 [PM] w RPG wszyscy herosi w tym samym party
        if (m_bUseRPG16)
        {
            pHeroControl = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsHeroControl16.eco", true);
        }
        else 
        {
            pHeroControl = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsHeroControl.eco", true);
        }
        pHeroControl.CommandMessage(eMsgInitHeroControl, nPlayerNum);
        SetThiefUID(uHero);
    }
    else if( m_nGameType == eGamePvP ) // zmiana inventory tylko w trybie PVP, a nie w RPGArena
    {
        //add magic cards on slots
        if(unVal.GetBasicSkill(eSkillAirMagic)>0)
        {
            uHero.AddMagicCard("MAGIC_LIGHTING",0);
            uHero.AddMagicCard("MAGIC_HEAL",1);
            uHero.AddMagicCard("MAGIC_BOOST_MANA",0);
            uHero.AddMagicCard("MAGIC_BOOST_LEVEL",0);
            uHero.RemoveObjectFromInventory("MAGIC_LIGHTING",0);
            uHero.RemoveObjectFromInventory("MAGIC_HEAL",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_MANA",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_LEVEL",0);
        }
        if(unVal.GetBasicSkill(eSkillFireMagic)>0)
        {
            uHero.AddMagicCard("MAGIC_FIREBOLT",0);
            uHero.AddMagicCard("MAGIC_FIREWALL",1);
            uHero.AddMagicCard("MAGIC_BOOST_MANA",0);
            uHero.AddMagicCard("MAGIC_BOOST_LEVEL",0);
            uHero.RemoveObjectFromInventory("MAGIC_FIREBOLT",0);
            uHero.RemoveObjectFromInventory("MAGIC_FIREWALL",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_MANA",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_LEVEL",0);
        }
        if(unVal.GetBasicSkill(eSkillWaterMagic)>0)
        {
            uHero.AddMagicCard("MAGIC_ICEBOLT",0);
            uHero.AddMagicCard("MAGIC_SUMMON_REAPER",1);
            uHero.AddMagicCard("MAGIC_BOOST_MANA",0);
            uHero.AddMagicCard("MAGIC_BOOST_LEVEL",0);
            uHero.RemoveObjectFromInventory("MAGIC_ICEBOLT",0);
            uHero.RemoveObjectFromInventory("MAGIC_SUMMON_REAPER",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_MANA",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_LEVEL",0);
        }
        if(unVal.GetBasicSkill(eSkillEarthMagic)>0)
        {
            
            uHero.AddMagicCard("MAGIC_SPIKES",0);
            uHero.AddMagicCard("MAGIC_MAGICHAMMER",1);
            uHero.AddMagicCard("MAGIC_BOOST_MANA",0);
            uHero.AddMagicCard("MAGIC_BOOST_LEVEL",0);
            uHero.RemoveObjectFromInventory("MAGIC_SPIKES",0);
            uHero.RemoveObjectFromInventory("MAGIC_MAGICHAMMER",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_MANA",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_LEVEL",0);
        }
        if(unVal.GetBasicSkill(eSkillNecromancyMagic)>0)
        {
            
            uHero.AddMagicCard("MAGIC_BONEARMOUR",0);
            uHero.AddMagicCard("MAGIC_SUMMON_SKELETON",1);
            uHero.AddMagicCard("MAGIC_BOOST_MANA",0);
            uHero.AddMagicCard("MAGIC_BOOST_LEVEL",0);
            uHero.RemoveObjectFromInventory("MAGIC_BONEARMOUR",0);
            uHero.RemoveObjectFromInventory("MAGIC_SUMMON_SKELETON",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_MANA",0);
            uHero.RemoveObjectFromInventory("MAGIC_BOOST_LEVEL",0);
        }
    }
    
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

function void RemoveHero(int nPlayerNum)
{
    unit uHero;
    
    uHero = GetPlayerHeroUnit(nPlayerNum);
    if ((uHero != null) && uHero.IsStored())
    {
        uHero.GetMission().CreateObject("RESURRECT_EFFECT",uHero.GetLocationX(),uHero.GetLocationY(),0,0);
        uHero.RemoveObject();
    }
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

state Initialize
{
    int nPlayer, nPlayersCnt, nIndex;
    int nX, nY;
    int arrMarkers[];
    global pScriptMusic;
    string strVal;
    
    strVal = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, "Type");
    if (strVal.EqualNoCase("PVP"))
    {
        m_nGameType = eGamePvP;
    }
    else if (strVal.EqualNoCase("RPGArena"))
    {
        m_nGameType = eGameRPGArena;
        m_bInitializeRankedGame = 0;//na PC'cie jest ustawiane zawsze na TRUE
    }
    else
    {
        m_nGameType = eGameRPG;
        m_bInitializeRankedGame = 0;//na PC'cie jest ustawiane zawsze na TRUE
    }

    strVal = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, "UseRPG16");
    if (strVal.EqualNoCase("true"))
    {
        m_bUseRPG16 = true;
    }
    else
    {
        m_bUseRPG16 = false;
    }
        

    LoadRPGComputeScript("Scripts\\RPGCompute\\RPGCompute.eco");
    
    InitalizePartyForTwoWorldsCampaign();
    AddGlobalScript("Scripts\\Campaigns\\Missions\\PNames.eco", true);    
    #ifdef USE_SOUNDS
    pScriptMusic = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsMusic.eco", true);
    pScriptMusic.CommandMessage(eMsgSetLevelType, eMultiplayerMapMission);
    m_nMusicScriptUID = pScriptMusic.GetScriptUID();
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsSounds.eco", true);
    #endif
    
    SetDayLength(30, 20, 237);

    if (m_nGameType == eGameRPG)
    {
        SetLimitedWorldStepRange(e80m);
    }
    //else PVP without SetLimitedWorldStepRange in town
    
    InitializeLevels();
    InitializeTownsAndCustomPlaces();
    
    GetMission(0).FillMarkersNums("MARKER", arrMarkers);
    nPlayersCnt = GetCampaign().GetPlayersCnt();
    for (nPlayer = 0; nPlayer < nPlayersCnt; nPlayer++)
    {
        if (arrMarkers.GetSize() > 0)
        {
            if( m_nGameType == eGameRPG )
            {
                nIndex = Rand(arrMarkers.GetSize());
            }
            else //if( (m_nGameType == eGamePvP) || (m_nGameType == eGameRPGArena) )
            {
                nIndex = Rand(ePvPStartMarkersCount); // dla rozgrywki PvP i RPGArena tylko 8 defaultowych markerow 1-8
            }
            GetMission(0).GetMarker("MARKER", arrMarkers[nIndex], nX, nY);
            arrMarkers.RemoveAt(nIndex);
        }
        else
        {
            nX = GetMission(0).GetWorldWidth()/2;
            nY = GetMission(0).GetWorldHeight()/2;
        }
        CreateHero(nPlayer, 0, nX, nY);
    }
    
    LoadGlobalScripts();
    SetDayTime(100);
    
    
	return Nothing, 3*30;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

state Nothing
{
    int i, nMission, nMissionsCnt;
    int anParties[];
    mission pMission;
    
    for (i = ePartyAnimals; i <= ePartyEvilWarriors; i++) anParties.Add(i);
    
    nMissionsCnt = GetMissionsCnt();
    for (nMission = 0; nMission < nMissionsCnt; nMission++)
    {
        pMission = GetMission(nMission);
        if ((pMission != null) && pMission.IsLevelLoaded())
        {
            pMission.RemoveKilledUnitsOutsideStepRange(anParties, false, false);
        }
    }
    return Nothing, 3*30;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

command InitializeCampaign(int nLevel, string strInitParam)
{
    string strParam, strGuildsGame, strXBoxRanked;
    int nPos;
    
    //strInitParam format: levelID modeID|null 0|1[guilds game] 0|1[XBox ranked]
    m_strInitializeLevel = "";
    m_strInitializeMode = "";
    m_bInitializeGuildsGame = false;
    m_bInitializeRankedGame = false;
    
    strParam = strInitParam;
    strParam.TrimLeft();
    nPos = strParam.Find(' ');
    if (nPos < 0)
    {
        return true;
    }
    m_strInitializeLevel = strParam;
    m_strInitializeLevel.Left(nPos);
    
    strParam.Mid(nPos + 1);
    strParam.TrimLeft();
    nPos = strParam.Find(' ');
    if (nPos < 0)
    {
        return true;
    }
    m_strInitializeMode = strParam;
    m_strInitializeMode.Left(nPos);
    if (m_strInitializeMode.EqualNoCase("null"))
    {
        m_strInitializeMode = "";
    }
    
    strParam.Mid(nPos + 1);
    strParam.TrimLeft();
    nPos = strParam.Find(' ');
    if (nPos < 0)
    {
        return true;
    }
    strGuildsGame = strParam;
    strGuildsGame.Left(nPos);
    if (strGuildsGame.EqualNoCase("1"))
    {
        m_bInitializeGuildsGame = 1;
    }
    else
    {
        m_bInitializeGuildsGame = 0;
    }
    
    strParam.Mid(nPos + 1);
    strParam.TrimLeft();
    strXBoxRanked = strParam;
    strXBoxRanked.TrimRight();
    if (strXBoxRanked.EqualNoCase("1"))
    {
        m_bInitializeRankedGame = 1;
    }
    else
    {
        m_bInitializeRankedGame = 0;
    }

    strParam = "Levels\\";
    strParam.Append(m_strInitializeLevel);
    strParam.Append(".txt");
    LoadMissionInfo(strParam, m_arrLevelInfoAttribs, m_arrLevelInfoValues);

	return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

event GetDifficultyLevel()
{
    return 1;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

command Message(int nMsg, int nParam1)
{
    global pAchievementScript;
    int i, count;
    
    if (nMsg == eMsgCampaignLevelNum2MissionNum)
    {
        return nParam1;
    }
    else if (nMsg == eMsgCampaignMissionNum2LevelNum)
    {
        return nParam1;
    }
    else if (nMsg == eMsgAchievement)
    {
        pAchievementScript = FindGlobalScript(m_nAchievementsScriptUID);
        pAchievementScript.CommandMessage(eMsgAchievement, nParam1 );
        return true;
    }
    else if (nMsg == eMsgUnblockResurrect)
    {
        count = GetGlobalScriptsCnt();
        for (i = 0; i < count; i++) GetGlobalScript(i).CommandMessage(eMsgUnblockResurrect, nParam1);
    }
    return 0;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

command Message(int nMsg, int nValue, unit uUnit)
{
    global pAchievementsScript;
    
    if (nMsg == eMsgAchievement)
    {
        pAchievementsScript = FindGlobalScript(m_nAchievementsScriptUID);
        pAchievementsScript.CommandMessage(eMsgAchievement, nValue, uUnit );
        return true;
    }
    return 0;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

command Message(int nMsg, unit uUnit)
{
    int i;
    if (nMsg == eMsgRegisterSingleDoor)
    {
        for (i = 0; i < GetGlobalScriptsCnt(); i++) GetGlobalScript(i).CommandMessage(eMsgRegisterSingleDoor,uUnit);
        return true;
    }
    return 0;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

event RemovedNetworkPlayer(int nPlayerNum)
{
    RemoveHero(nPlayerNum);
    return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

//uwaga: wywolywane lokalnie tylko na jednym kompie (dolaczajacym sie)
//nie mozna spowodowac zadnej zmiany
//na podstawie nRand losujemy miejsce utworzenia herosa
event GetNewNetworkPlayerCreatePos(int nPlayerNum, int nRand, int& nMissionNum, int& nX, int& nY)
{
    int arrMarkers[];
    
    nMissionNum = nRand % GetMissionsCnt();
    GetMission(nMissionNum).FillMarkersNums("MARKER", arrMarkers);
    if (arrMarkers.GetSize() > 0)
    {
        GetMission(nMissionNum).GetMarker("MARKER", arrMarkers[nRand % arrMarkers.GetSize()], nX, nY);
    }
    else
    {
        nX = GetMission(nMissionNum).GetWorldWidth()/2;
        nY = GetMission(nMissionNum).GetWorldHeight()/2;
    }
    
    return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

event CreatedNewNetworkPlayer(int nPlayerNum, int nMissionNum, int nX, int nY)
{
    CreateHero(nPlayerNum, nMissionNum, nX, nY);
    return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

event UsedDynamicTeleport(unit pTeleport)
{
    string strName;
    
    strName = "translate";
    strName.Append(pTeleport.GetObjectIDName());
    pTeleport.ActivateTeleport(true, true, 0, 1, strName);
    return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

event RemovedDynamicTeleport(unit pTeleport)
{
    return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

command MessageGet(int nParam, string &strValue)
{
    if (nParam == eMsgGetMissionName)
    {
        strValue = m_strInitializeLevel;
        return true;
    }
    return true;
}

command MessageGet(int nParam, int &nValue)
{
    if (nParam == eMsgGetGuildsGame)
    {
        nValue = m_bInitializeGuildsGame;
        return true;
    }
    else if (nParam == eMsgGetGameType)
    {
        nValue = m_nGameType;
        return true;
    }
    else if (nParam == eMsgGetRankedGame)
    {
        nValue = m_bInitializeRankedGame;
        return true;
    }
    return true;
}

command MessageGet(int nParam, int nParam1, string strParam2, int& nRetVal1, string& strRetVal2)
{
    if (nParam == eMsgGetMultiMissionInfoAttrib)
    {
        strRetVal2 = GetMissionInfoValue(m_arrLevelInfoAttribs, m_arrLevelInfoValues, strParam2);
        if (strRetVal2.GetLength() > 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    return false;
}

int m_nRankPointsForWinners;
int m_nGuildRankPointsForWinners;

command CommandDebug(string strLine)
{
    string strCommand, strScript, strScriptParam, strTranslate;
    stringW strText;
    int nPos, nLen, nGetPoints, nPoints, nPlayer, nType;
    int arrPoints[], arrPlayers[], arrGuildNum[];
    int i, j, nGuildNum;
    UnitValues unVal;
    
    strCommand = strLine;
    //#ec.dbg createnewgame scripts\network\MissionCampaign.eco Net_A_02
    if (!strnicmp(strCommand, "createnewgame", strlen("createnewgame")))
    {
        strCommand.Mid(strlen("createnewgame") + 1);
        strCommand.TrimLeft();
        nLen = strCommand.GetLength();
        nPos = 0;
        while ((nPos < nLen) && (strCommand.GetAt(nPos) != ' '))
        {
            nPos++;
        }
        strScript = strCommand;
        strScript.Left(nPos);
        strScriptParam = strCommand;
        strScriptParam.Mid(nPos + 1);
        strScriptParam.TrimLeft();
        if ((strScript.GetLength() > 0) && (strScriptParam.GetLength() > 0))
        {
            strTranslate = "translate";
            strTranslate.Append(strScriptParam);
            CreateNewNetworkGame(strScript, strScriptParam, strTranslate);
        }
    }
    else if (!strnicmp(strCommand, "InitPointsGame", strlen("InitPointsGame")))
    {
        strCommand.Mid(strlen("InitPointsGame") + 1);
        sscanf(strCommand, "%d", nGetPoints);
        m_nRankPointsForWinners = 0;
        for (i = 0; i < GetPlayersCnt(); i++)
        {
            if (IsPlayer(i))
            {
                nPoints = MIN(GetPlayerHeroUnit(i).GetHeroNetworkRankPoints(), nGetPoints);
                m_nRankPointsForWinners += nPoints;
                GetPlayerHeroUnit(i).AddHeroNetworkRankPoints(-nPoints);
            }
        }
    }
    else if (!stricmp(strCommand, "FinishPointsGame"))
    {
        for (i = 0; i < GetPlayersCnt(); i++)
        {
            if (IsPlayer(i)) 
            {
                arrPlayers.Add(i);
            }
        }
        if (arrPlayers.GetSize() == 1)
        {
            arrPoints.SetSize(1);
        }
        else
        {
            arrPoints.SetSize(arrPlayers.GetSize()/2);
        }
        nPoints = 0;
        for (i = 0; i < arrPoints.GetSize(); i++)
        {
            arrPoints[i] = m_nRankPointsForWinners/arrPoints.GetSize();
            nPoints += m_nRankPointsForWinners/arrPoints.GetSize();
        }
        if (arrPoints.GetSize())
        {
            arrPoints[0] += m_nRankPointsForWinners - nPoints;
        }
        nPlayer = 0;
        while ((arrPlayers.GetSize() > 0) && (arrPoints.GetSize() > 0))
        {
            i = Rand(arrPlayers.GetSize());
            GetPlayerHeroUnit(arrPlayers[i]).AddHeroNetworkRankPoints(arrPoints[0]);
            strText.Translate("translateNetworkVictory");
            GetPlayerInterface(arrPlayers[i]).EndGame(strText);
            arrPlayers.RemoveAt(i);
            arrPoints.RemoveAt(0);
        }
        for (i = 0; i < arrPlayers.GetSize(); i++)
        {
            strText.Translate("translateNetworkDefeat");
            GetPlayerInterface(arrPlayers[i]).EndGame(strText);
        }
    }
    else if (!strnicmp(strCommand, "AddRankPoints", strlen("AddRankPoints")))
    {
        strCommand.Mid(strlen("AddRankPoints") + 1);
        sscanf(strCommand, "%d %d", nPlayer, nPoints);
        GetPlayerHeroUnit(nPlayer).AddHeroNetworkRankPoints(nPoints);
    }
    else if (!strnicmp(strCommand, "InitGuildPointsGame", strlen("InitGuildPointsGame")))
    {
        strCommand.Mid(strlen("InitGuildPointsGame") + 1);
        sscanf(strCommand, "%d", nGetPoints);
        m_nRankPointsForWinners = 0;
        for (i = 0; i < GetPlayersCnt(); i++)
        {
            if (IsPlayer(i))
            {
                nGuildNum = GetPlayerHeroUnit(i).GetHeroNetworkGuildNum();
                if (nGuildNum < 0)
                {
                    continue;
                }
                if (arrGuildNum.FindInSorted(nGuildNum) >= 0)
                {
                    continue;
                }
                arrGuildNum.InsertInSorted(nGuildNum);
                nPoints = MIN(GetPlayerHeroUnit(i).GetHeroNetworkGuildRankPoints(), nGetPoints);
                m_nGuildRankPointsForWinners += nPoints;
                GetPlayerHeroUnit(i).AddHeroNetworkGuildRankPoints(-nPoints);
            }
        }
    }
    else if (!stricmp(strCommand, "FinishGuildPointsGame"))
    {
        for (i = 0; i < GetPlayersCnt(); i++)
        {
            if (IsPlayer(i)) 
            {
                nGuildNum = GetPlayerHeroUnit(i).GetHeroNetworkGuildNum();
                if (nGuildNum < 0)
                {
                    continue;
                }
                if (arrGuildNum.FindInSorted(nGuildNum) >= 0)
                {
                    continue;
                }
                arrGuildNum.InsertInSorted(nGuildNum);
                arrPlayers.Add(i);
            }
        }
        if (arrPlayers.GetSize() == 1)
        {
            arrPoints.SetSize(1);
        }
        else
        {
            arrPoints.SetSize(arrPlayers.GetSize()/2);
        }
        nPoints = 0;
        for (i = 0; i < arrPoints.GetSize(); i++)
        {
            arrPoints[i] = m_nGuildRankPointsForWinners/arrPoints.GetSize();
            nPoints += m_nGuildRankPointsForWinners/arrPoints.GetSize();
        }
        if (arrPoints.GetSize())
        {
            arrPoints[0] += m_nGuildRankPointsForWinners - nPoints;
        }
        nPlayer = 0;
        while ((arrPlayers.GetSize() > 0) && (arrPoints.GetSize() > 0))
        {
            i = Rand(arrPlayers.GetSize());
            GetPlayerHeroUnit(arrPlayers[i]).AddHeroNetworkGuildRankPoints(arrPoints[0]);
            strText.Translate("translateNetworkVictory");
            GetPlayerInterface(arrPlayers[i]).EndGame(strText);
            arrPlayers.RemoveAt(i);
            arrPoints.RemoveAt(0);
        }
        for (i = 0; i < arrPlayers.GetSize(); i++)
        {
            strText.Translate("translateNetworkDefeat");
            GetPlayerInterface(arrPlayers[i]).EndGame(strText);
        }
    }
    else if (!strnicmp(strCommand, "AddGuildRankPoints", strlen("AddGuildRankPoints")))
    {
        strCommand.Mid(strlen("AddGuildRankPoints") + 1);
        sscanf(strCommand, "%d %d", nPlayer, nPoints);
        GetPlayerHeroUnit(nPlayer).AddHeroNetworkGuildRankPoints(nPoints);
    }
    else if (!strnicmp(strCommand, "SetTeamNum", strlen("SetTeamNum")))
    {
        strCommand.Mid(strlen("SetTeamNum") + 1);
        sscanf(strCommand, "%d %d", nPlayer, i);
        GetPlayerHeroUnit(nPlayer).SetHeroNetworkTeamNum(i);
    }
    else if (!strnicmp(strCommand, "AddNetworkGameModePoints", strlen("AddNetworkGameModePoints")))
    {
#ifndef _DEMO                
        strCommand.Mid(strlen("AddNetworkGameModePoints") + 1);
        sscanf(strCommand, "%d %d %d", nPlayer, nType, nPoints);
        GetPlayerHeroUnit(nPlayer).AddHeroNetworkGameModePoints(nType, nPoints);
        GetCampaign().SendXBoxHeroNetworkGameModePoints();
#endif        
    }
    return true;
}//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧|

}
