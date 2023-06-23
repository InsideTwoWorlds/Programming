/*
//markery na ktirych stwarane sa postacie w miescie

                              "MARKER_PLAY"  - grajek na gitarze
                           "MARKER_PRAY"  - modlitwa 
                          "MARKER_WOODCUT" 
                            "MARKER_BROOM"
                          "MARKER_KNEEL"  - kleczenie i robienie czegos na ziemi
                        "MARKER_PICHFORK"
                           "MARKER_SCYTHE"
                           "MARKER_PINAXE"
                          "MARKER_WALKER" - ta postac chodzi po miescie
                         "MARKER_SITING" - siedzenie na ziemi 3 rozne animacje
                         
                 //kobiety
                          "MARKER_F_DANCE" - taniec
                          "MARKER_F_WALKER"
                          "MARKER_F_COOK" -gotowanie
                          "MARKER_F_PRAY" 
                          "MARKER_F_BROOM"
                          "MARKER_F_KNEEL"
                           
//markery ogólne niezalezne od miasta nie jest nannich nic tworzone
                        "MARKER_B_WOODCUT"
                        "MARKER_B_KNEEL"
                        "MARKER_B_SITING"

                         MARKER_BED  - lokator SLEEP   z markera pObject.GetMarkerObject(); pObject.GetLocator("SIT",nX,nY) i kierunek z obiektu.
                         
                         MARKER_CHEST - locator SIT


if (!nIsFemale) {
    
        if (nFlag == eBartender) {
            uUnit.CommandMakeCustomWork(5,-1,0,0,"");        
        }
        else if (nFlag == eWorkerPlay) {
            uUnit.CommandMakeCustomWork(0,-1,0,0,"");        
        }
        else if (nFlag == eWorkerPray) {
            uUnit.CommandMakeCustomWork(3,-1,0,0,"");        
        }
        else if (nFlag == eWorkerWoodcut) {
            if (Rand(2)) uUnit.CommandMakeCustomWork(4,-1,0,0,"AXE1");        
            else  uUnit.CommandMakeCustomWork(4,-1,0,0,"AXE2");        
        }    
        else if (nFlag == eWorkerBroom) {
            uUnit.CommandMakeCustomWork(6,-1,0,0,"BROOM");        
        }
        else if (nFlag == eWorkerKneel) {
            uUnit.CommandMakeCustomWork(7,-1,0,0,"");        
        }    
        else if (nFlag == eWorkerPitchfork) {    
            uUnit.CommandMakeCustomWork(8,-1,0,0,"PICHFORK");        
        }
        else if (nFlag == eWorkerScythe) {
            uUnit.CommandMakeCustomWork(9,-1,0,0,"SCYTHEA");      
        }
        else if (nFlag == eWorkerPinaxe) {
            uUnit.CommandMakeCustomWork(10,-1,0,0,"PINEAXE");      
        }
        else if (nFlag == eWorkerSitting) {
            n = Rand(5);
            if (n == 0) uUnit.CommandMakeCustomWork(11,-1,0,0,"");      
            if (n == 1) uUnit.CommandMakeCustomWork(12,-1,0,0,"STICK");      
            if (n == 2) uUnit.CommandMakeCustomWork(13,-1,0,0,"BOTTLE1");      
            if (n == 3) uUnit.CommandMakeCustomWork(13,-1,0,0,"BOTTLE2");      
            if (n == 4) uUnit.CommandMakeCustomWork(13,-1,0,0,"BOTTLE3");      
        }        

    }
    else {
    
        if (nFlag == eBartender) {
            uUnit.CommandMakeCustomWork(5,-1,0,0,"");        
        }
        else if (nFlag == eWorkerDance) {
            uUnit.CommandMakeCustomWork(0,-1,0,0,"");        
        }    
        else if (nFlag == eWorkerPray) {
            uUnit.CommandMakeCustomWork(3,-1,0,0,"");        
        }    
        else if (nFlag == eWorkerCook) {
            uUnit.CommandMakeCustomWork(4,-1,0,0,"");        
        }
        else if (nFlag == eWorkerBroom) {
            uUnit.CommandMakeCustomWork(6,-1,0,0,"BROOM");        
        }
        else if (nFlag == eWorkerKneel) {
            uUnit.CommandMakeCustomWork(7,-1,0,0,"");        
        }    
    
    }

}
*/



#define UNITS_HERO_EC

hero "hero"
{

////    Declarations    ////

state Initialize;
state Nothing;
state PrepareBeforeTalkWithDialogUnit;
state PrepareBeforeOpenContainerObject;
state WaitOpenContainerObject;
state PrepareBeforeOpenGate;
state WaitOpenGate;

unit m_uPickupObject;
unit m_uDialogUnit;
unit m_uContainerObject;
int  m_nContainerObjectPosX;
int  m_nContainerObjectPosY;

//#define STOPCURRENTACTION
function int StopCurrentAction();
#define CANCELSNEAKMODE
function void CancelSneakMode();

state StrikeAttackingTarget;
#define STATE_STRIKEATTACKINGTARGET StrikeAttackingTarget

#include "CommonUnits.ech"
#include "Move.ech"
#include "Alarm.ech"
#include "Attack.ech"
#include "MoveAttack.ech"
#include "Magic.ech"
#include "Skill.ech"
#include "Other.ech"

////    Functions    ////

function void ResetDialogUnit()
{
    if (m_uDialogUnit != null)
    {
        m_uDialogUnit.ResetAttribute("PreparingToDialog");
    }
    m_uDialogUnit = null;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function int StopCurrentAction()
{
    StopCurrentActionAttacking();
    StopCurrentActionMagic();
    m_uMountOnHorse = null;
    m_uPickupObject = null;
    ResetDialogUnit();
    m_uContainerObject = null;
    m_uTurnHeadObject = null;
	return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    States    ////

state Initialize
{
    return Nothing;   
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state PrepareBeforeTalkWithDialogUnit
{
    int bThisReady, bDialogUnitReady;
    
    if ((m_uDialogUnit == null) || !m_uDialogUnit.IsLive() || !m_uDialogUnit.IsStored() || !IsTheSameMission(m_uDialogUnit) || !m_uDialogUnit.IsDialogUnit())
    {
        if (IsMoving())
        {
            CallStopCurrentAction();
        }
        ResetDialogUnit();
        EndCommand(true);
        return Nothing, 0;
    }
    if (IsMoving())
    {
        CallStopCurrentAction();
    }
    else if (IsSettingArmedMode() || IsSettingSneakMode())
    {
    }
    else if (IsInArmedMode())
    {
        m_bAutoArmed = false;
        CallSetArmedMode(false);
    }
    else if (IsInSneakMode())
    {
        CallSetSneakMode(false);
    }
    else
    {
        bThisReady = true;
    }
//(p)    if (m_uDialogUnit.IsMoving() || m_uDialogUnit.IsSettingArmedMode() || m_uDialogUnit.IsSettingSneakMode())
    if (m_uDialogUnit.IsInDialogChat() || m_uDialogUnit.IsSettingArmedMode() || m_uDialogUnit.IsSettingSneakMode())
    {
    }
    else if (ABS(m_uDialogUnit.GetRelativeAngleTo(GetThis())) > 0x10)
    {
        m_uDialogUnit.CommandTurn(m_uDialogUnit.AngleTo(GetThis()));
    }
    else if (m_uDialogUnit.IsInArmedMode())
    {
        m_uDialogUnit.CommandSetArmedMode(false);
    }
    else if (m_uDialogUnit.IsInSneakMode())
    {
        m_uDialogUnit.CommandSkillSneak(false);
    }
    else
    {
        bDialogUnitReady = true;
    }
    if (bThisReady && bDialogUnitReady)
    {
        EndCommand(true);
        SetState(Nothing);
        //Start.. po EndCommand bo wewnatrz moga zostac wywolane nastepne komendy
        if (IsDialogUnitInTalkRange(m_uDialogUnit))
        {
            StartTalkWithDialogUnit(m_uDialogUnit);
        }
        ResetDialogUnit();
        return state, GetStateDelay();
    }
    else
    {
        return PrepareBeforeTalkWithDialogUnit, 15;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state PrepareBeforeOpenContainerObject
{
    int bThisReady, bContainerReady;
    
    if (!IsOpenContainerObjectType(m_uContainerObject, true))
    {
        if (IsMoving())
        {
            CallStopCurrentAction();
        }
        m_uContainerObject = null;
        EndCommand(true);
        return Nothing, 0;
    }
    if (IsMovingTurning() || IsTurningToGateOrContainerObject() || IsSettingArmedMode() || IsSettingSneakMode())
    {
    }
    else if (IsMoving())
    {
        CallStopCurrentAction();
    }
    else if (NeedTurnToGateOrContainerObject(m_uContainerObject, m_nContainerObjectPosX, m_nContainerObjectPosY))
    {
        CallTurnToGateOrContainerObject(m_uContainerObject, m_nContainerObjectPosX, m_nContainerObjectPosY);
    }
    else
    {
        bThisReady = true;
    }
    if (m_uContainerObject.IsShopUnit() && m_uContainerObject.IsLive())
    {
        if (m_uContainerObject.IsMovingTurning() || m_uContainerObject.IsSettingArmedMode() || m_uContainerObject.IsSettingSneakMode())
        {
        }
        else if (m_uContainerObject.IsMoving())
        {
            m_uContainerObject.CommandStop();
        }
        else if (ABS(m_uContainerObject.GetRelativeAngleTo(GetThis())) > 0x10)
        {
            m_uContainerObject.CommandTurn(m_uContainerObject.AngleTo(GetThis()));
        }
        else
        {
            bContainerReady = true;
        }
    }
    else
    {
        bContainerReady = true;
    }
    if (bThisReady && bContainerReady)
    {
        EndCommand(true);
        SetState(Nothing);
        //Start.. po EndCommand bo wewnatrz moga zostac wywolane nastepne komendy
        //nie sprawdzamy zasiegu dla deadBody ze wzgledu na RagDoll
        if (!m_uContainerObject.IsLive() || IsContainerObjectInOpenRange(m_uContainerObject))
        {
            if (!StartOpenContainerObject(m_uContainerObject, true))
            {
                return WaitOpenContainerObject, 0;
            }
            else
            {
                m_uContainerObject = null;
                return state, GetStateDelay();
            }
        }
        else
        {
            m_uContainerObject = null;
            return state, GetStateDelay();
        }
    }
    else
    {
        return PrepareBeforeOpenContainerObject, 5;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state WaitOpenContainerObject
{
    if (!StartOpenContainerObject(m_uContainerObject, false))
    {
        return WaitOpenContainerObject, 0;
    }
    else
    {
        m_uContainerObject = null;
        return Nothing, 0;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state PrepareBeforeOpenGate
{
    int bThisReady;
    
    if (!CanOpenGate(m_uContainerObject, true))
    {
        if (IsMoving())
        {
            CallStopCurrentAction();
        }
        m_uContainerObject = null;
        EndCommand(true);
        return Nothing, 0;
    }
    if (IsTurningToGateOrContainerObject())
    {
    }
    else if (NeedTurnToGateOrContainerObject(m_uContainerObject, m_uContainerObject.GetLocationX(), m_uContainerObject.GetLocationY()))
    {
        CallTurnToGateOrContainerObject(m_uContainerObject, m_uContainerObject.GetLocationX(), m_uContainerObject.GetLocationY());
    }
    else
    {
        bThisReady = true;
    }
    if (bThisReady)
    {
        EndCommand(true);
        SetState(Nothing);
        //Start.. po EndCommand bo wewnatrz moga zostac wywolane nastepne komendy
        if (!StartGateClickEvent(m_uContainerObject, true))
        {
            return WaitOpenGate, 0;
        }
        else
        {
            m_uContainerObject = null;
            return state, GetStateDelay();
        }
    }
    else
    {
        return PrepareBeforeOpenGate, 5;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state WaitOpenGate
{
    if (!StartGateClickEvent(m_uContainerObject, false))
    {
        return WaitOpenGate, 0;
    }
    else
    {
        m_uContainerObject = null;
        return Nothing, 0;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|


////    Events    ////

event GetCommandState(int nCommand)
{
    if (nCommand == eCommandSetArmedMode)
    {
        return GetCommandStateArmedMode();
    }
    else if (nCommand == eCommandSkillSneak)
    {
        return GetCommandStateSkillSneak();
    }
    return 0;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnAttackByOtherUnit(unit uAttacker)
{
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnStartDirectFightActionByEnemy(unit uAttacker)
{
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnHit(unit uByUnit)
{
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event AlarmEnemy(unit uEnemy)
{
    m_nLastAlarmTick = GetGameTick();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnStartKilledObjectAnim()
{
    ResetAttackTarget();
    ResetMagicTarget();
    m_uMountOnHorse = null;
    m_uPickupObject = null;
    ResetDialogUnit();
    m_uContainerObject = null;
    m_uTurnHeadObject = null;
    state Nothing;//na wypadek wskrzeszenia
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    Commands    ////

command Initialize()
{
    if (GetThis())
    {
        ENABLE_TRACE(false);
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Uninitialize()
{
    if (GetThis())
    {
        ResetAttackTarget();
        m_uDefender = null;
        ResetMagicTarget();
        m_uMountOnHorse = null;
        m_uPickupObject = null;
        ResetDialogUnit();
        m_uContainerObject = null;
        m_uTurnHeadObject = null;
        state Nothing;//na wypadek wskrzeszenia
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnUnloadLevel(mission pMission)
{
    if ((m_uTarget != null) && (m_uTarget.GetMission() == pMission))
    {
        m_uTarget = null;
    }
    if ((m_uDefender != null) && (m_uDefender.GetMission() == pMission))
    {
        m_uDefender = null;
    }
    if ((m_uMagicTarget != null) && (m_uMagicTarget.GetMission() == pMission))
    {
        m_uMagicTarget = null;
    }
    if ((m_uMountOnHorse != null) && (m_uMountOnHorse.GetMission() == pMission))
    {
        m_uMountOnHorse = null;
    }
    if ((m_uPickupObject != null) && (m_uPickupObject.GetMission() == pMission))
    {
        m_uPickupObject = null;
    }
    if ((m_uDialogUnit != null) && (m_uDialogUnit.GetMission() == pMission))
    {
        ResetDialogUnit();
    }
    if ((m_uContainerObject != null) && (m_uContainerObject.GetMission() == pMission))
    {
        m_uContainerObject = null;
    }
    if ((m_uTurnHeadObject != null) && (m_uTurnHeadObject.GetMission() == pMission))
    {
        m_uTurnHeadObject = null;
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveSubObjectToInventory(int nSlotNum, int nPosX, int nPosY, int nToItemNumber) hidden
{
    MoveSubObjectToInventory(nSlotNum, nPosX, nPosY, nToItemNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveSubObjectFromSlotToSlot(int nSlotNum, int nToSlotNum, int bSlotParam) hidden
{
    MoveSubObjectFromSlotToSlot(nSlotNum, nToSlotNum, bSlotParam);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveMagicFromSlotToInventory(int nMagicSlotNum, int bPowerUp, int nItemNumber) hidden
{
    MoveMagicFromSlotToInventory(nMagicSlotNum, bPowerUp, nItemNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveMagicFromSlotToSlot(int nMagicSlotNum, int nToMagicSlotNum, int bPowerUp, int nItemNumber) hidden
{
    MoveMagicFromSlotToSlot(nMagicSlotNum, nToMagicSlotNum, bPowerUp, nItemNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UseMagicCardOnSlot(int nCount, int nTmp1, int nTmp2, int nMagicSlotNum, int nMagicID) hidden
{
    UseMagicCardOnSlot(nMagicID, nCount, nMagicSlotNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UseObjectFromInventory(int nItemNumber, int nToSlotNum, int bSlotParam, int bShowUseEffect, int nItemID) hidden
{
    UseObjectFromInventory(nItemNumber, nToSlotNum, bSlotParam, nItemID, bShowUseEffect);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UsePrevWeapon() hidden
{
    UsePrevWeapon();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UseNextWeapon() hidden
{
    UseNextWeapon();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UseRegenerateHPPotion() priority PRIOR_USEHPPOTION hidden
{
    UseRegenerateHPPotion();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UseRegenerateManaPotion() priority PRIOR_USEMANAPOTION hidden
{
    UseRegenerateManaPotion();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command JoinInventoryObjects(int nItemNumber, int nToItemNumber, int nTmp) hidden
{
    JoinInventoryObjects(nItemNumber, nToItemNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetInventoryObjectPos(int nItemNumber, int nPosX, int nPosY) hidden
{
    SetInventoryObjectPos(nItemNumber, nPosX, nPosY);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command AutoArrangeInventory() hidden
{
    AutoArrangeInventory();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DropSubObject(int nSlotNum) hidden
{
    DropSubObject(nSlotNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DropInventory(int nItemID, int nItemNumber) hidden
{
    DropInventory(nItemNumber, nItemID);//OK, parametry na odwrot jak w komendzie
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DropMoney(int nMoney) hidden
{
    DropMoney(nMoney);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DropMagicFromSlot(int nMagicSlotNum, int bPowerUp, int nItemNumber) hidden
{
    DropMagicFromSlot(nMagicSlotNum, bPowerUp, nItemNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DropAlchemyItem(int nSlotIndex, int nTmp1, int nTmp2) hidden
{
    DropAlchemyItem(nSlotIndex);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveInventoryToAlchemyItem(int nItemNumber, int nToSlotIndex, int nTmp1, int nTmp2, int nItemID) hidden
{
    MoveInventoryToAlchemyItem(nItemNumber, nToSlotIndex, nItemID);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveAlchemyItemToInventory(int nSlotIndex, int nPosX, int nPosY, int nToItemNumber, int nTmp) hidden
{
    MoveAlchemyItemToInventory(nSlotIndex, nPosX, nPosY, nToItemNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveAlchemyItemFromSlotToSlot(int nSlotIndex, int nToSlotIndex, int nTmp1, int nTmp2, int nTmp3) hidden
{
    MoveAlchemyItemFromSlotToSlot(nSlotIndex, nToSlotIndex);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MakeAlchemy() hidden
{
    MakeAlchemy();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command AddAlchemyResultFormula(int nTmp, string strFormulaName) hidden
{
    AddAlchemyResultFormula(strFormulaName);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetAlchemyFormulaName(int nFormulaNumber, string strFormulaName) hidden
{
    SetAlchemyFormulaName(nFormulaNumber, strFormulaName);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DeleteAlchemyFormula(int nFormulaNumber) hidden
{
    DeleteAlchemyFormula(nFormulaNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command LoadAlchemyFormula(int nFormulaNumber) hidden
{
    LoadAlchemyFormula(nFormulaNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UnloadAlchemyFormula(int nFormulaNumber) hidden
{
    UnloadAlchemyFormula(nFormulaNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveAlchemyFormulaUp(int nFormulaNumber) hidden
{
    MoveAlchemyFormulaUp(nFormulaNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MoveAlchemyFormulaDown(int nFormulaNumber) hidden
{
    MoveAlchemyFormulaDown(nFormulaNumber);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command PickUpObject(unit uPickupObject) hidden
{
    if ((uPickupObject == null) || !uPickupObject.IsLive() || !uPickupObject.IsStored() || !IsTheSameMission(uPickupObject) || !CanPickUpObject(uPickupObject))
    {
        EndCommand(true);
        return true;
    }
    if (IsObjectInPickUpRange(uPickupObject))
    {
        PickUpObject(uPickupObject);
    }
    EndCommand(true);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SwitchObject(unit uSwitchObject) hidden
{
    if ((uSwitchObject == null) || !uSwitchObject.IsLive() || !uSwitchObject.IsStored() || !IsTheSameMission(uSwitchObject) || !CanSwitchObject(uSwitchObject))
    {
        EndCommand(true);
        return true;
    }
    if (IsObjectInSwitchRange(uSwitchObject))
    {
        SwitchObject(uSwitchObject);
    }
    EndCommand(true);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetPoint(int nPointIndex, int bIncrease, int nMinPoint) hidden
{
    SetPoint(nPointIndex, bIncrease, nMinPoint);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetSkill(int nParamIndex, int bIncrease, int nMinParam) hidden
{
    SetSkill(nParamIndex, bIncrease, nMinParam);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command TalkWithDialogUnit(unit uDialogUnit) hidden
{
    if ((uDialogUnit == null) || !uDialogUnit.IsLive() || !uDialogUnit.IsStored() || !IsTheSameMission(uDialogUnit) || !uDialogUnit.IsDialogUnit())
    {
        EndCommand(true);
        return true;
    }
    if (!IsDialogUnitInTalkRange(uDialogUnit))
    {
        EndCommand(true);
        return true;
    }
    CHECK_STOP_CURR_ACTION();
    if (IsMoving())
    {
        CallStopCurrentAction();
    }
    m_uDialogUnit = uDialogUnit;
    m_uDialogUnit.SetAttribute("PreparingToDialog", true);
    m_uDialogUnit.CommandStop();
    state PrepareBeforeTalkWithDialogUnit;
    SetStateDelay(0);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command ClickEventOnGate(unit uGate) hidden
{
    if ((m_uContainerObject == uGate) && ((state == PrepareBeforeOpenGate) || (state == WaitOpenGate)))
    {
        return true;
    }
    CHECK_STOP_CURR_ACTION();
    if (IsMoving())
    {
        CallStopCurrentAction();
    }
    if (!CanOpenGate(uGate, true))
    {
        EndCommand(true);
        state Nothing;
        return true;
    }
    m_uContainerObject = uGate;
    state PrepareBeforeOpenGate;
    SetStateDelay(0);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command OpenContainerObject(unit uContainerObject, int nPosX, int nPosY, int nPosZ) hidden
{
    if ((m_uContainerObject == uContainerObject) && ((state == PrepareBeforeOpenContainerObject) || (state == WaitOpenContainerObject)))
    {
        return true;
    }
    CHECK_STOP_CURR_ACTION();
    if (IsMoving())
    {
        CallStopCurrentAction();
    }
    if (!IsOpenContainerObjectType(uContainerObject, true))
    {
        EndCommand(true);
        state Nothing;
        return true;
    }
    //nie sprawdzamy zasiegu dla deadBody ze wzgledu na RagDoll
    if (uContainerObject.IsLive() && !IsContainerObjectInOpenRange(uContainerObject))
    {
        EndCommand(true);
        return true;
    }
    CHECK_STOP_CURR_ACTION();
    m_uContainerObject = uContainerObject;
    m_nContainerObjectPosX = nPosX;
    m_nContainerObjectPosY = nPosY;
    if (m_uContainerObject.IsUnit() && m_uContainerObject.IsLive())//shop
    {
        m_uContainerObject.CommandStop();
    }
    state PrepareBeforeOpenContainerObject;
    SetStateDelay(0);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetObjectFromContainer(unit uContainer, int nItemNumber, int nPosXY, int nToItemNumber, int bToSlot, int nItemID) hidden
{
    GetObjectFromContainer(uContainer, nItemNumber, nPosXY, nToItemNumber, bToSlot, nItemID);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetAllFromContainer(unit uContainer) hidden
{
    GetAllFromContainer(uContainer);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command PutObjectToContainer(unit uContainer, int nItemNumber, int nFromSlotIndex, int nFromMagicSlot, int bFromSlot, int nItemID) hidden
{
    PutObjectToContainer(uContainer, nItemNumber, nFromSlotIndex, nFromMagicSlot, bFromSlot, nItemID);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command OpenTeleport(unit uTeleport) hidden
{
    OpenTeleport(uTeleport);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command TeleportToActiveTargetTeleport(unit uTargetTeleport) hidden
{
    TeleportToActiveTargetTeleport(uTargetTeleport);
    GetCampaign().CommandMessage(eMsgAchievement, eAchievementMakeASuccessfulTeleportation, GetThis());
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command PutObjectToTradeContainer(int nItemNumber, int nFromSlotIndex, int nFromMagicSlot, int bFromSlot, int nItemID) hidden
{
    PutObjectToTradeContainer(nItemNumber, nFromSlotIndex, nFromMagicSlot, bFromSlot, nItemID);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetObjectFromTradeContainer(int nItemNumber, int nPosXY, int nToItemNumber, int bToSlot, int nItemID) hidden
{
    GetObjectFromTradeContainer(nItemNumber, nPosXY, nToItemNumber, bToSlot, nItemID);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetAllFromTradeContainer() hidden
{
    GetAllFromTradeContainer();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DecideAboutTrade(int bAgree) hidden
{
    DecideAboutTrade(bAgree);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command PlayerLeftTrade() hidden
{
    PlayerLeftTrade();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|


}
