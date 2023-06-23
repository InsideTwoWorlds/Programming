global "Enemies Script 16"
{
    
function void TrapCreateEffect(mission pMission, int nX, int nY);
    
#define TWO_WORLDS_ENEMIES_TRAPS    
    
    #include "..\\..\\Common\\Generic.ech"
    #include "..\\..\\Common\\Quest.ech"
    #include "..\\..\\Common\\Levels.ech"
    #include "..\\..\\Common\\CreateStrings.ech"
    #include "..\\..\\Common\\Enemies.ech"
//    #include "..\\..\\Common\\Ghosts.ech"
    
state Initialize;
state Nothing;

int nEnemyClass;
int nParty;
int nQuantityFactor;
int nForceLevel;

string astrTrapMarkersNames[];   // nazwy markerow pulapek
string astrTrapMarkers[];        // markery z pulapkami
int anTrapMarkers[];

string astrEnemiesMarkers[];     // nazwy markerow enemiesow
int nCurrentTrapCreateEffect;    // aktualny efekt przy tworzeniu enemiesow

string astrCreateEffects[];      // efekty przy summonowaniu

//===============================================
// enemy traps

consts {

    eMaxEnemyTrapMarkers        = 10,             //ile maksymalnie aktywnych pulapek  jest na planszy
    eEnemyTrapRangeA            = M2A(4),    
    eEnemyTrapActivationRangeA  = M2A(10),        
}

//===============================================

function int GetCurrentCreateEffect(string strMarker)
{
    int i;
    for (i = 0; i < astrTrapMarkersNames.GetSize(); i++)
    {
        if (astrTrapMarkersNames[i].EqualNoCase(strMarker)) return i;
    }
    return -1;
}

function void TrapCreateEffect(mission pMission, int nX, int nY)
{
    if (nCurrentTrapCreateEffect == -1) return;
    TRACE("Creating %s at %d %d                       \n",astrCreateEffects[nCurrentTrapCreateEffect], nX, nY);
    pMission.CreateObject(astrCreateEffects[nCurrentTrapCreateEffect], nX, nY, 0, 0);
}

//===============================================

function void InitializeEnemyTraps()
{
    nCurrentTrapCreateEffect = -1;
    astrTrapMarkersNames.Add("MARKER_TRAP1");
    astrTrapMarkersNames.Add("MARKER_TRAP2");
    astrTrapMarkersNames.Add("MARKER_TRAP3");
    astrTrapMarkersNames.Add("MARKER_TRAP4");
    astrTrapMarkersNames.Add("MARKER_TRAP5");
    astrEnemiesMarkers.Copy(anMarkerName);
    astrEnemiesMarkers.Sort(true);
    astrCreateEffects.Add("SUMMON_EARTH_HIT");
    astrCreateEffects.Add("SUMMON_AIR_HIT");
    astrCreateEffects.Add("SUMMON_WATER_HIT");
    astrCreateEffects.Add("SUMMON_FIRE_HIT");
    astrCreateEffects.Add("SUMMON_NECRO_HIT");
}

function int ProcessedMarkers(mission pMission)
{
    int nPEM;
    pMission.GetAttribute("PEM", nPEM);
    return nPEM;    
}

function void ProcessMarkers(mission pMission)
{
    int i, j;
    string astrMarkers[];
    int anMarkers[];
    int nMax;
    
    for (j = 0; j < astrTrapMarkersNames.GetSize(); j++)
    {
        nMax = pMission.GetMaxMarkerNum(astrTrapMarkersNames[j]);
        for (i = 1; i <= nMax; i++)
        {
            if (pMission.HaveMarker(astrTrapMarkersNames[j], i))
            {
                astrMarkers.Add(astrTrapMarkersNames[j]);
                anMarkers.Add(i);
            }
        }
    }
    
    if (anMarkers.GetSize() <= eMaxEnemyTrapMarkers)
    {
        anTrapMarkers.Copy(anMarkers);
        anMarkers.RemoveAll();
        astrTrapMarkers.Copy(astrMarkers);
        astrMarkers.RemoveAll();
    }
    else
    {
        for (i = 0; i < eMaxEnemyTrapMarkers; i++)
        {
            j = Rand(anMarkers.GetSize());
            anTrapMarkers.Add(anMarkers[j]);
            astrTrapMarkers.Add(astrMarkers[j]);
            anMarkers.RemoveAt(j);
            astrMarkers.RemoveAt(j);
        }
    }
    
    for (i = 0; i < anMarkers.GetSize(); i++)
    {
        pMission.RemoveMarker(astrMarkers[i], anMarkers[i]);        
        TRACE("Removing marker %s %d               \n",astrMarkers[i],anMarkers[i]);
    }        

    anMarkers.RemoveAll();
    astrMarkers.RemoveAll();

    TRACE("Active trap markers: %d                    \n",astrTrapMarkers.GetSize());
    for (i = 0; i < astrTrapMarkers.GetSize(); i++)
    {
        TRACE("%s %d               \n",astrTrapMarkers[i],anTrapMarkers[i]);
    }

    pMission.SetAttribute("PEM", true);

}

function string GetNearestEnemyTrapMarker(mission pMission, int nX, int nY)
{
    string astrMarkers[];
    int anMarkers[];
    string strMarker;
    strMarker = "";
    pMission.FillMarkersInRange(astrTrapMarkersNames, nX, nY, eEnemyTrapRangeA, astrMarkers, anMarkers, false);
    if (astrMarkers.GetSize() != 0)
    {
        strMarker = astrMarkers[0];
    }
    return strMarker;    
}

function int IsEnemyTrap(mission pMission, int nX, int nY)
{
    string strMarker;
    strMarker = GetNearestEnemyTrapMarker(pMission, nX, nY);
    return !strMarker.EqualNoCase("");
}
       
function int CreateMissionEnemies(mission pMission, int nUseTraps)
{
    int i,nMaxMarker,nX,nY,nEnemiesCreated;
    int nMission;
    
    if (!nUseTraps)
    {
        return CreateMissionEnemies(pMission);
    }
    
    nEnemiesCreated=0;
    pMission.GetAttribute("EnemiesCreated", nEnemiesCreated);
    if(nEnemiesCreated>=eLastEnemyClass)return false;
    
    nMission = pMission.GetMissionNum();
    
    if(nEnemiesCreated!=eClassBandit)
    {
        nMaxMarker = pMission.GetMaxMarkerNum(anMarkerName[nEnemiesCreated]);
//        TRACE("CREATE enemy num: %d  max markers %d                   \n",nEnemiesCreated,nMaxMarker);
        for (i=1;i<=nMaxMarker;i++)
        {
            if(pMission.GetMarker(anMarkerName[nEnemiesCreated],i,nX,nY)) 
                if (!IsEnemyTrap(pMission, nX, nY)) CreateEnemy(pMission,nX,nY,nMission,nEnemiesCreated,anParty[nEnemiesCreated],0,0,true,i);
        }
    }
    nEnemiesCreated++;
    pMission.SetAttribute("EnemiesCreated", nEnemiesCreated);
    return true;
}

function int FindEnemyType(string strMarkerName)
{
    int i;
    for (i = 0; i < anMarkerName.GetSize(); i++)
    {
        if (anMarkerName[i].EqualNoCase(strMarkerName))
        {           
            return i;
        }
    }
    return eEnemyUnknown;
}

function void CreateTrapEnemies(mission pMission, int nX, int nY)
{
    string astrMarkers[];
    int anMarkers[];
    int i;
    int nEnemyType;
    
    pMission.FillMarkersInRange(astrEnemiesMarkers, nX, nY, eEnemyTrapRangeA, astrMarkers, anMarkers, false);    
    if (astrMarkers.GetSize() == 0)
    {
        TRACE("Can't find enemy markers around point %d %d in range \5d                    \n",nX,nY,eEnemyTrapRangeA);
    }
    for (i = 0; i < astrMarkers.GetSize(); i++)
    {
        nEnemyType = FindEnemyType(astrMarkers[i]);
        if (nEnemyType == eEnemyUnknown)
        {
            continue;
        }
        if (!pMission.GetMarker(astrMarkers[i], anMarkers[i], nX, nY))
        {
            TRACE("CreateTrapEnemies: can't find marker %d %s              \n", astrMarkers[i], anMarkers[i]);
            continue;
        }
        TRACE("Creating enemy type %d with summon %s                       \n",nEnemyType, astrCreateEffects[nCurrentTrapCreateEffect]);
        CreateEnemy(pMission, nX, nY, pMission.GetMissionNum(), nEnemyType, anParty[nEnemyType], 0, 0, true, i);
    }
    astrMarkers.RemoveAll();
    anMarkers.RemoveAll();
}

function void CheckEnemyTrap(mission pMission, unit uHero)
{
    int i;
    int nX, nY;
    i = 0;
    while (i < anTrapMarkers.GetSize())
    {
        if (!pMission.GetMarker(astrTrapMarkers[i], anTrapMarkers[i], nX, nY))
        {
            TRACE("CheckEnemyTrap: can't find marker %s %d            \n", astrTrapMarkers[i], anTrapMarkers[i]);
            i++;
            continue;
        }
        if (uHero.DistanceTo(pMission, nX, nY) < eEnemyTrapActivationRangeA)
        {                                
            TRACE("Activating trap: %s %d                              \n", astrTrapMarkers[i], anTrapMarkers[i]);
            nCurrentTrapCreateEffect = GetCurrentCreateEffect(astrTrapMarkers[i]);
            CreateTrapEnemies(pMission, nX, nY);        
            nCurrentTrapCreateEffect = -1;
            pMission.RemoveMarker(astrTrapMarkers[i], anTrapMarkers[i]);
            anTrapMarkers.RemoveAt(i);
            astrTrapMarkers.RemoveAt(i);
        }
        else
        {
            i++;
        }            
    }    
}

//===============================================

event OnLoadLevel(mission pMission, int bFirstLoad)
{
    if(!bFirstLoad)return false;
    return false;
}

event OnUnloadLevel(mission pMission) {

    int i;
    int anParties[];
    for (i = ePartyAnimals; i <= ePartyEvilWarriors; i++) anParties.Add(i);
    pMission.RemoveKilledUnits(64,64,0,true,anParties,false,false); // 0,0,0 mozna zmienic na cokolwiek co obejmie cala mape
    ResetEnemiesCreated(pMission);
    ResetGhostsCreated(pMission);
    return false;
}

event RemovedUnit(unit uKilled, unit uAttacker, int a) {

    if (uKilled == null) return false;
                  
    RemoveGhost(uKilled);            
    if (uAttacker != null) {
        RemoveEnemyMarker(uKilled);
        RemoveGhostMarker(uKilled);
    }
                           
    return false;

}

state Initialize
{
    ENABLE_TRACE(true);
    TRACE("\n\n\n\n");
    InitializeEnemyLevels();
    InitializeGhosts();
    InitializeEnemyTraps();
    SetTimer(0, 5);
    //InitializeEnemiesOnMissions();
    return Nothing,1;
}
state Nothing
{
    int i;
    mission pMission;
    int nCreated;
    
    nCreated = false;
    for (i = 0; i < GetPlayersCnt(); i++)
    {
        if (!IsPlayer(i)) continue;
        pMission = GetHero(i).GetMission();    
        CheckATaintMonsters(pMission);
        if (!ProcessedMarkers(pMission))
        {
            ProcessMarkers(pMission);
        }
        if (!EnemiesCreated(pMission)) 
        {
            nCreated |= CreateMissionEnemies(pMission, true);
        }
        nCreated |= ProcessGhosts(GetHero(i).GetMission());        
    }
    
    if (nCreated) return Nothing, 5;    
    return Nothing,30*5;
}

event Timer0()
{
    int i;
    unit uHero;
    mission pMission;
    for (i = 0; i < GetPlayersCnt(); i++)
    {
        if (!IsPlayer(i)) continue;
        uHero = GetHero(i);
        pMission = uHero.GetMission();
        CheckEnemyTrap(pMission, uHero);
    }
    return false;
}

command Message(int nCommand, int nParam1, int nParam2, int nParam3) {

    if (nCommand == eMsgCreateEnemy) {
        if (nEnemyClass < eLastEnemyClass) CreateEnemy(GetCampaign().GetMission(nParam1),nParam2,nParam3,nParam1,nEnemyClass,nParty,nQuantityFactor,nForceLevel,false,0);
        else AddGhostMarkers(GetCampaign().GetMission(nParam1),nEnemyClass - eLastEnemyClass,nParam2,nParam3,nQuantityFactor);
        return true;
    }

    return 0;

}

command Message(int nCommand, int nParam1, int nParam2, int nParam3, int nParam4) {

    if (nCommand == eMsgSetCreateEnemyParams) {
        nEnemyClass = nParam1;
        nParty = nParam2;
        nQuantityFactor = nParam3;
        nForceLevel = nParam4;
        return true;    
    }
    if (nCommand == eMsgCreateBandits) {
        CreateEnemy(GetCampaign().GetMission(nParam1),nParam2,nParam3,nParam1,eClassBandit,ePartyBandits,0,0,true,nParam4);
        return true;
    }
    
    return 0;

}

command CommandDebug(string strLine)
{
    int i;
    int n;
    unit uHero;
    mission pMission;
    
    if (!stricmp(strLine, "PrintMarkerGhosts"))
    {
        pMission = GetHero(i).GetMission();
        n = pMission.GetMaxMarkerNum("MARKER_ENEMY_G_DWARF_01");
        for (i = 1; i <= n; i++)
        {
            if (pMission.HaveMarker("MARKER_ENEMY_G_DWARF_01",i)) {
                TRACE("jest marker ghost %d             \n",i);
            }            
        }
    
    }    
    else
    {
        return false;
    }
    
    return true;
}

}

