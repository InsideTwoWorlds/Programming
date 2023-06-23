global "PBandits"
{
    
#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Quest.ech"
#include "..\\..\\Common\\Levels.ech"
#include "..\\..\\Common\\CreateStrings.ech"
#include "..\\..\\Common\\UnitInfo.ech"
#include "PInc\\PEnums.ech"
#include "PInc\\PCommon.ech"
#include "PInc\\PUnitInfo.ech"
#include "PInc\\PGreetings.ech"

state Initialize;
state Nothing;

#define DIALOG_BANDIT1            "translateEVENT_4"
#define DIALOG_BANDIT2            "translateEVENT_5"
#define DIALOG_BANDIT_RESPECT1     "translateEVENT_6"
#define DIALOG_BANDIT_RESPECT2     "translateEVENT_7"

int nMaxNeutralBandits;
int nCurrentNeutralBandits;

//======================================        

consts {
    
    eNoBanditGroupID                = -1;
    
    eHeroProcessedTime              = 20 * 60 * 30;
    eBanditWarningsTime             = 30 * 3;
    
    eGroupStateNotCreated           = -1;
    eGroupStateNothing              = 0;
    eGroupStateActive               = 1;
    
    eBanditDialogRangeA             = 512;
    eHeroToBanditsRangeA            = 2048;
    eSameTargetHeroRangeA           = M2A(30);
    eCreateBanditsRangeA            = 1024;
    eBanditWarningsRangeA           = 1200;
    eBanditsTooFarFromMarkerRangeA  = 1800;

    eMaxAngleToChasedHero           = 4;
    eMaxKilledBandits               = 30;
    eMaxBanditWorkMarkers           = 20;

    // dialog flags
    eBPay100                        = 1;
    eBPay200                        = 2;
    eBPay500                        = 4;
    eBPay1000                       = 8;
    eBPay5000                       = 16;
    eBPay10000                      = 32;
    eBPay30000                      = 64;
    eBNoMoney                       = 128;
    eBScared                        = 32768;
    eBNotScared                     = 65536;
    eBHasInventory                  = 2048;
    eBHasntInventory                = 4096;
    eBDialogInputFlags              = 104703;
    eBPayMoney                      = 256;
    eBFight                         = 17408;
    eBLetGo                         = 4608;
    eBLooseInventory                = 8192;

    eBanditWarningStop              = 0;
    eBanditWarningArmed             = 1;
    eBanditWarningRandom            = 2;
    eBanditWarningLast              = 3;

    eTotalGroupIDs                  = 0xffff;

}

unit auBandits[];
int anBanditGroupID[];
int nCurrentBandit;

int anGroupID[];
int anGroupState[];
int anGroupMission[];
int anGroupMarker[];
int anGroupHeroTimer[];
int anGroupWarnings[];
int anGroupWarningTimers[];
int nCurrentGroup;

int nCurrentGroupID;

int nBanditsOn;

function void StartBanditDialog(int nUnit, unit uHero);

//======================================        

function int HasInventoryForBandits(unit uHero) {

    if (uHero.IsObjectInInventory("TROUSERS")) return true;
    if (uHero.IsObjectInInventory("AR_LEATHER_TROUSERS")) return true;
    if (uHero.IsObjectInInventory("AR_CHAIN_TROUSERS")) return true;
    if (uHero.IsObjectInInventory("AR_HALF_PLATE_TROUSERS")) return true;
    if (uHero.IsObjectInInventory("AR_PLATE_TROUSERS")) return true;

    return false;
    
}

function void RemoveInventoryForBandits(unit uHero) {

    if (uHero.IsObjectInInventory("TROUSERS")) uHero.RemoveObjectFromInventory("TROUSERS",false);
    else if (uHero.IsObjectInInventory("AR_LEATHER_TROUSERS")) uHero.RemoveObjectFromInventory("AR_LEATHER_TROUSERS",false);
    else if (uHero.IsObjectInInventory("AR_CHAIN_TROUSERS")) uHero.RemoveObjectFromInventory("AR_CHAIN_TROUSERS",false);
    else if (uHero.IsObjectInInventory("AR_HALF_PLATE_TROUSERS")) uHero.RemoveObjectFromInventory("AR_HALF_PLATE_TROUSERS",false);
    else if (uHero.IsObjectInInventory("AR_PLATE_TROUSERS")) uHero.RemoveObjectFromInventory("AR_PLATE_TROUSERS",false);

}

function void IncreaseKilledBandits(unit uHero) {

    int nKilledBandits;
    nKilledBandits = GetKilledBandits(uHero) + 1;
    SetKilledBandits(uHero,nKilledBandits);
    
}

//======================================        

function void AddBandit(unit uUnit, int nGroupID) {
    
    uUnit.SetPartyNum(ePartyNeutralBandits);
    SetExternalActivity(uUnit,eEActivityControlledByUnit);
    auBandits.Add(uUnit);
    anBanditGroupID.Add(nGroupID);
    nCurrentBandit = auBandits.GetSize();

}

function void RemoveBandit(int nUnit) {

    auBandits.RemoveAt(nUnit);
    anBanditGroupID.RemoveAt(nUnit);
    nCurrentBandit = auBandits.GetSize();

}   

function void CreateBanditUnitsForGroup(mission pMission, int anMarkers[], int nGroup) {

    int nMarker;
    int nX, nY;
    int count;
    int i, j;
    int nSize;
    
    nSize = anMarkers.GetSize();
    for (i = 0; i < nSize; i++) {
    
        pMission.GetMarker(MARKER_BANDITS,anMarkers[i],nX,nY);        
        SendMessageToGlobalScripts(eMsgCreateBandits,anGroupMission[nGroup],nX,nY,anMarkers[i]);
        pMission.SearchUnitsInArea(nX,nY,eCreateBanditsRangeA,GetSinglePartyArray(ePartyBandits));
        count = pMission.GetSearchUnitsInAreaCount();
        for (j = 0; j < count; j++) AddBandit(pMission.GetSearchUnitInArea(j),anGroupID[nGroup]);
    
    }

    pMission.ClearSearchUnitsInAreaArray();

}

function void CreateBanditUnits(mission pMission) {
    
    int i;
    int nX, nY;
    string astrMarkers[];
    int anMarkers[];
    
    for (i = 0; i < nCurrentGroup; i++) {
    
        if (anGroupState[i] != eGroupStateNotCreated) continue;
        if (anGroupMission[i] != pMission.GetMissionNum()) continue;

        pMission.GetMarker(MARKER_BANDITS,anGroupMarker[i],nX,nY);
        pMission.FillMarkersInRange(MARKER_BANDITS,nX,nY,eSameTargetHeroRangeA,astrMarkers,anMarkers,true);
        //anMarkers.Add(anGroupMarker[i]);
        CreateBanditUnitsForGroup(pMission,anMarkers,i);
        
        anGroupState[i] = eGroupStateNothing;          
            
    }
               
}

//======================================        

function int IsGroupNonzero(int nGroupID) {

    int i;
    for (i = 0; i < nCurrentBandit; i++) if (anBanditGroupID[i] == nGroupID) return true;
    return false;
    
}

function int FindGroup(int nGroupID) {

    int i;
    for (i = 0; i < nCurrentGroup; i++) 
         if (anGroupID[i] == nGroupID) return i;
         
    return eNoGroup;

}

function void AddGroup(int nGroupID, mission pMission, int nMarker) {

    anGroupID.Add(nGroupID);
    anGroupState.Add(eGroupStateNotCreated);
    anGroupMission.Add(pMission.GetMissionNum());
    anGroupMarker.Add(nMarker);
    anGroupHeroTimer.Add(GetCampaign().GetGameTick() - eHeroProcessedTime - 1);
    anGroupWarnings.Add(eBanditWarningStop);
    anGroupWarningTimers.Add(GetCampaign().GetGameTick());

    nCurrentGroup = anGroupID.GetSize();
    
}    

function void ClearGroup(int nGroupID) {

    int i;
    while (i < nCurrentBandit) {
        if (anBanditGroupID[i] == nGroupID) RemoveBandit(i);
        else i++;    
    }

}

function void RemoveGroup(int nGroup) {
    
    if (IsGroupNonzero(anGroupID[nGroup])) ClearGroup(anGroupID[nGroup]);

    anGroupID.RemoveAt(nGroup);
    anGroupState.RemoveAt(nGroup);
    anGroupMission.RemoveAt(nGroup);
    anGroupMarker.RemoveAt(nGroup);
    anGroupHeroTimer.RemoveAt(nGroup);
    anGroupWarnings.RemoveAt(nGroup);
    anGroupWarningTimers.RemoveAt(nGroup);
    
    nCurrentGroup = anGroupID.GetSize();

}

function void UpdateGroupMarker(int nGroupID) {

    int i;
    int nGroup;
    int nMarker;
    int anMarkers[];

    nGroup = FindGroup(nGroupID);
    ASSERT(nGroup != eNoGroup);

    for (i = 0; i < nCurrentBandit; i++) {
    
        if (anBanditGroupID[i] == nGroupID) {
        
            nMarker = GetMarkerNumberFromBaseMarker(GetBaseMarker(auBandits[i]));    
            if (nMarker == anGroupMarker[nGroup]) return;
            else anMarkers.Add(nMarker);
        
        }
    
    }

    if (anMarkers.GetSize()) {
        anGroupMarker[nGroup] = anMarkers[0];    
    }
    else {
        RemoveGroup(nGroup);
    }
    
}

//======================================        

function int GetNextGroupID() {

    nCurrentGroupID = (nCurrentGroupID + 1) % eTotalGroupIDs;
    return nCurrentGroupID;

}

function int BanditsCreated(mission pMission) {
    
    int nBanditsCreated;
    pMission.GetAttribute(BANDITS_CREATED_ATTRIBUTE,nBanditsCreated);
    return nBanditsCreated;

}

function void SetBanditsCreated(mission pMission, int nBanditsCreated) {

    pMission.SetAttribute(BANDITS_CREATED_ATTRIBUTE,nBanditsCreated);

}

//======================================        

function void RemoveMarkersFrom(int anMarkers[], int anRemoveFrom[]) {

    int i, j;    
    int count;
    count = anMarkers.GetSize();
    for (i = 0; i < count; i++) {
        j = 0;
        while (j < anRemoveFrom.GetSize()) {
            if (anMarkers[i] == anRemoveFrom[j]) anRemoveFrom.RemoveAt(j);
            else j++;
        }    
    }

}

function void CreateGroupsInRange(mission pMission, int anBanditMarkers[]) {

    int i;
    int anMarkers[];
    string astrMarkers[];
    int nX, nY;

    pMission.GetMarker(MARKER_BANDITS,anBanditMarkers[0],nX,nY);
    pMission.FillMarkersInRange(MARKER_BANDITS,nX,nY,eSameTargetHeroRangeA,astrMarkers,anMarkers,false);
    anMarkers.Add(anBanditMarkers[0]);
    
    AddGroup(GetNextGroupID(),pMission,anBanditMarkers[0]);
    
    RemoveMarkersFrom(anMarkers,anBanditMarkers);
    
}

function void CreateStandardBandits(mission pMission) {

    int i, nMaxNum;
    int nX, nY;
    
    nMaxNum = pMission.GetMaxMarkerNum(MARKER_BANDITS);
    for (i = 1; i <= nMaxNum; i++)    
        if (pMission.GetMarker(MARKER_BANDITS,i,nX,nY))
            SendMessageToGlobalScripts(eMsgCreateBandits,pMission.GetMissionNum(),nX,nY,i);
    
}

function void CreateBandits(mission pMission) {

    int i, nMaxNum;
    int anMarkers[];
    
    SetBanditsCreated(pMission,true);
    
    if (nCurrentNeutralBandits >= nMaxNeutralBandits) {
    
        CreateStandardBandits(pMission);
    
    }
    else {
    
        nMaxNum = pMission.GetMaxMarkerNum(MARKER_BANDITS);
        for (i = 1; i <= nMaxNum; i++) 
            if (pMission.HaveMarker(MARKER_BANDITS,i)) anMarkers.Add(i);

        while (anMarkers.GetSize())
            CreateGroupsInRange(pMission,anMarkers);

        CreateBanditUnits(pMission);
    
    }
    
}

//======================================        

function int IsHeroProcessed(int nGroup) {

    if (GetCampaign().GetGameTick() - anGroupHeroTimer[nGroup] < eHeroProcessedTime) return true;
    return false;

}

function void SetHeroProcessed(int nGroupID) {

    int i;
    for (i = 0; i < nCurrentGroup; i++) 
         if (anGroupID[i] == nGroupID) anGroupHeroTimer[i] = GetCampaign().GetGameTick();

}

/*
function int IsHeroNearGroup(int nGroup) {

    int nX, nY;
    unit uHero;

    if (IsHeroProcessed(nGroup)) return false;
    
    uHero = GetHero(0);    
    if (uHero.GetMission().GetMissionNum() != anGroupMission[nGroup]) return false;    
    if (!uHero.GetMission().GetMarker(MARKER_BANDITS,anGroupMarker[nGroup],nX,nY)) return false;
    if (uHero.DistanceTo(nX,nY) > eHeroToBanditsRangeA) return false;       
    return true;
        
}
*/

function int IsHeroNearGroup(int nGroup) {

    int i;
    int nX, nY;
    unit uHero;
    int nGroupID;

    if (IsHeroProcessed(nGroup)) return false;
        
    uHero = GetHero(0);    
    if (uHero.GetMission().GetMissionNum() != anGroupMission[nGroup]) return false;    
    if (!uHero.GetMission().GetMarker(MARKER_BANDITS,anGroupMarker[nGroup],nX,nY)) return false;
    if (uHero.DistanceTo(nX,nY) > eHeroToBanditsRangeA) return false;       

    nGroupID = anGroupID[nGroup];    

    for (i = 0; i < nCurrentBandit; i++) {    
        if (anBanditGroupID[i] == nGroupID && auBandits[i] != null) {
            if (auBandits[i].IsObjectInSightOrHearRange(uHero,false)) return true;
        }    
    }

    return false;
        
}

function int HeroTooFarFromGroup(int nGroup) {

    mission pMission;
    unit uHero;
    int nX, nY;    

    uHero = GetHero(0);
    if (anGroupMission[nGroup] == eNoMission) return true;
    if (uHero.GetMission().GetMissionNum() != anGroupMission[nGroup]) return true;
    
    pMission = GetCampaign().GetMission(anGroupMission[nGroup]);
    if (pMission == null) return true;
    if (!pMission.IsLevelLoaded()) return true;
    if (!pMission.GetMarker(MARKER_BANDITS,anGroupMarker[nGroup],nX,nY)) return true;

    if (uHero.DistanceTo(nX,nY) > eHeroToBanditsRangeA) return true;        
    
    return false;
    
}

function void SetGroupPartyEnemy(int nGroupID, int nEnemy) {

    int i;
    int nParty;
    int nGroupState;
    
    if (nEnemy) {
        nParty = ePartyBandits;
        nGroupState = eGroupStateActive;
    }
    else {
        nParty = ePartyNeutralBandits;
        nGroupState = eGroupStateNothing;
    }
 
    for (i = 0; i < nCurrentGroup; i++) {
        if (anGroupID[i] == nGroupID) anGroupState[i] = nGroupState;
    }
    
    for (i = 0; i < nCurrentBandit; i++) {            
        if (anBanditGroupID[i] == nGroupID) auBandits[i].SetPartyNum(nParty);
    }
    
}

function int IsGroupPartyEnemy(int nGroupID) {

    int i;
    unit uHero;
    
    uHero = GetHero(0);
    for (i = 0; i < nCurrentBandit; i++) 
        if (anBanditGroupID[i] == nGroupID) if (auBandits[i].IsEnemy(uHero)) return true;
        
    return false;

}

function void AlarmGroup(int nGroupID, int nAlarm) {

    int i;    
    int nRunMode;
    int nStop;
    int nGroupState;
    
    if (nAlarm) {
        nRunMode = true;
        nStop = false;
        nGroupState = eGroupStateActive;
    }
    else {
        nRunMode = false;
        nStop = true;
        nGroupState = eGroupStateNothing;
    }

    for (i = 0; i < nCurrentGroup; i++) {
        if (anGroupID[i] == nGroupID) anGroupState[i] = nGroupState;
    }

    for (i = 0; i < nCurrentBandit; i++) if (anBanditGroupID[i] == nGroupID) {

        auBandits[i].SetRunMode(nRunMode);
        if (nStop) auBandits[i].CommandStop();

    }
            
}

//======================================        

function void PlayBanditWarning(int nUnit, int nWarning) {

    if (nWarning == eBanditWarningStop) {
#ifdef BANDITS_DEBUG
        TRACE("playing eBanditWarningStop                          \n");
#endif           
        PlayBanditStop(auBandits[nUnit]);
    }
    else if (nWarning == eBanditWarningArmed) {
#ifdef BANDITS_DEBUG
        TRACE("playing eBanditWarningArmed                          \n");
#endif           
        PlayBanditWeapon(auBandits[nUnit]);
    }
    else {
        __ASSERT_FALSE();
    }

}

function void PlayBanditWarning(int nUnit, unit uHero) {

    int nGroup;
    
    nGroup = FindGroup(anBanditGroupID[nUnit]);
    if (GetCampaign().GetGameTick() - anGroupWarningTimers[nGroup] < eBanditWarningsTime) return;

    anGroupWarningTimers[nGroup] = GetCampaign().GetGameTick();        

    if (anGroupWarnings[nGroup] == eBanditWarningStop && uHero.IsMoving()) PlayBanditWarning(nUnit,eBanditWarningStop);
    else if (anGroupWarnings[nGroup] == eBanditWarningArmed && uHero.IsInArmedMode()) PlayBanditWarning(nUnit,eBanditWarningArmed);
    else {
        if (Rand(2) && uHero.IsMoving()) PlayBanditWarning(nUnit,eBanditWarningStop);
        else if (uHero.IsInArmedMode()) PlayBanditWarning(nUnit,eBanditWarningArmed);
    }
    anGroupWarnings[nGroup] += 1;

#ifdef BANDITS_DEBUG
    if (anGroupWarnings[nGroup] >= eBanditWarningLast) {
        TRACE("BanditWarnings reached maximum            \n");
    }
#endif    

}

//======================================        

function void ProcessBandit(int nUnit) {

    unit uHero;
    unit uUnit;
    int nX, nY;
    int nGroup;
    int nGroupID;
  
    uUnit = auBandits[nUnit];
    uHero = GetHero(0);
    nGroupID = anBanditGroupID[nUnit];
    nGroup = FindGroup(nGroupID);

    ASSERT(nGroup != eNoGroup);

    if (!uUnit.IsLive()) {

        RemoveBandit(nUnit);
        return;

    }

    if (anGroupState[nGroup] == eGroupStateNothing) {

        if (uUnit.GetAttackTarget() == uHero && (!uUnit.IsEnemy(uHero))) {
            SetGroupPartyEnemy(nGroupID,true);
        }        
        else {
            uUnit.GetMission().GetMarker(MARKER_BANDITS,anGroupMarker[nGroup],nX,nY);
            if ((uUnit.DistanceTo(nX,nY) > eBanditsTooFarFromMarkerRangeA) && (!uUnit.IsInArmedMode())) uUnit.CommandMove(nX,nY,0);
        }
    
    }

    if (anGroupState[nGroup] == eGroupStateActive) {

        if (uUnit.GetAttackTarget() == uHero && (!uUnit.IsEnemy(uHero))) {
            SetGroupPartyEnemy(nGroupID,true);
        }        
        if (uUnit.IsEnemy(uHero)) {
            ;
        }
        else if (uUnit.DistanceTo(uHero) > eBanditWarningsRangeA) {

            if (!uUnit.IsMoving()) uUnit.CommandMove(uHero.GetLocationX(),uHero.GetLocationY(),0);        
            else if (ABS(uUnit.GetRelativeAngleTo(uHero)) > eMaxAngleToChasedHero) uUnit.CommandMove(uHero.GetLocationX(),uHero.GetLocationY(),0);        

        }
        else if (uUnit.DistanceTo(uHero) > eBanditDialogRangeA) {

            PlayBanditWarning(nUnit,uHero);    
            if (!uUnit.IsMoving()) uUnit.CommandMove(uHero.GetLocationX(),uHero.GetLocationY(),0);        
            else if (ABS(uUnit.GetRelativeAngleTo(uHero)) > eMaxAngleToChasedHero) uUnit.CommandMove(uHero.GetLocationX(),uHero.GetLocationY(),0);        

        }
        else if (!uHero.IsMoving() && !uHero.IsInArmedMode()) {
        
            auBandits[nUnit].CommandStop();
            if (!IsUnitInDialogMode(uHero)) {
                SetHeroProcessed(nGroupID); 
                StartBanditDialog(nUnit,uHero);
            }

        }   
        else if (anGroupWarnings[nGroup] < eBanditWarningLast) {

            PlayBanditWarning(nUnit,uHero);

        }
        else {

            SetHeroProcessed(nGroupID); 
            SetGroupPartyEnemy(nGroupID,true);
        
        } 
        
    }

}

function void ProcessGroup(int nGroup) {

    int i;
    int nGroupID;
    unit uHero;
    
    uHero = GetHero(0);
    nGroupID = anGroupID[nGroup];
    
    if (anGroupState[nGroup] == eGroupStateNotCreated) return;
    if (!GetCampaign().GetMission(anGroupMission[nGroup]).IsLevelLoaded()) return;
    if (uHero.GetMission().GetMissionNum() != anGroupMission[nGroup]) return;

    if (anGroupState[nGroup] == eGroupStateNothing) {
    
        anGroupWarnings[nGroup] = eBanditWarningStop;
        if (IsHeroNearGroup(nGroup)) AlarmGroup(nGroupID,true);
    
    }

    if (anGroupState[nGroup] == eGroupStateActive) {

        if (!IsGroupPartyEnemy(nGroupID)) 
            if (!uHero.IsLive() || IsHeroProcessed(nGroup) || HeroTooFarFromGroup(nGroup)) {
                AlarmGroup(nGroupID,false);
                return;                    
            }                

    }
    
}

//======================================        

state Initialize {
    
    ENABLE_TRACE(true);
        
    nBanditsOn = true;
    return Nothing, 0;
    
}

state Nothing {

    int i;
    unit uHero;
    mission pMission;
    
    if (!nBanditsOn) return Nothing, 30;
       
    for (i = 0; i < GetPlayersCnt(); i++) {
    
        if (!IsPlayer(i)) continue;
        uHero = GetHero(i);
        pMission = uHero.GetMission();
        if (!BanditsCreated(pMission)) CreateBandits(pMission);
    
    }  

    for (i = 0; i < nCurrentGroup; i++) ProcessGroup(i);
    for (i = 0; i < nCurrentBandit; i++) ProcessBandit(i);        

    return Nothing, 30;
    
}      

//======================================        

function int GetBanditDialogInputFlags(int nUnit, unit uHero) {

    int nGold;
    int nFlags;
    int nLevel;
    int nRand;
      
    nFlags = eBDialogInputFlags;

#ifdef BANDITS_DEBUG
    TRACE("GetBanditDialogInputFlags: level difference %d gold %d             \n",uHero.GetUnitLevel() - auBandits[nUnit].GetUnitLevel(),uHero.GetMoney());
#endif    
    
    // przestraszenie
    nLevel = uHero.GetUnitLevel() - auBandits[nUnit].GetUnitLevel();
    nRand = 20;
    if (nLevel > 0) nRand += nLevel * 5;
    if (Rand(100) < nRand) {
#ifdef BANDITS_DEBUG
        TRACE("eBScared                  \n");
#endif        
        nFlags -= eBScared;
    }
    else {
#ifdef BANDITS_DEBUG
        TRACE("eBNotScared                  \n");
#endif        
        nFlags -= eBNotScared;
    }
    
    // kasa
    nGold = uHero.GetMoney();
    if (nGold >= 30000) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay30000                  \n");
#endif        
        nFlags -= eBPay30000;
    }
    else if (nGold >= 10000) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay10000                  \n");
#endif        
        nFlags -= eBPay10000;    
    }
    else if (nGold >= 5000) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay5000                  \n");
#endif        
        nFlags -= eBPay5000;
    }
    else if (nGold >= 1000) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay1000                  \n");
#endif        
        nFlags -= eBPay1000;
    }
    else if (nGold >= 500) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay500                  \n");
#endif        
        nFlags -= eBPay500;
    }
    else if (nGold >= 200) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay200                  \n");
#endif        
        nFlags -= eBPay200;
    }
    else if (nGold >= 100) {
#ifdef BANDITS_DEBUG
        TRACE("eBPay100                  \n");
#endif        
        nFlags -= eBPay100;
    }
    else {
#ifdef BANDITS_DEBUG
        TRACE("eBNoMoney                  \n");
#endif        
        nFlags -= eBNoMoney;    
    }

    // czy ma spodnie
    if (HasInventoryForBandits(uHero)) {
#ifdef BANDITS_DEBUG
        TRACE("eBHasInventory                  \n");
#endif        
        nFlags -= eBHasInventory;
    }
    else {
#ifdef BANDITS_DEBUG
        TRACE("eBHasntInventory                  \n");
#endif        
        nFlags -= eBHasntInventory;
    }

#ifdef TOWN_DEBUG
    TRACE("GetBanditDialogInputFlags returned: %d %d                        \n",nFlags,eBDialogInputFlags - nFlags);
#endif    
    
    return nFlags;

}

function void StartBanditDialog(int nUnit, unit uHero) {

    string strDialog;
                
    if (GetKilledBandits(uHero) > eMaxKilledBandits) {
        if(Rand(2))strDialog = DIALOG_BANDIT_RESPECT1;
        else strDialog = DIALOG_BANDIT_RESPECT2;
    }
    else {
        if (Rand(2)) strDialog = DIALOG_BANDIT1;
        else strDialog = DIALOG_BANDIT2;
    }

    GetPlayerInterface(uHero.GetHeroPlayerNum()).PlayDialog(GetScriptUID(),nUnit,eDefDialogFlags | eEndEventOnStartFadeOut | PlayDialogWaves(uHero),GetBanditDialogInputFlags(nUnit,uHero),strDialog,1,uHero,auBandits[nUnit]);

}

function void AddMoneyToBandits(int nGold, int nGroupID) {

    int i;
    unit auUnits[];
    int nQuantity;
    int nUnit;
    string strMoney;
    string strAttribute;
    
    if (nGold < 1000) {
        strMoney = "ART_MONEY100";
        nQuantity = nGold / 100;
    }
    else {
        strMoney = "ART_MONEY500";
        nQuantity = nGold / 500;
    }

    for (i = 0; i < nCurrentBandit; i++)
        if (anBanditGroupID[i] == nGroupID) auUnits.Add(auBandits[i]);

    if (auUnits.GetSize() == 0) return;
        
    for (i = 0; i < nQuantity; i++) {
        nUnit = Rand(auUnits.GetSize());
        strAttribute = "";
        auUnits[nUnit].GetAttribute("RewardGold",strAttribute);
        strAttribute = AddTextToString(strMoney,strAttribute);
        auUnits[nUnit].SetAttribute("RewardGold",strAttribute);    
    }

}

function void PayBanditFine(unit uHero, int nGroupID) {

    int nGold;  
    nGold = uHero.GetMoney();

#ifdef BANDITS_DEBUG
    TRACE("PayBanditFine: gold %d                 \n",nGold);
#endif    

    if (nGold >= 30000) {
        nGold -= 30000;
        AddMoneyToBandits(30000,nGroupID);
    }        
    else if (nGold >= 10000) {
        nGold -= 10000;
        AddMoneyToBandits(10000,nGroupID);
    }
    else if (nGold >= 5000) {
        nGold -= 5000;
        AddMoneyToBandits(5000,nGroupID);
    }
    else if (nGold >= 1000) {
        nGold -= 1000;
        AddMoneyToBandits(1000,nGroupID);
    }
    else if (nGold >= 500) {
        nGold -= 500;
        AddMoneyToBandits(500,nGroupID);
    }
    else if (nGold >= 200) {
        nGold -= 200;
        AddMoneyToBandits(200,nGroupID);
    }
    else if (nGold >= 100) {
        nGold -= 100;
        AddMoneyToBandits(100,nGroupID);
    }

    uHero.SetMoney(nGold);

#ifdef BANDITS_DEBUG
    TRACE("PayBanditFine gold after: %d                 \n",uHero.GetMoney());
#endif    

}

event EndTalkDialog(int nPlayerNum, int nDialogUID, int nEndEvent) {

    unit uHero;
    int nUnit;
    int nGroupID;
    
    uHero = GetHero(nPlayerNum);
    nUnit = nDialogUID;
    nGroupID = anBanditGroupID[nUnit];

    nCurrentNeutralBandits++;

#ifdef BANDITS_DEBUG
    TRACE("EndTalkDialog: event %d               \n",nEndEvent);
#endif        

    if (nEndEvent & eBPayMoney) {

#ifdef BANDITS_DEBUG
        TRACE("eBPayMoney: PayBanditFine, SetTargetHeroNoUnitForGroupsWithTarget                    \n");
#endif        
        PayBanditFine(uHero,nGroupID);
        return true;
    
    }
        
    if (nEndEvent & eBFight) {

#ifdef BANDITS_DEBUG
        TRACE("eBFight: SetBanditGroupParty(nGroup,ePartyEnemies)                    \n");
#endif        
        SetGroupPartyEnemy(nGroupID,true);
        return true;
    
    }
         
    if (nEndEvent & eBLetGo) {
    
#ifdef BANDITS_DEBUG
        TRACE("eBLetGo: SetTargetHeroNoUnitForGroupsWithTarget                    \n");
#endif        
        return true;
         
    }
    
    if (nEndEvent & eBLooseInventory) {
    
#ifdef BANDITS_DEBUG
        TRACE("eBLooseInventory: RemoveInventoryForBandits, SetTargetHeroNoUnitForGroupsWithTarget                    \n");
#endif        
        RemoveInventoryForBandits(uHero);
        return true;
         
    }
        
    return true;
         
}

//======================================        

event RemovedUnit(unit uKilled, unit uAttacker, int a) {

    int i;
    int nGroupID;
    
    for (i = 0; i < nCurrentBandit; i++) if (auBandits[i] == uKilled) {
        nGroupID = anBanditGroupID[i];
        RemoveBandit(i);
        IncreaseKilledBandits(uAttacker);    
        UpdateGroupMarker(nGroupID);
        return false;
    }
                  
    return false;

}

event OnUnloadLevel(mission pMission) {

    int i;
    i = 0;
    while (i < nCurrentBandit) {
        if (auBandits[i].GetMission().GetMissionNum() == pMission.GetMissionNum()) RemoveBandit(i);
        else i++;    
    }
    i = 0;
    while (i < nCurrentGroup) {
        if (anGroupMission[i] == pMission.GetMissionNum()) RemoveGroup(i);
        else i++;
    }
    SetBanditsCreated(pMission,false);

    return true;

}

//======================================        

command Message(int nParam, int nValue) {

    if (nParam == eMsgSetMaxNeutralBandits) {
        
        nMaxNeutralBandits = nValue;
        return true;
        
    }
    
    return 0;

}

//======================================        

#ifdef USE_COMMAND_DEBUG
command CommandDebug(string strLine) {

    int i, nMaxNum;
    int j;
    int nX, nY;
    string strMarker;
    int nMarker;        
    mission pMission;        
    int nType;
        
    if (!stricmp(strLine,"PrintBandits")) {
        TRACE("bandits number %d\n",nCurrentBandit);
        for (i = 0; i < nCurrentBandit; i++) {
            auBandits[i].GetAttribute("EnemyClass",nType);
            TRACE("bandit %d mission %d group %d party %d           \n",i,auBandits[i].GetMission().GetMissionNum(),anBanditGroupID[i],auBandits[i].GetPartiesNums().ElementAt(0));        
//            TRACE("type %d string %s           \n",nType,auBandits[i].GetObjectCreateString());        
        }
        return true;
    }
    else if (!stricmp(strLine,"BanditsOn")) {
        TRACE("Bandits are on                     \n");
        nBanditsOn = true;
        return true;
    }    
    else if (!stricmp(strLine,"BanditsOff")) {
        TRACE("Bandits are off                    \n");
        nBanditsOn = false;
        return true;
    }    
    else if (!stricmp(strLine,"PrintBanditGroups")) {
        for (i = 0; i < nCurrentGroup; i++) {
            TRACE("group %d id %d state %d mission %d marker %d timer %d warning %d enemy %d\n",i,anGroupID[i],anGroupState[i],anGroupMission[i],anGroupMarker[i],anGroupHeroTimer[i],anGroupWarnings[i],IsGroupPartyEnemy(anGroupID[i]));        
        }
        return true;
    }
    else if (!stricmp(strLine,"FindMarkerBandits")) {
        TRACE("Markers found:                             \n");
        nMaxNum = GetHero().GetMission().GetMaxMarkerNum(MARKER_BANDITS);
        for (i = 1; i <= nMaxNum; i++) if (GetHero().GetMission().GetMarker(MARKER_BANDITS,i,nX,nY)) {
            TRACE("%s %d found: %d %d %d %d                  \n",MARKER_BANDITS,i,nX,nY,A2G(nX),A2G(nY));        
        }
        return true;
    }    
    else if (!stricmp(strLine,"AddTrousers")) {
        TRACE("added\n");
        GetHero(0).AddInventory("AR_LEATHER_TROUSERS",true);
        return true;
    }
    else if (!stricmp(strLine,"ResetBandits")) {
        TRACE("bedits reset\n");
        for (i = 0; i < nCurrentGroup; i++) {
            anGroupHeroTimer[i] = GetCampaign().GetGameTick() - eHeroProcessedTime;
            anGroupState[i] = eGroupStateNothing;
            anGroupWarnings[i] = 0;
        }
        return true;
    }
    else return false;

    return true;

}
#endif

}
