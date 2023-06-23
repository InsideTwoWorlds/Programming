mission "PTown"
{

#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Mission.ech"
#include "..\\..\\Common\\Messages.ech"
#include "..\\..\\Common\\Lock.ech"
#include "..\\..\\Common\\Levels.ech"
#include "..\\..\\Common\\CreateStrings.ech"

#define UNIT_ARRAY             auUnit
#define UNIT_ARRAY_SIZE        100

consts {
    
    eAttackTimeInterval        = 100;
    
}

#define MISSION_SCRIPT

unit auUnit[UNIT_ARRAY_SIZE];
int nUnitsNumber;
int nCurrentGroup;
int anTargetTavern[UNIT_ARRAY_SIZE];
int nBarracksNumber;    
            
int nTownOn;
int nTownLoaded;

int nTownType;    
int nPartyTownNPCs;
int nTownX1;
int nTownX2;
int nTownY1;
int nTownY2;
int nTownDisabled;

function void PlayAGDialog(unit uDialogUnit, int nHero);
function void InitializeNPC(int nUnit);
function void PlayStandardGreetings(unit uUnit);
function void PlayScream(unit uUnit);    
function void PlayGuardStop(unit uUnit);    
function void ResetUnitTimers(int nUnit);
    
#include "PInc\\PEnums.ech"
#include "PInc\\PCommon.ech"
#include "PInc\\PActivity.ech"
#include "PInc\\PGuard.ech"
#include "PInc\\PGreetings.ech"
#include "PInc\\PGates.ech"
#include "PInc\\PUnitInfo.ech"
#include "PInc\\PTownGenerator.ech"
#include "PInc\\PFileParser.ech"

//======================================        
        
state Initialize;
state Nothing;

//======================================
//

function void PrintMarkersWarning() {
    
    int nCol, nRow, nLayer;
    int i, j, nMaxNum;

    MissionNum2Level(GetMissionNum(),nCol,nRow,nLayer);
    TRACE("mission: %d -> %c%d                \n",GetMissionNum(),    nCol - 1 + 'A',nRow);    

    if (GetMaxMarkerNum(MARKER_GUARD_BARRACKS) == -1) {
        TRACE("%s not found!             \n",MARKER_GUARD_BARRACKS);
    }
    if (GetMaxMarkerNum(MARKER_TAVERN) == -1) {
        TRACE("%s not found!             \n",MARKER_TAVERN);    
    }
    if (GetMaxMarkerNum(MARKER_PUBLIC_PLACE) == -1) {
        TRACE("%s not found!             \n",MARKER_PUBLIC_PLACE);       
    }    

    if (IsLevelLoaded()) {
        nMaxNum = GetMaxMarkerNum(MARKER_TAVERN);
        for (i = 1; i <= nMaxNum; i++) {
        
            if (!HaveTownMarker(MARKER_TAVERN,i)) continue;
            if (GetObjectMarker(MARKER_TAVERN,i) == null) {
                TRACE("%s %d doesn't have object                  \n",MARKER_TAVERN,i);        
            }
        
        }    
    }

    j = false;
    nMaxNum = GetMaxMarkerNum(MARKER_GUARD_PATROL);
    for (i = 1; i <= nMaxNum; i++) {
        if (HaveTownMarker(MARKER_GUARD_PATROL,i)) {
            j = true;
            break;
        }
    }
            
    if (j) {
        j = false;
        nMaxNum = GetMaxMarkerNum(MARKER_GUARD_ROUTE);
        for (i = 1; i <= nMaxNum; i += eRoutePoints) {
            if (HaveTownMarker(MARKER_GUARD_ROUTE,i)) {
                j = true;
                break;
            }
        }              
        if (!j) { TRACE("%s not found!                    \n",MARKER_GUARD_ROUTE); }
    }

}

//======================================

function void ResetUnitTimers(int nUnit) {

    anGreetingsLastTick[nUnit] = GetCampaign().GetGameTick() - eGreetingsInterval - 1;

}

//======================================
// bodies

function int CheckBodySpotted(unit uBody) {

    int nRange;
    int i, count;
    unit uUnit;

    nRange = uBody.GetSightRange();   
            
    if (uBody.SearchUnits(nRange,GetSinglePartyArray(PARTY_NPC))) {   

        count = uBody.GetSearchUnitsCount();
        for (i = 0; i < count; i++) {
            uUnit = uBody.GetSearchUnit(i);
            if (IsGuard(uUnit)) IncreaseCityCrimeLevel(eCrimePointsMurder);
            else if (UNIT_ARRAY[GetUnitNumber(uUnit)] != null) SendUnitToAlarmGuards(GetUnitNumber(uUnit),0,0,eCrimePointsMurder);               
            return true;        
        }
        
    }

    return false;
    
}

function void CheckForBodies() {

    int i;

    for (i = 1; i < UNIT_ARRAY_SIZE; i++) if (IsUnitDead(i)) {
    
        if (IsBodySpotted(UNIT_ARRAY[i])) continue;
        if (CheckBodySpotted(UNIT_ARRAY[i])) {
            SetBodySpotted(UNIT_ARRAY[i],true);
        }
    
    }

}

//======================================
// standardNPC

function void InitializeNPC(int nUnit) {

    SetMainState(nUnit,eMainStateNormal);
    UNIT_ARRAY[nUnit].SetPartyNum(PARTY_NPC);

}

function void ResurrectNPC(int nUnit)  {

    InitializeNPC(nUnit);

}

function void WhileNPCWorking(int nUnit) {

    UpdateActivity(nUnit);                            

}
 
function void WhileNPCNotWorking(int nUnit) {
 
    UpdateActivity(nUnit);
    
}
        
//======================================

function void ResurrectUnit(int nUnit) {

    int nUnitType;
    unit uUnit;
        
    ASSERT(UNIT_ARRAY[nUnit] != null);
    uUnit = CreateObject(GetCreateString(UNIT_ARRAY[nUnit]),UNIT_ARRAY[nUnit].GetLocationX(),UNIT_ARRAY[nUnit].GetLocationY(),0,Rand(256));
    SetLookAtAngle(uUnit);
    SetStandardDialogNumber(uUnit,GetStandardDialogNumber(UNIT_ARRAY[nUnit]));
    SetIsFemale(uUnit,IsFemale(UNIT_ARRAY[nUnit]));
    SetCustomFlags(uUnit,GetCustomFlags(UNIT_ARRAY[nUnit]));
    uUnit.GetUnitValues().SetLevel(UNIT_ARRAY[nUnit].GetUnitLevel());
    uUnit.UpdateChangedUnitValues();    
    uUnit.SetNPCNameNum(UNIT_ARRAY[nUnit].GetNPCNameNum());
    uUnit.SetPartyNum(PARTY_NPC);
    CopyMagicSkill(UNIT_ARRAY[nUnit],uUnit);

    SetUnitNumber(uUnit,nUnit);
    SetMask(uUnit,0);    

    ResetUnitTimers(nUnit);
    SetTargetHero(nUnit,eNoUnit);
    uUnit.SetAlarmModeUnit(true);            
    anAttackerNumber[nUnit] = 0;

    UNIT_ARRAY[nUnit].RemoveObject();
    UNIT_ARRAY[nUnit] = uUnit;
    
    nUnitType = GetUnitType(nUnit);
    if (IsGuard(UNIT_ARRAY[nUnit])) ResurrectGuard(nUnit);
    else ResurrectNPC(nUnit);

}

//======================================

function void StandardUnitBehavior(int nUnit) {

    int nMainState;    
    unit uCriminal;
    
    ASSERT(UNIT_ARRAY[nUnit] != null);

    if (IsUnitArmed(UNIT_ARRAY[nUnit])) {
        SetMainState(nUnit,eMainStateFighting);
    }
    else if (nMainState != eMainStateAlarmingGuards) {
        if (CheckForCriminals(UNIT_ARRAY[nUnit],uCriminal)) {
            FightOrRun(nUnit,uCriminal);
        }
    }

    nMainState = GetMainState(nUnit);
    
    if (nMainState == eMainStateNormal) {
    
        PlayStandardGreetings(UNIT_ARRAY[nUnit]);                                        
        UpdateDailyState(nUnit);
        UpdateGoingDailyState(nUnit);
        if (GetDailyState(nUnit) == eWorking) WhileNPCWorking(nUnit);
        else WhileNPCNotWorking(nUnit);
    
    }

    if (nMainState == eMainStateRunning) {
 
        uCriminal = GetNearestCriminal(UNIT_ARRAY[nUnit]);
        
        if ((uCriminal != null) && (!uCriminal.IsHeroUnit())) {
            __ASSERT_FALSE();
        }
 
        // jesli nie ma wrogow w poblizu
        if (uCriminal == null) SetMainState(nUnit,eMainStateNormal);            
        // jesli jest w poblizu straznikow, a wrog nadal go goni
        else if (CheckForGuards(UNIT_ARRAY[nUnit])) {
            if (!IsGuardAlarmedByUnit(UNIT_ARRAY[nUnit])) {
                SetGuardAlarmedByUnit(UNIT_ARRAY[nUnit],true);
                if (IsAttacker(nUnit,uCriminal)) UpdateCrimePoints(nUnit,uCriminal.GetHeroPlayerNum(),eCrimePointsFight,0);
                else UpdateCrimePoints(nUnit,uCriminal.GetHeroPlayerNum(),eCrimePointsChasing,0);
                ResetAttackerNumber(nUnit,uCriminal.GetHeroPlayerNum());
            }
        }
        else FightOrRun(nUnit,uCriminal);

    }        
    
    if (nMainState == eMainStateFighting) {

        if (!IsUnitArmed(UNIT_ARRAY[nUnit]) && (UNIT_ARRAY[nUnit].GetAttackTarget() == null)) SetMainState(nUnit,eMainStateNormal);        
/*
        else if (UnableToAttackHero(UNIT_ARRAY[nUnit],GetTargetHero(nUnit))) {
            UNIT_ARRAY[nUnit].CommandStop();
            SetMainState(nUnit,eMainStateNormal);                    
        }
*/
    }
    
    if (nMainState == eMainStateWaiting) {
    
        if (GetCampaign().GetGameTick() > anWaitingTimer[nUnit]) SetMainState(nUnit,eMainStateNormal);
    
    }
    
    if (nMainState == eMainStateAlarmingGuards) {            

        if (!IsUnitInDialogMode(UNIT_ARRAY[nUnit])) {
            if (CheckForGuardsOrBarracks(UNIT_ARRAY[nUnit])) UnitStopAlarming(nUnit,true);
            else if (!UNIT_ARRAY[nUnit].IsMoving() && !IsUnitInDialogMode(UNIT_ARRAY[nUnit])) SendUnitToAlarmGuardsAgain(nUnit);
        }               

    }

}

//======================================
// dialog units

function int IsInDialogState(unit uUnit) {

    int nState;

    ASSERT(uUnit != null);
    
    // jesli jest uzbrojony
    if (IsUnitArmed(uUnit)) return false;
    
    nState = GetMainState(uUnit);    
    if ((nState == eMainStateRunning) || (nState == eMainStateFighting)) return false;

    // straznik
    if ((nState == eMainStateNormal) && (GetDailyState(uUnit) == eWorking) && IsGuard(uUnit) && !IsGuardPatrolling(uUnit)) return false;
 
    return true;

}

function void ProcessDialogUnit(int nUnit) {

    int nDailyState;
    unit uUnit;

    uUnit = UNIT_ARRAY[nUnit];
    ASSERT(uUnit);
    
    if (!IsInDialogState(uUnit)) {
        if (IsDialogUnit(uUnit)) ResetIsDialogUnit(uUnit);
    }
    else {    
        if (!IsDialogUnit(uUnit)) SetIsDialogUnit(uUnit);    
    }

}    
    
//======================================
// states

state Initialize {
      
    int i;       
    int nX, nY;       
    unit uUnit;       
              
    ENABLE_TRACE(true);

    // skrypt inicjalizuje sie dopiero w momencie gdy wchodzi na niego pierwszy bohater
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        if (GetHero(i).GetMission().GetMissionNum() == GetMissionNum()) break;
    }
        
    if (i == GetPlayersCnt()) return Initialize,5*30;                     

    SetGatesNumbers(GetThis());

    InitializeCityGates();
    InitializePublicPlaces();
    InitializeTaverns();              
    InitializeRoutesAndBarracks();        
    InitializeBeds();
    nUnitsNumber = 0;

    if (!nTownDisabled) i = GenerateTownUnits();
    else i = 0;

    if(i<1)
    {
        nTownOn=false;
#ifdef TOWN_DEBUG
        TRACE("**********************************************                    \n");
        TRACE("Tragedia w miescie nie ma zadnego unita!!!!!!! type:%d party:%d   \n",nTownType,nPartyTownNPCs);
        TRACE("**********************************************                    \n");
#endif        
        return Nothing;
    }

    InitializeGuards();        
    SetFreeBeds();

    for (i = 1; i < UNIT_ARRAY_SIZE; i++) {
        if (UNIT_ARRAY[i] == null) continue;
        if (!IsQuestUnit(UNIT_ARRAY[i])) SendMessageToGlobalScripts(eMsgSetNPCNameNum,UNIT_ARRAY[i]);
        UpdateDailyState(i);
        SetInitialPosition(i);
        SetExternalActivity(i,eEActivityControlledByTown);
    }

    nTownOn = true;
    nUseCommandMove = true;
    nImmediatePositionFlag = IMMEDIATE_POSITION_FLAG;

//    PrintMarkersWarning();

    return Nothing;

}

state Nothing {
    
    int i;
    int nX, nY;
    unit uHero;
    int nFlag;

    if (!nTownOn) return Nothing, 30;
  
    nFlag = false;
    for (i = 0; i < GetPlayersCnt(); i++) {
        if (!IsPlayer(i)) continue;
        uHero = GetHero(i);
        if (uHero.GetMission().GetMissionNum() == GetMissionNum()) nFlag = true;
        IsHeroNearCityGate(uHero);
    }
    if (!nFlag) return Nothing,5*30;                     
                                 
//    CheckForBodies();              
    DecreaseCityCrimeLevel();    
    UpdateHeroesParties();
    UpdateGuardsNumber();
    CountUnitsInTaverns();
                           
    for (i = 1; i < UNIT_ARRAY_SIZE; i++) {

        if ((i % eNothingFrequency) != nCurrentGroup) continue;
        if (UNIT_ARRAY[i] == null) continue;                  
        ProcessDialogUnit(i);

        if (IsUnitActive(i)) {     
            if (IsGuard(UNIT_ARRAY[i])) GuardBehavior(i);
            else StandardUnitBehavior(i);
        }               
        else if (IsUnitDead(i) && (!nTownDisabled)) { 
            if (!IsHeroNearUnit(UNIT_ARRAY[i]) && IsBodyReadyToRemove(i)) RemoveBody(i);
            else if (!IsHeroNearUnit(UNIT_ARRAY[i]) && IsUnitReadyToResurrection(i)) ResurrectUnit(i);
        }
        
    }
   
    nCurrentGroup = (nCurrentGroup + 1) % eNothingFrequency;
    
    return Nothing,(30 / eNothingFrequency);

}    

//======================================
// commands
    
command Message(int nParam) {

    if (nParam == eMsgGetScriptID) {    
        return eTownScriptID;    
    }

    if (nParam == eMsgGetTownX1) {    
        return nTownX1;    
    }

    if (nParam == eMsgGetTownX2) {    
        return nTownX2;    
    }

    if (nParam == eMsgGetTownY1) {    
        return nTownY1;    
    }

    if (nParam == eMsgGetTownY2) {    
        return nTownY2;    
    }

    if (nParam == eMsgDebugTown) {    
        PrintMarkersWarning();
        return 0;
    }

    return 0;
    
}
    
command Message(int nParam, int nValue, unit uUnit) {

    int nUnit;
    
    // hero zaatakowal jednostke
    if (nParam == eMsgUnitAttacked) {

        nUnit = GetUnitNumber(uUnit);
        if (nUnit > 0) ProcessFight(nValue,uUnit);       
        return true;
       
    }
    if (nParam == eMsgPlayAGDialog) {
    
        PlayAGDialog(uUnit,nValue);
        return true;    
    
    }    
    if (nParam == eMsgPlayFCDialog) {
    
        PlayFCDialog(uUnit,GetHero(nValue));
        return true;    
    
    }    
    // cos zlockpickowano
    if (nParam == eMsgLockpicked) {
        
        if (uUnit.IsGate() && uUnit.GetHouseWithObject() != null) {
            ProcessBurglary(nValue);
        }
        else if (uUnit.IsContainer() && uUnit.GetHouseWithObject() != null) {
            ProcessTheft(nValue);            
        }

        return true;

    }

    return 0;

}


command Message(int nParam, int nValue) {
   
    if (nParam == eMsgSetTownType){ nTownType = nValue; return true;}
    if (nParam == eMsgSetTownX1){ nTownX1 = nValue; return true;}
    if (nParam == eMsgSetTownX2){ nTownX2 = nValue; return true;}
    if (nParam == eMsgSetTownY1){ nTownY1 = nValue; return true;}
    if (nParam == eMsgSetTownY2){ nTownY2 = nValue; return true;}
    
    if (nParam == eMsgSetTownParty){ 
        nPartyTownNPCs = nValue;
        return true;
    }
    
    // zarejestruj bramy miasta do obslugi w tym skrypcie
    if (nParam == eMsgRegisterCityGate) {
                
        RegisterCityGate(nValue);
        return true;

    }
    
    return 0;

}

command Message(int nParam, int nValue1, int nValue2, int nValue3) {

    if (nParam == eMsgDisableTown) {
    
        if (nValue1 >= nTownX1 && nValue1 <= nTownX2 && nValue2 >= nTownY1 && nValue2 <= nTownY2) nTownDisabled = true;                
        return true;
    
    }
    
    return 0;

}

//======================================
// events

event EndTalkDialog(int nPlayerNum, int nDialogUID, int nEndEvent) {

    if (nDialogUID == eDialogFindCriminalUID) EndTalkDialogGuard(nPlayerNum,nDialogUID,nEndEvent);        
    else if (nDialogUID > eDialogAlarmingGuardsUID) EndTalkDialogAlarmingGuards(nPlayerNum,nDialogUID,nEndEvent);       
    return false;
    
}

event EndChatDialog(int nChatDialogUID) {

//    TRACE("Unit %d EndChatDialog               \n",nChatDialogUID - eGreetingsChatDialogUID);
    FinishChatDialog(nChatDialogUID);
    return false;

}

event RemovedUnit(unit uKilled, unit uAttacker, int n) {

    int nUnit;

    nUnit = GetUnitNumber(uKilled);    
    if (uKilled != UNIT_ARRAY[nUnit]) return false;
    
    SetUnitIsDead(nUnit);
    if (uAttacker.IsHeroUnit()) ProcessMurder(uAttacker,uKilled);
    
    return false;

}

event ClickGateByUnit(unit uByUnit, unit uGate, int bFirstOpen, int bFirstHeroOpen, int& bClosedLockSound, int& bOpenLockSound, int& bBrokenLockpickSound) {
     
    return CityGateClicked(uGate);        

}

event OnLoadLevel(mission m, int n) {

    if (m.GetMissionNum() == GetMissionNum()) {
        nTownLoaded = true;
    }
    
    return true;

}

event RemovedNetworkPlayer(int nPlayerNum) {

    int i;
    CancelAlarm(nPlayerNum);
    for (i = 1; i < UNIT_ARRAY_SIZE; i++) {
        ResetAttackerNumber(i,nPlayerNum);
        ResetTargetHero(i,nPlayerNum);
    }
    anBanishmentTimer[nPlayerNum] = 0;
    anBanishedHero[nPlayerNum] = false;
    anHeroCrimePoints[nPlayerNum] = 0;
    anHeroCurrentCrime[nPlayerNum] = 0;
    return true;

}

//======================================
// debug

#ifdef USE_COMMAND_DEBUG

function unit FindNonNullUnit() {

    int i;
    for (i = 1; i < UNIT_ARRAY_SIZE; i++) if (UNIT_ARRAY[i] != null) return UNIT_ARRAY[i];
    return null;
    
}

command CommandDebug(string strLine) {

    int i, j;
    int n;
    int nUnit;
    unit uUnit;
    unit uHero;
    string strMarker;
    int nMarker;    
    mission pMission;
    string str;
    
    GetArgs(strLine);
    str = StrArg(0);
    
    // uwaga tutaj!!!
    if (GetHero().GetMission().GetMissionNum() != GetMissionNum()) return false;
    
    if (!stricmp(str, "TownOn")) {
        TRACE("TownIsOn\n");
        nTownOn = true;
    }
    else if (!stricmp(str, "TownOff")) {
        TRACE("TownIsOff\n");
        nTownOn = false;
    }
    else if (!stricmp(str, "ForceFastMoveOn")) {
        TRACE("ForceFastMoveIsOn\n");
        nForceFastMove = true;
    }
    else if (!stricmp(str, "ForceFastMoveOff")) {
        TRACE("ForceFastMoveIsOff\n");
        nForceFastMove = false;
    }
    else if (!stricmp(str, "UseCommandMoveOn")) {
        TRACE("UseCommandMoveIsOn\n");
        nUseCommandMove = true;
    }
    else if (!stricmp(str, "UseCommandMoveOff")) {
        TRACE("UseCommandMoveIsOff\n");
        nUseCommandMove = false;
    }
    else if (!stricmp(str, "SetImmediatePositionFlagTrue")) {
        TRACE("ImmediatePositionFlag set to true\n");
        nImmediatePositionFlag = true;
    }
    else if (!stricmp(str, "SetImmediatePositionFlagFalse")) {
        TRACE("ImmediatePositionFlag is false\n");
        nImmediatePositionFlag = false;
    }
    else if (!stricmp(str, "PrintBeds")) {
        for (nUnit = 1; nUnit < anBeds.GetSize(); nUnit++) {
            if (UNIT_ARRAY[nUnit] == null) continue;
            TRACE("unit %d bed %d shift %d\n",nUnit,MARKER_SLEEP_NUMBER,anShift[nUnit]);            
            if ((MARKER_SLEEP_NUMBER != eNoBed) && (!HaveTownMarker(MARKER_SLEEP,MARKER_SLEEP_NUMBER))) {
                TRACE("%s %d for unit %d not found!\n",MARKER_SLEEP,MARKER_SLEEP_NUMBER,nUnit);            
            }
        }
    }
    else if (!stricmp(str, "PrintFreeBeds")) {
        for (i = 1; i < anBeds.GetSize(); i++)
            if (HaveTownMarker("MARKER_SLEEP",i) && (anBeds[i] == eBedFree)) {
                TRACE("bed %d is free                   \n",i);            
            }       
    }
    else if (!stricmp(str, "PrintBedsState")) {
        for (i = 1; i < anBeds.GetSize(); i++)
            if (HaveTownMarker("MARKER_SLEEP",i)) {
                TRACE("bed %d state %d           \n",i,anBeds[i]);            
            }       
    }
    else if (!stricmp(str, "PrintMarkersSleep")) {
        for (i = 1; i < anBeds.GetSize(); i++) if (HaveTownMarker("MARKER_SLEEP",i)) {
            TRACE("MARKER_SLEEP %d exists\n",i);
        }
    }
    else if (!stricmp(str, "PrintRoutes")) {
        TRACE("routes number %d\n",nRoutesNumber);
        TRACE("dynamic guards number %d\n",nDynamicGuardsNumber);
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) {
            if (UNIT_ARRAY[nUnit] == null) continue;
            if (GetCustomFlags(UNIT_ARRAY[nUnit]) != eGuardRoute) continue;
            TRACE("guard %d route %d shift %d\n",nUnit,anRouteNumber[nUnit],anShift[nUnit]);
        }
        for (nUnit = 0; nUnit < nRoutesNumber; nUnit++) {
            TRACE("route %d first %d last %d guards %d\n",nUnit,anFirstRoute[nUnit],anLastRoute[nUnit],anGuardsOnRoute[nUnit]);
        }
    }    
    else if (!stricmp(str, "PrintUnitsInfo")) {
        TRACE("total units: %d\n",nUnitsNumber);
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) {
            if (UNIT_ARRAY[nUnit] == null) continue;
            TRACE("unit %d flag %d type %d ms %d ds %d a %d ea %d\n",nUnit,GetCustomFlags(UNIT_ARRAY[nUnit]),GetUnitType(UNIT_ARRAY[nUnit]),GetMainState(nUnit),GetDailyState(nUnit),GetActivity(UNIT_ARRAY[nUnit]),GetExternalActivity(UNIT_ARRAY[nUnit]));
        }
    }    
    else if (!stricmp(str, "PrintUnitsPosition")) {
        TRACE("total units: %d\n",nUnitsNumber);
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) {
            if (UNIT_ARRAY[nUnit] == null) continue;
            TRACE("unit %d xa %d ya %d xg %d yg %d\n",nUnit,UNIT_ARRAY[nUnit].GetLocationX(),UNIT_ARRAY[nUnit].GetLocationY(),A2G(UNIT_ARRAY[nUnit].GetLocationX()),A2G(UNIT_ARRAY[nUnit].GetLocationY()));
        }
    }    
    else if (!stricmp(str, "PrintUnitsDialog")) {
        TRACE("total units: %d\n",nUnitsNumber);
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) {
            if (UNIT_ARRAY[nUnit] == null) continue;
            TRACE("unit %d dialog %d flags %d           \n",nUnit,GetStandardDialogNumber(UNIT_ARRAY[nUnit]),GetCustomFlags(UNIT_ARRAY[nUnit]));
        }
    }    
    else if (!stricmp(str, "PrintUnitsChair")) {
        TRACE("total units: %d\n",nUnitsNumber);
        for (nUnit = IntArg(1); nUnit < IntArg(2); nUnit++) if (UNIT_ARRAY[nUnit] != null) {
            UNIT_ARRAY[nUnit].GetAttribute("PCN",n);
            TRACE("unit %d chair %d             \n",nUnit,n);
        }
    }    
    else if (!stricmp(str, "PrintWorkingUnits")) {
        i = 0;
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) if (UNIT_ARRAY[nUnit] != null) {
            UNIT_ARRAY[nUnit].GetAttribute("PWMN",n);
            if (n == 0) continue;
            i++;
            TRACE("unit %d work marker %d             \n",nUnit,n);
        }
        TRACE("total working units %d             \n",i);
    }    
    else if (!stricmp(str, "PrintSittingUnits")) {
        i = 0;
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) if (UNIT_ARRAY[nUnit] != null) {
            UNIT_ARRAY[nUnit].GetAttribute("PCN",n);
            if (n == 0) continue;
            i++;
            TRACE("unit %d chair %d             \n",nUnit,n);
        }
        TRACE("total sitting units %d             \n",i);
    }    
    else if (!stricmp(str, "PrintSleepingUnits")) {
        i = 0;
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) if (UNIT_ARRAY[nUnit] != null) {
            UNIT_ARRAY[nUnit].GetAttribute("PBN1",n);
            if (n == 0) continue;
            i++;
            TRACE("unit %d bed %d             \n",nUnit,n);
        }
        TRACE("total sleeping units %d             \n",i);
    }    
    else if (!stricmp(str, "PrintGuards")) {
        TRACE("total units: %d\n",nUnitsNumber);
        n = 0;
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) {
            if (UNIT_ARRAY[nUnit] == null) continue;
            if (!IsGuard(UNIT_ARRAY[nUnit])) continue;
            n++;
            TRACE("unit %d flag %d type %d ms %d ds %d ea %d\n",nUnit,GetCustomFlags(UNIT_ARRAY[nUnit]),GetUnitType(UNIT_ARRAY[nUnit]),GetMainState(nUnit),GetDailyState(nUnit),GetExternalActivity(UNIT_ARRAY[nUnit]));
        }
        TRACE("total number of guards: %d              \n",n);
    }    
    else if (!stricmp(str, "PrintUnitsParty")) {
        TRACE("total units: %d\n",nUnitsNumber);
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) if (UNIT_ARRAY[nUnit] != null) {
            TRACE("unit %d party %d             \n",nUnit,UNIT_ARRAY[nUnit].GetPartiesNums().ElementAt(0));
        }
    }    
    else if (!stricmp(str, "PrintDeadUnits")) {
        TRACE("Dead units: %d\n");
        for (nUnit = 1; nUnit < UNIT_ARRAY_SIZE; nUnit++) {
            if (IsUnitDead(nUnit)) {
                TRACE("unit %d is dead\n",nUnit);
            }
        }
    }    
    else if (!stricmp(str, "PrintHeroCrimePoints")) {
        TRACE("HeroCrimePoints: %d\n",anHeroCrimePoints[0]);
        TRACE("HeroCurrentCrime: %d\n",anHeroCurrentCrime[0]);
        TRACE("PointsCriminalEnemy level: %d\n",ePointsCriminalEnemy);
        if (anBanishedHero[0]) {
            TRACE("BanishmentTimer: %d, CurrentTime: %d\n",anBanishmentTimer[0],GetCampaign().GetGameTick());
        }
        else {
            TRACE("Not banished\n");
        }
        if (GetCampaign().IsPartyEnemy(ePartyPlayer1,PARTY_NPC) || GetCampaign().IsPartyEnemy(PARTY_NPC,ePartyPlayer1)) {
            TRACE("Is Enemy               \n");
        }
        else {
            TRACE("Not Eenemy           \n");
        }
    }
    else if (!stricmp(str, "SetHeroNeutral")) {       
        ResetHeroIsCriminal(0);
        SetHeroPartyNeutral(0);
        ResetHeroCrimePoints(0);
        TRACE("Hero set to neutral\n");
    }
    else if (!stricmp(str, "PrintGuardsPaidByHero")) {
        for (nUnit = 0; nUnit < UNIT_ARRAY_SIZE; nUnit++) if (IsUnitActive(nUnit) && IsGuard(nUnit)) {
            TRACE("guard %d paid mask %d\n",nUnit,anPaidByHero[nUnit]);
        }
    }
    else if (!stricmp(str, "PrintTaverns")) {
        TRACE("Taverns number %d\n",nTavernsNumber);
        for (i = 1; i <= nTavernsNumber; i++) {
            TRACE("Tavern %d units %d\n",i,anUnitsInTavern[i]);
        }    
    }
    else if (!stricmp(str, "PrintMarkersNumber")) {
        TRACE("taverns %d                                       \n",nTavernsNumber);
        TRACE("public places %d                                 \n",nPublicPlacesNumber);        
        TRACE("barracks number %d                               \n",nBarracksNumber);
    }
    else if (!stricmp(str, "PrintActivities")) {
        for (i = 1; i < UNIT_ARRAY_SIZE; i++) if (UNIT_ARRAY[i] != null) {
            UNIT_ARRAY[i].GetAttribute("PWM",strMarker);
            UNIT_ARRAY[i].GetAttribute("PWMN",nMarker);            
            TRACE("unit %d activity %d eactivity %d %s %d %d                \n",i,GetActivity(i),GetExternalActivity(i),strMarker,nMarker,UNIT_ARRAY[i].IsMakingCustomWork());
        }
    }
    else if (!stricmp(str, "PrintTargetTaverns")) {
        for (i = 1; i < UNIT_ARRAY_SIZE; i++) if (UNIT_ARRAY[i] != null) if (GetDailyState(i) == eRestingInTavern) {
            TRACE("unit %d target tavern %d activity %d ds %d ms %d\n",i,anTargetTavern[i],GetActivity(i),GetDailyState(i),GetMainState(i));        
        }
    }
    else if (!stricmp(str, "PrintTownMarkers")) {
        PrintTownMarkers();
    }
    else if (!stricmp(str, "PrintTownConfig")) {
        TRACE("range: (%d,%d)->(%d,%d)                     \n",nTownX1,nTownY1,nTownX2,nTownY2);
        TRACE("type: %d                    \n",nTownType);
        TRACE("party: %d                        \n",nPartyTownNPCs);
    }    
    else if (!stricmp(str, "DebugFCDialog")) {
        TRACE("Debugging FCDialog             \n");
        uHero = GetHero(0);        
        anHeroCrimePoints[0] = IntArg(1);
        anHeroCurrentCrime[0] = IntArg(2);
        uUnit = FindNonNullUnit();
        PlayFCDialog(uUnit,uHero);
    }    
    else if (!stricmp(str, "DebugAGDialog")) {
        TRACE("Debugging AGDialog             \n");
        uHero = GetHero(0);        
        uUnit = FindNonNullUnit();
        anUnitHeroCrimePoints[GetUnitNumber(uUnit)] = IntArg(1);
        PlayAGDialog(uUnit,0);
    }    
    else if (!stricmp(str,"PrintUnitPos")) {
        i = IntArg(1);
        TRACE("Unit %d position: %d %d - %d %d                       \n",i,UNIT_ARRAY[i].GetLocationX(),UNIT_ARRAY[i].GetLocationY(),A2G(UNIT_ARRAY[i].GetLocationX()),A2G(UNIT_ARRAY[i].GetLocationY()));
    }
    else return false;

    return true;

}
#endif

}
