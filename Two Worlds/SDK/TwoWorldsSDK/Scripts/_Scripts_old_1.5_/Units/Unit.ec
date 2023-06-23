#define UNITS_UNIT_EC

unit "unit"
{

////    Declarations    ////

state Initialize;
state Nothing;

#define STOPCURRENTACTION
function int StopCurrentAction();

#define AUTOCASTMAGICBEFOREFIGHT
function int AutoCastMagicBeforeFight(unit uTarget);
function int GetAutoCastMagicProbabilityBeforeFight();

#define AUTOCASTMAGICDURINGFIGHT
function int AutoCastMagicDuringFight(unit uTarget);
function int GetAutoCastMagicProbabilityDuringFight();
function int HaveMagicDistanceWeapon();

#include "CommonUnits.ech"
#include "Move.ech"
#include "Alarm.ech"
#include "Attack.ech"
#include "MoveAttack.ech"
#include "Magic.ech"
#include "Skill.ech"
#include "Activity.ech"
#include "Other.ech"
#include "MoveRandom.ech"

////    Functions    ////

function int StopCurrentAction()
{
    StopCurrentActionAttacking();
    m_uMountOnHorse = null;
    m_uTurnHeadObject = null;
    ResetActivity();
	return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    States    ////

state Initialize
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    int bTarget;
    unit uOwner;
    int nDelay;
    int nX, nY;
    
    nDelay = 20;
     
    if (CanBeDialogUnit(GetThis()) && !IsDialogUnit(GetThis())) SetIsDialogUnit(GetThis());
        
    if (StepTurnHead())
    {
        nDelay = 0;
    }

    if (HaveMagicDistanceWeapon() && (Rand(100) < GetAutoCastMagicProbabilitySearchTarget()))
    {    
        bTarget = FindMagicAttackTarget();
    }
    if (!bTarget && HaveUsableWeapon())
    {
        bTarget = FindNothingTarget();
    }
    if (!bTarget)
    {
        if (m_bAutoArmed)
        {
            m_bAutoArmed = false;
            CallSetArmedMode(false);
            return SettingUnarmedModeAfterAttack;
        }
        SetAutoRunMode(false);
        if (UpdateActivity()) {
            return state, nDelay;        
        }                
        uOwner = GetSummonedUnitOwner();
        if ((uOwner != null) && (DistanceTo(uOwner) > e5m))
        {
            CalcMoveToNearUnitPos(uOwner, e2m, nX, nY);
            SetAutoRunMode(true);
            MakeCommandMoveAttack(nX, nY, GetLocationZ());
        }
        if (!CheckMoveRandomInNothing(20))
        {
            return Nothing, nDelay;
        }
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
    if (HasCommonParty(uAttacker)) return true; //(p)
    if (OnAttackByOtherUnitAutoCastMagic(uAttacker, false))
    {
        return true;
    }
    return OnAttackByOtherUnit(uAttacker, false);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnStartDirectFightActionByEnemy(unit uAttacker)
{
    if (HasCommonParty(uAttacker)) return true; //(p)
    if (OnAttackByOtherUnitAutoCastMagic(uAttacker, false))
    {
        return true;
    }
    return OnStartDirectFightActionByEnemy(uAttacker);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnHit(unit uByUnit)
{
    if (uByUnit.IsHeroUnit())
    {
        if ((HasCommonParty(uByUnit) || (!IsEnemy(uByUnit) && !uByUnit.IsEnemy(GetThis()))) && 
            ((uByUnit.GetTicksSinceLastAttackEnemy() < 3*30) || ((GetAttackTarget() != null) && (GetAttackTarget() != uByUnit))))
        {
            return true; //(p)
        }
    }
    else
    {
        if ((HasCommonParty(uByUnit) || (!IsEnemy(uByUnit) && !uByUnit.IsEnemy(GetThis()))) && 
            ((uByUnit.GetTicksSinceLastAttackEnemy() < 3*30) || ((GetAttackTarget() != null) && (GetAttackTarget() != uByUnit))))
        {
            return true; //(p)
        }
    }
    if (uByUnit != null)
    {
        SendMessageToScripts(eMsgUnitAttacked,GetThis(),uByUnit); //(p)        
        if (!OnAttackByOtherUnitAutoCastMagic(uByUnit, true))
        {
            OnAttackByOtherUnit(uByUnit, true);
        }
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event AlarmEnemy(unit uEnemy)
{
    int bTarget;
    
    m_nLastAlarmTick = GetGameTick();

    if ((state == Nothing) || (state == Moving) || (state == MovingAndAttack) || (state == MakingCustomWork) || IsInActivityState())
    {    
        if (state == MakingCustomWork || IsInActivityState()) {
            StopCurrentActionImmediate();
            state Nothing;
        }
        if (HaveMagicDistanceWeapon() && (Rand(100) < GetAutoCastMagicProbabilitySearchTarget())/* &&
            IsObjectInSightOrHearRange(uEnemy, true)*/)
        {
            bTarget = AutoCastMagicAttackEnemy(uEnemy, true);
        }
        if (!bTarget && HaveUsableWeapon() /*&& IsObjectInSightOrHearRange(uEnemy, true)*/)
        {
            CHECK_CANCEL_SNEAKMODE();
            StoreHoldPos();
            BeginAttackTarget(uEnemy, true, true, true);
            SetStateDelay(0);
        }
        else if (state == Nothing)
        {
            CallTurnToAngle(AngleTo(uEnemy));
        }
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnStartKilledObjectAnim()
{
    ResetAttackTarget();
    ResetMagicTarget();
    m_uMountOnHorse = null;
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
    if ((m_uTurnHeadObject != null) && (m_uTurnHeadObject.GetMission() == pMission))
    {
        m_uTurnHeadObject = null;
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

}
