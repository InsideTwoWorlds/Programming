global "PDialogUnits"
{

#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Quest.ech"
#include "..\\..\\Common\\Messages.ech"
#include "..\\..\\Common\\CreateStrings.ech"
#include "..\\..\\Common\\Levels.ech"
#include "PInc\\PEnums.ech"    
#include "PInc\\PCommon.ech"
#include "PInc\\PUnitInfo.ech"    
#include "PInc\\PCamps.ech"

state Initialize;
state Nothing;

#define COACH_DIALOG_1     "translateEVENT_1%d"
#define COACH_DIALOG_2     "translateEVENT_2%d"
#define STANDARD_DIALOG    "translateRUMORS_%d"
#define CHANGER_EFFECT      "RESURRECT_EFFECT"
#define VISITED_SHOP_ATTRIBUTE "VS%d"

//======================================        

consts {

    // standard dialog flags
    eSDShop               = 0x01;
    eSDNoShop             = 0x02;
    eSDStart1             = 0x04;
    eSDStart2             = 0x08;
    eSDStart3             = 0x10;    
    eSDWorldState1        = 0x20;
    eSDWorldState2        = 0x40;
    eSDWorldState3        = 0x80;    

    eSDStartFlags         = eSDStart1 | eSDStart2 | eSDStart3;
    eSDWorldStateFlags    = eSDWorldState1 | eSDWorldState2 | eSDWorldState3;
    eSDInputFlags         = eSDShop | eSDNoShop | eSDStartFlags | eSDWorldStateFlags;
    
    // dialog types
    eDialogAlarmingGuards = 1;
    eDialogQuest          = 2;
    eDialogFindCriminal   = 3;

    // changer
    eChangersNum           = 2;                
    eCDHasEnoughGold      = 1;
    eCDHasntEnoughGold    = 2;
    eCDHasEnoughPoints    = 4;
    eCDHasntEnoughPoints  = 8;
    eCDInputFlags         = 15;
    eCDRemovePoints       = 16;
    
    // coach 
    eNoGold = 32;
    eGoodby = 64;
    ePrice100 = 128;
    ePrice300 = 256;
    ePrice1000 = 512;
    ePrice3000 = 1024;
    ePrice10000 = 2048;
    eIKnowAll = 4096;
    eIWantToLearn = 8192;
    eAllMoneyFlags = 3968;//4095-127
    eAllSkillsFlag = 12415; //127+4096+8192        

    // shop
    eShopUpdateTimeInterval = 30 * 60 * 15;
    
}

// changer
int anRequiredSkillPoints[eChangersNum];
int anRequiredParamPoints[eChangersNum];
int anRequiredGold[eChangersNum];
string astrChangerDialog[eChangersNum];

// coach    
#include "..\\..\\Common\\Treners.ech"

// shop
unit auShops[];
int anLastShopUpdateTick[];
int anPlayersLevels[eMaxPlayers];
int nShopsNumber;
#include "..\\..\\Common\\Shops.ech"

// current dialog unit
unit auDialogUnits[eMaxPlayers];

// world state
int nWorldStateArea1;
int nWorldStateArea2;
int nWorldStateArea3;

int nMultiplayer;

//======================================        
// world state

function void InitializeWorldState() {

    nWorldStateArea1 = 0;
    nWorldStateArea2 = 0;
    nWorldStateArea3 = 0;

}
    
function int GetWorldState(unit uUnit) {

    int nWorldRegion;
    int nDialog;
    
    nDialog = GetStandardDialogNumber(uUnit);
    
    if ((nDialog >= 0) && (nDialog <= 99)) { // tharbakin, czy wygrala carga czy skeldeni
        if (nWorldStateArea1 == 2) return eSDWorldState3;
        if (nWorldStateArea1 == 1) return eSDWorldState2;
        if (nWorldStateArea1 == 0) return eSDWorldState1;
        __ASSERT_FALSE();
    }
    if ((nDialog >= 100) && (nDialog <= 199)) { // czy jest pentagram
        if (nWorldStateArea2 == 2) return eSDWorldState3;
        if (nWorldStateArea2 == 1) return eSDWorldState2;
        if (nWorldStateArea2 == 0) return eSDWorldState1;
        __ASSERT_FALSE();
    }
    if ((nDialog >= 200) && (nDialog <= 299)) { // pustynia, czy smok zostal zabity
        if (nWorldStateArea3 == 2) return eSDWorldState3;
        if (nWorldStateArea3 == 1) return eSDWorldState2;
        if (nWorldStateArea3 == 0) return eSDWorldState1;
        __ASSERT_FALSE();
    }
    
    return eSDWorldState1;

}    
    
//======================================        
// standard dialog

function int GetStandardDialogFlags(unit uUnit) {

    int nFlags;
    int n;
    
    nFlags = eSDInputFlags;
    
    if (!uUnit.IsShopUnit()) nFlags -= eSDNoShop;
    else nFlags -= eSDShop;
    
    // start
    n = Rand(3);
    if (n == 0) nFlags -= eSDStart1;
    if (n == 1) nFlags -= eSDStart2;
    if (n == 2) nFlags -= eSDStart3;
    
    // world state
    nFlags -= GetWorldState(uUnit);
       
    return nFlags;

}

function void PlayStandardDialog(unit uHero, unit uUnit) {

    int nFlags;
    string str;
    
    if (uUnit.IsShopUnit())
    {
        str.Format(VISITED_SHOP_ATTRIBUTE,GetCustomFlags(uUnit) - eShopMerchant);
        uHero.GetAttribute(str,nFlags);
        if ((GetCampaign().IsNetworkGame() && nFlags < 3) || (!GetCampaign().IsNetworkGame() && nFlags < 10))
        {
            nFlags++;
            uHero.SetAttribute(str,nFlags);
        }
        else
        {
            GetPlayerInterface(uHero.GetHeroPlayerNum()).OpenHeroDialog(eHeroDlgModeInventory,uUnit);    
            return;
        }
    }
    
    auDialogUnits[uHero.GetHeroPlayerNum()] = uUnit;
        
    str.Format(STANDARD_DIALOG,GetStandardDialogNumber(uUnit));
    nFlags = GetStandardDialogFlags(uUnit);
#ifdef DIALOG_UNITS_DEBUG
    TRACE("Playing standard dialog %s with flags %d                     \n",str,nFlags);
#endif    
    GetPlayerInterface(uHero.GetHeroPlayerNum()).PlayDialog(GetScriptUID(),eStandardDialogUID,eDefDialogFlags | PlayDialogWaves(uHero),nFlags,str,1,uHero,uUnit);

}

function void EndTalkStandardDialog(int nPlayerNum, int nDialogUID, int nEndEvent) {

    ASSERT(auDialogUnits[nPlayerNum] != null);    
    if (auDialogUnits[nPlayerNum].IsShopUnit() && (nEndEvent & eSDShop)) GetPlayerInterface(nPlayerNum).OpenHeroDialog(eHeroDlgModeInventory,auDialogUnits[nPlayerNum]);
    auDialogUnits[nPlayerNum] = null;

}

//======================================        
// changer

function void InitializeChangers() {

    anRequiredSkillPoints[0] = 5;
    anRequiredParamPoints[0] = 15;
    anRequiredGold[0] = 500;
    astrChangerDialog[0] = "translateEVENT_8";
    
    anRequiredSkillPoints[1] = 15;
    anRequiredParamPoints[1] = 30;
    anRequiredGold[1] = 2000;
    astrChangerDialog[1] = "translateEVENT_9";
    
}

function int GetChangerType(unit uUnit) {

    ASSERT(uUnit);
    return GetCustomFlags(uUnit) - eChanger1;

}

function int GetChangerFlags(int nChanger, unit uHero) {

    int i;
    UnitValues unVal;
    int nSkillPoints;
    int nParamPoints;
    int nGold;
    int nFlags;
    
    nFlags = eCDInputFlags;
    unVal = uHero.GetUnitValues();
   
    nGold = uHero.GetMoney();
    nSkillPoints = 0; 
    for (i = eSkillParry; i < eSkillsCnt; i++) nSkillPoints += unVal.GetBasicSkill(i);   
    nParamPoints = 0;
    for (i = 0; i < ePointsCnt; i++) nParamPoints += unVal.GetBasicPoint(i);

    if ((nParamPoints >= anRequiredParamPoints[nChanger]) && (nSkillPoints >= anRequiredSkillPoints[nChanger])) nFlags -= eCDHasEnoughPoints;
    else nFlags -= eCDHasntEnoughPoints;
    if (nGold >= anRequiredGold[nChanger]) nFlags -= eCDHasEnoughGold;
    else nFlags -= eCDHasntEnoughGold;    
         
    return nFlags;      
      
}

function void RemovePoints(unit uHero, int nSkillPoints, int nParamPoints, int nGold) {

    int i, n;
    int anPoints[];
    int anTypes[];
    UnitValues unVal;

    unVal = uHero.GetUnitValues();

#ifdef DIALOG_UNITS_DEBUG
    TRACE("Removing %d skill points and %d param points for %d gold\n",nSkillPoints,nParamPoints,nGold);
#endif

    // skill points    
    anPoints.RemoveAll();
    anTypes.RemoveAll();
    for (i = eSkillParry; i < eSkillsCnt; i++) if (unVal.GetBasicSkill(i) > 0) {
        anPoints.Add(unVal.GetBasicSkill(i));
        anTypes.Add(i);
    }       
    for (i = 0; i < nSkillPoints; i++) {
        n = Rand(anTypes.GetSize());
        anPoints[n] -= 1;
        if (anPoints[n] == 0) {
            unVal.SetBasicSkill(anTypes[n],0);
            anPoints.RemoveAt(n);
            anTypes.RemoveAt(n);        
        }    
    }
    for (i = 0; i < anPoints.GetSize(); i++) unVal.SetBasicSkill(anTypes[i],anPoints[i]);        
    unVal.SetSkillPoints(unVal.GetSkillPoints() + nSkillPoints);     

    // param points    
    anPoints.RemoveAll();
    anTypes.RemoveAll();
    for (i = 0; i < ePointsCnt; i++) if (unVal.GetBasicPoint(i) > 0) {
        anPoints.Add(unVal.GetBasicPoint(i));
        anTypes.Add(i);
    }       
    for (i = 0; i < nParamPoints; i++) {
        n = Rand(anTypes.GetSize());
        anPoints[n] -= 1;
        if (anPoints[n] == 0) {
            unVal.SetBasicPoint(anTypes[n],0);
            anPoints.RemoveAt(n);
            anTypes.RemoveAt(n);        
        }    
    }
    for (i = 0; i < anPoints.GetSize(); i++) unVal.SetBasicPoint(anTypes[i],anPoints[i]);        
    unVal.SetParamPoints(unVal.GetParamPoints() + nParamPoints);     

    // gold                   
    uHero.SetMoney(uHero.GetMoney() - nGold);
    
    uHero.UpdateChangedUnitValues();          

    uHero.GetMission().CreateObject(CHANGER_EFFECT,uHero.GetLocationX(),uHero.GetLocationY(),0,0);
                                          
}

function void StartTalkWithDialogUnitChanger(unit uDialogUnit, unit uHero) {

    int nChanger;
    nChanger = GetChangerType(uDialogUnit);
            
#ifdef DIALOG_UNITS_DEBUG
    TRACE("Starting changer dialog with flags %d\n",GetChangerFlags(nChanger,uHero));
#endif
    GetPlayerInterface(uHero.GetHeroPlayerNum()).PlayDialog(GetScriptUID(),eDialogChangerUID + nChanger,eDefDialogFlags | PlayDialogWaves(uHero),GetChangerFlags(nChanger,uHero),astrChangerDialog[nChanger],1,uHero,uDialogUnit);

}

function void EndTalkDialogChanger(int nPlayerNum, int nDialogUID, int nEndEvent) {
    
    unit uHero;    
    int nChanger;
    nChanger = nDialogUID - eDialogChangerUID;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);

#ifdef DIALOG_UNITS_DEBUG
    TRACE("Changer dialog finished with event %d\n",nEndEvent);
#endif
    if (nEndEvent & eCDRemovePoints) RemovePoints(uHero,anRequiredSkillPoints[nChanger],anRequiredParamPoints[nChanger],anRequiredGold[nChanger]);
                        
}

//======================================
// coach

function int GetCoachType(unit uUnit) {

    ASSERT(uUnit);
    return GetCustomFlags(uUnit) - eTrainer1 + 1;
    
}

function string GetCoachDialog(unit uUnit) {

    string str;
    #ifdef _DEMO
        str.Format(COACH_DIALOG_1,GetCoachType(uUnit));
    #else
        if (Rand(2)) str.Format(COACH_DIALOG_1,GetCoachType(uUnit));
        else str.Format(COACH_DIALOG_2,GetCoachType(uUnit));    
    #endif
    return str;
    
}

function void StartTalkWithDialogUnitCoach(unit uDialogUnit, unit uHero) {
    
    int nSkillFlags, nPriceFlags;
    string strDialog;
    int nCoach;
    
    nCoach = GetCoachType(uDialogUnit);        
    strDialog = GetCoachDialog(uDialogUnit);
    
    nPriceFlags = CalculatePriceFlags(uHero,uDialogUnit);//wycenia gracza
    nSkillFlags = CalculateSkillFlags(uHero,nCoach,nPriceFlags);//ustawia na podstawie ceny i bierzacych skilli gracza        
    
#ifdef DIALOG_UNITS_DEBUG
    TRACE("Starting coach dialog %s                         \n",strDialog);
#endif
    GetPlayerInterface(uHero.GetHeroPlayerNum()).PlayDialog(GetScriptUID(),eDialogCoachUID + nCoach,eDefDialogFlags | PlayDialogWaves(uHero),nPriceFlags+nSkillFlags,strDialog,1,uHero,uDialogUnit);

}

function void EndTalkDialogCoach(int nPlayerNum, int nDialogUID, int nEndEvent) {
    
    string strTrl;
    stringW strText, strSkill;
    unit uHero;
    int nGold;
    int nCoach;
    int nSkill;
    
    nCoach = nDialogUID - eDialogCoachUID;
    
#ifdef DIALOG_UNITS_DEBUG
    TRACE("Coach dialog finished with event %d\n",nEndEvent);
#endif
    
    if ((nEndEvent & 31) == 0) return;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);

    nSkill = AddSkillFromEvent(uHero,nCoach,nEndEvent);
    nGold = CalculatePriceFromFlagsAfterDialog(nEndEvent);
    AddMoney(uHero,-nGold);
    
    strTrl.Format("translateSkillName%d", nSkill);
    strSkill.Translate(strTrl);
    strText.FormatTrl("translateHeroLearntNewSkillFormat", strSkill);
    GetPlayerInterface(uHero.GetHeroPlayerNum()).SetConsoleText(strText,eConsoleTextTime,true);
                        
}

//======================================
// shop

function void InitializeShops() {

    auShops.RemoveAll();
    anLastShopUpdateTick.RemoveAll();
    nShopsNumber = 0;

}

function void UpdateShop(int nShop) {
    
    int uHero;
    int i, j;                               
                
    if ((GetCampaign().GetGameTick() - anLastShopUpdateTick[nShop]) < eShopUpdateTimeInterval) return;     
    if (GetNearestHeroA(auShops[nShop],M2A(2))) return;   
    anLastShopUpdateTick[nShop] = GetCampaign().GetGameTick();

    auShops[nShop].RemoveAllObjectsFromShop();

    for (i = 0; i < eMaxPlayers; i++) anPlayersLevels[i] = 0;

    for (i = 0; i < GetPlayersCnt(); i++) {
        
        if (!IsPlayer(i)) continue;

        anPlayersLevels[i] = GetHero(i).GetUnitValues().GetLevel();

        for (j = 0; j < i; j++) if (anPlayersLevels[j] == anPlayersLevels[i]) break;
        // jesli i == j to znaczy, ze nie znalezlismy gracza o takim samym levelu
        // wiec musimy dodac sprzet dla niego
        if (i == j) {
            FillShop(auShops[nShop],GetGuild(auShops[nShop]),anPlayersLevels[i]);        
        }

    }

}    

function void AddShop(unit uShop) {

    uShop.EnableShop(true);//xxxmd - uwaga problemy z walka
    auShops.Add(uShop);
    anLastShopUpdateTick.Add(GetCampaign().GetGameTick() - eShopUpdateTimeInterval);
    nShopsNumber = auShops.GetSize();

    CalculatePriceRanges(uShop,GetGuild(uShop));           
    UpdateShop(nShopsNumber - 1);

}

function void RemoveShops(int nMissionNum) {

    int i;

    i = 0;
    while (i < auShops.GetSize()) {
        if (auShops[i].GetMission().GetMissionNum() == nMissionNum && auShops[i].IsRemoveOnUnloadLevel()) {
            auShops.RemoveAt(i);
            anLastShopUpdateTick.RemoveAt(i);
        }
        else i++;
    }

    nShopsNumber = auShops.GetSize();

}
     
//======================================

function void RegisterSingleDialogUnit(unit uUnit) {

    if (nMultiplayer && !(uUnit.IsShopUnit() || IsShop(uUnit) || IsCoach(uUnit) || IsChanger(uUnit) || IsQuestUnit(uUnit))) SetNoDialogUnit(uUnit,true);
    
    // white dragon
    if (uUnit.GetNPCNameNum() == 132) SetNoDialogUnit(uUnit,true);

    SetIsDialogUnit(uUnit,GetScriptUID());
    SetInitialGuild(uUnit);

    if (uUnit.IsShopUnit()) AddShop(uUnit);       

}

//======================================
// states

state Initialize {

    ENABLE_TRACE(true);
        
    InitializeChangers();
    InitializeShops();
    InitializeWorldState();    
    InitializeCampMarkers();    

    return Nothing, 0;

}
    
state Nothing {

    int i;
    unit uHero;
    mission pMission;
           
    for (i = 0; i < GetPlayersCnt(); i++) {
    
        if (!IsPlayer(i)) continue;
        uHero = GetHero(i);
        pMission = uHero.GetMission();
        if (!IsCampCreated(pMission)) CreateCamp(pMission);
    
    }  

    for (i = 0; i < nShopsNumber; i++) UpdateShop(i);

    return Nothing, 5 * 30;
    
}    

//======================================
// dialog events

function void PlayDialog(int nDialogType, unit uDialogUnit, int nHero) {

    int i, count;
    mission pMission;

    if (nDialogType == eDialogAlarmingGuards) {

        pMission = uDialogUnit.GetMission();
        ASSERT(pMission != null);
        count = pMission.GetMissionScriptsCnt();
        for (i = 0; i < count; i++) pMission.GetMissionScript(i).CommandMessage(eMsgPlayAGDialog,nHero,uDialogUnit);
        return;
    
    }
    else if (nDialogType == eDialogQuest) {
    
        count = GetCampaign().GetGlobalScriptsCnt();
        for (i = 0; i < count; i++) GetCampaign().GetGlobalScript(i).CommandMessage(eMsgPlayQuestDialog,nHero,uDialogUnit);
        return;
    
    }
    else if (nDialogType == eDialogFindCriminal) {
    
        count = GetCampaign().GetGlobalScriptsCnt();
        for (i = 0; i < count; i++) GetCampaign().GetGlobalScript(i).CommandMessage(eMsgPlayFCDialog,nHero,uDialogUnit);
        return;
    
    }
    __ASSERT_FALSE();

}

event StartTalkWithDialogUnit(unit uDialogUnit, unit uHero, int nDialogUID) {

    int nMainState;
    int nFlags;

#ifdef DIALOG_UNITS_DEBUG
    TRACE("StartTalkWithDialogUnit number %d flags %d ms %d ds %d act %d eact %d party %d               \n",GetUnitNumber(uDialogUnit),GetCustomFlags(uDialogUnit),GetMainState(uDialogUnit),GetDailyState(uDialogUnit),GetActivity(uDialogUnit),GetExternalActivity(uDialogUnit),uDialogUnit.GetPartiesNums().ElementAt(0));        
#endif    

    nMainState = GetMainState(uDialogUnit);
    
    if (nMainState == eMainStateAlarmingGuards) {

        PlayDialog(eDialogAlarmingGuards,uDialogUnit,uHero.GetHeroPlayerNum());
        return true;
    
    }
    else if (IsQuestUnit(uDialogUnit) && (GetCurrentQuest(uDialogUnit) != eNoQuest)) {
    
        PlayDialog(eDialogQuest,uDialogUnit,uHero.GetHeroPlayerNum());
        return true;
    
    }
    else if (IsGuard(uDialogUnit) && GetGuardWorkState(uDialogUnit) == eGuardChasingCriminal) {

        PlayDialog(eDialogFindCriminal,uDialogUnit,uHero.GetHeroPlayerNum());
        return true;
    
    }
    else {
    
        if (nMainState == eMainStateNormal) {

            if (IsCoach(uDialogUnit)) StartTalkWithDialogUnitCoach(uDialogUnit,uHero);
            else if (IsChanger(uDialogUnit)) StartTalkWithDialogUnitChanger(uDialogUnit,uHero);
            else PlayStandardDialog(uHero,uDialogUnit);
            return true;
    
        }
    
    }
    
    return true;

}

event EndTalkDialog(int nPlayerNum, int nDialogUID, int nEndEvent) {

    if (nDialogUID >= eStandardDialogUID) EndTalkStandardDialog(nPlayerNum,nDialogUID,nEndEvent);
    else if (nDialogUID >= eDialogCoachUID) EndTalkDialogCoach(nPlayerNum,nDialogUID,nEndEvent);
    else if (nDialogUID >= eDialogChangerUID) EndTalkDialogChanger(nPlayerNum,nDialogUID,nEndEvent);

    return true;
    
}

//======================================
// other events

event OnUnloadLevel(mission pMission) {

    RemoveShops(pMission.GetMissionNum());    
    SetCampCreated(pMission,false);
    return true;

}

event RemovedNetworkPlayer(int nPlayerNum) {

    auDialogUnits[nPlayerNum] = null;
    return true;

}

//======================================

command Message(int nParam, int nValue) {

    if (nParam == eMsgSetMultiplayer) {
        
        nMultiplayer = nValue;
        return true;
        
    }
    
    return 0;
    
}

command Message(int nParam, unit uUnit) {

    if (nParam == eMsgRegisterSingleDialogUnit) {

//        ASSERT(uUnit != null);
        if (uUnit != null) RegisterSingleDialogUnit(uUnit);           
        return true;
    
    }

    return 0;

}

command Message(int nParam, int nValue, int nValue1, int nValue2) {

    if (nParam == eMsgSetWorldState) {
    
        if (nValue == 1) nWorldStateArea1 = nValue1;
        if (nValue == 2) nWorldStateArea2 = nValue1;
        if (nValue == 3) nWorldStateArea3 = nValue1;
        return true;
    
    }

    return 0;

}

command MessageGet(int nParam, int &nRetValue) {

    if (nParam == eMsgIsPentagramActive) {
    
        if (nWorldStateArea2 == 1) nRetValue = true;
        else nRetValue = false;
        return true;
    
    }

    if (nParam == eMsgGetDialogScriptUID) {
    
        nRetValue = GetScriptUID();
        return true;
    
    }

    return 0;

}

//======================================
       
#ifdef USE_COMMAND_DEBUG
command CommandDebug(string strLine) {
    
    if (!stricmp(strLine, "PrintShops")) {
        TRACE("ShopsNumber: %d\n",nShopsNumber);
    }
    else if (!stricmp(strLine, "PrintWorldState")) {
        TRACE("WorldState:                \n");
        TRACE("Area 1: %d                       \n",nWorldStateArea1);
        TRACE("Area 2: %d                       \n",nWorldStateArea2);
        TRACE("Area 3: %d                       \n",nWorldStateArea3);
    }
    else return false;

    return true;

}

#endif

//======================================
       
}
