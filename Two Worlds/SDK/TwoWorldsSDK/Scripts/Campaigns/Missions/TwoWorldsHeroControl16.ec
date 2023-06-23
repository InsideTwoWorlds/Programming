#define TIME_BEFORE_EFFECT 40 // 30
#define TIME_TO_DISSAPEAR_HERO 5 // 30
#define TIME_TO_MOVE_CAMERA 50 // 60
#define TIME_TO_START_EFFECT 3*30 // 30
#define TIME_TO_APPEAR_HERO 31 // 31
#define ZOOM_LEVEL 4     // TO NARAZIE NIE DZIALA
        
        

global "heroControl16"
{
#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\UnitInfo.ech"
#include "..\\..\\Common\\Messages.ech"
#include "..\\..\\Common\\Quest.ech"
#include "..\\..\\Common\\Levels.ech"
#include "PInc\\PEnums.ech"

#define HEAL_EFFECT             "HEALING_PRT"
#define MANA_EFFECT             "MANA_REG_PRT"
 
state Initialize;
state Nothing;



 consts {
   
   eDefaultMode = 0; 
   eBerserkMode = 1;
   eDefenceMode = 2;   

    eCheckEnemiesInterval = 15 * 30;
    eCheckEnemiesRangeA = M2A(3);
    eMaxAttacksPerTarget = 4;

    eUnblockResurrectRangeA = M2A(40);
    
    eHealRangeA = M2A(6);
    eManaRangeA = M2A(6);
    eHealTimeInterval = 30 * 4;
    eManaTimeInterval = 30 * 4;
    eHealStep = 15;
    eManaStep = 15;
    eStepEasy = 20;
    eStepMedium = 15;
    eStepHard = 10;
    
    
}
int nPlayerNum;
//ozywianie bohatera
int bRessurect;
int bBell;
int nLastHPrec;
int nCurrentMode;
int nConsoleDelay;
int nStateDelay;
mission pLastMission;
int nLastCheckEnemiesTick;

int nLastHealTick;
int nLastManaTick;

int anBlockedResurrects[];

function void BlockResurrects()
{
    int i;
    int nMax;
    mission pMission;
    pMission = GetCampaign().GetMission(0);
    nMax = pMission.GetMaxMarkerNum(MARKER_RESURRECT);
    if (nMax < 1) 
    {
        return;
    }
    anBlockedResurrects.SetSize(nMax + 1);
    for (i = 2; i <= nMax; i++)
    {
        if (pMission.HaveMarker(MARKER_RESURRECT,i))
        {
            anBlockedResurrects[i] = true;
            TRACE("%s %d blocked              \n",MARKER_RESURRECT,i);
        }
    }
}

function void UnblockResurrect(int nIndex)
{
    anBlockedResurrects[nIndex] = false;
    TRACE("%s %d unblocked              \n",MARKER_RESURRECT,nIndex);
}

function void CheckResurrects(unit uHero)
{
    int i;
    int nX, nY;
    int nMax;
    mission pMission;
    pMission = uHero.GetMission();
    nMax = pMission.GetMaxMarkerNum(MARKER_RESURRECT);
    for (i = 2; i <= nMax; i++)
    {
        if (!anBlockedResurrects[i]) continue;
        if (pMission.GetMarker(MARKER_RESURRECT,i,nX,nY) && uHero.DistanceTo(nX,nY) < eUnblockResurrectRangeA)
        {
            GetCampaign().CommandMessage(eMsgUnblockResurrect,i);
        }
    }    
}

function void AddSP(unit uHero) {
    
    // 1 - teleporty
    // 2 - killed
    // 3 - lockpicking
    // 4 - stealing
    
    int i;
    string str;
    
    uHero.GetAttribute("AddSP",i);
    if (!i) return;
    uHero.SetAttribute("AddSP",0);
    
    if (i == 1) str = "translateTeleports";    
    else if (i == 2) str = "translateKilled";
    else if (i == 3) str = "translateLockpicks";
    else if (i == 4) str = "translateStealing";
    else return;

    GetPlayerInterface(uHero.GetHeroPlayerNum()).SetConsoleText(str,120,true,true);
    AddSkillPoints(uHero,1);

}

function void Heal(unit uHero) {

    int i;
    int nMax,nMax2;
    mission pMission;
    int nHeal, nMana,nStep;
    int nX, nY;
    unit pObject;
    //UnitValues unVal;

    nStep = eStepMedium;
    if(GetCampaign().EventGetDifficultyLevel()==0)nStep = eStepEasy;
    if(GetCampaign().EventGetDifficultyLevel()==2)nStep = eStepHard;
        
    nHeal = false;
    nMana = false;    
    if(!uHero.IsLive())return;
    
    pMission = uHero.GetMission();
    
    nMax = pMission.GetMaxMarkerNum(MARKER_RESURRECT);
    for (i = 1; i <= nMax; i++) 
        if (pMission.GetMarker(MARKER_RESURRECT,i,nX,nY) && uHero.DistanceTo(nX,nY) < eHealRangeA) {
            nHeal = true;
            break;
        }
    
    if (nHeal) {
        
        //unVal = uHero.GetUnitValues();
        nMax = uHero.GetMaxHP();
        nMax2 = MIN(3000,nMax);
        
        i = uHero.GetHP();
        if (i < nMax) {
            if (GetCampaign().GetGameTick() - nLastHealTick > eHealTimeInterval) {    
                nLastHealTick = GetCampaign().GetGameTick();
                pObject = pMission.CreateObject(HEAL_EFFECT,uHero.GetLocationX(),uHero.GetLocationY(),0,0);
                pObject.SetDynamicHoldObject(uHero,false,false);
            }
            i = i + MAX(1,(nMax2 * nStep) / 1000);
            if (i > nMax) i = nMax;
            uHero.SetHP(i);
            uHero.UpdateChangedUnitValues();
        }
                    
    }
                
    nMax = pMission.GetMaxMarkerNum(MARKER_MANA);
    for (i = 1; i <= nMax; i++) 
        if (pMission.GetMarker(MARKER_MANA,i,nX,nY) && uHero.DistanceTo(nX,nY) < eManaRangeA) {
            nMana = true;
            break;
        }
    
    if (nMana) {
        
        nMax = uHero.GetMaxMana();
        nMax2 = nMax; //MIN(3000,nMax);
        i = uHero.GetMana();
        if (i < nMax) {
            if (GetCampaign().GetGameTick() - nLastManaTick > eManaTimeInterval) {    
                nLastManaTick = GetCampaign().GetGameTick();
                pObject = pMission.CreateObject(MANA_EFFECT,uHero.GetLocationX(),uHero.GetLocationY(),0,0);
                pObject.SetDynamicHoldObject(uHero,false,false);
            }
            i = i + MAX(1, (nMax2 * nStep) / 1000);
            if (i > nMax) i = nMax;
            uHero.SetMana(i);
            uHero.UpdateChangedUnitValues();
        }
    }
           
}

function void CheckEnemies(unit uHero) {

    int i, j, count;
    int anAngles[];
    int anTempAngles[];
    unit auEnemies[];
    int angle, delta;
    unit uUnit;
   
    if ((GetCampaign().GetGameTick() - nLastCheckEnemiesTick) < eCheckEnemiesInterval) return;
    nLastCheckEnemiesTick = GetCampaign().GetGameTick();

    uHero.SearchUnits(eCheckEnemiesRangeA,uHero.GetEnemiesParties());
    count = uHero.GetSearchUnitsCount();
    if (count == 0) return;
    for (i = 0; i < count; i++) {
        uUnit = uHero.GetSearchUnit(i);
        if (GetEnemyType(uUnit) == eEnemySwordsman && uUnit.GetAttackTarget() == uHero) {
            auEnemies.Add(uUnit);
            anAngles.Add((uHero.AngleTo(uUnit) + 128) % 256);    
            anTempAngles.Add(anAngles[anAngles.GetSize() - 1]);
        }
    }
    uHero.ClearSearchUnitsArray();

    if (anAngles.GetSize() == 0) return;
    if (anAngles.GetSize() == 1) {
        auEnemies[0].CommandUserOneParam1(-1);
        return;
    }
    anAngles.Sort(true);
    count = MIN(eMaxAttacksPerTarget,anAngles.GetSize());
    
    angle = 0;
    delta = 256 / count;
    for (i = 0; i < count; i++) {
        for (j = 0; j < auEnemies.GetSize(); j++) if (anTempAngles[j] == anAngles[i]) {
            auEnemies[j].CommandUserOneParam1(angle);
            angle += delta;
            auEnemies.RemoveAt(j);
            anTempAngles.RemoveAt(j);
        }    
    }

    while (auEnemies.GetSize()) {
        auEnemies[0].CommandUserNoParam0();
        auEnemies.RemoveAt(0);    
        anTempAngles.RemoveAt(0);
    }

    anAngles.RemoveAll();
        
}
  
function void IncreaseRessurectCount(unit uHero)
{
    int i;
    i=0;
    uHero.GetAttribute("Ress",i);
    i++;
    uHero.SetAttribute("Ress",i);
}
function void IncreaseKillCount(unit uHero)
{
    int i;
    i=0;
    uHero.GetAttribute("Kill",i);
    i++;
    uHero.SetAttribute("Kill",i);
    
    i=0;
    uHero.GetAttribute("M",i);
    i++;
    uHero.SetAttribute("M",i);
    if(i==GetNextMonstersLimit(i-1)) uHero.SetAttribute("AddSP",2);
}

int bDreamWorld;

function int IsHeroAtDreamPlace(unit uHero,int nAttr)
{
    int nX,nY;
    uHero.GetLocation(nX,nY);
    nX/=256;
    nY/=256;
    //                  X1           Y1        X2        Y2    XXXMD wypelnic poprawne wartosci
    if(nAttr==1 && nX>= 99  && nY >= 89 && nX<=120 && nY<=113) return true;
    if(nAttr==2 && nX>= 93  && nY >= 53 && nX<=113 && nY<=73) return true;
    if(nAttr==3 && nX>= 45  && nY >= 79 && nX<=65 && nY<=99) return true;
    return false;
}

function void CheckDreamWorld(unit uHero)
{
    mission pMission;
    int nAttr;
    pMission = uHero.GetMission();
    nAttr=0;
    pMission.GetAttribute("Dream",nAttr);
    if(nAttr>=1 && nAttr<=3) //czy misja jest dreamworldowa
    {
      if(IsHeroAtDreamPlace(uHero,nAttr)) //czy na miejscu dreamworlda?
      {
          if(bDreamWorld) return;
          else 
          {
              GetCampaign().GetPlayerInterface(nPlayerNum).SetDreamlandEntranceState(50);
              bDreamWorld=true;
             // TRACE("*****************************\n***** DREAM WORLD ENABLED ***\n*****************************\n");
          }                                       
          return;
      }
    }
    
    if(bDreamWorld) 
    {
        bDreamWorld=false;
        GetCampaign().GetPlayerInterface(nPlayerNum).SetDreamlandEntranceState(0);
           // TRACE("******************************\n***** DREAM WORLD DISABLED ***\n******************************\n");
    }
}

function int GetNearestResurrect(mission pSrcMission, int nSrcX, int nSrcY, mission pDestMission, int&nDestX, int&nDestY, int& nDestDist)
{
    int i, j, nDist, nMinDist, nX, nY, nX2, nY2, nSrcRow, nSrcCol, nLayer, nDestRow, nDestCol;
    
    j=pDestMission.GetMaxMarkerNum(MARKER_RESURRECT);
    if(j<1)
    {
        return false;
    }
    //Distance(pSrcMission, nSrcX, nSrcY, pDestMission, nX, nY) works only for neighbours
    MissionNum2Level(pSrcMission.GetMissionNum(), nSrcCol, nSrcRow, nLayer);
    MissionNum2Level(pDestMission.GetMissionNum(), nDestCol, nDestRow, nLayer);
    nSrcX = nSrcCol*pSrcMission.GetWorldWidth() + nSrcX;
    nSrcY = nSrcRow*pSrcMission.GetWorldHeight() + (pSrcMission.GetWorldHeight() - nSrcY);
    nMinDist = INT_MAX;
    for(i=1;i<=j;i++)
    {
        if(pDestMission.GetMarker(MARKER_RESURRECT,i,nX,nY))
        {
            nX2 = nDestCol*pDestMission.GetWorldWidth() + nX;
            nY2 = nDestRow*pDestMission.GetWorldHeight() + (pDestMission.GetWorldHeight() - nY);
            
            nDist = DistanceSqrt(nSrcX, nSrcY, nX2, nY2);
            if ((nMinDist == INT_MAX) || (nDist < nMinDist))
            {
                nMinDist = nDist;
                nDestX = nX;
                nDestY = nY;
                nDestDist = nDist;
            }
        }
    }
    ASSERT(nMinDist != INT_MAX);
    return true;
}

function int GetNearestResurrectInNeighbours(unit uHero, mission& pDestMission, int&nDestX, int&nDestY)
{
    int nCol, nRow, nLayer, nRange, nMaxRange, nCol2, nRow2, nX, nY, nDist, nMinDist;
    mission pMission;
    
    pDestMission = null;
    nMinDist = INT_MAX;
    MissionNum2Level(uHero.GetMission().GetMissionNum(), nCol, nRow, nLayer);
    nMaxRange = MAX(eLevelColsCnt, eLevelRowsCnt);
    for (nRange = 1; nRange <= nMaxRange; nRange++)
    {
        //up
        nRow2 = nRow - nRange;
        for (nCol2 = nCol - nRange; nCol2 <= nCol + nRange; nCol2++)
        {
            if ((nCol2 < 1) || (nCol2 > eLevelColsCnt) || (nRow2 < 1) || (nRow2 > eLevelRowsCnt))
            {
                continue;
            }
            pMission = GetMission(nCol2, nRow2, nLayer);
            if ((pMission == null) || !GetNearestResurrect(uHero.GetMission(), uHero.GetLocationX(), uHero.GetLocationY(), pMission, nX, nY, nDist))
            {
                continue;
            }
            if (!pMission.IsLevelLoaded())
            {
                nDist += 1000000;//prefer loaded level
            }
            if ((nMinDist == INT_MAX) || (nDist < nMinDist))
            {
                nMinDist = nDist;
                pDestMission = pMission;
                nDestX = nX;
                nDestY = nY;
            }
        }
        //down
        nRow2 = nRow + nRange;
        for (nCol2 = nCol - nRange; nCol2 <= nCol + nRange; nCol2++)
        {
            if ((nCol2 < 1) || (nCol2 > eLevelColsCnt) || (nRow2 < 1) || (nRow2 > eLevelRowsCnt))
            {
                continue;
            }
            pMission = GetMission(nCol2, nRow2, nLayer);
            if ((pMission == null) || !GetNearestResurrect(uHero.GetMission(), uHero.GetLocationX(), uHero.GetLocationY(), pMission, nX, nY, nDist))
            {    
                continue;
            }
            if (!pMission.IsLevelLoaded())
            {
                nDist += 1000000;//prefer loaded level
            }
            if ((nMinDist == INT_MAX) || (nDist < nMinDist))
            {
                nMinDist = nDist;
                pDestMission = pMission;
                nDestX = nX;
                nDestY = nY;
            }
        }
        //left
        nCol2 = nCol - nRange;
        for (nRow2 = nRow - nRange; nRow2 <= nRow + nRange; nRow2++)
        {
            if ((nCol2 < 1) || (nCol2 > eLevelColsCnt) || (nRow2 < 1) || (nRow2 > eLevelRowsCnt))
            {
                continue;
            }
            pMission = GetMission(nCol2, nRow2, nLayer);
            if ((pMission == null) || !GetNearestResurrect(uHero.GetMission(), uHero.GetLocationX(), uHero.GetLocationY(), pMission, nX, nY, nDist))
            {
                continue;
            }
            if (!pMission.IsLevelLoaded())
            {
                nDist += 1000000;//prefer loaded level
            }
            if ((nMinDist == INT_MAX) || (nDist < nMinDist))
            {
                nMinDist = nDist;
                pDestMission = pMission;
                nDestX = nX;
                nDestY = nY;
            }
        }
        //right
        nCol2 = nCol + nRange;
        for (nRow2 = nRow - nRange; nRow2 <= nRow + nRange; nRow2++)
        {
            if ((nCol2 < 1) || (nCol2 > eLevelColsCnt) || (nRow2 < 1) || (nRow2 > eLevelRowsCnt))
            {
                continue;
            }
            pMission = GetMission(nCol2, nRow2, nLayer);
            if ((pMission == null) || !GetNearestResurrect(uHero.GetMission(), uHero.GetLocationX(), uHero.GetLocationY(), pMission, nX, nY, nDist))
            {
                continue;
            }
            if (!pMission.IsLevelLoaded())
            {
                nDist += 1000000;//prefer loaded level
            }
            if ((nMinDist == INT_MAX) || (nDist < nMinDist))
            {
                nMinDist = nDist;
                pDestMission = pMission;
                nDestX = nX;
                nDestY = nY;
            }
        }
        if (pDestMission != null)
        {
            return true;
        }
    }
    return false;
}

function int GetNearestRessurect(unit uHero, mission& pDestMission, int&nDestX, int&nDestY)
{
    int i,j,nDist,nMarker, nX,nY;
    mission pMission;
    
    pMission = uHero.GetMission();
    j=pMission.GetMaxMarkerNum(MARKER_RESURRECT);
    if(j<1)
    {
        if (GetCampaign().GetMissionsCnt() > 1)
        {
            return GetNearestResurrectInNeighbours(uHero, pDestMission, nDestX, nDestY);
        }
        else
        {
            return false;
        }
    }
    nMarker=0;
    nDist=256*256;
    for(i=1;i<=j;i++)
    {
        if (anBlockedResurrects[i]) continue;
        if(pMission.GetMarker(MARKER_RESURRECT,i,nX,nY))
        {
            if(uHero.DistanceTo(nX,nY)<nDist)
            {
                nDist=uHero.DistanceTo(nX,nY);
                nMarker=i;
            }
        }
    }
    pDestMission = pMission;
    pMission.GetMarker(MARKER_RESURRECT,nMarker,nDestX,nDestY);
    return true;
}
        
function void CheckRessurect(unit uHero)
{
    int nX,nY;
    stringW strMsg;
    mission pMission;
    
    if(uHero.IsLive())return;
    
    if (bRessurect == 0)// efekt wylatywania duszy
    {
        bRessurect = 1;
        nStateDelay = TIME_BEFORE_EFFECT;
        uHero.GetLocation(nX,nY);
        return;
    }
    
    if(bRessurect==1)// efekt wylatywania duszy
    {
        bRessurect = 2;
        uHero.GetLocation(nX,nY);
        GetPlayerInterface(nPlayerNum).FadeInScreen(3*30,0,0,0);
        nStateDelay=3*30;
        //nStateDelay = TIME_TO_DISSAPEAR_HERO;
        return;
    }
    if(bRessurect==2)// zniknij bohatera
    {
        bRessurect = 3;
        //nStateDelay = TIME_TO_MOVE_CAMERA;
        nStateDelay = 0;
        uHero.SetNotRenderObjectNow(true);
        
        return;
    }
    if(bRessurect==3)// przesun kamere
    {
        if(GetCampaign().EventGetDifficultyLevel()>1)
        {
            strMsg.Translate("translateGameOver");
            GetPlayerInterface(nPlayerNum).EndGame(strMsg);
            return;    
        }
        bRessurect = 4;
        nStateDelay = TIME_TO_START_EFFECT;
        GetPlayerInterface(nPlayerNum).FadeOutScreen(2*30,0,0,0);
        if(GetNearestRessurect(uHero, pMission, nX, nY))
        {
            uHero.SetImmediatePosition(pMission, nX,nY,0,0,true);
        }
        return;
    }
    if(bRessurect==4)//pokaz efekt wlatywania duszy
    {
        bRessurect = 5;
        nStateDelay = TIME_TO_APPEAR_HERO;
        
        uHero.GetMission().CreateObject("RESURRECT_EFFECT",uHero.GetLocationX(),uHero.GetLocationY(),0,0);
        return;
    }
    if(bRessurect==5)//wskrzeszenie
    {
        bRessurect=0;
        IncreaseRessurectCount(uHero);
        uHero.SetNotRenderObjectNow(false);
        uHero.ResurrectUnit();
        uHero.SetHP(uHero.GetMaxHP()/3);
        nStateDelay=90;//3sec
        return;
    }
}
    
int bSearchForRelict;
state Initialize
{
    TRACE("\n\n\n\n");
    SetTimer(0,30);   
    SetTimer(1,30);   //temporary
    SetTimer(2,10*30);   //main plot
    SetTimer(3,30);   //orc armour
    SetTimer(4,3);   //hp & mana
    bRessurect=false;
    bSearchForRelict=true;
    nConsoleDelay=0;
    nStateDelay=90;//3sec
    bRessurect=0;
    BlockResurrects();
    return Nothing;
}

state Nothing
{
    unit uHero;
    
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    
    CheckEnemies(uHero);
    CheckDreamWorld(uHero);
    CheckRessurect(uHero);
    
    return Nothing,nStateDelay;
}

command Message(int nMsg, int nParam1)
{
    if (nMsg == eMsgInitHeroControl)
    {
        nPlayerNum = nParam1;
    }
    else if (nMsg == eMsgUnblockResurrect)
    {
        UnblockResurrect(nParam1);
    }
    return true;
}

event RemovedNetworkPlayer(int nPlayer)
{
    if (nPlayer == nPlayerNum)
    {
        RemoveGlobalScript();
    }
    return true;
}


event Timer0()
{
    unit uHero;
    int nHealthPrecent;
    
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    if(uHero.GetHP()<1) return true;
    nHealthPrecent = uHero.GetHP()*100/uHero.GetMaxHP();
    if(nHealthPrecent<30)GetPlayerInterface(nPlayerNum).PlayWave("FIGHT_HEART");//,255-nHealthPrecent*5);
    if(bBell>0)bBell=0; else bBell=1;
    if(nHealthPrecent<16 && (bBell>0 || nLastHPrec>15)) 
    {
        bBell=1;
        GetPlayerInterface(nPlayerNum).PlayWave("FIGHT_BELL");//,255-nHealthPrecent*5);
    }
    nLastHPrec = nHealthPrecent;
    return true;    
}
event Timer1()//temporary
{
    unit uHero;
    int nMode;
    string str;
    
    if(nConsoleDelay){nConsoleDelay--; return true;}
    
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    nMode = eDefaultMode;    
   
   return true;
}
event Timer2()//main plot putting together  stones
{
    unit uHero;
    int nMode;
    string str;
    
    #define ExchangeObj(a,b,c) if(uHero.IsObjectInInventory(a)){uHero.RemoveObjectFromInventory(a,false);uHero.RemoveObjectFromInventory(c,false); uHero.AddInventory(b,1);}
    #define ExchangeObj2(a,b,c) if(uHero.IsObjectInInventory(a)){uHero.RemoveObjectFromInventory(a,false);uHero.RemoveObjectFromInventory(c,false); uHero.AddInventory(b,1);bSearchForRelict=false;}
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    
    
    if(!bSearchForRelict) return true;
    
    if(uHero.IsObjectInInventory("RELIC_STONE_01"))
    {
        ExchangeObj("RELIC_00","RELIC_01","RELIC_STONE_01");
        ExchangeObj("RELIC_02","RELIC_03","RELIC_STONE_01");
        ExchangeObj("RELIC_04","RELIC_05","RELIC_STONE_01");
        ExchangeObj("RELIC_06","RELIC_07","RELIC_STONE_01");
        ExchangeObj("RELIC_08","RELIC_09","RELIC_STONE_01");
        ExchangeObj("RELIC_10","RELIC_11","RELIC_STONE_01");
        ExchangeObj("RELIC_12","RELIC_13","RELIC_STONE_01");
        ExchangeObj2("RELIC_14","RELIC_15","RELIC_STONE_01");
    }
    else if(uHero.IsObjectInInventory("RELIC_STONE_02"))
    {
        ExchangeObj("RELIC_00","RELIC_02","RELIC_STONE_02");
        ExchangeObj("RELIC_01","RELIC_03","RELIC_STONE_02");
        ExchangeObj("RELIC_04","RELIC_06","RELIC_STONE_02");
        ExchangeObj("RELIC_05","RELIC_07","RELIC_STONE_02");
        ExchangeObj("RELIC_08","RELIC_10","RELIC_STONE_02");
        ExchangeObj("RELIC_09","RELIC_11","RELIC_STONE_02");
        ExchangeObj("RELIC_12","RELIC_14","RELIC_STONE_02");
        ExchangeObj2("RELIC_13","RELIC_15","RELIC_STONE_02");
        
    }
    else if(uHero.IsObjectInInventory("RELIC_STONE_04"))
    {
        ExchangeObj("RELIC_00","RELIC_04","RELIC_STONE_04");
        ExchangeObj("RELIC_01","RELIC_05","RELIC_STONE_04");
        ExchangeObj("RELIC_02","RELIC_06","RELIC_STONE_04");
        ExchangeObj("RELIC_03","RELIC_07","RELIC_STONE_04");
        ExchangeObj("RELIC_08","RELIC_12","RELIC_STONE_04");
        ExchangeObj("RELIC_09","RELIC_13","RELIC_STONE_04");
        ExchangeObj("RELIC_10","RELIC_14","RELIC_STONE_04");
        ExchangeObj2("RELIC_11","RELIC_15","RELIC_STONE_04");
    }
    else if(uHero.IsObjectInInventory("RELIC_STONE_08"))
    {
        ExchangeObj("RELIC_00","RELIC_08","RELIC_STONE_08");
        ExchangeObj("RELIC_01","RELIC_09","RELIC_STONE_08");
        ExchangeObj("RELIC_02","RELIC_10","RELIC_STONE_08");
        ExchangeObj("RELIC_03","RELIC_11","RELIC_STONE_08");
        ExchangeObj("RELIC_04","RELIC_12","RELIC_STONE_08");
        ExchangeObj("RELIC_05","RELIC_13","RELIC_STONE_08");
        ExchangeObj("RELIC_06","RELIC_14","RELIC_STONE_08");
        ExchangeObj2("RELIC_07","RELIC_15","RELIC_STONE_08");
    }
    return true;
}

event Timer3()//main plot orc armour
{
    unit uHero;
    int nAttr;
    string strBody;
    int i;
    
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    
    nAttr=-1;
    uHero.GetAttribute("ORCARMOUR",nAttr);
    if(nAttr==-1)
    {
        uHero.SetAttribute("ORCARMOUR",0);
        return true;
    }
    if(nAttr==0)
    {
        if (uHero.HaveEquipmentOnSlot(eSlotArmourBody))
        {
            strBody = uHero.GetEquipmentIDOnSlot(eSlotArmourBody);
        }
        if(strBody.EqualNoCase("ORC_ARMOUR"))//xxxmd - sprawdzac czy ubrana
        {
            TRACE("*******SET NEUTRAL TO Greenskins******************        \n");
            GetCampaign().SetPartyNeutral(ePartyGreenskins, ePartyPlayer1);           //xxx pomimo tego nadal atakuja
            for (i = ePartyHumans; i <= ePartyLastVillage; i++) GetCampaign().SetPartyEnemy(i,ePartyPlayer1);
            uHero.SetAttribute("ORCARMOUR",1);
            return true;
        }
    }
    if(nAttr==1)
    {
        if (uHero.HaveEquipmentOnSlot(eSlotArmourBody))
        {
            strBody = uHero.GetEquipmentIDOnSlot(eSlotArmourBody);
        }
        if(!strBody.EqualNoCase("ORC_ARMOUR"))//xxxmd - sprawdzac czy nie ubrana
        {
            TRACE("*******SET ENEMY TO Greenskins******************        \n");
            GetCampaign().SetPartyEnemy(ePartyGreenskins, ePartyPlayer1);
            for (i = ePartyHumans; i <= ePartyLastVillage; i++) GetCampaign().SetPartyNeutral(i,ePartyPlayer1);
            uHero.RemoveObjectFromInventory("ORC_ARMOUR",false);
            uHero.SetAttribute("ORCARMOUR",0);
            return true;
        }
    }
    return true;
}

event Timer4() {

    unit uHero;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    Heal(uHero);
    AddSP(uHero);
    CheckResurrects(uHero);
    return true;

}

event RemovedUnit(unit uKilled, unit uAttacker, int a)
{
    unit uHero;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    if(!uHero) return false;
    if(uHero==uKilled){SetStateDelay(0);return false;} 
    if(uHero==uAttacker) 
    {
        IncreaseKillCount(uHero);
    }
    return false;
}

function void AddSkillPoints()
{
    unit uHero;
    UnitValues unVal;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    unVal = uHero.GetUnitValues();
    unVal.SetSkillPoints(10);
    unVal.SetParamPoints(10);
    uHero.UpdateChangedUnitValues();
}   
function void AddAllSkills()
{
    unit uHero;
    int i;
    UnitValues unVal;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    
    unVal = uHero.GetUnitValues();
    for(i=eSkillParry;i<=eSkillSetTrap;i++)
    {
        LockSkill(uHero, i, false);
        uHero.GetUnitValues().SetBasicSkill(i,1);
    }
    uHero.UpdateChangedUnitValues();
}   
function void LevelUp(int nMul)
{
    unit uHero;
    UnitValues unVal;
    int nLevel;
    
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    unVal = uHero.GetUnitValues();
    //nLevel = unVal.GetLevel();
    unVal.SetParamPoints(unVal.GetParamPoints()+(5*nMul));
    unVal.SetSkillPoints(unVal.GetSkillPoints()+nMul);
    uHero.UpdateChangedUnitValues();
    //unVal.SetLevel(nLevel+nMul);
}   
function void Rep()
{
    unit uHero;
    int i,j;
    uHero = GetCampaign().GetPlayerHeroUnit(nPlayerNum);
    
    for(i=eFirstGuild;i<=eGuildSkelden;i++)
    {
        uHero.GetAttribute(i,j);
        if(j<10)uHero.SetAttribute(i,j+1);
    }
    
}   

command CommandDebug(string strLine)
{
    string strCommand;
    unit uUnit;
    mission pMission;
    int nX,nY;
    
    strCommand = strLine;
    if (!stricmp(strLine, "rescue"))//official rescue cheat
    {
        uUnit = GetCampaign().GetPlayerHeroUnit(0);
        pMission = uUnit.GetMission();
        if(GetNearestRessurect(uUnit, pMission, nX, nY))
        {
            uUnit.SetImmediatePosition(pMission, nX,nY,0,0,true);
        }
    }
    else if (!stricmp(strLine, "AddSkillPoints"))
    {
        AddSkillPoints();
    }
    else if (!stricmp(strLine, "Rep"))
    {
        Rep();
    }
    else if (!stricmp(strLine, "Skills"))
    {
        AddSkillPoints();
        AddAllSkills();
    }
    else if (!stricmp(strLine, "LevelUp"))
    {
        LevelUp(1);
    }
    else if (!stricmp(strLine, "LevelUp5"))
    {
        LevelUp(5);
    }
    else if (!stricmp(strLine, "LevelUp10"))
    {
        LevelUp(10);
    }
    else if (!strnicmp(strCommand, "cave1", strlen("cave1")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("cave1") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            if (pMission.GetMarker("MARKER_TELEPORT",1,nX,nY)) GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, nX, nY-512, 0, 0, true);
            else GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, pMission.GetWorldWidth()/2, pMission.GetWorldHeight()/2, 0, 0, true);
        }
    }  
    else if (!strnicmp(strCommand, "cave2", strlen("cave2")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("cave2") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            if (pMission.GetMarker("MARKER_TELEPORT",2,nX,nY)) GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, nX, nY-512, 0, 0, true);
            else GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, pMission.GetWorldWidth()/2, pMission.GetWorldHeight()/2, 0, 0, true);
        }
    }  
    else if (!strnicmp(strCommand, "tel1", strlen("tel1")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("tel1") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            if (pMission.GetMarker("MARKER_TELEPORT_STATIC",1,nX,nY)) GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, nX, nY-512, 0, 0, true);
        }
    }  
    else if (!strnicmp(strCommand, "tel2", strlen("tel2")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("tel2") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            if (pMission.GetMarker("MARKER_TELEPORT_STATIC",2,nX,nY)) GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, nX, nY-512, 0, 0, true);
        }
    }  
    else
    {
        return false;
    }
    return true;
}

}
