RPGCompute "RPGCompute"
{
#define NEW_BALANCING
////    Declarations    ////

//int m_arrMultiValueDivider[11];
int m_arrAddSkillsInEquipment[];
stringW m_arrAddPointFormat[ePointsCnt];
stringW m_arrAddParamFormat[eParamsCnt];
stringW m_arrAddProtectFormat[eProtectsCnt];
string m_arrPointInfoFormat[eParamsCnt];
string m_arrPointInfoFormat2[eParamsCnt];
string m_arrPointInfoFormat2Neg[eParamsCnt];
string m_arrSkillMagicShool[5];
stringW m_arrAddSkillInfoFormat[eSkillsCnt];
stringW m_arrMagicCardPowerUpName[eMagicCardPowerUpCnt];
stringW m_arrDamageName[12];
stringW m_arrArmourName[6];
string m_arrLockpickChance[8];
string m_arrLockName[9];
string astrPointName[ePointsCnt];
string astrParamName[eParamsCnt];
string astrProtectName[eProtectsCnt];
stringW m_arrRequiredMagicSchool[5];
//int m_arrExperiencePointsForLevel[512];


consts
{
    ePointsPerLevel = 5;//mnoznik do roznych celow
    eSacrificeDamageMul = 2;
    eParamPointsPerLevel = 5;
    eSkillPointsPerLevel = 1;
}

#include "..\\Common\\Generic.ech"
//#include "..\\Common\\Quest.ech"
#include "Equipment.ech"
#include "Weapon.ech"
#include "Unit.ech"
#include "Magic.ech"
#include "DefaultEvents.ech"
#include "Alchemy.ech"
#include "Info.ech"


////    Commands    ////

state Nothing
{
}

command Initialize()
{
  

    m_arrLockpickChance[1] = "translateSkillLockPickingChance1";
    m_arrLockpickChance[2] = "translateSkillLockPickingChance2";
    m_arrLockpickChance[3] = "translateSkillLockPickingChance3";
    m_arrLockpickChance[4] = "translateSkillLockPickingChance4";
    m_arrLockpickChance[5] = "translateSkillLockPickingChance5";
    m_arrLockpickChance[6] = "translateSkillLockPickingChance6";
    m_arrLockpickChance[7] = "translateSkillLockPickingChance7";


    m_arrLockName[0] = "translateLockLevel0";
    m_arrLockName[1] = "translateLockLevel1";
    m_arrLockName[2] = "translateLockLevel2";
    m_arrLockName[3] = "translateLockLevel3";
    m_arrLockName[4] = "translateLockLevel4";
    m_arrLockName[5] = "translateLockLevel5";
    m_arrLockName[6] = "translateLockLevel6";
    m_arrLockName[7] = "translateLockLevel7";
    m_arrLockName[8] = "translateLockLevel8";

    
    
    m_arrAddSkillsInEquipment.Add(eSkillParry);//0
    m_arrAddSkillsInEquipment.Add(eSkillStability);
    m_arrAddSkillsInEquipment.Add(eSkillStrongHand);
    m_arrAddSkillsInEquipment.Add(eSkillCriticalHit);
    m_arrAddSkillsInEquipment.Add(eSkillStoneSkin);
    m_arrAddSkillsInEquipment.Add(eSkillKnockDown);
    m_arrAddSkillsInEquipment.Add(eSkillStoneSkin);//6
    m_arrAddSkillsInEquipment.Add(eSkillLockPicking);
    m_arrAddSkillsInEquipment.Add(eSkillHorseRiding);//8
    
    m_arrAddSkillsInEquipment.Add(eSkillBerserk);//9    //dotad bron
    m_arrAddSkillsInEquipment.Add(eSkillDefensiveFight);// 
    m_arrAddSkillsInEquipment.Add(eSkillDirtyTrick);
    m_arrAddSkillsInEquipment.Add(eSkillStun);
    m_arrAddSkillsInEquipment.Add(eSkillShieldTrick);
    m_arrAddSkillsInEquipment.Add(eSkillPullShield);
    
    m_arrAddSkillsInEquipment.Add(eSkillStrongHand);//15
    m_arrAddSkillsInEquipment.Add(eSkillDismountFromHorse);
    
    m_arrAddSkillsInEquipment.Add(eSkillKnifeDeathStrike);
    m_arrAddSkillsInEquipment.Add(eSkillDeadlyPiruet);
    m_arrAddSkillsInEquipment.Add(eSkillBurn);
    //19
        
    m_arrAddSkillsInEquipment.Add(eSkillFastAiming);//20
    m_arrAddSkillsInEquipment.Add(eSkillArchery);
    m_arrAddSkillsInEquipment.Add(eSkillCloseDistanceShoot);
    m_arrAddSkillsInEquipment.Add(eSkillPrecizeAiming);//23
    
    m_arrAddSkillsInEquipment.Add(eSkillAlchemy);//24
    m_arrAddSkillsInEquipment.Add(eSkillAirMagic);
    m_arrAddSkillsInEquipment.Add(eSkillFireMagic);
    m_arrAddSkillsInEquipment.Add(eSkillWaterMagic);
    m_arrAddSkillsInEquipment.Add(eSkillEarthMagic);
    m_arrAddSkillsInEquipment.Add(eSkillNecromancyMagic);//29    

    m_arrMagicCardPowerUpName[eMagicCardPowerUpDamage].Translate("translateSpellPowerUpDamage");
    m_arrMagicCardPowerUpName[eMagicCardPowerUpMagicTime].Translate("translateSpellPowerUpMagicTime");
    m_arrMagicCardPowerUpName[eMagicCardPowerUpUsedMana].Translate("translateSpellPowerUpUsedMana");
    m_arrMagicCardPowerUpName[eMagicCardPowerUpMagicLevel].Translate("translateSpellPowerUpMagicLevel");
    m_arrMagicCardPowerUpName[eMagicCardPowerUpSummonLevel].Translate("translateSpellPowerUpSummonLevel");
        
    m_arrDamageName[0].Translate("translateDamage0");
    m_arrDamageName[1].Translate("translateDamage1");
    m_arrDamageName[2].Translate("translateDamage2");
    m_arrDamageName[3].Translate("translateDamage3");
    m_arrDamageName[4].Translate("translateDamage4");
    m_arrDamageName[5].Translate("translateDamage5");
    m_arrDamageName[6].Translate("translateDamage6");
    m_arrDamageName[7].Translate("translateDamage7");
    m_arrDamageName[8].Translate("translateDamageBow");
    m_arrDamageName[9].Translate("translateRangeBow");
    m_arrDamageName[10].Translate("translateAccuracyBow");
    m_arrDamageName[11].Translate("translateTrapHoldTime");

    m_arrArmourName[0].Translate("translateProtect0");
    m_arrArmourName[1].Translate("translateProtect1");
    m_arrArmourName[2].Translate("translateProtect2");
    m_arrArmourName[3].Translate("translateProtect3");
    m_arrArmourName[4].Translate("translateProtect4");
    m_arrArmourName[5].Translate("translateProtect5");
    
    
    astrPointName[ePointsVitality]="translatePotionAddVit";
    astrPointName[ePointsDexterity]="translatePotionAddDex";
    astrPointName[ePointsStrength]="translatePotionAddStr";
    astrPointName[ePointsMagic]="translatePotionAddMag";
    
    astrParamName[eParamHP]="translatePotionAddMaxHP";
    astrParamName[eParamDamage]="translatePotionAddDamage";
    astrParamName[eParamAttack]="translatePotionAddAttack";
    astrParamName[eParamDefence]="translatePotionAddDefence";
    astrParamName[eParamMana]="translatePotionAddMaxMana";

    astrProtectName[eProtectPhysical]="translatePotionAddProtectPhysical";
    astrProtectName[eProtectCold]="translatePotionAddProtectCold";
    astrProtectName[eProtectFire]="translatePotionAddProtectFire";
    astrProtectName[eProtectElectric]="translatePotionAddProtectElectric";
    astrProtectName[eProtectSpirit]="translatePotionAddProtectSpirit";
    
    m_arrSkillMagicShool[0] =  "translateSkillAirMagic";
    m_arrSkillMagicShool[1] =  "translateSkillFireMagic";
    m_arrSkillMagicShool[2] =  "translateSkillWaterMagic";
    m_arrSkillMagicShool[3] =  "translateSkillEarthMagic";
    m_arrSkillMagicShool[4] =  "translateSkillNecromancyMagic";
    
    m_arrAddPointFormat[ePointsVitality].Translate("translateAddParamPointsVitality");
    m_arrAddPointFormat[ePointsDexterity].Translate("translateAddParamPointsDexterity");
    m_arrAddPointFormat[ePointsStrength].Translate("translateAddParamPointsStrength");
    m_arrAddPointFormat[ePointsMagic].Translate("translateAddParamPointsMagic");
    
    m_arrAddParamFormat[eParamHP].Translate("translateAddParamHP");
    m_arrAddParamFormat[eParamDamage].Translate("translateAddParamDamage");
    m_arrAddParamFormat[eParamAttack].Translate("translateAddParamAttack");
    m_arrAddParamFormat[eParamDefence].Translate("translateAddParamDefence");
    m_arrAddParamFormat[eParamMana].Translate("translateAddParamMana");
    m_arrAddParamFormat[eParamStamina].Translate("translateAddParamStamina");

    m_arrAddProtectFormat[eProtectPhysical].Translate("translateAddProtectPhysical");
    m_arrAddProtectFormat[eProtectCold].Translate("translateAddProtectCold");
    m_arrAddProtectFormat[eProtectFire].Translate("translateAddProtectFire");
    m_arrAddProtectFormat[eProtectElectric].Translate("translateAddProtectElectric");
    

    m_arrPointInfoFormat[ePointsVitality] = "translateParamVitality";
    m_arrPointInfoFormat[ePointsDexterity] = "translateParamDexterity";
    m_arrPointInfoFormat[ePointsStrength] = "translateParamStrength";
    m_arrPointInfoFormat[ePointsMagic] = "translateParamMagic";
    m_arrPointInfoFormat2[ePointsVitality] = "translateParamVitality2";
    m_arrPointInfoFormat2[ePointsDexterity] = "translateParamDexterity2";
    m_arrPointInfoFormat2[ePointsStrength] = "translateParamStrength2";
    m_arrPointInfoFormat2[ePointsMagic] = "translateParamMagic2";
    m_arrPointInfoFormat2Neg[ePointsVitality] = "translateParamVitality2Neg";
    m_arrPointInfoFormat2Neg[ePointsDexterity] = "translateParamDexterity2Neg";
    m_arrPointInfoFormat2Neg[ePointsStrength] = "translateParamStrength2Neg";
    m_arrPointInfoFormat2Neg[ePointsMagic] = "translateParamMagic2Neg";


    m_arrAddSkillInfoFormat[eSkillParry].Translate(            "translateAddSkillParry");
    m_arrAddSkillInfoFormat[eSkillSwimming].Translate(         "translateAddSkillSwimming");
    m_arrAddSkillInfoFormat[eSkillStability].Translate(        "translateAddSkillStability");
    m_arrAddSkillInfoFormat[eSkillStrongHand].Translate(       "translateAddSkillStrongHand");
    m_arrAddSkillInfoFormat[eSkillCriticalHit].Translate(      "translateAddSkillCriticalHit"); //"PM First Strike: %d");
    m_arrAddSkillInfoFormat[eSkillDoubleBlade].Translate(      "translateAddSkillDoubleBlade");
    m_arrAddSkillInfoFormat[eSkillKnockDown].Translate(        "translateAddSkillKnockDown");
    m_arrAddSkillInfoFormat[eSkillHorseRiding].Translate(      "translateAddSkillHorseRiding");
    m_arrAddSkillInfoFormat[eSkillFastAiming].Translate(       "translateAddSkillFastAiming");   //"P  Armour knowledge: %d");
    m_arrAddSkillInfoFormat[eSkillArchery].Translate(          "translateAddSkillArchery");
    m_arrAddSkillInfoFormat[eSkillCloseDistanceShoot].Translate("translateAddSkillCloseDistanceShoot");
    m_arrAddSkillInfoFormat[eSkillPrecizeAiming].Translate(    "translateAddSkillPrecizeAiming");
    m_arrAddSkillInfoFormat[eSkillStoneSkin].Translate(        "translateAddSkillStoneSkin");
    m_arrAddSkillInfoFormat[eSkillLockPicking].Translate(      "translateAddSkillLockPicking");
    m_arrAddSkillInfoFormat[eSkillAlchemy].Translate(          "translateAddSkillAlchemy");
    m_arrAddSkillInfoFormat[eSkillAirMagic].Translate(         "translateAddSkillAirMagic");
    m_arrAddSkillInfoFormat[eSkillFireMagic].Translate(        "translateAddSkillFireMagic");
    m_arrAddSkillInfoFormat[eSkillWaterMagic].Translate(       "translateAddSkillWaterMagic");
    m_arrAddSkillInfoFormat[eSkillEarthMagic].Translate(       "translateAddSkillEarthMagic");
    m_arrAddSkillInfoFormat[eSkillNecromancyMagic].Translate(  "translateAddSkillNecromancyMagic");
    m_arrAddSkillInfoFormat[eSkillBerserk].Translate(          "translateAddSkillBerserk");
    m_arrAddSkillInfoFormat[eSkillDefensiveFight].Translate(   "translateAddSkillDefensiveFight");
    m_arrAddSkillInfoFormat[eSkillDirtyTrick].Translate(       "translateAddSkillDirtyTrick");
    m_arrAddSkillInfoFormat[eSkillStun].Translate(             "translateAddSkillStun");
    m_arrAddSkillInfoFormat[eSkillSwordBrake].Translate(       "translateAddSkillSwordBreak");
    m_arrAddSkillInfoFormat[eSkillDismountFromHorse].Translate("translateAddSkillDismountFromHorse");
    m_arrAddSkillInfoFormat[eSkillPullShield].Translate(       "translateAddSkillPullShield");
    m_arrAddSkillInfoFormat[eSkillKnifeDeathStrike].Translate( "translateAddSkillKnifeDeathStrike");
    m_arrAddSkillInfoFormat[eSkillDeadlyPiruet].Translate(     "translateAddSkillDeadlyPiruet");
    m_arrAddSkillInfoFormat[eSkillBurn].Translate(             "translateAddSkillBurn");
    m_arrAddSkillInfoFormat[eSkillShieldTrick].Translate(      "translateAddSkillShieldTrick");
    m_arrAddSkillInfoFormat[eSkillDisarmingArrow].Translate(   "translateAddSkillDisarmingArrow");
    m_arrAddSkillInfoFormat[eSkillMultiArrows].Translate(      "translateAddSkillMultiArrows");
    m_arrAddSkillInfoFormat[eSkillPiercing].Translate(         "translateAddSkillPiercing");
    m_arrAddSkillInfoFormat[eSkillArrowOfDust].Translate(      "translateAddSkillArrowOfDust");
    m_arrAddSkillInfoFormat[eSkillSneak].Translate(            "translateAddSkillSneak");
    m_arrAddSkillInfoFormat[eSkillStealing].Translate(         "translateAddSkillStealing");
    m_arrAddSkillInfoFormat[eSkillSetTrap].Translate(          "translateAddSkillSetTrap");

    m_arrRequiredMagicSchool[0].Translate("translateRequiredAirMagicSchoolSkill");
    m_arrRequiredMagicSchool[1].Translate("translateRequiredFireMagicSchoolSkill");
    m_arrRequiredMagicSchool[2].Translate("translateRequiredWaterMagicSchoolSkill");
    m_arrRequiredMagicSchool[3].Translate("translateRequiredEarthMagicSchoolSkill");
    m_arrRequiredMagicSchool[4].Translate("translateRequiredNecromancyMagicSchoolSkill");

    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//kolejnosc wywolania dla nowego unita:
//InitEquipment/Weapon
//InitUnit

command InitEquipment(EquipmentValues eVal, EquipmentParams ePar, int nLevel, int nClass, int nMeshNum)
{
    InitEquipment(eVal, ePar, nLevel, nClass, nMeshNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitWeapon(EquipmentValues wVal, WeaponParams wPar, int nLevel, int nClass, int nMeshNum)
{
    InitWeapon(wVal, wPar, nLevel, nClass, nMeshNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitBrokenWeapon(EquipmentValues wBrokenVal, WeaponParams wBrokenPar, EquipmentValues wNewVal, WeaponParams wNewPar)
{
    InitBrokenWeapon(wBrokenVal, wBrokenPar, wNewVal, wNewPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitMagicClub(EquipmentValues mcVal, MagicClubParams mcPar, int nLevel, int nClass, int nMeshNum)
{
    InitMagicClub(mcVal, mcPar, nLevel, nClass, nMeshNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitBrokenMagicClub(EquipmentValues mcBrokenVal, MagicClubParams mcBrokenPar, EquipmentValues mcNewVal, MagicClubParams mcNewPar)
{
    InitBrokenMagicClub(mcBrokenVal, mcBrokenPar, mcNewVal, mcNewPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitMagicCard(EquipmentValues mcVal, MagicCardParams mcPar, int nLevel, int nClass, int nMeshNum)
{
    InitMagicCard(mcVal, mcPar, nLevel, nClass, nMeshNum);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitUnit(unit pUnit, UnitParams unPar, UnitValues unVal, int nLevel)
{
    InitUnit(pUnit, unPar, unVal, nLevel);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitMissile(unit pUnit, MissileValues mVal, MissileParams mPar, EquipmentValues wVal, WeaponParams wPar, unit pEnemy)
{
    InitMissile(pUnit, mVal, mPar, wVal, wPar, pEnemy);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitOtherMissile(unit pUnit, int nDamage, MissileValues mVal, MissileParams mPar)
{
    InitOtherMissile(pUnit, nDamage, mVal, mPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitMagicMissile(unit pUnit, int nMagicCardSlotNum, MissileValues mVal, MissileParams mPar)
{
    InitMagicMissile(pUnit, nMagicCardSlotNum, mVal, mPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicParamObjectNumber(unit pUnit, int nMagicCardSlotNum, int nObjectCount)
{
    return GetMagicParamObjectNumber(pUnit, nMagicCardSlotNum, nObjectCount);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicCastRange(unit pUnit, int nMagicCardSlotNum)
{
    return GetMagicCastRange(pUnit, nMagicCardSlotNum);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicManaUse(unit pUnit, int nMagicCardSlotNum)
{
    return GetMagicManaUse(pUnit, nMagicCardSlotNum);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicSummonCount(unit pUnit, int nMagicCardSlotNum)
{
    return GetMagicSummonCount(pUnit, nMagicCardSlotNum);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicMaxSummonCount(unit pUnit, int nMagicCardSlotNum)
{
    return GetMagicMaxSummonCount(pUnit, nMagicCardSlotNum);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicSummonLevels(unit pUnit, int nMagicCardSlotNum, int& nUnitLevel, int& nWeaponLevel, int& nShieldLevel, int& nArmourLevel, int& nOtherLevel)
{
    GetMagicSummonLevels(pUnit, nMagicCardSlotNum, nUnitLevel, nWeaponLevel, nShieldLevel, nArmourLevel, nOtherLevel,true);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command FinishMagicSummonedUnit(unit pUnit, int nMagicCardSlotNum, unit pSummonedUnit)
{
    FinishMagicSummonedUnit(pUnit, nMagicCardSlotNum, pSummonedUnit);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command InitMagicWeapons(unit pUnit, int nMagicCardSlotNum, EquipmentValues wRightVal, WeaponParams wRightPar, EquipmentValues wLeftVal, WeaponParams wLeftPar, int& nTicks)
{
    InitMagicWeapons(pUnit, nMagicCardSlotNum, wRightVal, wRightPar, wLeftVal, wLeftPar, nTicks);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanMakeMagic(unit pUnit, int nMagicCardSlotNum)
{
    return CanMakeMagic(pUnit, nMagicCardSlotNum);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanMakeMagicMissileOnTarget(unit pUnit, int nMagicCardSlotNum, unit pTarget)
{
    return CanMakeMagicMissileOnTarget(pUnit, nMagicCardSlotNum, pTarget);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanMakeMagicGenericOnUnit(unit pUnit, int nMagicCardSlotNum, unit pTarget)
{
    return CanMakeMagicGenericOnUnit(pUnit, nMagicCardSlotNum, pTarget);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetMagicGenericOnUnitRange(unit pUnit, int nMagicCardSlotNum, int& nRange, int& bOnCastUnit, int& nTargetPartiesMask)
{
    GetMagicGenericOnUnitRange(pUnit, nMagicCardSlotNum, nRange, bOnCastUnit, nTargetPartiesMask);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MakeMagicGenericOnUnit(unit pUnit, int nMagicCardSlotNum, unit pTarget)
{
    MakeMagicGenericOnUnit(pUnit, nMagicCardSlotNum, pTarget);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command FinishMakingMagic(unit pUnit, int nMagicCardSlotNum, unit pTarget)
{
    FinishMakingMagic(pUnit, nMagicCardSlotNum, pTarget);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command AddPermanentPotion(unit pUnit, PotionArtefactParams ptPar)
{
    AddPermanentPotion(pUnit, ptPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command UpdateChangedUnitValues(unit pUnit)
{
    UpdateChangedUnitValues(pUnit);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SelectDirectFightStrikeAnim(unit pUnit, unit pEnemy, int nAnimsCnt)
{
    return SelectDirectFightStrikeAnim(pUnit, pEnemy, nAnimsCnt);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanStartDirectFightAction(unit pUnit, unit pEnemy)
{
    return CanStartDirectFightAction(pUnit, pEnemy);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetDirectFightAction(unit pUnit, unit pEnemy, int bInRange, int& nFightAction)
{
    GetDirectFightAction(pUnit, pEnemy, bInRange, nFightAction);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetNextSequenceDirectFightAction(unit pUnit, unit pEnemy, int nFightAction, int nCurrAnimSequenceNum, int nAnimSequencesCnt)
{
    return GetNextSequenceDirectFightAction(pUnit, pEnemy, nFightAction, nCurrAnimSequenceNum, nAnimSequencesCnt);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetDirectFightActionOnStartActionByEnemy(unit pUnit, unit pEnemy, int nEnemyFightAction, int& nFightAction, int& bMakeFightAction)
{
    GetDirectFightActionOnStartActionByEnemy(pUnit, pEnemy, nEnemyFightAction, nFightAction, bMakeFightAction);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command OnEndDirectFightAction(unit pUnit, unit pEnemy, int nFightAction, int bMadeFightAction, int& bMoveBack)
{
    OnEndDirectFightAction(pUnit, pEnemy, nFightAction, bMadeFightAction, bMoveBack);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command OnHitSuccess(unit pUnit, unit pEnemy, int nFightAction, int nHPDamage, int bByPoison, int bFirstMissileHit)
{
    OnHitSuccess(pUnit, pEnemy, nFightAction, nHPDamage, bByPoison, bFirstMissileHit);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetHitFightAction(unit pUnit, unit pEnemy, int nEnemyFightAction, int bByHitPushedMissile, int& nFightAction, int& nAnimDelay)
{
    GetHitFightAction(pUnit, pEnemy, nEnemyFightAction, bByHitPushedMissile, nFightAction, nAnimDelay);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetShootAction(unit pUnit, unit pEnemy, int& nShootFightAction, int& nAimingTicks, int& nMissileCount, int& nShootChanceValue, int& nShootChanceIncTicks, int& nShootChanceIncValue)
{
    GetShootAction(pUnit, pEnemy, nShootFightAction, nAimingTicks, nMissileCount, nShootChanceValue, nShootChanceIncTicks, nShootChanceIncValue);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanUseTwoWeapons(unit pUnit)
{
    return CanUseTwoWeapons(pUnit);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetHPDamageOnTarget(MissileValues mVal, unit pTarget, int nSplashDistancePercent, int& nHPDamage, int& nPoisonDamage)
{
    GetHPDamageOnTarget(mVal, pTarget, nSplashDistancePercent, nHPDamage, nPoisonDamage);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetPoisonHPDamage(int& nPoison, int& nHPDamage)
{
    GetPoisonHPDamage(nPoison, nHPDamage);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetExperiencePointsForLevel(int nLevel)
{
    return GetExperiencePointsForLevel(nLevel);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command OnSetLevel(unit pUnit, int nOldLevel, int nNewLevel)
{
    OnSetLevel(pUnit, nOldLevel, nNewLevel);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanIncreasePoint(unit pUnit, int nPointIndex)
{
    return CanIncreasePoint(pUnit, nPointIndex);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command IncreasePoint(unit pUnit, int nPointIndex, int bIncrease)
{
    IncreasePoint(pUnit, nPointIndex, bIncrease);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanIncreaseSkill(unit pUnit, int nSkillIndex, int& bLockedSkill)
{
    return CanIncreaseSkill(pUnit, nSkillIndex, bLockedSkill);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command IncreaseSkill(unit pUnit, int nSkillIndex, int bIncrease)
{
    IncreaseSkill(pUnit, nSkillIndex, bIncrease);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetNextAttackSkill(unit pUnit, int nSkillIndex, int bSecondHand)
{
    return SetNextAttackSkill(pUnit, nSkillIndex, bSecondHand);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanMakeActiveSkill(unit pUnit, int nSkillIndex, int bSecondHand, unit pEnemy, int& bShowDisabled, int& bAvailable)
{
    return CanMakeActiveSkill(pUnit, nSkillIndex, bSecondHand, pEnemy, bShowDisabled, bAvailable);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MakeActiveSkill(unit pUnit, int nSkillIndex, int nFightAction, unit pEnemy)
{
    return MakeActiveSkill(pUnit, nSkillIndex, nFightAction, pEnemy);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetSkillSetTrapValues(unit pUnit, int& nAddDamage, int& nAddTicks)
{
    nAddDamage = CalcTrapDamage_SkillSetTrap(pUnit);
    nAddTicks  = CalcTrapHoldTime_SkillSetTrap(pUnit) * 30;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetSkillSneakValues(unit pUnit, int& nDecSightRangePercent, int& nDecSightAnglePercent, int& nDecEarRangePercent)
{
    GetSkillSneakValues(pUnit, nDecSightRangePercent, nDecSightAnglePercent, nDecEarRangePercent);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetSkillDustEffectID(unit pUnit, int nSkillIndex, string& strEffectID)
{
    GetSkillDustEffectID(pUnit, nSkillIndex, strEffectID);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetSkillHorseRidingValues(unit pUnit, int& bCanRideHorse, int& nMaxSpeedPercent, int& bCanUseDirectFightWeapons, int& bCanUseShootWeapons, int& bCanCastMagic)
{
    GetSkillHorseRidingValues(pUnit, bCanRideHorse, nMaxSpeedPercent, bCanUseDirectFightWeapons, bCanUseShootWeapons, bCanCastMagic);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetHitCollidedByHorseDamage(unit pUnit, unit pTarget, int& nHPDamage, int& nPoisonDamage)
{
    GetHitCollidedByHorseDamage(pUnit, pTarget, nHPDamage, nPoisonDamage);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanJoinInventoryEquipments(unit pUnit, EquipmentParams ePar, EquipmentValues eVal, EquipmentValues eToVal)
{
    return CanJoinInventoryEquipments(pUnit, ePar, eVal, eToVal);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command JoinInventoryEquipments(unit pUnit, EquipmentParams ePar, EquipmentValues eVal, EquipmentValues eToVal, EquipmentValues eNewVal)
{
    JoinInventoryEquipments(pUnit, ePar, eVal, eToVal, eNewVal);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanJoinInventoryWeapons(unit pUnit, WeaponParams wPar, EquipmentValues eVal, EquipmentValues eToVal)
{
    return CanJoinInventoryWeapons(pUnit, wPar, eVal, eToVal);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command JoinInventoryWeapons(unit pUnit, WeaponParams wPar, EquipmentValues eVal, EquipmentValues eToVal, EquipmentValues eNewVal)
{
    JoinInventoryWeapons(pUnit, wPar, eVal, eToVal, eNewVal);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanJoinInventoryEquipmentWithSpecialArtefact(unit pUnit, EquipmentParams ePar, EquipmentValues eVal, SpecialArtefactParams artPar)
{
    return CanJoinInventoryEquipmentWithSpecialArtefact(pUnit, ePar, eVal, artPar);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command JoinInventoryEquipmentWithSpecialArtefact(unit pUnit, EquipmentParams ePar, EquipmentValues eVal, SpecialArtefactParams artPar)
{
    JoinInventoryEquipmentWithSpecialArtefact(pUnit, ePar, eVal, artPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanJoinInventoryWeaponWithSpecialArtefact(unit pUnit, WeaponParams wPar, EquipmentValues eVal, SpecialArtefactParams artPar)
{
    return CanJoinInventoryWeaponWithSpecialArtefact(pUnit, wPar, eVal, artPar);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command JoinInventoryWeaponWithSpecialArtefact(unit pUnit, WeaponParams wPar, EquipmentValues eVal, SpecialArtefactParams artPar)
{
    JoinInventoryWeaponWithSpecialArtefact(pUnit, wPar, eVal, artPar);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetHeroShopPricePercents(unit pHero, unit pShopUnit, int& nBuyPercent, int& nSellPercent)
{
    GetHeroShopPricePercents(pHero, pShopUnit, nBuyPercent, nSellPercent);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DefaultEventClickGateByUnit(unit uHero, unit uGate, int bFirstOpen, int bFirstHeroOpen, int& bClosedLockSound, int& bOpenLockSound, int& bBrokenLockpickSound)
{
    return DefaultEventClickGateByUnit(uHero, uGate, bFirstOpen, bFirstHeroOpen, bClosedLockSound, bOpenLockSound, bBrokenLockpickSound);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DefaultEventOpenContainerObject(unit uHero, unit uContainerObject, int bFirstOpen, int bFirstHeroOpen, int& bClosedLockSound, int& bOpenLockSound, int& bBrokenLockpickSound)
{
    return DefaultEventOpenContainerObject(uHero, uContainerObject, bFirstOpen, bFirstHeroOpen, bClosedLockSound, bOpenLockSound, bBrokenLockpickSound);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DefaultEventCloseContainerObject(unit uHero, unit uShopUnit, int nBuyMoney, int nSellMoney)
{
    return DefaultEventCloseContainerObject(uHero, uShopUnit, nBuyMoney, nSellMoney);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanStartOpenLock(unit uHero, unit uObject, int& bPlayAnim)
{
    return CanStartOpenLock(uHero, uObject, bPlayAnim);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command CanUseInventoryItemInAlchemy(unit uHero, string strObjectID, EquipmentValues eVal, object pChangedParams, int& nMaxCount, int& nTotalMaxCount)
{
    return CanUseInventoryItemInAlchemy(uHero, strObjectID, eVal, pChangedParams, nMaxCount, nTotalMaxCount);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command MakeAlchemyResult(unit uHero, int bCalcFormulaArtefact)
{
    return MakeAlchemyResult(uHero, bCalcFormulaArtefact);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetRegenerationHPMaxVal(unit uUnit)
{
    return GetRegenerationHPMaxVal(uUnit);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetRegenerationManaMaxVal(unit uUnit)
{
    return GetRegenerationManaMaxVal(uUnit);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetObjectInfoText(unit pUnit, int nSlotNum, int nSlotNum2, UnitValues unVal, string strObjectID, EquipmentValues eVal, object pChangedParams, stringW strName, int bAlchemyResultInfo, stringW& strText)
{
    GetObjectInfoText(pUnit, nSlotNum, nSlotNum2, unVal, null, strObjectID, eVal, pChangedParams, strName, bAlchemyResultInfo, strText);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetPointInfoText(unit pUnit, int nPointIndex, stringW& strLabel, stringW& strTooltip)
{
    GetPointInfoText(pUnit, nPointIndex, strLabel, strTooltip);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetSkillInfoText(unit pUnit, int nSkillIndex, stringW& strText)
{
    GetSkillInfoText(pUnit, nSkillIndex, strText);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetInventoryUnitInfoText(unit pUnit, stringW& strTitles, stringW& strValues)
{
    GetInventoryUnitInfoText(pUnit, strTitles, strValues);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetInventoryUnitStatText(unit pUnit, int nStaticNum, int& bVisible, int& nIconTemplateNum, stringW& strValue, stringW& strTooltip)
{
    GetInventoryUnitStatText(pUnit, nStaticNum, bVisible, nIconTemplateNum, strValue, strTooltip);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetReputationInfoText(unit pUnit, stringW& strText)
{
    GetReputationInfoText(pUnit, strText);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetHeroSelectionInfo(unit pUnit, unit uPointedObject, object pChangedParams, stringW strName, int& bDrawTargetSelection, int& nTargetHP, int& nTargetPoison, int& nTargetMaxHP, stringW& strText)
{
    GetHeroSelectionInfo(pUnit, uPointedObject, pChangedParams, strName, bDrawTargetSelection, nTargetHP, nTargetPoison, nTargetMaxHP, strText);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetHeroSelectionLockInfo(unit pUnit, unit uPointedObject, object pChangedParams, int& nLockIconNum, int& bIsChanceToOpenLock)
{
    GetHeroSelectionLockInfo(pUnit, uPointedObject, pChangedParams, nLockIconNum, bIsChanceToOpenLock);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command GetDisplayShootChanceValues(unit pUnit, int& nVal1, int& nVal2, int& nMaxVal)
{
    GetDisplayShootChanceValues(pUnit, nVal1, nVal2, nMaxVal);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

}
