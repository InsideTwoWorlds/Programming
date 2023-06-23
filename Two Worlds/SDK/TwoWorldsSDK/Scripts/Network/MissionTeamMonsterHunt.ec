global "Team Monster Hunt script"
{

#include "MissionTeamBase.ech"

#include "..\Common\Enums.ech"
#include "..\Common\Enemies.ech"

#define TEAMMONSTERHUNT_MONSTEROWNER  "TeamMonsterHuntTargetOwner"
#define TEAMMONSTERHUNT_MONSTERPOINTS "TeamMonsterHuntTargetPoints"

////////////////////////////////////////////////////////////////////////////////
consts
{
// dodatkowe markery
    eMarkerTeam1Monster   = 51, // 51-70
    eMarkerTeam2Monster   = 71, // 71-90
    eMarkerTeamMonsterNum = 20,
// interfejs    
    eHuntConsoleTextTime =  5 * 30,
// gameplay
    ePointsRequiredForVictory = 100,
    eMonsterRespawnTicks      = 3 * 30,

    eMonsterBig               = 0, // poszczegolne monstery
    eMonsterMedium            = 1,
    eMonsterSmall             = 2,

    eMonsterBigCount          = 1,  // liczba monsterow
    eMonsterMediumCount       = 2,
    eMonsterSmallCount        = 7,

    eMonsterBigPoints         = 50, // punkty za kazdego monstera
    eMonsterMediumPoints      = 10,
    eMonsterSmallPoints       = 1,
//
    eMonsterHuntMainStateTicksInterval = 30,
}

////////////////////////////////////////////////////////////////////////////////
// dodatkowe markery
int m_arrTeam1MonsterX[]; // zwierzaki
int m_arrTeam1MonsterY[];
int m_arrTeam1MonsterAngle[];
int m_arrTeam2MonsterX[]; // zwierzaki
int m_arrTeam2MonsterY[];
int m_arrTeam2MonsterAngle[];
// dodatkowe zmienne herosow
int m_arrTeam1PointsCount[]; // ile pkt zdobyl osobiscie
int m_arrTeam2PointsCount[];
// dodatkowe zmienne
unit m_arrTeam1Monster[];
int  m_arrTeam1MonsterRespawnTicks[];
unit m_arrTeam2Monster[];
int  m_arrTeam2MonsterRespawnTicks[];
// dodatkowe zmienne teamow
int m_nTeam1GamePoints; // ile pkt zdobyl team
int m_nTeam2GamePoints;

string m_arrTeam1MonsterNames[];
int    m_arrTeam1AvailableTypes[];
int    m_arrTeam1LevelModifiers[];
string m_arrTeam2MonsterNames[];
int    m_arrTeam2AvailableTypes[];
int    m_arrTeam2LevelModifiers[];

// zmienne gameplaya
int  m_nPointsRequiredForVictory;
int  m_nAverageHeroesLevel;

////////////////////////////////////////////////////////////////////////////////
state Initialize;
state JoiningTeams;
state CountdownBeforeFight;
state Fight;
state Results;
state GameOver;

function void TeamMonsterHuntInit();
function void InitTeamMonsterHuntMapSigns();
function void InitMonsterMapSigns();
function void InitMonsterMapSigns(unit arrMonsters[], int nMapSign);
function int  InitMonsterMarkers();
function void InitTeams();
function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrPointsCount[]);
function void InitAverageHeroesLevel();
function void InitPossibleTeamMonsters();
function int  InitTeamMonsters();
function int  InitTeamMonsters(int nMonsterOwner, unit arrMonsters[], int arrMonsterRespawnTicks[], int arrMonsterX[], int arrMonsterY[], int arrMonsterAngle[]);
function unit CreateTeamMonster(int nParty, int nX, int nY, int nAngle, int nType, string arrMonsterNames[],int arrAvailableTypes[], int arrLevelModifiers[]);
//function unit CreateMonster(int nMonsterOwner, int nMonsterType, int nX, int nY, int nAngle);
//function string CreateMonsterString(int nMonsterOwner, int nMonsterType);
//function string CreateMonsterString(int nMonsterType, string arrMonsterBig[], string arrMonsterMedium[], string arrMonsterSmall[],
//                                                      int nWeaponForBig, int nWeaponForMedium, int nWeaponForSmall,
//                                                      int nLevelModifierBig, int nLevelModifierMedium, int nLevelModifierSmall);
function void IncreaseTeamPointsCount(int nTeamNum, int nPoints);
function void IncreaseHeroPointsCount(int nTeamNum, int nHeroIndex, int nPoints);
function void IncreaseHeroPointsCount(int arrPointsCount[], int nHeroIndex, int nPoints);
function void PrepareToRespawnMonster(int nTeamNum, unit pMonster);
function void RespawnTeamMonsters();
function void RespawnTeamMonsters(int nTeamNum);
function void RespawnTeamMonsters(unit arrMonsters[], int arrMonsterRespawnTicks[]);
function int  RespawnMonster(unit pMonster);
function int  MoveMonsterToTeamStartMarker(unit pMonster, int nTeamNum);
function void CheckIfAnyTeamHasRequiredPoints();
function void KillTeamMonsters();
function void KillTeamMonsters(unit arrTeamMonsters[]);
function void DistributePoints();
function void DistributeEarthNetPlayerPoints();
function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrPointsCount[]);
function void DistributeXBOXPoints_TeamMonsterHunt();
function void DistributeXBOXPoints_TeamMonsterHunt(int arrWinningHeroNum[], int arrLosingHeroNum[]);

function void ShowHuntText();
function void ShowHuntGamePointsText();

function int GetTeamOfTheMonster(unit pMonster);
function int GetIndexOfTheMonster(int nTeamNum, unit pMonster);
function int GetIndexOfTheMonster(unit arrMonsters[], unit pMonster);

////////////////////////////////////////////////////////////////////////////////
function void TeamMonsterHuntInit()
{
    TeamBaseInit();
    InitTeamStartMarkers(); // musi byc tu a nie w MissionTeamBase.ech, bo w DM trzeba wziac pod uwage m_nMarkerShift
    InitMonsterMarkers();
    
    m_nMainStateTicksInterval = eMonsterHuntMainStateTicksInterval;
    m_nPointsRequiredForVictory = ePointsRequiredForVictory;
    m_nTeam1GamePoints = 0;
    m_nTeam2GamePoints = 0;
    
    EnableShowLocalTeamMapSigns(true);
    EnableShowRemoteTeamMapSigns(false);
    EnableItemRespawns(true);
    InitRespawnItemMarkers();
    InitRespawnItems();
}//--------------------------------------------------------------------------------------|

function void InitTeamMonsterHuntMapSigns()
{
    InitTeamMapSigns();
    InitMonsterMapSigns();
}//--------------------------------------------------------------------------------------|

function void InitMonsterMapSigns()
{
    InitMonsterMapSigns(m_arrTeam1Monster, eMapSignTeam1Monster);
    InitMonsterMapSigns(m_arrTeam2Monster, eMapSignTeam2Monster);
}//--------------------------------------------------------------------------------------|

function void InitMonsterMapSigns(unit arrMonsters[], int nMapSign)
{
    int nIndex;

    for(nIndex = 0; nIndex < arrMonsters.GetSize(); nIndex++)
    {
        AddUnitMapSign( arrMonsters[nIndex], nMapSign);
    }
}//--------------------------------------------------------------------------------------|

function int InitMonsterMarkers()
{
    InitMarkers(eMarkerTeam1Monster, eMarkerTeamMonsterNum, m_arrTeam1MonsterX, m_arrTeam1MonsterY, m_arrTeam1MonsterAngle);
    InitMarkers(eMarkerTeam2Monster, eMarkerTeamMonsterNum, m_arrTeam2MonsterX, m_arrTeam2MonsterY, m_arrTeam2MonsterAngle);
    return 1;
}//--------------------------------------------------------------------------------------|

function void InitTeams()
{
    InitTeam(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1HeroRespawnTicks, m_arrTeam1PointsCount);
    InitTeam(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2HeroRespawnTicks, m_arrTeam2PointsCount);
    InitAverageHeroesLevel();
}//--------------------------------------------------------------------------------------|

function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrPointsCount[])
{
    int nPlayerIndex;

    InitTeam(arrHeroNumber, arrRankPoints, arrRespawnTicks);

    arrPointsCount.RemoveAll();
    for(nPlayerIndex = 0; nPlayerIndex < arrHeroNumber.GetSize(); nPlayerIndex++)
    {
        arrPointsCount.Add(0);
    }
}//--------------------------------------------------------------------------------------|

function int InitTeamMonsters()
{
    InitPossibleTeamMonsters();

    InitTeamMonsters(eTeam1, m_arrTeam1Monster, m_arrTeam1MonsterRespawnTicks, m_arrTeam1MonsterX, m_arrTeam1MonsterY, m_arrTeam1MonsterAngle);
    InitTeamMonsters(eTeam2, m_arrTeam2Monster, m_arrTeam2MonsterRespawnTicks, m_arrTeam2MonsterX, m_arrTeam2MonsterY, m_arrTeam2MonsterAngle);
    return 1;
}//--------------------------------------------------------------------------------------|

function void InitAverageHeroesLevel()
{
    // z dowolnego playera
    int nIndex;
    int nCount;

    nCount = 0;
    m_nAverageHeroesLevel = 0;

    for(nIndex = 0; nIndex < GetCampaign().GetPlayersCnt(); nIndex++)
    {
        if( IsPlayer(nIndex) )
        {
            m_nAverageHeroesLevel += GetCampaign().GetPlayerHeroUnit(nIndex).GetUnitValues().GetLevel();
            nCount++;
        }
    }
    m_nAverageHeroesLevel = MAX(1, m_nAverageHeroesLevel / nCount);
    TRACE("average heroes level: %d\n", m_nAverageHeroesLevel);
}//--------------------------------------------------------------------------------------|

function void InitPossibleTeamMonsters()
{
// team1
    m_arrTeam1MonsterNames.Add("MU_SNAKE_%02d(%%d)");  // po zmianie typu monstera trzeba
    m_arrTeam1MonsterNames.Add("MU_SEAGUY_%02d(%%d)"); // zaktualizowac CreateTeamMonster()
    m_arrTeam1MonsterNames.Add("MU_VYVERN_%02d(%%d)");

    m_arrTeam1AvailableTypes.Add(3); // liczba mozliwych typow danego monstera (np MU_SNAKE_01, MU_SNAKE_02, MU_SNAKE_03)
    m_arrTeam1AvailableTypes.Add(3);
    m_arrTeam1AvailableTypes.Add(3);

    m_arrTeam1LevelModifiers.Add(5); // modyfikator poziomu monstera (level monstera = level gracza + modyfikator)
    m_arrTeam1LevelModifiers.Add(0);
    m_arrTeam1LevelModifiers.Add(-5);
// team2
    m_arrTeam2MonsterNames.Add("MU_HELLWARIOR(%%d)");  // analogicznie
    m_arrTeam2MonsterNames.Add("MU_MINION_%02d(%%d)");
    m_arrTeam2MonsterNames.Add("MU_ZOMBIE_%02d(%%d)");

    m_arrTeam2AvailableTypes.Add(1);
    m_arrTeam2AvailableTypes.Add(3);
    m_arrTeam2AvailableTypes.Add(3);

    m_arrTeam2LevelModifiers.Add(5);
    m_arrTeam2LevelModifiers.Add(0);
    m_arrTeam2LevelModifiers.Add(-5);
}//--------------------------------------------------------------------------------------|

function int InitTeamMonsters(int nMonsterOwner, unit arrMonsters[], int arrMonsterRespawnTicks[], int arrMonsterX[], int arrMonsterY[], int arrMonsterAngle[])
{
    unit pMonster;
    int nIndex;
    int arrMonsterCount[];
    int arrMonsterType[];
    int arrX[], arrY[], arrAngle[];
    int nX, nY, nAngle;
    int nRandValue;

    arrX.Copy(arrMonsterX); // kopie tablic markerow startowych monsterow
    arrY.Copy(arrMonsterY);
    arrAngle.Copy(arrMonsterAngle);

    arrMonsterType.Add(eMonsterBig);
    arrMonsterCount.Add(eMonsterBigCount);
    arrMonsterType.Add(eMonsterMedium);
    arrMonsterCount.Add(eMonsterMediumCount);
    arrMonsterType.Add(eMonsterSmall);
    arrMonsterCount.Add(eMonsterSmallCount);

    while( arrMonsterType.GetSize() && arrMonsterCount.GetSize() )
    {
        if( arrMonsterCount[0] <= 0 )
        {
            arrMonsterType.RemoveAt(0);
            arrMonsterCount.RemoveAt(0);
            continue;
        }
// pobranie wspolrzednych markera dla monstera
        if( arrX.GetSize() && arrY.GetSize() && arrAngle.GetSize() )
        {
            nRandValue = Rand(arrX.GetSize());
            nX = arrX[nRandValue];
            nY = arrY[nRandValue];
            nAngle = arrAngle[nRandValue];
            arrX.RemoveAt(nRandValue);
            arrY.RemoveAt(nRandValue);
            arrAngle.RemoveAt(nRandValue);
        }
        else
        {
            TRACE("Zabraklo monster markerow dla teamu %d (ale bedzie ok)\n", nMonsterOwner);
            nRandValue = Rand(arrMonsterX.GetSize());
            nX = arrMonsterX[nRandValue];
            nY = arrMonsterY[nRandValue];
            nAngle = arrMonsterAngle[nRandValue];
        }
// tworzenie potwora
        if( nMonsterOwner == eTeam1 )
        {
            pMonster = CreateTeamMonster(nMonsterOwner, nX, nY, nAngle, arrMonsterType[0], m_arrTeam1MonsterNames,
                                         m_arrTeam1AvailableTypes, m_arrTeam1LevelModifiers);
        }
        else if( nMonsterOwner == eTeam2 )
        {
            pMonster = CreateTeamMonster(nMonsterOwner, nX, nY, nAngle, arrMonsterType[0], m_arrTeam2MonsterNames,
                                         m_arrTeam2AvailableTypes, m_arrTeam2LevelModifiers);
        }
        else
        {
            TRACE("!!! Nieznany team !!!\n");
        }

        if( pMonster != null )
        {
            arrMonsters.Add(pMonster);
            arrMonsterRespawnTicks.Add(0); // cokolwiek, potem potrzebne
        }
        arrMonsterCount[0] -= 1; // zmniejsz licznik potworow
    }

    return 1;    
}//--------------------------------------------------------------------------------------|

function void IncreaseTeamPointsCount(int nTeamNum, int nPoints)
{
    if( nTeamNum == eTeam1 )
    {
        m_nTeam1GamePoints += nPoints;
    }
    else if( nTeamNum == eTeam2 )
    {
        m_nTeam2GamePoints += nPoints;
    }
    else
    {
        TRACE("!!! Nieznany team !!!\n");
    }
}//--------------------------------------------------------------------------------------|

function void IncreaseHeroPointsCount(int nTeamNum, int nHeroIndex, int nPoints)
{
    if( nTeamNum == eTeam1 )
    {
        IncreaseHeroPointsCount(m_arrTeam1PointsCount, nHeroIndex, nPoints);
    }
    else if( nTeamNum == eTeam2 )
    {
        IncreaseHeroPointsCount(m_arrTeam2PointsCount, nHeroIndex, nPoints);
    }
    else
    {
        TRACE("!!! Nieznany team !!!\n");
    }
}//--------------------------------------------------------------------------------------|

function void IncreaseHeroPointsCount(int arrPointsCount[], int nHeroIndex, int nPoints)
{
    ASSERT( (nHeroIndex >= 0) && (nHeroIndex < arrPointsCount.GetSize()) );
    arrPointsCount[nHeroIndex] += nPoints;
}//--------------------------------------------------------------------------------------|

function void PrepareToRespawnMonster(int nTeamNum, unit pMonster)
{
    int nMonsterIndex;

    nMonsterIndex = GetIndexOfTheMonster(nTeamNum, pMonster);
    ASSERT( nMonsterIndex > -1);

    if( nTeamNum == eTeam1 )
    {
        m_arrTeam1MonsterRespawnTicks[nMonsterIndex] = eMonsterRespawnTicks; 
    }
    else if( nTeamNum == eTeam2 )
    {
        m_arrTeam2MonsterRespawnTicks[nMonsterIndex] = eMonsterRespawnTicks;
    }
}//--------------------------------------------------------------------------------------|

function void RespawnTeamMonsters()
{
    RespawnTeamMonsters(eTeam1);
    RespawnTeamMonsters(eTeam2);
}//--------------------------------------------------------------------------------------|

function void RespawnTeamMonsters(int nTeamNum)
{
    if( nTeamNum == eTeam1 )
    {
        RespawnTeamMonsters(m_arrTeam1Monster, m_arrTeam1MonsterRespawnTicks);
    }
    else if( nTeamNum == eTeam2 )
    {
        RespawnTeamMonsters(m_arrTeam2Monster, m_arrTeam2MonsterRespawnTicks);
    }
}//--------------------------------------------------------------------------------------|

function void RespawnTeamMonsters(unit arrMonsters[], int arrMonsterRespawnTicks[])
{
    int nIndex;
    ASSERT( arrMonsters.GetSize() == arrMonsterRespawnTicks.GetSize() );
    for(nIndex = 0; nIndex < arrMonsters.GetSize(); nIndex++)
    {
        if( arrMonsters[nIndex].IsLive() )
        {
            continue;
        }
        if( arrMonsterRespawnTicks[nIndex] > 0 )
        {
            arrMonsterRespawnTicks[nIndex] -= m_nMainStateTicksInterval;
        }
        else
        {
            RespawnMonster(arrMonsters[nIndex]);
        }
    }
}//--------------------------------------------------------------------------------------|

function int RespawnMonster(unit pMonster)
{
    int nTeamNum;

    pMonster.ResurrectUnit();
    nTeamNum = GetTeamOfTheMonster(pMonster);
    ASSERT(nTeamNum > -1);
    MoveMonsterToTeamStartMarker(pMonster, nTeamNum);
    TRACE("respawned monster form team %d\n", nTeamNum);
    return 1;
}//--------------------------------------------------------------------------------------|

function int MoveMonsterToTeamStartMarker(unit pMonster, int nTeamNum)
{
    int nMarkerIndex;
    int nX, nY, nAngle;

    
    if( nTeamNum == eTeam1 )
    {
        nMarkerIndex = Rand( m_arrTeam1MonsterX.GetSize() );
        nX = m_arrTeam1MonsterX[nMarkerIndex];
        nY = m_arrTeam1MonsterY[nMarkerIndex];
        nAngle = m_arrTeam1MonsterAngle[nMarkerIndex];
    }
    else if( nTeamNum == eTeam2 )
    {
        nMarkerIndex = Rand( m_arrTeam2MonsterX.GetSize() );
        nX = m_arrTeam2MonsterX[nMarkerIndex];
        nY = m_arrTeam2MonsterY[nMarkerIndex];
        nAngle = m_arrTeam2MonsterAngle[nMarkerIndex];
    }
    else
    {
        TRACE("!!! Nieznany team %d !!!\n", nTeamNum);
        return 0;
    }
    m_pCurrentMission.CreateObject(TELE_OUT_EFFECT, pMonster.GetLocationX(), pMonster.GetLocationY(), 0, 0);
    pMonster.SetImmediatePosition( nX, nY, 0, nAngle, true);
    m_pCurrentMission.CreateObject(TELE_IN_EFFECT, pMonster.GetLocationX(), pMonster.GetLocationY(), 0, nAngle);
    
    return 1;
}//--------------------------------------------------------------------------------------|

function void KillTeamMonsters()
{
    KillTeamMonsters(m_arrTeam1Monster);
    KillTeamMonsters(m_arrTeam2Monster);
}//--------------------------------------------------------------------------------------|

function void KillTeamMonsters(unit arrTeamMonsters[])
{
    int nIndex;
    for(nIndex = 0; nIndex < arrTeamMonsters.GetSize(); nIndex++)
    {
        if( arrTeamMonsters[nIndex].IsLive() )
        {
            m_pCurrentMission.CreateObject(TELE_OUT_EFFECT, arrTeamMonsters[nIndex].GetLocationX(), arrTeamMonsters[nIndex].GetLocationY(), 0, 0);
            arrTeamMonsters[nIndex].RemoveObject();
        }
    }
}//--------------------------------------------------------------------------------------|

function void DistributePoints()
{
#ifdef _XBOX
    DistributeXBOXPoints_TeamMonsterHunt();
#else
    if( IsGuildsGame() )
    {
        DistributeEarthNetGuildPoints();
        ShowEarthNetGuildPointsText();
    }
    else
    {
        DistributeEarthNetPlayerPoints();
        ShowEarthNetPlayerPointsText();
    }
#endif
}//--------------------------------------------------------------------------------------|

function void DistributeEarthNetPlayerPoints()
{
// policz punkty w tablicach
    if( m_nWinner == eTeam1 )
    {
        DistributeEarthNetPlayerPoints(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1PointsCount);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeEarthNetPlayerPoints(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2PointsCount);
    }
    else
    {
        TRACE("!!! Unknown winner !!!");
    }
}//--------------------------------------------------------------------------------------|

function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrPointsCount[])
{
    int nIndex;
    int nPrizePointsPerPlayer;
    int nPlayersCount;
    int nMaxPointsHeroIndex;
    unit pHero;
    int nOverallPrizePoints;
    int arrPoints[];         // bezwzgledna liczba punktow za wygrana rozgrywke (wlacznie z zainwestowanymi)

    if( IsGuildsGame() )
    {
        return;
    }
// liczenie liczby zwycieskich herosow, ktoregos moze juz nie byc
    nPlayersCount = 0;
    for(nIndex = 0; nIndex < arrHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer( arrHeroNum[nIndex] ) )
        {
            continue;
        }
        nPlayersCount++;
    }
// kto ma najwiecej punktow za potwory na koncie
    nMaxPointsHeroIndex = GetIndexOfMinValueInArray(arrPointsCount);
// ile pkt przypada na pojedynczego playera
    nPrizePointsPerPlayer = m_nEarthNetPlayerPointsPool / nPlayersCount;
    TRACE("Pool points: %d, players: %d\nPoints per player: %d, bonus points: %d\n", m_nEarthNetPlayerPointsPool, nPlayersCount, nPrizePointsPerPlayer, m_nEarthNetPlayerPointsPool % nPlayersCount);
// dodanie punktow zwycieskim playerom
    for(nIndex = 0; nIndex < arrHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer( arrHeroNum[nIndex] ) )
        {
            arrPoints.Add(0); // musi byc zeby zgadzaly sie indeksy
            continue;
        }
        arrPoints.Add(nPrizePointsPerPlayer);
        m_nEarthNetPlayerPointsPool -= nPrizePointsPerPlayer;
        ASSERT( m_nEarthNetPlayerPointsPool >= 0 );
    }
// jezeli po rozdysponowaniu punktow cos jeszcze zostalo to daj to playerowi z najwieksza liczba pkt
    if( m_nEarthNetPlayerPointsPool > 0 )
    {
        TRACE("Bonus points (%d) goes to %d\n", m_nEarthNetPlayerPointsPool, nMaxPointsHeroIndex);
        ASSERT( (nMaxPointsHeroIndex >= 0) && (nMaxPointsHeroIndex < arrPrizePoints.GetSize()) );
        arrPoints[nMaxPointsHeroIndex] += m_nEarthNetPlayerPointsPool;
    }
// zapis z tablicy do playera
    for(nIndex = 0; nIndex < arrHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer( arrHeroNum[nIndex] ) )
        {
            continue;
        }
        pHero = GetCampaign().GetPlayerHeroUnit(arrHeroNum[nIndex]);

        if( GetGameType() == eGamePvP )
        {
            pHero.AddHeroNetworkRankPoints(arrPoints[nIndex]);
        }
        else if( GetGameType() == eGameRPGArena )
        {
            pHero.SetMoney( pHero.GetMoney() + arrPoints[nIndex] );
        }

        arrPrizePoints[nIndex] += arrPoints[nIndex]; // korekta tego co bedzie wyswietlane (zdobyte punkty bez swoich odzyskanych)
    }
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_TeamMonsterHunt()
{
    if( m_nWinner == eTeam1 )
    {
        DistributeXBOXPoints_TeamMonsterHunt(m_arrTeam1HeroNumber, m_arrTeam2HeroNumber);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeXBOXPoints_TeamMonsterHunt(m_arrTeam2HeroNumber, m_arrTeam1HeroNumber);
    }
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_TeamMonsterHunt(int arrWinningHeroNum[], int arrLosingHeroNum[])
{
    int nGamePoints;
    int nIndex;
    stringW strText;
    
    nGamePoints = arrLosingHeroNum.GetSize() * 5;
    for(nIndex = 0; nIndex < arrWinningHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer(arrWinningHeroNum[nIndex]) )
        {
            continue;
        }
        GetCampaign().GetPlayerHeroUnit(arrWinningHeroNum[nIndex]).AddHeroNetworkGameModePoints(eGameModePointsMonsterkilling, nGamePoints);
        if (IsRankedGame())
        {
            strText.FormatTrl(TEXT_GETPOINTS, nGamePoints);
            ShowTextToPlayer(arrWinningHeroNum[nIndex], strText, eResultsConsoleTextTime, true);
        }
    }
#ifndef _DEMO        
    GetCampaign().SendXBoxHeroNetworkGameModePoints();
#endif    
}//--------------------------------------------------------------------------------------|

function void CheckIfAnyTeamHasRequiredPoints()
{
    if( m_nWinner != eNoWinnerYet )
    {
        return; // juz ktos wygral, nie ma co sprawdzac    
    }
    if( (m_nTeam1GamePoints < m_nPointsRequiredForVictory) &&
        (m_nTeam2GamePoints < m_nPointsRequiredForVictory) )
    {
        return;
    }
    if( (m_nTeam1GamePoints >= m_nPointsRequiredForVictory) &&
        (m_nTeam2GamePoints >= m_nPointsRequiredForVictory) )
    {
        TRACE("!!! Blad! Moze byc tylko jeden zwyciezca !!!\n");
        return;
    }
    if( m_nTeam1GamePoints >= m_nPointsRequiredForVictory )
    {
        m_nWinner = eTeam1;
    }
    else if( m_nTeam2GamePoints >= m_nPointsRequiredForVictory )
    {
        m_nWinner = eTeam2;
    }
}//--------------------------------------------------------------------------------------|

function void ShowHuntText()
{
    stringW strTextHunt, strTextPoints;
    strTextHunt.Translate(TEXT_HUNT);
    strTextPoints.FormatTrl(TEXT_POINTSREQUIREDTOWIN, m_nPointsRequiredForVictory);
    ShowTextToTeam(eTeam1, strTextHunt,   eHuntConsoleTextTime, false);
    ShowTextToTeam(eTeam1, strTextPoints, eHuntConsoleTextTime, true);
    ShowTextToTeam(eTeam2, strTextHunt,   eHuntConsoleTextTime, false);
    ShowTextToTeam(eTeam2, strTextPoints, eHuntConsoleTextTime, true);
}//--------------------------------------------------------------------------------------|

function void ShowHuntGamePointsText()
{
    stringW strTeam1, strTeam2;
    stringW strText;

    strTeam1.Translate(TEXT_TEAM1);
    strTeam2.Translate(TEXT_TEAM2);

    strText.FormatTrl(TEXT_GAMEPOINTS, strTeam1, m_nTeam1GamePoints, m_nTeam2GamePoints, strTeam2);

    ShowBottomTextToTeam(eTeam1, strText, eResultsConsoleTextTime, false);
    ShowBottomTextToTeam(eTeam2, strText, eResultsConsoleTextTime, false);
}//--------------------------------------------------------------------------------------|

function int GetTeamOfTheMonster(unit pMonster)
{
    int nIndex;

    nIndex = GetIndexOfTheMonster(eTeam1, pMonster);
    if( nIndex > -1 )
    {
        return eTeam1;
    }
    nIndex = GetIndexOfTheMonster(eTeam2, pMonster);
    if( nIndex > -1 )
    {
        return eTeam2;
    }
    return -1;
}//--------------------------------------------------------------------------------------|

function int GetIndexOfTheMonster(int nTeamNum, unit pMonster)
{
    if( nTeamNum == eTeam1 )
    {
        return GetIndexOfTheMonster(m_arrTeam1Monster, pMonster);
    }
    else if( nTeamNum == eTeam2 )
    {
        return GetIndexOfTheMonster(m_arrTeam2Monster, pMonster);
    }
    return -1;
}//--------------------------------------------------------------------------------------|

function int GetIndexOfTheMonster(unit arrMonsters[], unit pMonster)
{
    int nIndex;
    
    for(nIndex = 0; nIndex < arrMonsters.GetSize(); nIndex++)
    {
        if( pMonster == arrMonsters[nIndex] )
        {
            return nIndex;
        }
    }
    return -1;
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
event RemovedNetworkPlayer(int nPlayerNum)
{
    stringW strText;
    TRACE("TeamMonsterHunt::RemovedNetworkPlayer(%d)\n", nPlayerNum);
    
    strText.FormatTrl(TEXT_LEFTTHEGAME, m_arrHeroNames[nPlayerNum]);
    ShowTextToAll(strText, eDefaultConsoleTextTime, true);
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event RemovedUnit(unit uKilled, unit uAttacker, int a)
{
    int nKilledTeamNum;
    int nKilledHeroIndex;
    int nKilledHeroNum;
    int nAttackerMonsterOwner;
    int nAttackTeamNum;
    int nAttackHeroIndex;
    int nAttackHeroNum;    
    int nKilledMonsterOwner;
    int nKilledMonsterPoints;
    stringW strText, strTeam1Text, strTeam2Text;

    nAttackTeamNum = -1;
    nAttackHeroIndex = -1;
    nAttackHeroNum = -1;
    if( (uAttacker != null) && uAttacker.IsHeroUnit() )
    {
        nAttackHeroNum = uAttacker.GetHeroPlayerNum();
        nAttackTeamNum = GetTeamOfTheHero(nAttackHeroNum);
        if( nAttackTeamNum == -1 )
        {
            __ASSERT_FALSE();
        }
        nAttackHeroIndex = GetIndexOfTheHero(nAttackHeroNum, nAttackTeamNum);
        if( nAttackHeroIndex == -1 )
        {
            __ASSERT_FALSE();
        }
    }

    // zabity zostal player
    if( uKilled.IsHeroUnit() )
    {
        nKilledHeroNum = uKilled.GetHeroPlayerNum();
        nKilledTeamNum = GetTeamOfTheHero(nKilledHeroNum);
        if( nKilledTeamNum == -1 ) // gdyby ktos wyszedl z gry przed dolaczeniem do teamu
        {
            return false;
        }
        nKilledHeroIndex = GetIndexOfTheHero(nKilledHeroNum, nKilledTeamNum);
        if( nKilledHeroIndex == -1 ) // gdyby ktos wyszedl z gry przed dolaczeniem do teamu
        {
            return false;
        }

        if( state == Fight )
        {
            // jezeli bohater zostal fizycznie zabity przez kogos
            // (a nie wyszedl z gry, utopil sie albo spadl z wysokosci)
            // to wypisz info
            if( uAttacker )
            {
                if( !uAttacker.IsHeroUnit() )
                {
                    strText.FormatTrl(TEXT_WASKILLED, m_arrHeroNames[nKilledHeroNum] );
                }
                else if( nAttackTeamNum != nKilledTeamNum )
                {
                    strText.FormatTrl(TEXT_WASKILLEDBY, m_arrHeroNames[nKilledHeroNum], m_arrHeroNames[nAttackHeroNum]);
                }
                else
                {
                    strText.FormatTrl(TEXT_WASKILLEDBY_FF, m_arrHeroNames[nKilledHeroNum], m_arrHeroNames[nAttackHeroNum]);
                }
                ShowTextToAll(strText, eKilledConsoleTextTime, true);
            }
            PrepareToRespawnHero(nKilledTeamNum, nKilledHeroIndex);
        }
        else // na wszelki wypadek gdyby komus udalo sie zginac po walce
        {
//          RespawnTeamHero(uKilled); // niech zostanie martwy
        }
    }
    // zabity zostal zwierzak (teamowy albo summonowany)
    else
    {
        if( m_nWinner != eNoWinnerYet ) // jezeli jest juz zwyciezca to nie musze sprawdzac monsterow
        {
            return true;
        }
        // zabity zostal monster teamowy
        if( uKilled.GetAttribute(TEAMMONSTERHUNT_MONSTEROWNER, nKilledMonsterOwner) &&
            uKilled.GetAttribute(TEAMMONSTERHUNT_MONSTERPOINTS, nKilledMonsterPoints) )
        {
            // atakujacym byl hero
            if( (uAttacker != null) && uAttacker.IsHeroUnit() )
            {
                if( nKilledMonsterOwner == eTeam1 )
                {
                    strTeam1Text.FormatTrl(TEXT_YOURMONSTERKILLEDBY, m_arrHeroNames[nAttackHeroNum], nKilledMonsterPoints);
                    strTeam2Text.FormatTrl(TEXT_ENEMYMONSTERKILLEDBY, m_arrHeroNames[nAttackHeroNum], nKilledMonsterPoints);
                }
                else if( nKilledMonsterOwner == eTeam2 )
                {
                    strTeam1Text.FormatTrl(TEXT_ENEMYMONSTERKILLEDBY, m_arrHeroNames[nAttackHeroNum], nKilledMonsterPoints);
                    strTeam2Text.FormatTrl(TEXT_YOURMONSTERKILLEDBY, m_arrHeroNames[nAttackHeroNum], nKilledMonsterPoints);
                }
                else
                {
                    __ASSERT_FALSE();
                }
                
                if( nKilledMonsterOwner != nAttackTeamNum )
                {
                    TRACE("Hero %d(%d) zabil obcego monstera (+%d pkt)\n", nAttackHeroNum, nAttackTeamNum, nKilledMonsterPoints);
                    IncreaseTeamPointsCount(nAttackTeamNum, nKilledMonsterPoints);
                    IncreaseHeroPointsCount(nAttackTeamNum, nAttackHeroIndex, nKilledMonsterPoints);
                }
                else // friendly fire, punkty dostaje przecinwik
                {
                    TRACE("Hero %d(%d) zabil wlasnego monstera! (+%d pkt dla przeciwnika)\n", nAttackHeroNum, nAttackTeamNum, nKilledMonsterPoints);
                    IncreaseTeamPointsCount( GetOppositeTeam(nAttackTeamNum), nKilledMonsterPoints); // IncreaseHeroPointsCount(nAttackTeamNum, nAttackHeroIndex, -nKilledMonsterPoints);
                }
                ShowTextToTeam(eTeam1, strTeam1Text, eKilledConsoleTextTime, true);
                ShowTextToTeam(eTeam2, strTeam2Text, eKilledConsoleTextTime, true);
            }
            // atakujacym byl monster teamowy
            else if( (uAttacker != null) && uAttacker.GetAttribute(TEAMMONSTERHUNT_MONSTEROWNER, nAttackerMonsterOwner) )
            {
                if( nKilledMonsterOwner == eTeam1 )
                {
                    strTeam1Text.FormatTrl(TEXT_YOURMONSTERKILLED, nKilledMonsterPoints);
                    strTeam2Text.FormatTrl(TEXT_ENEMYMONSTERKILLED, nKilledMonsterPoints);
                }
                else if( nKilledMonsterOwner == eTeam2 )
                {
                    strTeam1Text.FormatTrl(TEXT_ENEMYMONSTERKILLED, nKilledMonsterPoints);
                    strTeam2Text.FormatTrl(TEXT_YOURMONSTERKILLED, nKilledMonsterPoints);
                }
                else
                {
                    __ASSERT_FALSE();
                }
                
                if( nKilledMonsterOwner != nAttackerMonsterOwner )
                {
                    TRACE("Monster (%d) zabil obcego monstera (+%d pkt)\n", nAttackerMonsterOwner, nKilledMonsterPoints);
                    IncreaseTeamPointsCount(nAttackerMonsterOwner, nKilledMonsterPoints);
                }
                else // monster friendly fire
                {
                    TRACE("Monster (%d) zabil wlasnego monstera? (+%d pkt dla przeciwnika)\n", nAttackerMonsterOwner, nKilledMonsterPoints);
                    IncreaseTeamPointsCount( GetOppositeTeam(nAttackerMonsterOwner), nKilledMonsterPoints);
                }
                ShowTextToTeam(eTeam1, strTeam1Text, eKilledConsoleTextTime, true);
                ShowTextToTeam(eTeam2, strTeam2Text, eKilledConsoleTextTime, true);
            }
            else
            {
            // monstery summonowane nie nabijaja punktow
            }
            PrepareToRespawnMonster(nKilledMonsterOwner, uKilled);
            // moze ktos wygral
            CheckIfAnyTeamHasRequiredPoints();
        }
    }
    return true;
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
state Initialize
{
    TRACE("------------------------------------------------\n");
    TRACE("STATE: Initialize\n");
    TeamMonsterHuntInit();
    
    if( IsGuildsGame() )
    {
        AssignGuildHeroesToTeams();
        CheckGuildTeams();
        MoveHeroesToStartMarkers(false, true);
        ShowPlayersAssignedText();
        TRACE("STATE: CountdownBeforeFight\n");
        SetCountdownTimeForGuildGame();
        return CountdownBeforeFight, 0;
    }

    MoveHeroesToStartMarkers(false, true);
    ShowChooseTeamText();
    TRACE("STATE: JoiningTeams\n");
    return JoiningTeams, 0;
}//--------------------------------------------------------------------------------------|

state JoiningTeams
{
    CureHeroes(); // na wypadek gdyby gracze ze soba zaczeli juz walczyc
    RespawnHeroesImmediately();
    if( CheckIfHeroesJoinedTeams() )
    {
        TRACE("STATE: CountdownBeforeFight\n");
        return CountdownBeforeFight, 0;
    }
    return JoiningTeams, 0;
}//--------------------------------------------------------------------------------------|

state CountdownBeforeFight
{
    CureHeroes(); // na wypadek gdyby gracze ze soba zaczeli juz walczyc
    RespawnHeroesImmediately();

    if( CheckIfCountdownEnded() )
    {
        __TraceTeamGamePoints(eStart);
        SetBorderMargin(eDefaultBorder);
        ResetHeroesDamages();
        InitTeams();
        InitTeamMonsters();
        InitGuilds();
        MoveTeamsToTeamStartMarkers();
        InitTeamMonsterHuntMapSigns();
        TRACE("STATE: Hunt\n");
        ShowHuntText();
        return Fight, 0;
    }
    return CountdownBeforeFight, 0;
}//--------------------------------------------------------------------------------------|

state Fight
{
    RespawnItems();
    RespawnTeamMonsters();
    RespawnTeamHeroesAtNoCondition();
    ShowHuntGamePointsText();
    CheckIfBothTeamsArePresent();

    if( m_nWinner != eNoWinnerYet )
    {
        TRACE("STATE: Results\n");
        KillTeamMonsters();
        ShowTeamResultsText();
        DistributePoints();
        return Results, 1;
    }
    return Fight, m_nMainStateTicksInterval - 1;
}//--------------------------------------------------------------------------------------|

state Results
{
    __TraceTeamGamePoints(eEnd);
    CureHeroes();
    return GameOver, eResultsConsoleTextTime;
}//--------------------------------------------------------------------------------------|

state GameOver
{
    EndGame(eEndGameTextCommon);
    return GameOver, 0;
}//--------------------------------------------------------------------------------------|


////////////////////////////////////////////////////////////////////////////////
command CommandDebug(string strLine)
{
    string strCommand;
    int nX, nY;
    int nIndex;
    mission pMission;
    
    strCommand = strLine;
    
    if (!strCommand.CompareNoCase("PrintTeams"))
    {
        if( state == JoiningTeams )
        {
            TRACE("Teams incomplete yet\n");
            TRACE("%d vs %d (%d free)\n", m_arrTeam1HeroNumber.GetSize(), m_arrTeam2HeroNumber.GetSize(), GetCampaign().GetPlayersCnt() - m_arrTeam1HeroNumber.GetSize() - m_arrTeam2HeroNumber.GetSize());
        }
        else if( state == CountdownBeforeFight )
        {
            TRACE("Teams not initialized yet\n");
            TRACE("%d vs %d (%d free)\n", m_arrTeam1HeroNumber.GetSize(), m_arrTeam2HeroNumber.GetSize(), GetCampaign().GetPlayersCnt() - m_arrTeam1HeroNumber.GetSize() - m_arrTeam2HeroNumber.GetSize());
        }
        else
        {
            TRACE("%d vs %d (team monster hunt)\n", m_arrTeam1HeroNumber.GetSize(), m_arrTeam2HeroNumber.GetSize());
            TRACE("Team1:\n");
            for(nIndex = 0; nIndex < m_arrTeam1HeroNumber.GetSize(); nIndex++)
            {
                TRACE("num %d guild %d rank %d gamepts %d\n", m_arrTeam1HeroNumber[nIndex],
                                                              GetCampaign().GetPlayerHeroUnit(m_arrTeam1HeroNumber[nIndex]).GetHeroNetworkGuildNum(),
                                                              m_arrTeam1RankPoints[nIndex],
                                                              m_arrTeam1PointsCount[nIndex] );
            }
            TRACE("Team2:\n");
            for(nIndex = 0; nIndex < m_arrTeam2HeroNumber.GetSize(); nIndex++)
            {
                TRACE("num %d guild %d rank %d gamepts %d\n", m_arrTeam2HeroNumber[nIndex],
                                                              GetCampaign().GetPlayerHeroUnit(m_arrTeam2HeroNumber[nIndex]).GetHeroNetworkGuildNum(),
                                                              m_arrTeam2RankPoints[nIndex],
                                                              m_arrTeam1PointsCount[nIndex] );
            }
        }
    }
    else if (!strCommand.CompareNoCase("PrintTeamPoints"))
    {
        TRACE("Team points: %d : %d\n", m_nTeam1GamePoints, m_nTeam2GamePoints);
    }
    else
    {
        return TeamBaseCommandDebug(strCommand);
    }
    return 1;
}//--------------------------------------------------------------------------------------|

// skopiowane z Common\Enemies.ech -> function unit CreateSingleEnemy()
function unit CreateTeamMonster(int nParty, int nX, int nY, int nAngle, int nType, string arrMonsterNames[],int arrAvailableTypes[], int arrLevelModifiers[])
{
    int i, nMeshType, nArmor, nWeapon, nEnemyType;
    string strUnit, strTMP, strEnemy;
    string strWeapon, strArmour, strShield, strHelmet, strGloves, strBoots, strTrousers, strQuiver;
    unit uUnit;
    int nLevel;
    int nPointsForMonster;
    
    nMeshType  = eHaveEquipment;
    nWeapon    = eNoWeapon;
    nArmor     = eNoArmor;
    nEnemyType = eEnemyUnknown;
    nPointsForMonster = 0;

    if( arrAvailableTypes[nType] > 1 )
    {
        strEnemy.Format(arrMonsterNames[nType], 1 + Rand(arrAvailableTypes[nType]) );
    }
    else
    {
        strEnemy = arrMonsterNames[nType];
    }
    nLevel = MAX(1, m_nAverageHeroesLevel + arrLevelModifiers[nType]);

    if( !strnicmp(strEnemy, "MU_SNAKE_", strlen("MU_SNAKE_")) )
    {
        strEnemy.Format("MU_SNAKE_%02d(%%d)", 1 + Rand(3));
        nWeapon = eDoubleBladed;
        nPointsForMonster = eMonsterBigPoints;
    }
    else if( !strnicmp(strEnemy, "MU_SEAGUY_", strlen("MU_SEAGUY_")) )
    {
        strEnemy.Format("MU_SEAGUY_%02d(%%d)", 1 + Rand(3));
        nWeapon = eOneHanded + Rand(2); 
        nEnemyType = eEnemySwordsman;
        nPointsForMonster = eMonsterMediumPoints;
    }
    else if( !strnicmp(strEnemy, "MU_VYVERN_", strlen("MU_VYVERN_")) )
    {
        strEnemy.Format("MU_VYVERN_%02d(%%d)", 1 + Rand(3));
        nPointsForMonster = eMonsterSmallPoints;
    }
    else if( !strnicmp(strEnemy, "MU_HELLWARIOR", strlen("MU_HELLWARIOR")) )
    {
        strEnemy = "MU_HELLWARIOR(%d)";
        nWeapon  = eOneHanded + Rand(2); 
        nEnemyType = eEnemySwordsman;
        nPointsForMonster = eMonsterBigPoints;
    }
    else if( !strnicmp(strEnemy, "MU_MINION_", strlen("MU_MINION_")) )
    {
        strEnemy.Format("MU_MINION_%02d(%%d)", 1 + Rand(3));
        nWeapon = eOneHanded+Rand(2); 
        nEnemyType = eEnemySwordsman;
        nPointsForMonster = eMonsterMediumPoints;
    }
    else if( !strnicmp(strEnemy, "MU_ZOMBIE_", strlen("MU_ZOMBIE_")) )
    {
        strEnemy.Format("MU_ZOMBIE_%02d(%%d)", 1 + Rand(3));
        nEnemyType = eEnemySwordsman;
        nPointsForMonster = eMonsterSmallPoints;
    }
    else
    {
        __ASSERT_FALSE();
        TRACE("!!! Brak odpowiedniego potwora !!!\n");
        return null;        
    }
        
    strWeapon   = "NULL";
    strShield   = "NULL";
    strArmour   = "NULL";
    strHelmet   = "NULL";
    strGloves   = "NULL";
    strTrousers = "NULL";
    strBoots    = "NULL";
    strQuiver   = "NULL";
// goblinow i orkow i tak nie ma w tym trybie
    if(nMeshType != eSimpleMesh)
    {
        if( nWeapon == eOneHanded || nWeapon == eShieldman || nWeapon == eDoubleBladed )
        {
            /*if((nType == eGoblin2 || nType == eGoblin) && Rand(2))
            {
                strWeapon.Format("WP_MACE_%02d(5,0)",7+Rand(4));
            }
            else*/
                strWeapon = GetWeapon(Rand(eLastMeeleWeapon+1), nLevel);
        }
        
        if( nWeapon == eShieldman )
        {
            /*if(nType==eGoblin || nType==eGoblin2)
            {
                
                if(nLevel<4) strShield = "AR_GOBLIN_SHIELD_01(2,0)";
                else if(nLevel<7) strShield = "AR_GOBLIN_SHIELD_02(4,0)";
                else strShield = "AR_GOBLIN_SHIELD_03(6,0)";
            }
            else*/
                strShield = GetEquipment(eShield, nLevel);
            
        }
        if( nWeapon == eDoubleBladed )
        {
            strShield = GetWeapon(Rand(eLastMeeleWeapon+1),nLevel,1);
        }
        if( nWeapon == eArcher )
        {
            /*if( nType == eGoblinArcher || nType == eGoblin2Archer )
            {
                i = Rand(3);
                if( i == 0 ) strWeapon = "WP_GOBLINBOW_01(4,0)";
                else if( i == 1 ) strWeapon = "WP_GOBLINBOW_02(4,0)";
                else if( i == 2 ) strWeapon = "WP_GOBLINBOW_03(4,0)";
            }
            else*/
                strWeapon = GetWeapon(eBow,nLevel);
            strQuiver = GetEquipment(eQuiver,MAX(1,nLevel-4+Rand(9)));
        }
        if(nWeapon>=eMageAir && nWeapon<=eMageAir+4)
        {
            strWeapon = GetWeapon(eClub1+nWeapon-eMageAir,nLevel/3);//XXXMD Mage
        }
        
        if(nArmor==eFullArmor)
        {
            strArmour = GetEquipment(eArmour,nLevel);
            strHelmet = GetEquipment(eHelmet,nLevel);
            strGloves = GetEquipment(eGloves,nLevel);
            strTrousers = GetEquipment(eTrousers,nLevel);
            strBoots = GetEquipment(eBoots,nLevel);
        }
        if(nArmor==eLightArmor)
        {
            strArmour = GetEquipment(eArmour,nLevel);
            strTrousers = GetEquipment(eTrousers,nLevel);
            strBoots = GetEquipment(eBoots,nLevel);
        }
        if(nArmor==eRandArmor)
        {
            if(!Rand(2))strArmour = GetEquipment(eArmour,nLevel);
            if(!Rand(3))strHelmet = GetEquipment(eHelmet,nLevel);
            if(!Rand(4))strGloves = GetEquipment(eGloves,nLevel);
            strTrousers = GetEquipment(eTrousers,nLevel);
            strBoots = GetEquipment(eBoots,nLevel);
        }   
/*        if( nType == eOrcChief || nType == eOrc2Chief || nType == eSnowOrcChief )
        {
            i=1+Rand(3);
            strHelmet.Format("AR_ORC_HELMET_0%d(%d,0)",i,nLevel);
        }*/
    }
    //sk³adanie nazwy przeciwnika
    if(nMeshType == eSimpleMesh)
        strTMP.Format("%s",strEnemy);
    else
        strTMP.Format("%s#%s,%s,%s,%s,%s,%s,%s,%s",strEnemy,strWeapon,strShield,strHelmet,strArmour,strGloves,strTrousers,strBoots,strQuiver);
    strUnit.Format(strTMP,nLevel);
                
    if( bCreateWithEffect )
        m_pCurrentMission.CreateObject(FX_CREATE_UNDEAD,nX,nY,0, nAngle);
    // tworzenie przeciwników
    uUnit = m_pCurrentMission.CreateObject(strUnit, nX, nY, 0, nAngle);
    // zrobienie z unita wrogów dla gracza
    if(uUnit)
        TRACE("%s (for %d pts) created by team %d at %d, %d\n", strUnit, nPointsForMonster, nParty, A2G(nX), A2G(nY) );
    else
        TRACE("!!! BLAD Nie stworzono '%s'\n", strUnit);

    if(uUnit) 
    {
        uUnit.SetPartyNum(nParty);
        uUnit.SetAlarmModeUnit(true);
//        SetIsCamper(uUnit,true);  
//        if(anUseMarkers[nType])
//            SetExternalActivity(uUnit,eEActivityControlledByUnit);

        uUnit.SetAttribute(TEAMMONSTERHUNT_MONSTEROWNER, nParty);
        uUnit.SetAttribute(TEAMMONSTERHUNT_MONSTERPOINTS, nPointsForMonster);
        uUnit.CommandUserOneParam0(true);
        
        if(nWeapon>=eMageAir && nWeapon<=eMageAir+4)
        {
            SM(eSkillAirMagic+nWeapon-eMageAir,MAX(10,MIN(2,nLevel/2)));
            uUnit.UpdateChangedUnitValues();
            uUnit.AddMagicCard(GetSimpleMagicCardString(1+nWeapon-eMageAir),0);
        }
        
        if( nWeapon == eOneHanded || nWeapon == eShieldman || nWeapon == eDoubleBladed )
        {
            if(!Rand(5))SK(eSkillDirtyTrick);
            if(!Rand(5))SK(eSkillCriticalHit);
            if(!Rand(5))SK(eSkillPullShield);
        }
        if( nWeapon == eShieldman )
        {
            SK(eSkillParry);
        }
        if( nWeapon == eDoubleBladed )
        {
            SK(eSkillParry);
            SK(eSkillDoubleBlade);
        }
        if( nWeapon == eArcher )
        {
            SK(eSkillArchery);
            if( !Rand(2) ) SK(eSkillCloseDistanceShoot);
            if( !Rand(5) ) SK(eSkillMultiArrows);
        }
        uUnit.UpdateChangedUnitValues();
        if( nEnemyType != eEnemyUnknown )
        {
            SetEnemyType(uUnit,nEnemyType);
        }
    }
    return uUnit;
}

}
