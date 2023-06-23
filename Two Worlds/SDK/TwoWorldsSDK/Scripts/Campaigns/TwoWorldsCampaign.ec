#define USE_SOUNDS



#ifdef _XBOX
campaign "Two Worlds-Xbox"
#else
campaign "Two Worlds"
#endif
{
#include "..\\Common\\Generic.ech"
#include "..\\Common\\Enums.ech"
#include "..\\Common\\Guilds.ech"
#include "..\\Common\\Quest.ech"
#include "..\\Common\\Party.ech"
#include "..\\Common\\Levels.ech"
#include "..\\Common\\Messages.ech"
#include "..\\Common\\Stealing.ech"

consts
{
eColWidth = 80;
eColStart = 80;
eRowWidth = 80;
eRowStart = 80;

eMinHeroLevel = 10;

}

#ifdef _DEBUG
enum startLevel
{
    "E1 - Troglin Temple",
    
    "E3  - Tharbakin Town",
    "F7  - Cathalon Town",
    "D8  - Qudinar Town",
    "B10 - Ashos Town",
    "F12 - GorGamaar Town",
    "H6  - Osgaroth Town",
    
    "E2 - Komorin Village",
    "D2 - Covengor Village",
    "D3 - Gorelin Village",
    "E6 - Four Stones Village",
    "D7 - Windbreak Village",
    "C6 - Clovelly Village",
    
    "G1 - Outpost",
	"F1 - Border",
    "E10 - Hadeborg",
    "C9 - Orc camp", 
    
    "E2 - Goblins",
    "H9 - Desert",
    "H2 - Winter",
    "B8 - Burrows",
    "G10 - Burnt Forest",
    
    "E7 - Cathalon Forest",
    "C10 - bamboo forest",
    "D3 - Watchtower",
    "H2 - Brumhill (devastated village)",
    "F7_1 - Dungeon",
    "I11 - Test new blocks",
    "I12 - Test old blocks",
    "E9_1 - Test dungeon Mac",
    "C4_1 - Test dungeon Hit",
    
multi:
	""
}
#endif //_DEBUG

state Initialize;
state Nothing;

int m_nDifficultyLevel;

int m_arrLevelNum2MissionNum[];
int m_arrMissionNum2LevelNum[];
int m_nMusicScriptUID;
int m_nAchievementsScriptUID;

function string GetMapName(int nCol, int nRow, int nLayer) 
{

    string strMission;
    string strName;

    // podziemne mapy
    if (nLayer == 1) 
    {    
        
        if (nCol == 'B' && nRow == 8) return "translateSaveNameB8";
        if (nCol == 'D' && nRow == 8) return "translateSaveNameD8";        
        
        if (nRow < 10) strMission.Format("%c0%d",nCol + 'A' - 1,nRow);
        else strMission.Format("%c%d",nCol + 'A' - 1,nRow);
        strName.Format("translateCAVE_%s_0_%d",strMission,1);
        return strName;    

    }

    nCol = nCol + 'A' - 1;

    // miasta
    if (nCol == 'E' && nRow == 3) return "translateSaveNameTharbakin";
    if (nCol == 'F' && nRow == 7) return "translateSaveNameCathalon";
    if (nCol == 'D' && nRow == 8) return "translateSaveNameQudinar";
    if (nCol == 'A' && nRow == 10) return "translateSaveNameAshos";
    if (nCol == 'B' && nRow == 10) return "translateSaveNameAshos";
    if (nCol == 'F' && nRow == 12) return "translateSaveNameGorGamaar";
    if (nCol == 'H' && nRow == 6) return "translateSaveNameOsgaroth";
    if (nCol == 'E' && nRow == 10) return "translateSaveNameHadeborg";
        
    // wieze
    if (nCol == 'D' && nRow == 5) return "translateSaveNameTowerNecro";
    if (nCol == 'A' && nRow == 7) return "translateSaveNameTowerNecro";
    if (nCol == 'G' && nRow == 7) return "translateSaveNameTowerNecro";
    if (nCol == 'B' && nRow == 11) return "translateSaveNameTowerNecro";
    if (nCol == 'F' && nRow == 11) return "translateSaveNameTowerNecro";
    
    // rzeka
    if (nCol == 'I' && nRow == 3) return "translateSaveNameRiver";
    if (nCol == 'H' && nRow == 3) return "translateSaveNameRiver";
    if (nCol == 'G' && nRow == 4) return "translateSaveNameRiver";
    if (nCol == 'F' && nRow == 4) return "translateSaveNameRiver";
    if (nCol == 'F' && nRow == 5) return "translateSaveNameRiver";
    if (nCol == 'F' && nRow == 6) return "translateSaveNameRiver";
    if (nCol == 'E' && nRow == 8) return "translateSaveNameRiver";
    if (nCol == 'C' && nRow == 8) return "translateSaveNameRiver";
    if (nCol == 'B' && nRow == 9) return "translateSaveNameRiver";

    // 10
    if (nCol == 'I' && nRow == 1) return "translateSaveName10";

    // 2
    if (nCol >= 'G' && nCol <= 'I' && nRow >= 4 && nRow <= 7) return "translateSaveName2";
    
    // 1
    if (nRow <= 4) return "translateSaveName1";
    
    // 7
    if (nRow <= 7) return "translateSaveName7";
    if (nCol == 'A' && (nRow == 8 || nRow == 9)) return "translateSaveName7";
    
    // 3
    if (nCol >= 'H' && nCol <= 'I' && nRow >= 8 && nRow <= 9) return "translateSaveName3";
    
    // 8
    if (nCol == 'B' && nRow == 12) return "translateSaveName8";
    
    // 5
    if (nCol == 'B' && nRow == 8) return "translateSaveName5";
    
    // 4
    if ((nCol == 'G' || nCol == 'H') && nRow == 10) return "translateSaveName4";
    
    // 9
    if (nCol >= 'H' && nRow >= 10) return "translateSaveName9";
    
    // 6
    return "translateSaveName6";

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
    pMusicScript.CommandMessage(eMsgSetMissionNum, pMission.GetMissionNum() );
    pMusicScript.CommandMessage(eMsgSetTownType,   nTownType );
    pMusicScript.CommandMessage(eMsgSetTownX1,     nX1 );
    pMusicScript.CommandMessage(eMsgSetTownX2,     nX2 );
    pMusicScript.CommandMessage(eMsgSetTownY1,     nY1 );
    pMusicScript.CommandMessage(eMsgSetTownY2,     nY2 );
    pMusicScript.CommandMessage(eMsgSetPlayInsideTown, false );
}

#define AT(a,b) pMission.SetAttribute(a,b)
function void SetMissionAttributes(int nMissionNum,int nCol,int nRow,int nLayer)
{
    mission pMission;
    
    pMission = GetMission(nMissionNum);
    
    pMission.SetAttribute(WEATHER_TYPE_ATTR, eMapTypeCommon); //WT==Weather Type
    
    
    if(nCol>eColG && nRow>5 && nRow<8) AT(WEATHER_TYPE_ATTR, eMapTypeOswaroth);
    
    if((nCol==eColC && nRow==8)
    || (nCol==eColE && nRow==8)
    || (nCol==eColI && nRow==3)) AT(WEATHER_TYPE_ATTR, eMapTypeDenseFog);


if(nCol==eColF && nRow==7 ||     //Cathalon
       nCol==eColE && nRow==3 ||       //Tharbakin 
       nCol==eColE && nRow==1 ||       //Temple Earth 
       nCol==eColD && nRow==8 ||       //Qudinar 
       nCol==eColB && nRow==10        //Ashos 
    )    
        AT(WEATHER_TYPE_ATTR, eMapTypeTown);

    
    if(nCol==eColD && nRow==5 ||   //necrotowers
    nCol==eColA && nRow==7 ||
    nCol==eColG && nRow==7 ||
    nCol==eColB && nRow==11 ||
    nCol==eColF && nRow==11
    )    
        AT(WEATHER_TYPE_ATTR, eMapTypeTower);
    if(nCol==eColB && nRow==8)
        AT(WEATHER_TYPE_ATTR, eMapTypeBarrow);
    if(nCol==eColG && nRow==10  ||
       nCol==eColH && nRow==10
      )    
        AT(WEATHER_TYPE_ATTR, eMapTypeForest);
    
    if(nCol==eColG && nRow==1  ||
       nCol==eColD && nRow==2  ||
       nCol==eColD && nRow==7  ||
       nCol==eColE && nRow==6  ||
       nCol==eColE && nRow==2  ||
       nCol==eColF && nRow==3  ||
       nCol==eColD && nRow==4  ||
       nCol==eColC && nRow==6  ||
       nCol==eColD && nRow==3  ||
       nCol==eColD && nRow==1)AT(WEATHER_TYPE_ATTR, eMapTypeVillage);
       
    if(nCol==eColE && nRow==1) AT(WEATHER_TYPE_ATTR, eMapTypeStart);    
    
    if(nCol>=eColD &&nCol<=eColF && nRow==9  ||
       nCol>=eColE &&nCol<=eColF&& nRow==10
      )    
        AT(WEATHER_TYPE_ATTR, eMapTypeSwamp);
    
    
    if(nCol>eColH && nRow<2)
        AT(WEATHER_TYPE_ATTR, eMapTypeSnow);
    
    if(nCol>eColC && nRow>10)
        AT(WEATHER_TYPE_ATTR, eMapTypeVolcano);
    
    if(nCol>eColG && nRow>7 && nRow<10) AT(WEATHER_TYPE_ATTR, eMapTypeDesert);
        
    if(nCol==eColF && nRow==2) AT("Dream", 1);
    if(nCol==eColD && nRow==4) AT("Dream", 2);
    if(nCol==eColE && nRow==9) AT("Dream", 3);
        
}


function void InitializeLevels()
{
    int nRow, nCol, nLayer;
    string strName, strLevel, strScript;
    int nIndex, nLevelNum, nMissionNum, nMissionsCnt;
    int nX, nY, nZ, nDir;
    mission pMission;
    
    SetLevelsHorizon("Levels\\horizont.hor");
    //PentaSegs PentaAngs AddPentagram
    SetPentagram("30 4   18240 -17600 3000 250 34160 -29520 3000 250 28360 -48000 3000 250 8800 -48000 3000 250 2720 -29520 3000 250");
    SetEndOfTheWorldSouthMargin(200*e1m, 205*e1m);
    SetEndOfTheWorldNorthMargin(64*e1m, 69*e1m);
    SetEndOfTheWorldWestMargin(40*e1m, 45*e1m);

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
                strScript = "Scripts\\Campaigns\\Missions\\Mission_";
                strScript.Append(strName);
                strScript.Append(".eco");
                if (!CheckFileExist(strScript))
                {
                    strScript = "Scripts\\Campaigns\\Missions\\EmptyMission.eco";
                }
                CreateMission(strLevel, strScript, nMissionNum);
                nLevelNum = Level2LevelNum(nCol, nRow, nLayer);
                m_arrLevelNum2MissionNum[nLevelNum] = nMissionNum;
                m_arrMissionNum2LevelNum.Add(nLevelNum);
                
                GetMission(nMissionNum).SetPositionOnCampaignTexture(nCol - 1, nRow - 1);
                GetMission(nMissionNum).SetHorizonOffset(-(nCol - 1)*A2G(GetMission(nMissionNum).GetWorldWidth()), (nRow - 1)*A2G(GetMission(nMissionNum).GetWorldHeight()));
                
                SetMissionAttributes(nMissionNum,nCol,nRow,nLayer);

                nMissionNum++;
                
                    
            }
        }
    }
    CleanupLevelsHeadersCache();

    //B09 fix
    pMission = MIS(B9);
    if (pMission.GetMarker("MARKER_TELEPORT_DEST", 1, nX, nY, nZ, nDir))
    {
        pMission.RemoveMarker("MARKER_TELEPORT_DEST", 1);
        pMission.AddMarker("MARKER_RESSURECT", 3, nX, nY, nZ, nDir, "");
    }
    

#ifdef _DEMO    
    //translateMessageOptionNotAvailableInDemo
    nMissionsCnt = GetMissionsCnt();
    for (nMissionNum = 0; nMissionNum < nMissionsCnt; nMissionNum++)
    {
        pMission = GetMission(nMissionNum);
        if (pMission != null)
        {
            pMission.DisableLevel(true);
        }
    }
    pMission = MIS(E2);   pMission.DisableLevel(false);
    pMission = MIS(E3);   pMission.DisableLevel(false);
    pMission = MIS(E3_1); pMission.DisableLevel(false);
    pMission = MIS(F2);   pMission.DisableLevel(false);
    pMission = MIS(F2_1); pMission.DisableLevel(false);
    pMission = MIS(F3);   pMission.DisableLevel(false);
    pMission = MIS(F3_1); pMission.DisableLevel(false);
    SetEndOfTheWorldSouthMargin(e1m, e2m);
    SetEndOfTheWorldNorthMargin(e1m, e2m);
    SetEndOfTheWorldEastMargin(e1m, e2m);
    SetEndOfTheWorldWestMargin(e1m, e2m);
#endif //_DEMO
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void CreateHero(mission pMission, int nX, int nY)
{
    unit uHero;
    UnitValues unVal;
    int i;

   #ifdef _DEMO    
    uHero = pMission.CreateHero(0, nX, nY, 0, 128);
   #else
   uHero = pMission.CreateHero(0, nX, nY, 0, 0);
   #endif
    uHero.SetPartyNum(ePartyPlayer);
    
    unVal = uHero.GetUnitValues();
         
    for(i=eFirstNormalSkill;i<eSkillsCnt;i++)if(unVal.GetBasicSkill(i)==0)LockSkill(uHero,i);
    uHero.AddMagicCard("MAGIC_FIREBOLT",0);
    uHero.AddMagicCard("MAGIC_HEAL",1);
    uHero.RemoveObjectFromInventory("AR_LEATHER_ARMOUR",0);
    uHero.AddInventory("AR_SPECIAL_ARMOUR(1,0)",1);
    unVal.SetParamPoints(0);
    unVal.SetSkillPoints(0);
    uHero.UpdateChangedUnitValues();
    for(i=eFirstGuild;i<=eGuildSkelden;i++) uHero.SetAttribute(i, 0);
    SetThiefUID(uHero);
    

    if (GetPlayerInterface(0).IsLocalHeroXPadControlled())
    {
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefSkillPrior(0, 0, 1);
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefSkillPrior(0, 1, 2);
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefSkillPrior(0, 2, 3);
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefSkillPrior(0, 3, 4);
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefMagic(0, 4, 0);
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefMagic(0, 5, 1);
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefObject(0, 6, "WP_SWORD_0");
        GetPlayerInterface(0).SetCustomCommandsDialogButtonDefObject(0, 7, "WP_BOW_01");
        GetPlayerInterface(0).SetCustomCommandsDialogSelectedButton(4);
    }

}

//!!przerzucic do skryptu obslugi teleportow
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

state Initialize
{
    mission pStartMission;
    global pScriptMusic;
    global pScript;
    int nX,nY;
    unit uHero;
       
    LoadRPGComputeScript("Scripts\\RPGCompute\\RPGCompute.eco");
    
    SetDayLength(30, 20, 237);
    
    SetLimitedWorldStepRange(e80m);
       
    InitializeLevels();
  
    nX = 74*256;
    nY = 114*256;
    
    pStartMission = MIS(E1); nX = 70*256;  nY = 52*256;
#ifdef _DEMO
    pStartMission = MIS(E2); nX = 68*256;  nY = 124*256;
#endif    
#ifdef _DEBUG
    if(startLevel==1){pStartMission = MIS(E3); nX = 68*256;  nY = 82*256;}
    if(startLevel==2){pStartMission = MIS(F7); nX = 61*256;  nY = 62*256;}
    if(startLevel==3){pStartMission = MIS(D8); nX = 96*256;  nY = 90*256;}
    if(startLevel==4){pStartMission = MIS(B10);nX = 90*256;  nY = 90*256;}
    if(startLevel==5){pStartMission = MIS(F12);nX = 70*256;  nY = 70*256;}
    if(startLevel==6){pStartMission = MIS(H6); nX = 64*256;  nY = 20*256;}
    
    if(startLevel==7){pStartMission = MIS(E2); nX = 50*256;  nY = 75*256;}
    if(startLevel==8){pStartMission = MIS(D2); nX = 75*256;  nY = 81*256;}
    if(startLevel==9){pStartMission = MIS(D3); nX = 54*256;  nY = 64*256;}
    if(startLevel==10){pStartMission = MIS(E6);}
    if(startLevel==11){pStartMission = MIS(D7); nX = 65*256+128;  nY = 67*256;}
    if(startLevel==12){pStartMission = MIS(C6); nX = 44*256;  nY = 72*256;}
    
    if(startLevel==13){pStartMission = MIS(G1); nX = 6*256;  nY = 12*256;}
    if(startLevel==14){pStartMission = MIS(F1); nX = 64*256;  nY = 20*256;}
 
    if(startLevel==15){pStartMission = MIS(E10); nX = 57*256;  nY = 37*256;}
    if(startLevel==16){pStartMission = MIS(C9);  nX = 115*256;  nY = 53*256;}
    
    
    if(startLevel==17){pStartMission = MIS(E2); nX = 91*256;  nY = 95*256;}
    if(startLevel==18){pStartMission = MIS(H9); nX = 27*256;  nY = 48*256;}
    if(startLevel==19){pStartMission = MIS(H2); nX = 23*256;  nY = 52*256;}
    if(startLevel==20){pStartMission = MIS(B8); nX = 33*256;  nY = 105*256;}
    if(startLevel==21){pStartMission = MIS(G10); nX = 47*256;  nY = 97*256;}
    
    
    
    if(startLevel==22){pStartMission = MIS(E7); nX = 68*256;  nY = 95*256;}
    if(startLevel==23){pStartMission = MIS(C10);nX = 64*256;  nY = 64*256;}
    if(startLevel==24){pStartMission = MIS(D3); nX = 39*256;  nY = 15*256;}
    if(startLevel==25){pStartMission = MIS(H2); nX = 25*256;  nY = 50*256;}
    if(startLevel==26){pStartMission = MIS(F7_1);nX = 67*256;  nY = 66*256;}
    
    if(startLevel==27){pStartMission = MIS(FI11);nX = 79*256;  nY = 83*256;}
    if(startLevel==28){pStartMission = MIS(FI12);nX = 80*256;  nY = 45*256;}
    
    if(startLevel==29){pStartMission = MIS(E9_1);nX = 63*256;  nY = 66*256;}
    if(startLevel==30){pStartMission = MIS(C4_1);nX = 67*256;  nY = 64*256;}
#endif //_DEBUG
    
    AddGlobalScript("Scripts\\Campaigns\\Missions\\PNames.eco", true);    
    #ifdef USE_SOUNDS
    pScriptMusic = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsMusic.eco", true);
    m_nMusicScriptUID = pScriptMusic.GetScriptUID();
    #endif
    
    pStartMission.LoadLevel();
    CreateHero(pStartMission, nX, nY);
    uHero=GetHero();
    //Towns
    #ifdef _DEMO
      InitializeTownScript(MIS(E2), eTownTypeKomorin,  ePartyE2,   44, 70,  64,  97, false);
      InitializeTownScript(MIS(E3), eTownTypeTharbakin,ePartyE3, 52, 63,  95, 107, true);
    #else
    
    
    InitializeTownScript(MIS(F7), eTownTypeCathalon, ePartyF7, 32, 37,  99, 105, true);
    InitializeTownScript(MIS(E3), eTownTypeTharbakin,ePartyE3, 52, 63,  95, 107, true);
    InitializeTownScript(MIS(B10),eTownTypeAshos ,   ePartyB10,33, 62, 106, 118, true);
    InitializeTownScript(MIS(D8), eTownTypeQudinaar, ePartyD8, 44, 22, 108, 189, true);
  //Villages  
    InitializeTownScript(MIS(G1), eTownTypeOutpost,  ePartyG1,   28, 17,  40,  28, false);// w wioskach nie ma miejskiej muzyki
    InitializeTownScript(MIS(D2), eTownTypeCovenant, ePartyD2,   92, 48, 111,  75, false);
    InitializeTownScript(MIS(D7), eTownTypeWindbreak,ePartyD7,   55, 64,  79,  83, false);
    InitializeTownScript(MIS(E6), eTownType4Stones,  ePartyE6,   44, 52,  83,  83, false);
    InitializeTownScript(MIS(E2), eTownTypeKomorin,  ePartyE2,   44, 70,  64,  97, false);
    InitializeTownScript(MIS(F3), eTownTypeExcavations,ePartySkelden, 36, 58,  74,  87, false);
    InitializeTownScript(MIS(H8), eTownTypeKehar,    ePartyH8,   98, 17, 124,  47, false);
    InitializeTownScript(MIS(H8), eTownTypeKehar,    ePartyH8,  113, 72, 122,  93, false);
    InitializeTownScript(MIS(D4), eTownTypeVillageD4,ePartyD4,   20, 96,  36, 111, false);
    InitializeTownScript(MIS(C6), eTownTypeClovelly, ePartyC6,   12, 76,  46, 122, false);
    InitializeTownScript(MIS(E11),eTownTypeNecro,    ePartyE11,  48, 89,  63, 104, false);
    InitializeTownScript(MIS(D3), eTownTypeCovenant, ePartyD2,   54, 85,  75, 108, false);//Rovan village
    InitializeTownScript(MIS(D3), eTownTypeGorelin,  ePartyD3,   82, 37,  99,  60, false);
    InitializeTownScript(MIS(D1), eTownTypeKargaCamp,ePartyKarga,58, 39,  92,  63, false);
    
    // miasta, ktore maja wlasny track, ale po nim nie sa grane tracki 'inside town'
    InitializeCustomPlace(MIS(G2),  eTownTypeGromsCamp, 22, 68, 42, 88);
    InitializeCustomPlace(MIS(G3),  eTownTypeGromsCamp, 56, 59, 76, 89);
    InitializeCustomPlace(MIS(D2),  eTownTypeGromsCamp, 15, 62, 53, 82);
    InitializeCustomPlace(MIS(F12), eTownTypeGorGamar,  51, 72, 97, 117);
  #endif  
    AddGlobalScript("Scripts\\Campaigns\\Missions\\PDialogUnits.eco", true);    
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsTeleports.eco", true);
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsWeather.eco", true);
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsLights.eco", true);
    #ifdef USE_SOUNDS
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsSounds.eco", true);
    #endif
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsEnemies.eco", true);
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsContainers.eco", true);
    AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsHeroControl.eco", true);
    pScript = AddGlobalScript("Scripts\\Campaigns\\Missions\\PBandits.eco", true);
    pScript.CommandMessage(eMsgSetMaxNeutralBandits,3);
    AddGlobalScript("Scripts\\Campaigns\\Missions\\PQuests.eco", true);
    pScript = AddGlobalScript("Scripts\\Campaigns\\Missions\\TwoWorldsAchievements.eco", true);
    m_nAchievementsScriptUID = pScript.GetScriptUID();
    
    InitalizePartyForTwoWorldsCampaign();
    
    SetDayTime(100);
#ifndef _DEMO    
    GetCampaign().GetPlayerInterface(0).PlayVideoCutscene("Video\\Cut1.wmv",true,false);
#endif    
    return Nothing, 3*30;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|


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
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Message(int nMsg, int nParam1)
{
    global pAchievementsScript;
    
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
    else if (nMsg == eMsgAchievement)
    {
        pAchievementsScript = FindGlobalScript(m_nAchievementsScriptUID);
        pAchievementsScript.CommandMessage(eMsgAchievement, nParam1 );
        return true;
    }
    return 0;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Message(int nMsg, int nValue, unit uUnit)
{
    int i;
    mission pMission;
    global pAchievementsScript;
    
    if (nMsg == eMsgLockpicked)
    {
        ASSERT(uUnit != null);
        pMission = uUnit.GetMission();
        ASSERT(pMission != null);
        for (i = 0; i < pMission.GetMissionScriptsCnt(); i++) if (pMission.GetMissionScript(i).CommandMessage(eMsgGetScriptID) == eTownScriptID) pMission.GetMissionScript(i).CommandMessage(eMsgLockpicked,nValue,uUnit);
        for (i = 0; i < GetGlobalScriptsCnt(); i++) GetGlobalScript(i).CommandMessage(eMsgLockpicked,nValue,uUnit);
        return true;
    }
    else if (nMsg == eMsgAchievement)
    {
        pAchievementsScript = FindGlobalScript(m_nAchievementsScriptUID);
        pAchievementsScript.CommandMessage(eMsgAchievement, nValue, uUnit );
        return true;
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

event GetSaveGameName(mission pCurrMission, int bOnlyLevelName, stringW& strName)
{
    int nCol, nRow, nLayer, nGameSec;
    stringW strTime, strTmp;
    
    MissionNum2Level(pCurrMission.GetMissionNum(), nCol, nRow, nLayer);    
    strName.Translate(GetMapName(nCol,nRow,nLayer));    

    if (!bOnlyLevelName)
    {
        nGameSec = GetGameSec();
        if (nGameSec/(60*60) > 0)
        {
            strTmp.Translate("translateSaveLoadHourMinSecFormat");
            strTime.Format(strTmp, nGameSec/(60*60), (nGameSec/60)%60, nGameSec%60);
        }
        else
        {
            strTmp.Translate("translateSaveLoadMinSecFormat");
            strTime.Format(strTmp, (nGameSec/60)%60, (nGameSec%60));
        }
    
        strTmp.Copy(" ");
        strName.Append(strTmp);
        strName.Append(strTime);
    }
    
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CommandDebug(string strLine)
{
    string strCommand, strCmd, strLoad, strUnload;
    mission pMission;
    
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
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|



command InitializeCampaign(int nLevel, string strInitParam) 
#ifdef _DEBUG
    button startLevel
#endif
{
    m_nDifficultyLevel = nLevel;

#ifdef _DEBUG
    sscanf(strInitParam, "%d", nLevel);
    startLevel = nLevel;
#endif
    
	return true;
}
event GetDifficultyLevel()
{
    return m_nDifficultyLevel;
}

#define PART_LENGTH   4
#define PACK_MAXCOUNT 5

function int CheckCodePart(int nPart, int arrCode[])
{
    int nPartIndex;
    int nIndex;

    int n1stPartIndex;
    int n2ndPartIndex;
    int n3rdPartIndex;

    int nPackIndex;
    int arrLastPart[];
    int nCount;
    int arrPackValues[];

    n1stPartIndex = 0 * PART_LENGTH;
    n2ndPartIndex = 1 * PART_LENGTH;
    n3rdPartIndex = 2 * PART_LENGTH;

    nPartIndex = nPart * PART_LENGTH;
    
    arrPackValues.Add(2);   arrPackValues.Add(13);   arrPackValues.Add(31);
    arrPackValues.Add(3);   arrPackValues.Add(17);   arrPackValues.Add(37);
    arrPackValues.Add(5);   arrPackValues.Add(19);   arrPackValues.Add(41);
    arrPackValues.Add(7);   arrPackValues.Add(23);   arrPackValues.Add(43);
    arrPackValues.Add(11);  arrPackValues.Add(29);   arrPackValues.Add(47);

    // pierwsze trzy czesci kodu
    if( nPart < (PART_LENGTH - 1) )
    {
        if(  arrCode[nPartIndex + 3] != (arrCode[nPartIndex + 0] +
                                         arrCode[nPartIndex + 1] +
                                         arrCode[nPartIndex + 2] + nPart) % 10 )
        {
             return -1;
        }
        return 0;
    }
    // czwarta czesc kodu
    else
    {
        for(nPackIndex = 0; nPackIndex < PACK_MAXCOUNT; nPackIndex++ )
        {
            arrLastPart.RemoveAll();
            for(nIndex = 0; nIndex < PART_LENGTH ; nIndex++)
            {
                arrLastPart.Add( (arrCode[n1stPartIndex + nIndex] * arrPackValues[nPackIndex * (PART_LENGTH - 1) + 0] +
                                  arrCode[n2ndPartIndex + nIndex] * arrPackValues[nPackIndex * (PART_LENGTH - 1) + 1] +
                                  arrCode[n3rdPartIndex + nIndex] * arrPackValues[nPackIndex * (PART_LENGTH - 1) + 2] ) % 10);
            }
            // porownanie
            nCount = 0;
            for(nIndex = 0; nIndex < PART_LENGTH; nIndex++)
            {
                if( arrLastPart[nIndex] == arrCode[nPartIndex + nIndex] )
                {
                    nCount++;
                }
            }
            if( nCount == PART_LENGTH )
            {
                return nPackIndex;
            }
        }
    }
    return -1;
}

function int GetCodeIndexFromString(string strBonusCode)
{
    int nIndex;
    int arrCode[];
    int nValue;
    int nRet;
    
    if( strlen(strBonusCode) != 16 )
    {
        return -1;    
    }
    for(nIndex = 0; nIndex < strlen(strBonusCode); nIndex++)
    {
        nValue = GetChar(strBonusCode, nIndex) - '0';
        if( nValue < 0 || nValue > 9 )
        {
            return -1;
        }
        arrCode.Add(nValue);
    }
    ASSERT(arrCode.GetSize() == 16);
        
    for(nIndex = 0; nIndex < 4; nIndex++)
    {
        nRet = CheckCodePart(nIndex, arrCode);
        if( nRet == -1 )
        {
            return -1;    
        }
    }
    return nRet;
}

function string TidyBonusCodeString(string strBonusCode)
{
    string strNewString;
    int nIndex;

    for(nIndex = 0; nIndex < strlen(strBonusCode); nIndex++)
    {
        if( GetChar(strBonusCode, nIndex) == ' ' || GetChar(strBonusCode, nIndex) == '-' )
        {
            continue;
        }
        strNewString.Append( GetChar(strBonusCode, nIndex) );
    }
    return strNewString;
}

command BonusCode(string strBonusCode)
{
    string strCode;
    int nX,nY,nCode;
    unit uHero;
    mission pMission;   
    
    strCode = strBonusCode;
    
    nCode = GetCodeIndexFromString( TidyBonusCodeString(strBonusCode) );
    TRACE("Code: %d\n", nCode);

    if( nCode == -1)
    {
        return false;
    }

    if (nCode==0)//********************SPECIAL OBJECTS*****************
    {
        uHero=GetHeroMulti();
        nX=0;
        uHero.GetAttribute("Code1",nX);
        if(nX==12)return false;
        uHero.SetAttribute("Code1",12);
        uHero.GetLocation(nX,nY);
        pMission=uHero.GetMission();
        pMission.CreateObject("WP_SWORD_SPEC(5,1)",nX,nY,0,0);
    }
    else if (nCode==1)
    {
        uHero=GetHeroMulti();
        nX=0;
        uHero.GetAttribute("Code2",nX);
        if(nX==12)return false;
        uHero.SetAttribute("Code2",12);
        uHero.GetLocation(nX,nY);
        pMission=uHero.GetMission();
        pMission.CreateObject("WP_BOW_SPEC(5,1)",nX,nY,0,0);
    }
    else if (nCode==2)
    {
        uHero=GetHeroMulti();
        nX=0;
        uHero.GetAttribute("Code3",nX);
        if(nX==12)return false;
        uHero.SetAttribute("Code3",12);
        uHero.GetLocation(nX,nY);
        pMission=uHero.GetMission();
        pMission.CreateObject("WP_POLE_ARM_SPEC(5,1)",nX,nY,0,0);
    }
    else if (nCode==3)
    {
        uHero=GetHeroMulti();
        nX=0;
        uHero.GetAttribute("Code4",nX);
        if(nX==12)return false;
        uHero.SetAttribute("Code4",12);
        uHero.GetLocation(nX,nY);
        pMission=uHero.GetMission();
        pMission.CreateObject("AR_ARMOUR_SPEC(5,2)",nX,nY,0,0);
    }
    else if (nCode==4)
    {
        uHero=GetHeroMulti();
        nX=0;
        uHero.GetAttribute("Code5",nX);
        if(nX==12)return false;
        uHero.SetAttribute("Code5",12);
        uHero.GetLocation(nX,nY);
        pMission=uHero.GetMission();
        pMission.CreateObject("AR_SHIELD_SPEC(5,2)",nX,nY,0,0);
    }
    
    ///....
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

}


/*
ma byc            jest
lockpicking   precize shoot


*/
