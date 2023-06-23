global "PQuestsMulti16"
{

#define QS QS_MULTI16

state Initialize;
state StartingQuests;
state Nothing;

consts {

    eQuestsNum             = 100;
    eQuestUnitsNum         = 698;
    eHeroLocationStart     = 500;

}

#define QUESTS_MULTI_DEBUG

#define eFirstQuest GetFirstQuest()
#define eFirstQuestUnit GetFirstQuest()

//======================================        

function int GetQuestTakenFlag(int nIndex);
function string GetMissionName();

function void SetQuestSolvedByHero(int nQuestNum, int nHero);
//function void SetQuestSolvedByHero(int nQuestNum, unit uHero);

//function void CloseQuestAllHeroes(int nQuestNum, int nHero);
function void FailQuestAllHeroes(int nQuestNum, int nHero);

//function void RemoveQuestGiverLocation(int nQuestNum, int nHero);
//function void RemoveQuestGiverLocation(unit uUnit);

function void ActivateTeleports();

function int GetFirstQuest();

//======================================        

#include "PInc\\PQuestsCommon.ech"

//======================================        

int anQuestTakenFlag[eQuestsNum];
int anQuestSolvedFlag[eQuestsNum];
int nCurrentStartingQuest;
int nTeleportsActivated;

int anHeroLocation[eMaxPlayers];

int nFirstQuest;

string strMissionName;

//======================================        

function void InitFirstQuest()
{
    string strFirstQuest;
    GetMultiMissionInfoAttrib("FirstQuest", strFirstQuest);
    sscanf(strFirstQuest,"%d",nFirstQuest);    
}

function int GetFirstQuest()
{
    return nFirstQuest;
}


//======================================        

function string GetMissionName()
{
    return strMissionName;
}

function int GetQuestTakenFlag(int nIndex)
{
    return anQuestTakenFlag[nIndex];
}

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

//        pMission.CreateObject("ACTIVATE_TELEPORT",nX,nY,0,0);
        uTeleport.ActivateTeleport(true,true,25,25,"translateTEL_C02_0_1");
    
    }

}

function void ActivateTeleports() {

    if (nTeleportsActivated) return;
    if (GetCampaign().GetMission(0).IsLevelLoaded()) ActivateTeleports(GetCampaign().GetMission(0));    
    nTeleportsActivated = true;

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

//======================================        
// init quests

function void InitQuests() { 

    int i;    
  
    InitializeMapSigns();
  
    for (i = 0; i < eQuestsNum; i++) {

        anQuestState[i] = eQuestStateDisabled;
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

//    if (!IsPlayer(nHero)) return;
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

//    if (!IsPlayer(nHero)) return;
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
    unit uHero;
    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i) && i != nHero) {
            if (IsQuestTakenByHero(nQuestNum,i)) {
                /// 14.09.07         
                uHero = GetHero(i);
                SolveQuest(nQuestNum,uHero,true);
                if (GetQuestState(nQuestNum,uHero) != eQuestStateSolved) return;

                LogQuestClosed(nQuestNum,uHero);

                GiveQuestReward(nQuestNum,eWhenQuestClosed,uHero);        
                DoQuestAction(nQuestNum,eWhenQuestClosed,uHero.GetMission().GetMissionNum(),uHero);
                ActivateQuests(nQuestNum,eWhenQuestClosed,uHero);
            }
        }
        
}

function void FailQuestAllHeroes(int nQuestNum, int nHero) {

    int i;
    for (i = 0; i < GetPlayersCnt(); i++)
        if (IsPlayer(i) && i != nHero) FailCloseQuest(nQuestNum,GetHero(i));
        
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

    int i;

    ASSERT(uHero != null);

    if (GetQuestState(nQuestNum,uHero) == eQuestStateDisabled) EnableQuest(nQuestNum,uHero);
    if (GetQuestState(nQuestNum,uHero) != eQuestStateEnabled) return;

    SetQuestState(nQuestNum,uHero,eQuestStateTaken);

    // uwaga!!! te funkcje musza byc wywolywane w takiej kolejnosci, zeby nie bylo kolizji numerow lokacji questa underground i givera
    LogQuestTaken(nQuestNum,uHero);

    if (anQuestGiverMapping[nQuestNum] != eNoMapping) GiveQuestReward(nQuestNum,eWhenQuestTaken,uHero);
    DoQuestAction(nQuestNum,eWhenQuestTaken,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestTaken,uHero);

    for (i = 0; i < GetPlayersCnt(); i++)    
        if (IsPlayer(i) && i != uHero.GetHeroPlayerNum()) 
            TakeQuest(nQuestNum,GetHero(i));                

#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d taken by hero %d                                  \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif
    
}

function void SolveQuest(int nQuestNum, unit uHero, int nDoActions) {

    int i;

    ASSERT(uHero != null);

    // tutaj teoretycznie mozna dodac jeszcze
//    if (anQuestState[nQuestNum] == eQuestStateDisabled) EnableQuest(nQuestNum,uHero);
//    if (anQuestState[nQuestNum] == eQuestStateEnabled) TakeQuest(nQuestNum,uHero);
    if (GetQuestState(nQuestNum,uHero) != eQuestStateTaken) return;

    SetQuestState(nQuestNum,uHero,eQuestStateSolved);
     
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

    /// 14.09.07         
    GiveQuestReward(nQuestNum,eWhenQuestClosed,uHero);        
    DoQuestAction(nQuestNum,eWhenQuestClosed,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestClosed,uHero);
    CloseQuestAllHeroes(nQuestNum,uHero.GetHeroPlayerNum());

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

    LogQuestFailed(nQuestNum,uHero);

    GiveQuestReward(nQuestNum,eWhenQuestFailed,uHero);        
    DoQuestAction(nQuestNum,eWhenQuestFailed,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestFailed,uHero);
 
#ifdef QUESTS_MULTI_DEBUG
    TRACE("Quest %d failed by hero %d                                   \n",nQuestNum,uHero.GetHeroPlayerNum());
#endif

}

//======================================        
// states

function void LoadQuests() {

    string strQTXFilename;

    InitQuests();
    GetMultiMissionInfoAttrib("QTXFilename", strQTXFilename);
    LoadQuests1(strQTXFilename);        
    LoadQuests2();        

}

function void StartQuests(int first, int last) {

    int i;
    for (i = first; i < last; i++) if (anQuestFlags[i] & eQuestLoaded) {
        PromoteQuest(i,GetHero(0));
    }

}

state Initialize {
    
    int i;
    mission pMission;
    
    ENABLE_TRACE(true);
    TRACE("\n\n\n\n                                   \n");

    InitFirstQuest();

    GetCampaign().CommandMessageGet(eMsgGetMissionName,strMissionName);

    AddResurrectsAsLocations();    
    AddManaRegsAsLocations();
    LoadQuests();

    for (i = 0; i < GetPlayersCnt(); i++) 
        if (IsPlayer(i)) {
            pMission = GetHero(i).GetMission();
            SetGatesNumbers(pMission);
            SetQuestGatesClickable(pMission,GetScriptUID());    
            RegisterQuestUnits(pMission);         
        }

    nQuestsOn = true;
    nCurrentQuest = 0;

    SetTimer(1,5 * 30);
            
    return StartingQuests;

}

state StartingQuests {

    int next;
    
    next = MIN(eQuestsNum,nCurrentStartingQuest + 100);
    StartQuests(nCurrentStartingQuest,next);
    if (next == eQuestsNum) return Nothing;
    else {
        nCurrentStartingQuest = next;
        return state;
    }
    
}

//======================================        

event Timer0() {

    UpdateHeroLocations();
    return true;

}

event CreatedNewNetworkPlayer(int nPlayerNum, int nMissionNum, int nX, int nY) {
        
    AddHeroLocations(nPlayerNum);
    return true;

}

//======================================        

}
