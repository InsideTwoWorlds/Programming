global "PQuests"
{

#define QS QS_SINGLE

state Initialize;
state Initialize1;
state StartingQuests;
state Nothing;

consts {

    eFirstQuest            = 0;
    eQuestsNum             = 400;
    eFirstQuestUnit        = 0;
    eQuestUnitsNum         = 698;

}

#include "PInc\\PQuestsCommon.ech"

//======================================        

int anQuestHeroFlag[eQuestsNum];
int nCurrentStartingQuest;

//======================================        
// achievements

function void UpdateAchievements(int nQuestNum, unit uHero) {

    if (nQuestNum == 15 || nQuestNum == 16 || nQuestNum == 17 || nQuestNum == 18 || nQuestNum == 109)
    {
        GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindARelic,uHero); 
        GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindEarthElement,uHero); 
        GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindFireElement,uHero); 
        GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindWaterElement,uHero); 
        GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindAirElement,uHero); 
    }    

    if (nQuestNum == 15) GetCampaign().CommandMessage(eMsgAchievement,eAchievementDeliverAllElementsToQudinaar,uHero); 
    if (nQuestNum == 21) GetCampaign().CommandMessage(eMsgAchievement,eAchievementKillGandohar,uHero); 
    if (nQuestNum == 23) GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindARelic,uHero); 
    if (nQuestNum == 24) GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindEarthElement,uHero); 
    if (nQuestNum == 25) GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindFireElement,uHero); 
    if (nQuestNum == 26) GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindWaterElement,uHero); 
    if (nQuestNum == 27) GetCampaign().CommandMessage(eMsgAchievement,eAchievementFindAirElement,uHero); 
    
}

//======================================        
// quest states

function void SetQuestState(int nQuestNum, int nHero, int nQuestState) {

    anQuestState[nQuestNum] = nQuestState;
    
}

function void SetQuestState(int nQuestNum, unit uHero, int nQuestState) {

    SetQuestState(nQuestNum,0,nQuestState);
    
}

function int GetQuestState(int nQuestNum, int nHero) {

    return anQuestState[nQuestNum];
    
}

function int GetQuestState(int nQuestNum, unit uHero) {

    return GetQuestState(nQuestNum,0);
    
}

function int IsQuestDisabled(int nQuestNum) {

    if (anQuestState[nQuestNum] == eQuestStateDisabled || anQuestState[nQuestNum] == eQuestStateDisabledEnd) return true;
    return false;
    
}

function int IsQuestMoreAdvancedThan(int nQuestNum, int nLastQuest) {

    if (anQuestState[nQuestNum] > anQuestState[nLastQuest]) return true;
    return false;
    
}

//======================================        
// quest dialog state

function void SetQuestDialogState(int nQuestNum, int nHero, int nQuestDialogState) {

    anQuestDialogState[nQuestNum] = nQuestDialogState;

}

function void SetQuestDialogState(int nQuestNum, unit uHero, int nQuestDialogState) {

    SetQuestDialogState(nQuestNum,uHero.GetHeroPlayerNum(),nQuestDialogState);

}

function int GetQuestDialogState(int nQuestNum, int nHero) {

    return anQuestDialogState[nQuestNum];

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
        anQuestHeroFlag[i] = 0;
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
    anQuestHeroFlag[nQuestNum] |= nHero;
    
}

function void SetQuestTakenByHero(int nQuestNum, unit uHero) {

    SetQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function void ResetQuestTakenByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return;
    nHero = ~(1 << nHero);
    anQuestHeroFlag[nQuestNum] &= nHero;

}

function void ResetQuestTakenByHero(int nQuestNum, unit uHero) {

    ResetQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function int IsQuestTakenByHero(int nQuestNum, int nHero) {

    if (!IsPlayer(nHero)) return false;
    nHero = (1 << nHero);
    if (anQuestHeroFlag[nQuestNum] & nHero) return true;
    return false;

}

function int IsQuestTakenByHero(int nQuestNum, unit uHero) {

    return IsQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

// uwaga tutaj!!! IsSolved ustawia tylko flage oznaczajaca wziecie questa przez bohatera
// dodatkowo trzeba jeszcze sprawdzac QuestState

function void ResetQuestSolvedByHero(int nQuestNum, int nHero) {

    ResetQuestTakenByHero(nQuestNum,nHero);

}

function void ResetQuestSolvedByHero(int nQuestNum, unit uHero) {

    ResetQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

function int IsQuestSolvedByHero(int nQuestNum, int nHero) {

    return IsQuestTakenByHero(nQuestNum,nHero);

}

function int IsQuestSolvedByHero(int nQuestNum, unit uHero) {

    return IsQuestTakenByHero(nQuestNum,uHero.GetHeroPlayerNum());

}

//======================================        

function void PromoteQuest(int nQuestNum, unit uHero) {

    ASSERT(uHero != null);

    if (anQuestState[nQuestNum] != eQuestStateDisabled) return;

    anQuestLevel[nQuestNum] += 1;
    if (anQuestLevel[nQuestNum] >= anQuestEnableLevel[nQuestNum]) EnableQuest(nQuestNum,uHero);

}

function void EnableQuest(int nQuestNum, unit uHero) {

    if (anQuestState[nQuestNum] != eQuestStateDisabled) return;
    
    anQuestState[nQuestNum] = eQuestStateEnabled;
    if (anQuestGiverType[nQuestNum] == eQuestNoGiver) {
        TakeQuest(nQuestNum,uHero);
    }
    else {
        ActivateQuestGiver(nQuestNum);        
    }
    GiveQuestReward(nQuestNum,eWhenQuestEnabled,uHero);        
    DoQuestAction(nQuestNum,eWhenQuestEnabled,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestEnabled,uHero);    

}

function void DisableQuest(int nQuestNum, unit uHero) {

    int nMapping;

    if (anQuestState[nQuestNum] == eQuestStateDisabledEnd) return;

    if (anQuestState[nQuestNum] > eQuestStateEnabled) RemoveQuestFromMap(nQuestNum,uHero);
    anQuestState[nQuestNum] = eQuestStateDisabledEnd; 
    anQuestLevel[nQuestNum] = -100;

    if (anQuestGiverMapping[nQuestNum] != eNoMapping) {
        nMapping = anQuestGiverMapping[nQuestNum];
        if (DeactivateQuestGiver(nQuestNum)) {
            ActivateQuestGiverMapping(nMapping);
        }
    }

#ifdef QUEST_DEBUG
    TRACE("Quest %d disabled                                   \n",nQuestNum);
#endif

}

function void TakeQuest(int nQuestNum, unit uHero) {

#ifdef _DEMO
    stringW strMsg;
#endif    


    ASSERT(uHero != null);

    if (anQuestState[nQuestNum] == eQuestStateDisabled) EnableQuest(nQuestNum,uHero);
    if (anQuestState[nQuestNum] != eQuestStateEnabled) return;

    anQuestState[nQuestNum] = eQuestStateTaken;
    SetQuestTakenByHero(nQuestNum,uHero);

    LogQuestTaken(nQuestNum,uHero);

    if (anQuestGiverMapping[nQuestNum] != eNoMapping) GiveQuestReward(nQuestNum,eWhenQuestTaken,uHero);
    DoQuestAction(nQuestNum,eWhenQuestTaken,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestTaken,uHero);

#ifdef QUEST_DEBUG
    TRACE("Quest %d taken                                   \n",nQuestNum);
#endif
    
#ifdef _DEMO    
    if (nQuestNum == 117) {
        strMsg.Translate("translateGameOverDemo");
        GetPlayerInterface(uHero.GetHeroPlayerNum()).EndGame(strMsg);
    }                
#endif    
    
}

function void SolveQuest(int nQuestNum, unit uHero, int nDoActions) {

    ASSERT(uHero != null);

    // tutaj teoretycznie mozna dodac jeszcze
//    if (anQuestState[nQuestNum] == eQuestStateDisabled) EnableQuest(nQuestNum,uHero);
//    if (anQuestState[nQuestNum] == eQuestStateEnabled) TakeQuest(nQuestNum,uHero);
    if (anQuestState[nQuestNum] != eQuestStateTaken) return;

    UpdateAchievements(nQuestNum,uHero);

    anQuestState[nQuestNum] = eQuestStateSolved;
     
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
        GiveQuestReward(nQuestNum,eWhenQuestSolved,uHero);        
        DoQuestAction(nQuestNum,eWhenQuestSolved,uHero.GetMission().GetMissionNum(),uHero);
        ActivateQuests(nQuestNum,eWhenQuestSolved,uHero);
    }

#ifdef QUEST_DEBUG
    TRACE("Quest %d solved                                   \n",nQuestNum);
#endif

}

function void SolveQuest(int nQuestNum, unit uHero) {

    SolveQuest(nQuestNum,uHero,true);

}

function void CloseQuest(int nQuestNum, unit uHero) {

    unit uUnit;

    ASSERT(uHero != null);

    if (anQuestState[nQuestNum] == eQuestStateDisabled) return;
    if (anQuestState[nQuestNum] == eQuestStateEnabled) TakeQuest(nQuestNum,uHero);
    if (anQuestState[nQuestNum] == eQuestStateTaken) SolveQuest(nQuestNum,uHero);
    if (anQuestState[nQuestNum] != eQuestStateSolved) return;

    anQuestState[nQuestNum] = eQuestStateClosed;

    LogQuestClosed(nQuestNum,uHero);
                      
    GiveQuestReward(nQuestNum,eWhenQuestClosed,uHero);        
    DoQuestAction(nQuestNum,eWhenQuestClosed,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestClosed,uHero);
     
#ifdef QUEST_DEBUG
    TRACE("Quest %d closed                                   \n",nQuestNum);
#endif

}

function void FailCloseQuest(int nQuestNum, unit uHero) {

    unit uUnit;

    ASSERT(uHero != null);

    if (anQuestState[nQuestNum] <= eQuestStateEnabled) {
        DisableQuest(nQuestNum,uHero);
        return;
    }
    if (anQuestState[nQuestNum] >= eQuestStateClosed) {
        return;
    }

    anQuestState[nQuestNum] = eQuestStateFailed;

    LogQuestFailed(nQuestNum,uHero);

    GiveQuestReward(nQuestNum,eWhenQuestFailed,uHero);        
    DoQuestAction(nQuestNum,eWhenQuestFailed,uHero.GetMission().GetMissionNum(),uHero);
    ActivateQuests(nQuestNum,eWhenQuestFailed,uHero);
 
#ifdef QUEST_DEBUG
    TRACE("Quest %d failed                                   \n",nQuestNum);
#endif

}

//======================================        
// states

function void LoadQuests(int nMode) {

    if (nMode == 1) {
        InitQuests();
        LoadQuests1("Scripts\\Quests\\TwoWorldsQuests.qtx");        
    }
    if (nMode == 2) {
        LoadQuests2();        
    }

}

function void StartQuests(int first, int last) {

    int i;
    for (i = first; i < last; i++) if (anQuestFlags[i] & eQuestLoaded) {
        PromoteQuest(i,GetHero(0));
    }

}

state Initialize {
    
    ENABLE_TRACE(true);
    TRACE("\n\n\n\n                                   \n");

    AddResurrectsAsLocations();    
    AddManaRegsAsLocations();
    AddCavesAsLocations();
    LoadQuests(1);
    SetTimer(1,5 * 30);

    InitDangerousPlacesInMusicScript();
            
    return Initialize1;

}

state Initialize1 {

    int i;        
    mission pMission;

    LoadQuests(2);    

    for (i = 0; i < GetPlayersCnt(); i++) 
        if (IsPlayer(i)) {
            pMission = GetHero(i).GetMission();
            SetGatesNumbers(pMission);
            SetQuestGatesClickable(pMission,GetScriptUID());    
            RegisterQuestUnits(pMission);         
        }

    nQuestsOn = true;
    nCurrentQuest = 0;
    
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

}
