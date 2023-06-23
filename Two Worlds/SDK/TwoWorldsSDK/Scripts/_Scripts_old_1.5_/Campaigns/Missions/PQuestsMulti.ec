global "PQuestsMulti"
{

#define QUESTS_MULTI

state Initialize;
state GeneratingQuests;
state Nothing;

string strMissionName;

consts {

    eFirstQuest            = 699;
    eQuestsNum             = 300;
    eFirstQuestUnit        = 699;
    eQuestUnitsNum         = 300;
    
}

//======================================        

function string GetMissionName();
function int GetMultiplayerMissionAndPositionOffsets(int nCol, int nRow, int nLayer);
function void DecodeMissionAndPositionOffsets(int &nMission, int &nX, int &nY);
function string MultiMissionName2SingleMissionName(string strMission, int nX, int nY);

function void SetQuestSolvedByHero(int nQuestNum, int nHero);
function void SetQuestSolvedByHero(int nQuestNum, unit uHero);

function void CloseQuestAllHeroes(int nQuestNum, int nHero);
function void FailQuestAllHeroes(int nQuestNum, int nHero);

function void RemoveQuestGiverLocation(int nQuestNum, int nHero);
function void RemoveQuestGiverLocation(unit uUnit);

function void ActivateTeleports();
function void CheckBringObjectLocations();

#include "PInc\\PQuestsCommon.ech"

//======================================        

int anQuestTakenFlag[eQuestsNum];
int anQuestSolvedFlag[eQuestsNum];

/*
function void TestQuests() {

    int i;
    int n;
    string str;
    int nTargetX, nTargetY;
    int nX, nY;
    mission pMission;
    unit uObject;
    
    pMission = GetCampaign().GetMission(0);
    n = pMission.GetMaxMarkerNum(MARKER_QUEST_MULTI_BRING_OBJECT);
    str = "QITEM_038";
    for (i = 1; i <= n; i++) {
        if (!pMission.GetMarker(MARKER_QUEST_MULTI_BRING_OBJECT,i,nX,nY)) continue;
        GetPointInRange(nX,nY,0,eActionObjectCreateRangeA,null,nTargetX,nTargetY);
        uObject =  pMission.CreateObject(str,nTargetX,nTargetY,0,Rand(256));
        if (uObject == null) {
            TRACE("can't create %s on %d %d                   \n",str,nTargetX,nTargetY);
        }                
    }

}
*/
//======================================        

function string GetMissionName() {

    return strMissionName;
    
}

//======================================        

function int CodeMissionAndPositionOffsets(int nStartCol, int nStartRow, int nCol, int nRow, int nLayer) {

    if ((nCol == nStartCol || nCol == nStartCol + 1) && (nRow == nStartRow || nRow == nStartRow + 1)) {
    
        return (((nCol - nStartCol) * 128) << 16) | (((nStartRow + 1 - nRow) * 128) << 8) | nLayer;
    
    }

    return eNoMission;

}

function void DecodeMissionAndPositionOffsets(int &nMission, int &nX, int &nY) {
    
    int nTmpMission;
    int nTmpX, nTmpY;
    
    nTmpX = nMission >> 16;
    nTmpY = (nMission >> 8) & 0xff;
    nTmpMission = nMission & 0xff;
    
    nX += nTmpX;
    nY += nTmpY;
    nMission = nTmpMission;    

}

function int GetMultiplayerMissionAndPositionOffsets(int nCol, int nRow, int nLayer) {

    int nStartCol;
    int nStartRow;
    
    if (!GetSinglePlayerMission(GetMissionName(),nStartCol,nStartRow)) return eNoMission;
    return CodeMissionAndPositionOffsets(nStartCol,nStartRow,nCol,nRow,nLayer);

}

function string MultiMissionName2SingleMissionName(string strMission, int nX, int nY) {

    int nCol;
    int nRow;
    string str;

    GetSinglePlayerMission(strMission,nCol,nRow);

    nCol += (nX >> 15);
    nRow += (1 - (nY >> 15));

    if (nRow < 10) str.Format("%c0%d",nCol,nRow);
    else str.Format("%c%d",nCol,nRow);
    
//    TRACE("mission %s col %c %d row %d str %s                \n",strMission,nCol,nCol,nRow,str);
    
    return str;

}

//======================================        
// multiplayer

#define MARKER_QUEST_MULTI_KILL            "MARKER_QUEST_POINT_CAA"
#define MARKER_QUEST_MULTI_KILL_UNDEAD     "MARKER_QUEST_POINT_CAU"
#define MARKER_QUEST_MULTI_BRING_OBJECT    "MARKER_QUEST_POINT_BO"
#define MARKER_QUEST_GIVER_MULTI           "MARKER_QUEST_START_M"
#define MARKER_Q_FINDCHAIR                 "MARKER_Q_FINDCHAIR"
#define QUEST_GIVER_MULTI_NAME             "translateNPCName%d"

#define MAIN_QUEST_NAME                    "translateMultiQTitle"
#define MAIN_QUEST_INFO                    "translateMultiQ"
#define MAIN_QUEST_CLOSED                  "translateMultiQClosed"
#define MAIN_QUEST_CONSOLE                 "translateMultiQUnlocked"

//#define QUESTS_MULTI_DEBUG

consts {

    eQuestMultiUnknownType = 0;
    eQuestMultiKill        = 1;
    eQuestMultiKillUndead  = 2;
    eQuestMultiBringObject = 3;
    
    eQuestKillFirst        = 200;
    eQuestKillLast         = 259;
    eQuestKillUndeadFirst  = 100;
    eQuestKillUndeadLast   = 129;
    eQuestBringObjectFirst = 1;
    eQuestBringObjectLast  = 29;
    eQuestCreateEnemyFirst = eQuestKillFirst;
    eQuestCreateEnemyLast  = eQuestKillLast;
    eQuestCreateEnemyUndeadFirst = eQuestKillUndeadFirst;
    eQuestCreateEnemyUndeadLast = eQuestKillUndeadLast;

    eHeroLocationStart     = 300;
    eBringObjectLocationStart = 400;

}

int nQuestsMultiMin;
int nQuestsMultiMax;

int anQuestsKill[];
int anQuestsKillMarkers[];
int anQuestsKillUndead[];
int anQuestsKillUndeadMarkers[];
int anQuestsBringObject[];
int anQuestsBringObjectMarkers[];

int anQuestGiversMarkers[];
int anQuestTypes[];

int anActionsCreateEnemy[];
int anActionsCreateEnemyUndead[];

int nTotalQuests;
int nHeroesAvgLevel;

string astrMarkersEnemies[];

string strNextMapName;
int nNextMapActivationLevel;
int nClosedQuests;

int anHeroLocation[eMaxPlayers];

int nTeleportsActivated;

int anBOLQuest[];
string astrBOLName[];
int anBOLPosX[];
int anBOLPosY[];
int anBOLHero[];
int nCurrentBringObjectLocation;

//======================================        

#define MARKER_TELEPORT_STATIC       "MARKER_TELEPORT_STATIC"

function void ActivateTeleports(mission pMission) {

    int i, nMaxNum;
    unit uTeleport;
    int nX, nY;
    
    nMaxNum = pMission.GetMaxMarkerNum(MARKER_TELEPORT_STATIC);
    for (i = 0; i <= nMaxNum; i++) {
    
        if (!pMission.GetMarker(MARKER_TELEPORT_STATIC,i,nX,nY)) continue;
        
        uTeleport = pMission.GetObjectMarker(MARKER_TELEPORT_STATIC,i);        
        ASSERT(uTeleport);

        pMission.CreateObject("ACTIVATE_TELEPORT",nX,nY,0,0);
        uTeleport.ActivateTeleport(true,true,25,25,"translateTEL_C02_0_1");
    
    }

}

function void ActivateTeleports() {

    if (nTeleportsActivated) return;
    if (GetCampaign().GetMission(0).IsLevelLoaded()) ActivateTeleports(GetCampaign().GetMission(0));    
    nTeleportsActivated = true;

}

//======================================        

function int GetNextFreeMarker(mission pMission, string strMarker) {

    if (pMission.GetMaxMarkerNum(strMarker) < 1) return 1;
    return pMission.GetMaxMarkerNum(strMarker) + 1;

}

function int IsQuestGiverMale(int nQuestNum) {

    // jesli questy sa parzyste i nie jest to quest 718
    // (co po odjeciu 699 daje nieparzyste questy i nie quest 19) to sa quest giver jest mezczyzna
    if ((nQuestNum % 2) && (nQuestNum != 19)) return true;
    return false;

}

function int CanAddQuest(int nQuestNum) {

    nQuestNum += eFirstQuest;
    if (strMissionName.EqualNoCase("Net_M_01")) {
        if (nQuestNum >= 700 && nQuestNum <= 705) return true;
        if (nQuestNum >= 800 && nQuestNum <= 805) return true;
        if (nQuestNum >= 900 && nQuestNum <= 905) return true;
        return false;
    }
    if (strMissionName.EqualNoCase("Net_M_02")) {
        if (nQuestNum >= 700 && nQuestNum <= 710) return true;
        if (nQuestNum >= 800 && nQuestNum <= 810) return true;
        if (nQuestNum >= 900 && nQuestNum <= 910) return true;
        return false;
    }
    if (strMissionName.EqualNoCase("Net_M_03")) {
        if (nQuestNum >= 700 && nQuestNum <= 715) return true;
        if (nQuestNum >= 800 && nQuestNum <= 815) return true;
        if (nQuestNum >= 900 && nQuestNum <= 915) return true;
        return false;
    }
    return true;

}

//======================================        
// enemies

function void GenerateEnemies() {

    int i, j, n;
    int nMission;
    string strMission;
    mission pMission;
    int nX, nY;
    int nMarker,nEnemyType;
    string strMarker;
    nEnemyType=Rand(3);
    astrMarkersEnemies.Add("MARKER_ENEMY_M_GU");
    astrMarkersEnemies.Add("MARKER_ENEMY_M_SU");
    astrMarkersEnemies.Add("MARKER_ENEMY_M_GA");
    astrMarkersEnemies.Add("MARKER_ENEMY_M_SA");
    astrMarkersEnemies.Add("MARKER_ENEMY_M_CA");
    
    strMission = GetMissionName();
    for (i = 0; i < astrMarkersEnemies.GetSize(); i++) {
        for (nMission = 0; nMission < GetCampaign().GetMissionsCnt(); nMission++) {

            pMission = GetCampaign().GetMission(nMission);
            n = pMission.GetMaxMarkerNum(astrMarkersEnemies[i]);
        
            for (j = 1; j <= n; j++) {
                if (!pMission.GetMarker(astrMarkersEnemies[i],j,nX,nY)) continue;
                strMarker = GetMarkerEnemyMulti(strMission,astrMarkersEnemies[i],nEnemyType);
                nMarker = GetNextFreeMarker(pMission,strMarker);
                pMission.AddMarker(strMarker,nMarker,nX,nY,0,0,"");
 //               TRACE("%s %d added                       \n",strMarker,nMarker);
            }
            
            pMission.SetAttribute("EnemiesCreated",0);
        
        }                
    }

}

//======================================        
// hero location

function void AddHeroLocation(int nHero, int nTargetHero) {

    int i;
    int nX;
    int nY;
    stringW strName;
    mission pMission;
    
    nX = GetHero(nHero).GetLocationX();
    nY = GetHero(nHero).GetLocationY();
    strName = GetPlayerInterface(nHero).GetPlayerName();
    pMission = GetHero(nHero).GetMission();
    
    if (nTargetHero != -1) {
        if (nTargetHero != nHero) GetPlayerInterface(nTargetHero).AddCampaignLocation(eHeroLocationStart + nHero,strName,eMapSignYellow,eMapSignYellow,pMission,nX,nY);    
        return;
    }
    
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        if (nHero == i) continue;
        GetPlayerInterface(i).AddCampaignLocation(eHeroLocationStart + nHero,strName,eMapSignYellow,eMapSignYellow,pMission,nX,nY);
    }

    anHeroLocation[nHero] = true;

}

function void AddHeroLocation(int nHero) {

    AddHeroLocation(nHero,-1);
    
}

function void RemoveHeroLocation(int nHero) {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        if (nHero == i) continue;
        GetPlayerInterface(i).RemoveCampaignLocation(eHeroLocationStart + nHero);
    }

    anHeroLocation[nHero] = false;

}

function void UpdateHeroLocation(int nHero) {

    int i;
    int nX;
    int nY;
    mission pMission;
    
    nX = GetHero(nHero).GetLocationX();
    nY = GetHero(nHero).GetLocationY();
    pMission = GetHero(nHero).GetMission();
    
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        if (nHero == i) continue;
        GetPlayerInterface(i).SetCampaignLocationPosition(eHeroLocationStart + nHero,pMission,nX,nY);
    }

}

function void UpdateHeroLocations() {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i) && anHeroLocation[i]) RemoveHeroLocation(i);
        else if (IsPlayer(i)) {
            if (!anHeroLocation[i]) AddHeroLocation(i);
            else UpdateHeroLocation(i);
        }    
    }
    for (i = GetPlayersCnt(); i < eMaxPlayers; i++) {
        if (anHeroLocation[i]) RemoveHeroLocation(i);
    }

}

function void AddHeroLocations(int nTargetHero) {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (IsPlayer(i) && anHeroLocation[i]) AddHeroLocation(i,nTargetHero);
    }
    
}

//======================================        
// bring object locations

function void AddBringObjectLocation(int nQuestNum, string strObject, int nX, int nY) {

    anBOLQuest.Add(nQuestNum);
    astrBOLName.Add(strObject);
    anBOLPosX.Add(nX);
    anBOLPosY.Add(nY);
    anBOLHero.Add(0);

    nCurrentBringObjectLocation = anBOLQuest.GetSize();

}

function void ShowBringObjectLocations(int nQuestNum, int nHero) {

    int i;
    string str;
    mission pMission;

    pMission = GetCampaign().GetMission(anQuestMission[nQuestNum]);
    for (i = 0; i < nCurrentBringObjectLocation; i++) if (anBOLQuest[i] == nQuestNum) {
        str.Format("translate%s",GetRealObjectName(astrBOLName[i]));
        GetPlayerInterface(nHero).AddCampaignLocation(eBringObjectLocationStart + i,str,eMapSignBlue,eMapSignBlue,pMission,anBOLPosX[i],anBOLPosY[i]);    
        anBOLHero[i] |= (1 << nHero);
    }

}

function void HideBringObjectLocations(int nQuestNum, int nHero) {

    int i;
    for (i = 0; i < nCurrentBringObjectLocation; i++) 
        if ((anBOLQuest[i] == nQuestNum) && (anBOLHero[i] & (1 << nHero))) {
            GetPlayerInterface(nHero).RemoveCampaignLocation(eBringObjectLocationStart + i);    
            anBOLHero[i] &= (~(1 << nHero));
        }

}

function void HideBringObjectLocationToAllHeroes(int nLocation) {

    int i;
    for (i = 0; i < eMaxPlayers; i++) {
        if (IsPlayer(i) && (anBOLHero[nLocation] & (1 << i))) {
            GetPlayerInterface(i).RemoveCampaignLocation(eBringObjectLocationStart + nLocation);    
        }
    }

    anBOLHero[nLocation] = 0;

}

function int IsBringObjectLocationEmpty(int nLocation) {

    mission pMission;
    pMission = GetCampaign().GetMission(0);
    
    pMission.SearchObjectsInArea(anBOLPosX[nLocation],anBOLPosY[nLocation],eActionObjectCreateRangeA,astrBOLName[nLocation]);
    if (pMission.GetSearchUnitsInAreaCount()) {    
        pMission.ClearSearchUnitsInAreaArray();
        return false;
    }
    pMission.ClearSearchUnitsInAreaArray();
    return true;
    
}

function void CheckBringObjectLocations() {

    int i;
    int nHero;
    
    for (i = 0; i < nCurrentBringObjectLocation; i++) if (anBOLHero[i] != 0) {
        if (IsBringObjectLocationEmpty(i)) HideBringObjectLocationToAllHeroes(i);    
    }

}

//======================================        
// main quest

function stringW FormatMainQuestInfo() {

    stringW str;
    
    str.Translate(MAIN_QUEST_INFO);
    str.Format(str,nNextMapActivationLevel,nClosedQuests,nNextMapActivationLevel - nClosedQuests);
        
    return str;

}

function stringW FormatTranslateMainQuest() {

    stringW strText;
    stringW strMission;
    stringW strSpace;
    string str;
    
    str.Format("translate%s",strNextMapName);
    strMission.Translate(str);
    strSpace.Copy(" ");
    
    strText.Translate(MAIN_QUEST_CONSOLE);
    strText.Append(strSpace);
    strText.Append(strMission);

    return strText;

}

function void ActivateNextMap(unit uHero) {

    int nActivatedBefore;
    
    uHero.GetPlayersCommonAttribute(strNextMapName,nActivatedBefore);    
    if (nActivatedBefore) return;

    uHero.SetPlayersCommonAttribute(strNextMapName,true);
    // unlockowanie miast
    if (strNextMapName.EqualNoCase("Net_M_03")) uHero.SetPlayersCommonAttribute("Net_T_02",true);    
    if (strNextMapName.EqualNoCase("Net_M_09")) uHero.SetPlayersCommonAttribute("Net_T_03",true);
    
    QuestConsoleTextOut(uHero.GetHeroPlayerNum(),FormatTranslateMainQuest());
    GetPlayerInterface(uHero.GetHeroPlayerNum()).PlayWave("QUEST_SOLVED");
    
}

function void InitMainQuest(unit uHero) {

#ifndef _XBOX

    stringW strDescription;
    string strGroup;   
    int nState;     

    if (nNextMapActivationLevel == 0 || strNextMapName.EqualNoCase("")) return;

    strGroup.Format("translate%s",GetMissionName());

    if (nClosedQuests < nNextMapActivationLevel) {
        strDescription = FormatMainQuestInfo();
        nState = eQuestStateActive;
    }
    else {
        strDescription.Copy(MAIN_QUEST_CLOSED);
        ActivateNextMap(uHero);
        nState = eQuestStateSolved;
    }
    
    GetPlayerInterface(uHero.GetHeroPlayerNum()).AddQuest(0,eQuestsNum,MAIN_QUEST_NAME,strDescription,strDescription,-1,-1,GetCampaign().GetMission(0),-1,-1,nState);
    GetPlayerInterface(uHero.GetHeroPlayerNum()).SetQuestsDirTitle(0,strGroup);
        
#endif        
        
}

function void UpdateMainQuest(unit uHero) {

#ifndef _XBOX

    stringW strDescription;
    int nState;

    if (nNextMapActivationLevel == 0 || strNextMapName.EqualNoCase("")) return;

    if (nClosedQuests < nNextMapActivationLevel) {
        strDescription = FormatMainQuestInfo();
        nState = eQuestStateActive;
    }
    else if (nClosedQuests == nNextMapActivationLevel) {
        strDescription.Copy(MAIN_QUEST_CLOSED);
        ActivateNextMap(uHero);
        nState = eQuestStateSolved;
    }
    else return;
            
    GetPlayerInterface(uHero.GetHeroPlayerNum()).SetQuestTooltipDescription(eQuestsNum,strDescription);
    GetPlayerInterface(uHero.GetHeroPlayerNum()).SetQuestDescription(eQuestsNum,strDescription);
    GetPlayerInterface(uHero.GetHeroPlayerNum()).SetQuestState(eQuestsNum,nState);
                
#endif
            
}

function void StartMainQuest() {

#ifndef _XBOX

    int i;
    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i)) InitMainQuest(GetHero(i));

#endif

}

function void UpdateClosedQuests() {

#ifndef _XBOX

    int i;
    nClosedQuests++;
    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i)) UpdateMainQuest(GetHero(i));

#endif

}

//======================================        

#define QM(mis,mar) (((mis) << 16) | ((mar) & 0xffff))
#define QM2MIS(qm) ((qm) >> 16)
#define QM2MAR(qm) ((qm) & 0xffff)

//======================================        

function void GetQuestActions(int nQuestNum, int nType, int anActions[]) {

    int i;
    for (i = 0; i < nCurrentAction; i++) 
            if (anActionQuest[i] == nQuestNum && anActionType[i] == nType) anActions.Add(i);

}

function void GetQuestActions(int nQuestFirst, int nQuestLast, int nType, int anActions[]) {

    int nQuestNum;    
    for (nQuestNum = nQuestFirst; nQuestNum <= nQuestLast; nQuestNum++) GetQuestActions(nQuestNum,nType,anActions);

}

//======================================        

function void PrepareQuests(int nFirst, int nLast, int anQuests[]) {
    
    int i;
    anQuests.RemoveAll();
    for (i = nFirst; i <= nLast; i++) 
        if (anQuestFlags[i] & eQuestLoaded) {
            if (anQuestReputationLevel[i] > nHeroesAvgLevel) continue;
            if (!CanAddQuest(i)) continue;
            anQuestReputationLevel[i] = 0;
            anQuests.Add(i);
        }

}

function void PrepareQuestMarkers(string strMarker, int anMarkers[]) {

    int i;
    int nMax;
    int nMission;
    mission pMission;
    
    anMarkers.RemoveAll();
    for (nMission = 0; nMission < GetCampaign().GetMissionsCnt(); nMission++) {
        pMission = GetCampaign().GetMission(nMission);
        nMax = pMission.GetMaxMarkerNum(strMarker);
        for (i = 1; i <= nMax; i++)
            if (pMission.HaveMarker(strMarker,i)) anMarkers.Add(QM(nMission,i));    
    }

}

function void InitQuestGenerator() {

    nHeroesAvgLevel = GetHeroesAvgLevel();

    PrepareQuestMarkers(MARKER_QUEST_GIVER_MULTI,anQuestGiversMarkers);

    PrepareQuests(eQuestKillFirst,eQuestKillLast,anQuestsKill);
    PrepareQuestMarkers(MARKER_QUEST_MULTI_KILL,anQuestsKillMarkers);    
    PrepareQuests(eQuestKillUndeadFirst,eQuestKillUndeadLast,anQuestsKillUndead);    
    PrepareQuestMarkers(MARKER_QUEST_MULTI_KILL_UNDEAD,anQuestsKillUndeadMarkers);    
    PrepareQuests(eQuestBringObjectFirst,eQuestBringObjectLast,anQuestsBringObject);
    PrepareQuestMarkers(MARKER_QUEST_MULTI_BRING_OBJECT,anQuestsBringObjectMarkers);    
    
    GetQuestActions(eQuestCreateEnemyFirst,eQuestCreateEnemyLast,eActionEnemyCreate,anActionsCreateEnemy);
    GetQuestActions(eQuestCreateEnemyUndeadFirst,eQuestCreateEnemyUndeadLast,eActionEnemyCreate,anActionsCreateEnemyUndead);
        
}

function void DeInitQuestGenerator() {

    anQuestGiversMarkers.RemoveAll();
    
    anQuestsKill.RemoveAll();
    anQuestsKillMarkers.RemoveAll();
    anQuestsKillUndead.RemoveAll();
    anQuestsKillUndeadMarkers.RemoveAll();
    anQuestsBringObject.RemoveAll();
    anQuestsBringObjectMarkers.RemoveAll();

    anQuestTypes.RemoveAll();

    anActionsCreateEnemy.RemoveAll();
    anActionsCreateEnemyUndead.RemoveAll();

}

//======================================        

function int ChooseQuestMultiType(int &nQuestsKill, int &nQuestsKillUndead, int &nQuestsBringObject) {

    int n;
    int anTypes[];
    
    if (nQuestsKill > 0) anTypes.Add(eQuestMultiKill);
    if (nQuestsKillUndead > 0) anTypes.Add(eQuestMultiKillUndead);
    if (nQuestsBringObject > 0) anTypes.Add(eQuestMultiBringObject);
    
    if (anTypes.GetSize() == 0) return eQuestMultiUnknownType;
    
    n = anTypes[Rand(anTypes.GetSize())];
    if (n == eQuestMultiKill) nQuestsKill--;
    if (n == eQuestMultiKillUndead) nQuestsKillUndead--;
    if (n == eQuestMultiBringObject) nQuestsBringObject--;

    anTypes.RemoveAll();
    return n;       

}

function void InitQuestTypes() {

    int nQuestGivers;
    int nQuestsKill;
    int nQuestsKillUndead;
    int nQuestsBringObject;
    int nQuestsLeft;
    int nType;

    nQuestGivers = anQuestGiversMarkers.GetSize();

    nQuestsKill = MIN(anQuestsKill.GetSize(),anQuestsKillMarkers.GetSize());
    nQuestsKillUndead = MIN(anQuestsKillUndead.GetSize(),anQuestsKillUndeadMarkers.GetSize());
    nQuestsBringObject = MIN(anQuestsBringObject.GetSize(),anQuestsBringObjectMarkers.GetSize());  

#ifdef QUESTS_MULTI_DEBUG
    TRACE("nQuestsKill %d nQuestKillUndead %d nQuestsBringObject %d                \n",nQuestsKill,nQuestsKillUndead,nQuestsBringObject);
#endif

    nTotalQuests = MIN(nQuestGivers,nQuestsKill + nQuestsKillUndead + nQuestsBringObject);    
#ifdef QUESTS_MULTI_DEBUG
    TRACE("nTotalQuests before: %d             \n",nTotalQuests);
#endif
    if (nTotalQuests > nQuestsMultiMax) nTotalQuests = nQuestsMultiMin + Rand(nQuestsMultiMax - nQuestsMultiMin);
#ifdef QUESTS_MULTI_DEBUG
    TRACE("nTotalQuests after: %d             \n",nTotalQuests);
#endif

    anQuestTypes.RemoveAll();
    nQuestsLeft = nTotalQuests;
    
    while (nQuestsLeft) {
    
        nType = ChooseQuestMultiType(nQuestsKill,nQuestsKillUndead,nQuestsBringObject);
        if (nType == eQuestMultiUnknownType) break;
        anQuestTypes.Add(nType);
        nQuestsLeft--;
    
    }
    
    nTotalQuests = anQuestTypes.GetSize();
    
}

function int ChooseFromArray(int anArray[]) {

    if (anArray.GetSize()) return anArray[Rand(anArray.GetSize())];
    return -1;

}

function void SetItemChosen(int anArray[], int nItem) {

    int i;
    for (i = 0; i < anArray.GetSize(); i++)
        if (anArray[i] == nItem) {
            anArray.RemoveAt(i);
            return;
        }

}

function int ChooseQuestValues(int &nType, int &nGiverMarker, int &nQuest, int &nQuestMarker) {

    nType = ChooseFromArray(anQuestTypes);

    nGiverMarker = ChooseFromArray(anQuestGiversMarkers);
    
    if (nType == eQuestMultiKill) {
        nQuest = ChooseFromArray(anQuestsKill);
        nQuestMarker = ChooseFromArray(anQuestsKillMarkers);        
    }
    else if (nType == eQuestMultiKillUndead) {
        nQuest = ChooseFromArray(anQuestsKillUndead);
        nQuestMarker = ChooseFromArray(anQuestsKillUndeadMarkers);        
    }
    else if (nType == eQuestMultiBringObject) {
        nQuest = ChooseFromArray(anQuestsBringObject);
        nQuestMarker = ChooseFromArray(anQuestsBringObjectMarkers);        
    }
    else {
        __ASSERT_FALSE();
        nQuest = -1;
        nQuestMarker = -1;
    }    

    if (nType == -1 || nGiverMarker == -1 || nQuest == -1 || nQuestMarker == -1) {
#ifdef QUESTS_MULTI_DEBUG
        TRACE("ChooseQuestValues returned false: nType %d mGiver %d nGiverMarker %d nQuest %d nQuestMarker %d             \n",nType,nGiver,nGiverMarker,nQuest,nQuestMarker);
#endif
        return false;
    }
    return true;

}

function void SetQuestValuesChosen(int nType, int nGiverMarker, int nQuest, int nQuestMarker) {

    SetItemChosen(anQuestTypes,nType);
    SetItemChosen(anQuestGiversMarkers,nGiverMarker);
    if (nType == eQuestMultiKill) {
        SetItemChosen(anQuestsKill,nQuest);
        SetItemChosen(anQuestsKillMarkers,nQuestMarker);
    }
    else if (nType == eQuestMultiKillUndead) {
        SetItemChosen(anQuestsKillUndead,nQuest);
        SetItemChosen(anQuestsKillUndeadMarkers,nQuestMarker);
    }
    else if (nType == eQuestMultiBringObject) {
        SetItemChosen(anQuestsBringObject,nQuest);
        SetItemChosen(anQuestsBringObjectMarkers,nQuestMarker);
    }
    else {
        __ASSERT_FALSE();
    }

}

//======================================        

function void GenerateQuestGiver(int nGiver, int nGiverMarker, int nQuestNum) {

    mission pMission;
    int nX, nY;

    anUnitNumber[nGiver] = QM2MAR(nGiverMarker);
    anUnitMission[nGiver] = QM2MIS(nGiverMarker);
    anUnitNameTranslate[nGiver] = GetMultiQuestGiverNameTranslate(IsQuestGiverMale(nQuestNum));  

#ifdef QUESTS_MULTI_DEBUG
    TRACE("QuestGiver %s generated, number %d marker %d        \n",astrUnitName[nGiver],nGiver,anUnitNumber[nGiver]);
#endif

    pMission = GetCampaign().GetMission(anUnitMission[nGiver]);
    if (pMission.GetMarker(MARKER_QUEST_GIVER_MULTI,anUnitNumber[nGiver],nX,nY)) {
        pMission.AddMarker(MARKER_QUEST_START,anUnitNumber[nGiver],nX,nY,0,0,"");
        pMission.AddMarker(MARKER_Q_FINDCHAIR,anUnitNumber[nGiver],nX,nY,0,0,"");
    }
    else {
        __ASSERT_FALSE();
    }
       
}

function int GenerateQuestKill(int nQuestNum, string strMarker) {

    int i;
    mission pMission;
    int nX, nY;
    int anActions[];
    int nMarker;
    
    pMission = GetCampaign().GetMission(anQuestMission[nQuestNum]);
    pMission.GetMarker(strMarker,anQuestMarker[nQuestNum],nX,nY);

    nMarker = GetNextFreeMarker(pMission,MARKER_QUEST_CLEAR_AREA);
    anQuestMarker[nQuestNum] = nMarker;
    pMission.AddMarker(MARKER_QUEST_CLEAR_AREA,nMarker,nX,nY,0,0,"");
    pMission.AddMarker(MARKER_ACTION_CREATE_ENEMY,nMarker,nX,nY,0,0,"");
    
    GetQuestActions(nQuestNum,eActionEnemyCreate,anActions);
    for (i = 0; i < anActions.GetSize(); i++) {
        anActionMission[anActions[i]] = anQuestMission[nQuestNum];
        anActionMarker[anActions[i]] = nMarker;
    }

    return true;

}

function int GenerateQuestBringObject(int nQuestNum) {

    mission pMission;
    int nX, nY;
    int anActions[];
    int anActionsCreateEnemies[];
    int i, j, n;
    int anMarkers[];
    int nMission;
    int nMarker;

    GetQuestActions(nQuestNum,eActionObjectCreate,anActions);        
    GetQuestActions(nQuestNum,eActionEnemyCreate,anActionsCreateEnemies);
        
    // sprawdzamy, czy jest wystarczajaco miejsca na generowane przemioty
    if (anActions.GetSize() > anQuestsBringObjectMarkers.GetSize()) return false; // nie mamy miejsca na tyle obiektow
    
    // wybieramy markery, na ktorych bedziemy generowali
    for (i = 0; i < anActions.GetSize(); i++) {
        n = ChooseFromArray(anQuestsBringObjectMarkers);
        if (n == -1) { // "zwracamy" wybrane markery
            for (i = 0; i < anMarkers.GetSize(); i++) anQuestsBringObjectMarkers.Add(anMarkers[i]);
            return false;
        }
        anMarkers.Add(n);
        SetItemChosen(anQuestsBringObjectMarkers,n);    
    }
    
    ASSERT(anMarkers.GetSize() == anActions.GetSize());
    
    for (i = 0; i < anActions.GetSize(); i++) {

        n = anMarkers[i];
        nMission = QM2MIS(n);
        nMarker = QM2MAR(n);        

        pMission = GetCampaign().GetMission(nMission);
        pMission.GetMarker(MARKER_QUEST_MULTI_BRING_OBJECT,nMarker,nX,nY);
        pMission.AddMarker(MARKER_ACTION_CREATE_OBJECT,nMarker,nX,nY,0,0,"");
        
        anActionParam1[anActions[i]] = anActionMarker[anActions[i]]; // przepisujemy ilosc generowanych obiektow z pola marker na pole param1
        anActionMission[anActions[i]] = nMission;
        anActionMarker[anActions[i]] = nMarker;

        AddBringObjectLocation(nQuestNum,astrActionString[anActions[i]],nX,nY);

        for (j = 0; j < anActionsCreateEnemies.GetSize(); j++) {
            if (anActionMarker[anActionsCreateEnemies[j]] == i + 1) {
                nMarker = GetNextFreeMarker(pMission,MARKER_ACTION_CREATE_ENEMY);
                pMission.AddMarker(MARKER_ACTION_CREATE_ENEMY,nMarker,nX,nY,0,0,"");
                anActionMission[anActionsCreateEnemies[i]] = nMission;
                anActionMarker[anActionsCreateEnemies[i]] = nMarker;
            }
        }

    }
    
    return true;
                   
}

function void GenerateQuest(int nType, int nQuest, int nQuestMarker) {

    int i;
    int nResult;

    anQuestMission[nQuest] = QM2MIS(nQuestMarker);
    anQuestMarker[nQuest] = QM2MAR(nQuestMarker);

#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d generated, type %d marker %d        \n",nQuest,nType,anQuestMarker[nQuest]);
#endif

    if (nType == eQuestMultiKill) {
        nResult = GenerateQuestKill(nQuest,MARKER_QUEST_MULTI_KILL);
    }
    if (nType == eQuestMultiKillUndead) {
        nResult = GenerateQuestKill(nQuest,MARKER_QUEST_MULTI_KILL_UNDEAD);
    }
    if (nType == eQuestMultiBringObject) {
        nResult = GenerateQuestBringObject(nQuest);
    }

    if (!nResult) return;
    
    for (i = 0; i < GetPlayersCnt(); i++) 
        if (IsPlayer(i)) EnableQuest(nQuest,GetHero(i));

}

function void DoActionsCreateEnemy(string strMarker, int anMarkers[], int anActions[]) {

    int nAction;
    int nMarker;
    int nMission;
    mission pMission;
    int nX, nY;
    int nTmpMarker;
    int nTmpMission;
    
    while (anMarkers.GetSize()) {
    
        nAction = ChooseFromArray(anActions);
        if (nAction == -1) return;
    
        nMission = QM2MIS(anMarkers[0]);
        nMarker = QM2MAR(anMarkers[0]);
        
        pMission = GetCampaign().GetMission(nMission);
        pMission.GetMarker(strMarker,nMarker,nX,nY);
        nMarker = GetNextFreeMarker(pMission,MARKER_ACTION_CREATE_ENEMY);
        pMission.AddMarker(MARKER_ACTION_CREATE_ENEMY,nMarker,nX,nY,0,0,"");
        
        nTmpMission = anActionMission[nAction];
        nTmpMarker = anActionMarker[nAction];
        anActionMission[nAction] = nMission;
        anActionMarker[nAction] = nMarker;
        ActionEnemyCreate(nAction);
        anActionMission[nAction] = nTmpMission;
        anActionMarker[nAction] = nTmpMarker;
        
        anMarkers.RemoveAt(0);        
    
    }

}

function void GenerateQuests() {

    int nType;
    int nGiverMarker;
    int nQuest;
    int nQuestMarker;
    int nQuestsLeft;

    InitQuestGenerator();
    InitQuestTypes();

    nQuestsLeft = nTotalQuests;
    
    while (nQuestsLeft) {
    
        if (ChooseQuestValues(nType,nGiverMarker,nQuest,nQuestMarker)) {        
            GenerateQuestGiver(anQuestGiverMapping[nQuest],nGiverMarker,nQuest);
            GenerateQuest(nType,nQuest,nQuestMarker);
            SetQuestValuesChosen(nType,nGiverMarker,nQuest,nQuestMarker);
        }
        
        nQuestsLeft--;
    
    }                   
        
    DoActionsCreateEnemy(MARKER_QUEST_MULTI_KILL,anQuestsKillMarkers,anActionsCreateEnemy);        
    DoActionsCreateEnemy(MARKER_QUEST_MULTI_KILL_UNDEAD,anQuestsKillUndeadMarkers,anActionsCreateEnemyUndead);        
            
    DeInitQuestGenerator();    

}

//======================================        
// quest states

function void SetQuestState(int nQuestNum, int nHero, int nQuestState) {

    int i;

    if (nQuestState == eQuestStateDisabled) {
        anQuestState[nQuestNum] = eQuestStateDisabled;
    }
    else if (nQuestState == eQuestStateEnabled) {
        anQuestState[nQuestNum] = eQuestStateEnabled;    
    }
    else if (nQuestState == eQuestStateTaken) {
        anQuestState[nQuestNum] = eQuestStateEnabled;    
        SetQuestTakenByHero(nQuestNum,nHero);        
    }
    else if (nQuestState == eQuestStateSolved) {
        anQuestState[nQuestNum] = eQuestStateEnabled;       
        SetQuestSolvedByHero(nQuestNum,nHero);        
    }
    else if (nQuestState == eQuestStateClosed) {
        anQuestState[nQuestNum] = eQuestStateClosed;        
    }
    else if (nQuestState == eQuestStateFailed) {
        anQuestState[nQuestNum] = eQuestStateFailed;        
    }
    else if (nQuestState == eQuestStateDisabledEnd) {
        anQuestState[nQuestNum] = eQuestStateDisabledEnd;    
    }
    else {
        __ASSERT_FALSE();
    }    
       
}

function void SetQuestState(int nQuestNum, unit uHero, int nQuestState) {

    SetQuestState(nQuestNum,uHero.GetHeroPlayerNum(),nQuestState);
    
}

function int GetQuestState(int nQuestNum, int nHero) {

    int i;

    if (anQuestState[nQuestNum] == eQuestStateDisabled) {
        return eQuestStateDisabled;
    }
    else if (anQuestState[nQuestNum] == eQuestStateEnabled) {
        if (IsQuestSolvedByHero(nQuestNum,nHero)) return eQuestStateSolved;
        if (IsQuestTakenByHero(nQuestNum,nHero)) return eQuestStateTaken;
        return eQuestStateEnabled;
    }
    else if (anQuestState[nQuestNum] == eQuestStateClosed) {
        return eQuestStateClosed;
    }
    else if (anQuestState[nQuestNum] == eQuestStateFailed) {
        return eQuestStateFailed;
    }
    else if (anQuestState[nQuestNum] == eQuestStateDisabledEnd) {
        return eQuestStateDisabledEnd;    
    }
    
    __ASSERT_FALSE();

    return eQuestStateDisabled;
    
}

function int GetQuestState(int nQuestNum, unit uHero) {

    return GetQuestState(nQuestNum,uHero.GetHeroPlayerNum());
    
}

function int IsQuestDisabled(int nQuestNum) {

    int i;
    int nQuestState;
    
    if (anQuestState[nQuestNum] == 0) return true;

    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        nQuestState = GetQuestState(nQuestNum,i);
        if (nQuestState != eQuestStateDisabled && nQuestState != eQuestStateDisabledEnd) return false;        
        
    }
    
    return true;
    
}

function int IsQuestMoreAdvancedThan(int nQuestNum, int nLastQuest) {

    int i;
    int nQuestMax;
    int nLastMax;
    int nState;
    
    nQuestMax = eQuestStateDisabled;
    nLastMax = eQuestStateDisabled;
    
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        nState = GetQuestState(nQuestNum,i);
        if (nState > nQuestMax) nQuestMax = nState;
        nState = GetQuestState(nLastQuest,i);
        if (nState > nLastMax) nLastMax = nState;
    }

    if (nQuestMax > nLastMax) return true;
    return false;
    
}

//======================================        
// quest dialog state

function void SetQuestDialogState(int nQuestNum, int nHero, int nQuestDialogState) {

    int nValue;
    if (!IsPlayer(nHero)) return;
    nValue = anQuestDialogState[nQuestNum];
    SetFlagAtPosition(nValue,nHero,nQuestDialogState);
    anQuestDialogState[nQuestNum] = nValue;

}

function void SetQuestDialogState(int nQuestNum, unit uHero, int nQuestDialogState) {

    SetQuestDialogState(nQuestNum,uHero.GetHeroPlayerNum(),nQuestDialogState);

}

function int GetQuestDialogState(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return 0;
    return GetFlagAtPosition(anQuestDialogState[nQuestNum],nHero);

}

function int GetQuestDialogState(int nQuestNum, unit uHero) {

    return GetQuestDialogState(nQuestNum,uHero.GetHeroPlayerNum());

}
/*
function void SetQuestLevel(int nQuestNum, int nHero, int nQuestLevel) {

    int nValue;
    if (!IsPlayer(nHero)) return;
    nValue = anQuestLevel[nQuestNum];
    SetFlagAtPosition(nValue,nHero,nQuestLevel);
    anQuestLevel[nQuestNum] = nValue;

}

function void SetQuestLevel(int nQuestNum, unit uHero, int nQuestLevel) {

    SetQuestLevel(nQuestNum,uHero.GetHeroPlayerNum(),nQuestLevel);
    
}

function int GetQuestLevel(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return eQuestInitialLevel;
    return GetFlagAtPosition(anQuestLevel[nQuestNum],nHero);

}

function int GetQuestLevel(int nQuestNum, unit uHero) {

    return GetQuestLevel(nQuestNum,uHero.GetHeroPlayerNum());

}
*/

//======================================        
// set quests

function void InitQuests() { 

    int i;    
  
    InitializeMapSigns();
  
    for (i = 0; i < eQuestsNum; i++) {

        anQuestState[i] = 0;
        anQuestType[i] = eQuestTypeUnknown;
        anQuestMission[i] = eNoMission;
        anQuestFlags[i] = eAutoCloseOnSolve;
        anQuestLevel[i] = eQuestInitialLevel;
        anQuestGiverMapping[i] = eNoMapping;
        anQuestGiverType[i] = eQuestNoGiver;
        anQuestTakenFlag[i] = 0;
        anQuestSolvedFlag[i] = 0;
        anQuestReputationGuild[i] = eNoGuild;
        anQuestReputationLevel[i] = -1;        
    }

}

//======================================        

function int GetFirstQuestHero(int nQuestHeroFlag) {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++) 
        if (IsPlayer(i))
            if (nQuestHeroFlag & (1 << i)) return i;
    return eNoUnit;

}

function void SetQuestTakenByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return;
    nHero = (1 << nHero);
    anQuestTakenFlag[nQuestNum] |= nHero;

}

function void SetQuestTakenByHero(int nQuestNum, unit uHero) {

    SetQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function void ResetQuestTakenByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return;
    nHero = ~(1 << nHero);
    anQuestTakenFlag[nQuestNum] &= nHero;

}

function void ResetQuestTakenByHero(int nQuestNum, unit uHero) {

    ResetQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function int IsQuestTakenByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return false;
    nHero = (1 << nHero);
    if (anQuestTakenFlag[nQuestNum] & nHero) return true;
    return false;

}

function int IsQuestTakenByHero(int nQuestNum, unit uHero) {

    return IsQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function void SetQuestSolvedByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return;
    nHero = (1 << nHero);
    anQuestSolvedFlag[nQuestNum] |= nHero;

}

function void SetQuestSolvedByHero(int nQuestNum, unit uHero) {

    SetQuestSolvedByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function void ResetQuestSolvedByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return;
    nHero = ~(1 << nHero);
    anQuestSolvedFlag[nQuestNum] &= nHero;

}

function void ResetQuestSolvedByHero(int nQuestNum, unit uHero) {

    ResetQuestSolvedByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function int IsQuestSolvedByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return false;
    nHero = (1 << nHero);
    if (anQuestSolvedFlag[nQuestNum] & nHero) return true;
    return false;

}

function int IsQuestSolvedByHero(int nQuestNum, unit uHero) {

    return IsQuestSolvedByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

//======================================        

function void CloseQuest(int nQuestNum, unit uHero, int nDoActions);

function void CloseQuestAllHeroes(int nQuestNum, int nHero) {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i) && i != nHero) 
            if (IsQuestTakenByHero(nQuestNum,nHero)) CloseQuest(nQuestNum,GetHero(i),false);
            else RemoveQuestGiverLocation(nQuestNum,i);
        
}

function void FailQuestAllHeroes(int nQuestNum, int nHero) {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i) && i != nHero) FailCloseQuest(nQuestNum,GetHero(i));
        
}

//======================================        

function void AddQuestGiverLocation(int nQuestNum, int nHero) {

    mission pMission;
    int nX, nY;
    int nLocation;
    string str;
    
    pMission = GetQuestUnitMission(anQuestGiverMapping[nQuestNum]);
    GetQuestUnitPosition(anQuestGiverMapping[nQuestNum],nX,nY);
    nLocation = nLocationsNum + anQuestGiverMapping[nQuestNum];
    str.Format(QUEST_GIVER_MULTI_NAME,anUnitNameTranslate[anQuestGiverMapping[nQuestNum]]);

    GetPlayerInterface(nHero).AddCampaignLocation(nLocation,str,eMapSignGreen,eMapSignGreen,pMission,nX,nY);

}

function void RemoveQuestGiverLocation(int nQuestNum, int nHero) {

    int nLocation;
//    if (nQuestNum == eNoQuest) return;
    nLocation = nLocationsNum + anQuestGiverMapping[nQuestNum];
  /*  if (GetPlayerInterface(nHero).FindCampaignLocation(nLocation))*/ GetPlayerInterface(nHero).RemoveCampaignLocation(nLocation);

}

function void RemoveQuestGiverLocation(unit uUnit) {

    int i;
    int nQuestNum;

    nQuestNum = GetCurrentQuest(uUnit);
    if (nQuestNum == eNoQuest) return;

    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i)) RemoveQuestGiverLocation(nQuestNum,i);

}

//======================================        

function void PromoteQuest(int nQuestNum, unit uHero) {

    ASSERT(uHero != null);

    if (GetQuestState(nQuestNum,uHero) != eQuestStateDisabled) return;

    anQuestLevel[nQuestNum] += 1;
    if (anQuestLevel[nQuestNum] >= anQuestEnableLevel[nQuestNum]) EnableQuest(nQuestNum,uHero);

}

function void EnableQuest(int nQuestNum, unit uHero) {

    if (GetQuestState(nQuestNum,uHero) > eQuestStateEnabled) return;
     
    SetQuestState(nQuestNum,uHero,eQuestStateEnabled);
    if (anQuestGiverType[nQuestNum] == eQuestNoGiver) {
        TakeQuest(nQuestNum,uHero);
    }
    else {
        ActivateQuestGiver(nQuestNum);        
    }
    
    GiveQuestReward(nQuestNum,eWhenQuestEnabled,uHero);        
    if ((anQuestFlags[nQuestNum] & eEnableActionsDone) == 0) {
        DoQuestAction(nQuestNum,eWhenQuestEnabled,uHero.GetMission().GetMissionNum(),uHero);        
        anQuestFlags[nQuestNum] |= eEnableActionsDone;
    }
    ActivateQuests(nQuestNum,eWhenQuestEnabled,uHero);    
    
    AddQuestGiverLocation(nQuestNum,uHero.GetHeroPlayerNum());

#ifdef QUESTS_MULTI_DEBUG
     TRACE("Quest %d enabled for hero %d            \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

}

function void DisableQuest(int nQuestNum, unit uHero) {

    int i;
    int nMapping;

    if (GetQuestState(nQuestNum,uHero) == eQuestStateDisabledEnd) return;

    for (i = 0; i < GetPlayersCnt(); i++) 
        if (IsPlayer(i)) {
            if (GetQuestState(nQuestNum,i) > eQuestStateDisabled) RemoveQuestFromMap(nQuestNum,GetHero(i));
        }

    SetQuestState(nQuestNum,uHero,eQuestStateDisabledEnd);                 
    anQuestLevel[nQuestNum] = -100;

    if (anQuestGiverMapping[nQuestNum] != eNoMapping) {
        nMapping = anQuestGiverMapping[nQuestNum];
        if (DeactivateQuestGiver(nQuestNum)) {
            ActivateQuestGiverMapping(nMapping);
        }
    }

#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d disabled by hero %d                                  \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

}

function void TakeQuest(int nQuestNum, unit uHero) {

    ASSERT(uHero != null);

    if (GetQuestState(nQuestNum,uHero) == eQuestStateDisabled) EnableQuest(nQuestNum,uHero);
    if (GetQuestState(nQuestNum,uHero) != eQuestStateEnabled) return;

    SetQuestState(nQuestNum,uHero,eQuestStateTaken);

    // uwaga!!! te funkcje musza byc wywolywane w takiej kolejnosci, zeby nie bylo kolizji numerow lokacji questa underground i givera
    RemoveQuestGiverLocation(nQuestNum,uHero.GetHeroPlayerNum());
    ShowBringObjectLocations(nQuestNum,uHero.GetHeroPlayerNum());
    LogQuestTaken(nQuestNum,uHero);

    if (anQuestGiverMapping[nQuestNum] != eNoMapping) GiveQuestReward(nQuestNum,eWhenQuestTaken,uHero);
    DoQuestAction(nQuestNum,eWhenQuestTaken,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestTaken,uHero);

#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d taken by hero %d                                  \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

    
}

function void SolveQuest(int nQuestNum, unit uHero, int nDoActions) {

    ASSERT(uHero != null);

    // tutaj teoretycznie mozna dodac jeszcze
//    if (anQuestState[nQuestNum] == eQuestStateDisabled) EnableQuest(nQuestNum,uHero);
//    if (anQuestState[nQuestNum] == eQuestStateEnabled) TakeQuest(nQuestNum,uHero);
    if (GetQuestState(nQuestNum,uHero) != eQuestStateTaken) return;

    SetQuestState(nQuestNum,uHero,eQuestStateSolved);

    HideBringObjectLocations(nQuestNum,uHero.GetHeroPlayerNum());
     
    if (anQuestFlags[nQuestNum] & eBackToGiverMapSign) {
        LogQuestGoBack(nQuestNum,uHero);
    }
    else if (anQuestFlags[nQuestNum] & eBackToGiver) {
        LogQuestSolved(nQuestNum,uHero);
    }
    else {    // anQuestFlags[nQuestNum] & eAutoCloseOnSolve
        LogQuestSolved(nQuestNum,uHero);
        CloseQuest(nQuestNum,uHero);  
    }

    // uwaga!!!
    if (nDoActions) {
        if ((anQuestType[nQuestNum] != eQuestTypeKill) && (anQuestType[nQuestNum] != eQuestTypeFindAndKill)) GiveQuestReward(nQuestNum,eWhenQuestSolved,uHero);        
        DoQuestAction(nQuestNum,eWhenQuestSolved,uHero.GetMission().GetMissionNum(),uHero);
        ActivateQuests(nQuestNum,eWhenQuestSolved,uHero);
    }

#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d solved by hero %d                                  \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

}

function void SolveQuest(int nQuestNum, unit uHero) {

    SolveQuest(nQuestNum,uHero,true);

}

function void CloseQuest(int nQuestNum, unit uHero, int nDoActions) {

    unit uUnit;

    ASSERT(uHero != null);

    if (GetQuestState(nQuestNum,uHero) == eQuestStateDisabled) return;
    if (GetQuestState(nQuestNum,uHero) == eQuestStateEnabled) TakeQuest(nQuestNum,uHero);
    if (GetQuestState(nQuestNum,uHero) == eQuestStateTaken) SolveQuest(nQuestNum,uHero,nDoActions);
    if (GetQuestState(nQuestNum,uHero) != eQuestStateSolved) return;

    LogQuestClosed(nQuestNum,uHero);
         
    if (nDoActions) {                      
        CloseQuestAllHeroes(nQuestNum,uHero.GetHeroPlayerNum());
        GiveQuestReward(nQuestNum,eWhenQuestClosed,uHero);        
        DoQuestAction(nQuestNum,eWhenQuestClosed,uHero.GetMission().GetMissionNum(),uHero);
        ActivateQuests(nQuestNum,eWhenQuestClosed,uHero);
        UpdateClosedQuests();
    }

    SetQuestState(nQuestNum,uHero,eQuestStateClosed);
     
#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d closed by hero %d                                  \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

}

function void CloseQuest(int nQuestNum, unit uHero) {

    CloseQuest(nQuestNum,uHero,true);

}

function void FailCloseQuest(int nQuestNum, unit uHero) {

    unit uUnit;

    ASSERT(uHero != null);

    if (GetQuestState(nQuestNum,uHero) != eQuestStateTaken && GetQuestState(nQuestNum,uHero) != eQuestStateSolved) return;

    SetQuestState(nQuestNum,uHero,eQuestStateFailed);

    HideBringObjectLocations(nQuestNum,uHero.GetHeroPlayerNum());

    LogQuestFailed(nQuestNum,uHero);

    GiveQuestReward(nQuestNum,eWhenQuestFailed,uHero);        
    DoQuestAction(nQuestNum,eWhenQuestFailed,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestFailed,uHero);

    // uwaga!!! dodajemy tylko po to, zeby miec pewnosc, ze lokacja jest na mapie i nie leca asserty
    AddQuestGiverLocation(nQuestNum,uHero.GetHeroPlayerNum());
    RemoveQuestGiverLocation(nQuestNum,uHero.GetHeroPlayerNum());
 
#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d failed by hero %d                                   \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

}

//======================================        
// states

function void LoadQuests() {

    InitQuests();
    LoadQuests1("Scripts\\Quests\\TwoWorldsQuests.qtx");        
    LoadQuests2();        

}

state Initialize {

    int i;
    mission pMission;
    
    ENABLE_TRACE(true);
    TRACE("\n\n\n\n                                   \n");

    GetCampaign().CommandMessageGet(eMsgGetMissionName,strMissionName);

    AddResurrectsAsLocations();    
    AddManaRegsAsLocations();    
    AddCavesAsLocations();
    LoadQuests();
    
    for (i = 0; i < GetPlayersCnt(); i++) 
        if (IsPlayer(i)) {
//            GetHero(i).SetPlayersCommonAttribute("Net_M_09", true);  // test!!!
//            GetHero(i).SetPlayersCommonAttribute("Net_T_02",true);  // test!!!
//            GetHero(i).SetPlayersCommonAttribute("Net_T_03",true);  // test!!!  
            pMission = GetHero(i).GetMission();
            SetGatesNumbers(pMission);
            SetQuestGatesClickable(pMission,GetScriptUID());    
            RegisterQuestUnits(pMission);         
        }
    
    nQuestsOn = true;
            
    return GeneratingQuests, 0;

}

state GeneratingQuests {

    InitQuestGiversMultiNames();
    GenerateEnemies();
    GenerateQuests();
    StartMainQuest();
    SetTimer(0,30);
    SetTimer(1,5 * 30);

    return Nothing;

}

//======================================        

command Message(int nParam, int nValue1, int nValue2, int nValue3) {

    if (nParam == eMsgInitQuestsMulti) {

        nQuestsMultiMin = nValue1;
        nQuestsMultiMax = nValue2;
        nNextMapActivationLevel = nValue3;
        return true;

    }

    return 0;

}

command Message(int nParam, string strValue) {

    if (nParam == eMsgInitQuestsMulti) {
    
        strNextMapName = strValue;
        return true;        
    
    }

    return 0;

}

//======================================        

event Timer0() {

    UpdateHeroLocations();
    return true;

}

event CreatedNewNetworkPlayer(int nPlayerNum, int nMissionNum, int nX, int nY) {

    int i;
        
    InitMainQuest(GetHero(nPlayerNum));
    AddHeroLocations(nPlayerNum);
    for (i = 0; i < eQuestsNum; i++) 
        if (anQuestState[i] == eQuestStateEnabled) EnableQuest(i,GetHero(nPlayerNum));
    return true;

}

//======================================        

}
