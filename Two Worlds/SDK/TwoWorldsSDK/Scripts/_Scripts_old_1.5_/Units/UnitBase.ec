#define UNITS_UNITBASE_EC

unit "unitbase"
{

////    Declarations    ////

state Initialize;
state Nothing;

#define STOPCURRENTACTION
function int StopCurrentAction();

#include "CommonUnits.ech"
#include "Move.ech"
#include "MoveAttack.ech"
#include "Alarm.ech"
#include "MoveRandom.ech"

////    Functions    ////

function int StopCurrentAction()
{
	return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    States    ////

state Initialize
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    unit uUnit;
    
    if (GetUnitTypeFlags() & eUnitTypeRunAwayFromUnits)
    {
        uUnit = SearchOneUnit(eTargetTypeLand | eTargetTypeUnit | eTargetTypeLive, GetSinglePartyArray(eAnyPartyNum));
        if (uUnit != null)
        {
            SetAutoRunMode(true);
            MoveAwayFromObjectRandAngle(uUnit, e16m, 16);
            AlarmPartyUnitsAboutEnemy(uUnit);
            return Moving;
        }
    }
    SetAutoRunMode(false);
    if (!CheckMoveRandomInNothing(60))
    {
        return Nothing, 60;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    Events    ////

event GetCommandState(int nCommand)
{
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
    if ((GetHorseRider() != null) && (uByUnit != null))
    {
        GetHorseRider().SetEventAttackByOtherUnit(uByUnit);
    }
    SetAutoRunMode(true);
    MoveAwayFromObjectRandAngle(uByUnit, e16m, 16);
    AlarmPartyUnitsAboutEnemy(uByUnit);
    state Moving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event AlarmEnemy(unit uEnemy)
{
    m_nLastAlarmTick = GetGameTick();
    
    if (state == Nothing)
    {
        CallTurnToAngle(AngleTo(uEnemy));
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnStartKilledObjectAnim()
{
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
        state Nothing;//na wypadek wskrzeszenia
    }
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event OnUnloadLevel(mission pMission)
{
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

}
