global "heroControl"
{
#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Quest.ech"
#include "..\\..\\Common\\Levels.ech"
    
state Initialize;
state Start;
state Nothing;



consts 
{
   
    icon25=25;
    eBlackTowerCount =5;
}

function void InitBlackTowersVisitedState();
function void SetBlackTowerVisited(int nTowerIndex, unit uHero);
function int GetVisitedBlackTowersCount();

//po wejsciu na nowa mape - sprawdzic czy jest na niej nieaktywny teleport jak tak to sprawdzac czy gracz
//zbliza sie do niego
//jak sie zblizy uruchomic teleport - particle itp. , wpisac na mape i tyle.



// dodac sprawdzanie  is active z teleportu - jak bedzie funkcja do tego.

int bIsInactiveTeleport, nTowerTeleportState,nDelay;
mission pLastMission;
int arrBlackTowerVisited[eBlackTowerCount];

state Initialize
{
    int nIndex;
    bIsInactiveTeleport=true;
    nTowerTeleportState=0;
    InitBlackTowersVisitedState();
    return Start;
}
function void CheckTowerTeleports(unit uHero, mission pMission);

state Start
{
    unit uHero,uTeleport;
    mission pMission;
    int i,nCol,nRow,nLayer,t;
    string str;
    
    uHero = GetCampaign().GetPlayerHeroUnit(0);
    pMission=uHero.GetMission();

    i=pMission.GetMissionNum();
    MissionNum2Level(i,nCol,nRow,nLayer);

    if(nCol==eColE &&nRow==2)
    {
        uTeleport = pMission.GetObjectMarker("MARKER_TELEPORT_STATIC",2);
        str.Format("translateTEL_%c%02d_%d_%d",'A'+nCol-1,nRow,nLayer,2);
        if (!CheckTranslate(str)) str.Copy("translateTEL_C02_0_1");
        uTeleport.ActivateTeleport(true,true, icon25, icon25, str);
        return Nothing;
    }
    return state,5*30;
}

state Nothing
{
    unit uHero,uTeleport;
    mission pMission;
    int i,x,nX,nY,nCol,nRow,nLayer,t;
    string str;
    uHero = GetCampaign().GetPlayerHeroUnit(0);
    
    pMission=uHero.GetMission();
    nDelay=30;
    CheckTowerTeleports(uHero, pMission);
    
    if(pMission==pLastMission && !bIsInactiveTeleport) return state,nDelay;
    
    pLastMission = pMission;
    
    bIsInactiveTeleport=false;
    for(i=1;i<5;i++)
        if(pMission.GetMarker("MARKER_TELEPORT_STATIC",i,nX,nY))
        {
            uTeleport = pMission.GetObjectMarker("MARKER_TELEPORT_STATIC",i);
            ASSERT(uTeleport);
            if(!uTeleport.IsTeleportActiveSource())//teleport not active  //zamiast tego ma byc is teleport active
            {
                if(uHero.IsObjectInInventory("TELEPORT_ACTIVATOR") && IsUnitNearPoint(uHero,pMission, nX,nY,5))
                {
                    t=0;
                    uHero.GetAttribute("T",t);
                    t++;
                    uHero.SetAttribute("T",t);
                    if(t==GetNextSkillPointLimit(t-1)) uHero.SetAttribute("AddSP",1);
                    
               //     pMission.CreateObject("ACTIVATE_TELEPORT",nX,nY,0,0);
                    MissionNum2Level(pMission.GetMissionNum(),nCol,nRow,nLayer);
                    str.Format("translateTEL_%c%02d_%d_%d",'A'+nCol-1,nRow,nLayer,i);
                    if (!CheckTranslate(str)) str.Copy("translateTEL_C02_0_1");
                    uTeleport.ActivateTeleport(true,true, icon25, icon25, str);
                }
                else
                    bIsInactiveTeleport=true;
            }
        }
    return state,nDelay;
}

function void InitBlackTowersVisitedState()
{
    int nIndex;
    for(nIndex = 0; nIndex < eBlackTowerCount; nIndex++)
    {
        arrBlackTowerVisited[nIndex] = false;
    }
}

function void SetBlackTowerVisited(int nTowerIndex, unit uHero)
{
    int nIndex;
    int nVisitedCount;

    if( (nTowerIndex == -1) || (arrBlackTowerVisited[nTowerIndex] == true) )
    {
        return;
    }
    arrBlackTowerVisited[nTowerIndex] = true;

    nVisitedCount = 0;
    for(nIndex = 0; nIndex < eBlackTowerCount; nIndex++)
    {
        if( arrBlackTowerVisited[nIndex] )
        {
            nVisitedCount++;
        }
    }
    TRACE("new black tower found: %d/%d\n", nVisitedCount, eBlackTowerCount);
    if( nVisitedCount == eBlackTowerCount )
    {
        GetCampaign().CommandMessage(eMsgAchievement, eAchievementVisitAllBlackTowers, uHero);
    }
}

function int GetVisitedBlackTowersCount()
{
    int nIndex, nCount;
    nCount = 0;
    for (nIndex = 0; nIndex < eBlackTowerCount; nIndex++)
    {
        if( arrBlackTowerVisited[nIndex] )
        {
            nCount++;
        }
    }
    return nCount;
}

function void CheckTowerTeleports(unit uHero, mission pMission)
{
    int nX,nY;
    int eXs1, eYs1, eZs1;
    int eXl1, eYl1, eZl1;
    int eXs2, eYs2, eZs2;
    int eXl2, eYl2, eZl2;
    int nCol, nRow, nLayer,nMissionNum;
    int nTowerIndex;
    
    nMissionNum=pMission.GetMissionNum();
    MissionNum2Level(nMissionNum,nCol,nRow,nLayer);
    
    if(nCol==eColD &&nRow==5)
    {
        eXs1 = 18864;
        eYs1 = 20484;
        eZs1 = 11117;
        
        eXl1 = 18870;
        eYl1 = 19684;
        eZl1 = 16150;
        
        eXs2 = 18880;
        eYs2 = 18584;
        eZs2 = 15440;
        
        eXl2 = 73*256;
        eYl2 = 83*256;
        eZl2 = 0;
        
        nTowerIndex = 0;
    }
    else if(nCol==eColA &&nRow==7)
    {
        eXs1 = 18120;
        eYs1 = 8438;
        eZs1 = 11036;
        
        eXl1 = 17406;
        eYl1 = 8700;
        eZl1 = 16054;
        
        eXs2 = 16272;
        eYs2 = 9084;
        eZs2 = 15344;
        
        eXl2 = 19418;
        eYl2 = 8000;
        eZl2 = 0;

        nTowerIndex = 1;
    }
    else if(nCol==eColG &&nRow==7)
    {
        eXs1 = 22440;
        eYs1 = 9282;
        eZs1 = 11064;
        
        eXl1 = 22578;
        eYl1 = 8500;
        eZl1 = 16074;
        
        eXs2 = 22748;
        eYs2 = 7344;
        eZs2 = 15364;
        
        eXl2 = 22278;
        eYl2 = 10280;
        eZl2 = 0;

        nTowerIndex = 2;
    }
    else if(nCol==eColB &&nRow==11)
    {
        eXs1 = 24197;
        eYs1 = 22756;
        eZs1 = 11135;
        
        eXl1 = 24189;
        eYl1 = 21957;
        eZl1 = 16153;
        
        eXs2 = 24181;
        eYs2 = 20767;
        eZs2 = 15444;
        
        eXl2 = 23778;
        eYl2 = 24069;
        eZl2 = 0;
        
        nTowerIndex = 3;
    }
    else if(nCol==eColF &&nRow==11)
    {
        eXs1 = 16812;
        eYs1 = 21095;
        eZs1 = 11100;
        
        eXl1 = 17572;
        eYl1 = 21255;
        eZl1 = 16096;
        
        eXs2 = 18724;
        eYs2 = 21532;
        eZs2 = 15387;
        
        eXl2 = 15684;
        eYl2 = 20914;
        eZl2 = 0;
        
        nTowerIndex = 4;
    }
    else
    {
        nDelay=60;
        nTowerIndex = -1;
        return;
    }
    
    
    
    
    if(nTowerTeleportState==0)
    {
        if (uHero.DistanceTo(pMission, eXs1, eYs1) <= 128)
        {
            uHero.GetLocation(nX,nY);
            pMission.CreateObject("TELE_OUT_EFFECT",nX, nY,eZs1,0);
            pMission.CreateObject("TELE_IN_EFFECT",eXl1,eYl1,eZl1,0);
            nTowerTeleportState=1;
            nDelay=15;
            
            SetBlackTowerVisited(nTowerIndex, uHero);
            return;
        }
        if (uHero.DistanceTo(pMission, eXs2, eYs2) <= 128)
        {
            uHero.GetLocation(nX,nY);
            pMission.CreateObject("TELE_OUT_EFFECT",nX, nY,eZs2,0);
            pMission.CreateObject("TELE_IN_EFFECT",eXl2,eYl2,eZl2,0);
            nTowerTeleportState=3;
            nDelay=15;

            SetBlackTowerVisited(nTowerIndex, uHero);
            return;
        }
    }
    if(nTowerTeleportState==1)
    {
        pMission.CreateObject("TELE_IN_EFFECT",eXl1,eYl1,eZl1,0);
        uHero.SetImmediatePosition(eXl1,eYl1,eZl1+48,0,0);
        nTowerTeleportState=0;
        nDelay=15;
        return;
    }
    if(nTowerTeleportState==3)
    {
        pMission.CreateObject("TELE_IN_EFFECT",eXl2,eYl2,eZl2,0);
        uHero.SetImmediatePosition(eXl2,eYl2,eZl2+48,0,0);
        nTowerTeleportState=0;
        nDelay=15;
        return;
    }
        
}

command CommandDebug(string strLine)
{
    int nX,nY,nZ;
    unit uHero;
    mission pMission;
    
    if (!stricmp(strLine, "pos"))
    {
        uHero = GetCampaign().GetPlayerHeroUnit(0);
        uHero.GetLocation(nX,nY);
        nZ=uHero.GetLocationZ();
        TRACE("x=%d, Y=%d,  Z=%d         \n",nX,nY,nZ);
    }
    else if (!stricmp(strLine,"PrintBlackTowersCount"))
    {
        TRACE("BlackTowers: %d/%d (%d%%)\n", GetVisitedBlackTowersCount(), eBlackTowerCount, 100 * GetVisitedBlackTowersCount() / eBlackTowerCount );
    }
    return true;
}



}
