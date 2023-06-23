global "Enemies Script"
{
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
    InitializeEnemyLevels();
    InitializeGhosts();
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
        if (!EnemiesCreated(pMission)) 
        {
            nCreated |= CreateMissionEnemies(pMission);
        }
        nCreated |= ProcessGhosts(GetHero(i).GetMission());        
    }
    
    if (nCreated) return Nothing, 5;    
    return Nothing,30*5;
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

