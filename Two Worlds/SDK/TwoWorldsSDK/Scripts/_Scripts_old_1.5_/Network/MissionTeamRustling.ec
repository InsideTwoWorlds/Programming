global "Team Rustling script"
{

#include "MissionTeamBase.ech"

////////////////////////////////////////////////////////////////////////////////
consts
{
// gameplay
    eMaxHorseCount = 30,        // maksymalna liczba koni, moze byc wieksza od eMarkerHorseNum
    ePointInterval = 5 * 30;    // punkt za 5 sek obecnosci konia w zagrodzie
    eGameCountdownTicks = 15 * 60 * 30; // 10 minut gry

    eNeutralParty = 2,            // dla koni poza wybiegami
// dodatkowe markery
    eMarkerTeam1Paddock   = 111, // 111-117
    eMarkerTeam2Paddock   = 121, // 121-127
    eMarkerTeamPaddockNum = 6,
    eMarkerHorse          = 131, // 131-150
    eMarkerHorseNum       = 20,
// interfejs    
    eBringHorsesConsoleTextTime =  5 * 30,
// stany
    eRustlingMainStateTicksInterval = 10,
}

////////////////////////////////////////////////////////////////////////////////
// dodatkowe markery
int m_arrTeam1PaddockX[]; // wybiegi dla koni
int m_arrTeam1PaddockY[];
int m_arrTeam2PaddockX[];
int m_arrTeam2PaddockY[];
int m_arrHorseX[];        // markery koni
int m_arrHorseY[];
int m_arrHorseAngle[];
// dodatkowe zmienne herosow
int m_arrTeam1KilledCount[]; // ile razy zginal
int m_arrTeam2KilledCount[];
// dodatkowe zmienne teamow
int m_nTeam1GamePoints; // punkty za konie na wybiegu
int m_nTeam2GamePoints;
// dodatkowe zmienne
unit m_arrHorses[];
int  m_arrHorsePaddockTicks[];
int  m_arrHorseRespawnTicks[];
int  m_arrHorseMoveRandomParam[];
int  m_arrHorseInPaddock[];
int  m_nGameCountdownTicks;
////////////////////////////////////////////////////////////////////////////////
state Initialize;
state JoiningTeams;
state CountdownBeforeFight;
state Fight;
state Results;
state GameOver;

function void TeamRustlingInit();
function void InitTeamRustlingMapSigns();
function void InitPaddockMapSigns();
function int  InitPaddockMarkers();
function int  InitHorseMarkers();
function void InitTeams();
function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrKilledCount[]);
function int  InitHorses();
function int  CanCreateHorse();
function int  CreateHorse(string strHorseName, int nHorseX, int nHorseY, int nHorseAngle);
function void SetHorseMoveRandomParam(unit pHorse, int nParam);
function void InitGameCountdownTime();
function int  ProcessGameCountdownTime();
function void CheckHorsesLocation();
function void CheckHorsesCount();
function void PrepareToRespawnHorse(int nHorseIndex);
function void RespawnHorses();
function int  RespawnHorse(int nHorseIndex);
function int  MoveHorseToStartMarker(int nHorseIndex);
function int  IsHorseInTeamPaddock(int nHorseIndex);
function void AddGamePoint(int nTeamNum);
function void RemoveHorses();
function void DecideAboutWinner();
function void DistributePoints();
function void DistributeEarthNetPlayerPoints();
function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrKilledCount[]);
function void DistributeXBOXPoints_TeamRustling();
function void DistributeXBOXPoints_TeamRustling(int arrWinningHeroNum[], int arrLosingHeroNum[]);

function int  GetTeamPaddockMapSign(int nTeamNum, int &nMapSign);
function int  GetTeamPaddockCenterPoint(int nTeamNum, int &nCenterX, int &nCenterY);
function void GetTeamPaddockCenterPoint(int arrPaddockX[], int arrPaddockY[], int &nCenterX, int &nCenterY);
function int  FindHorseIndex(unit pHorse);
function void IncreaseKilledCount(int nTeamNum, int nHeroIndex);
function void IncreaseKilledCount(int arrKilledCount[], int nHeroIndex);

function void ShowBringText();
function void ShowRustlingGamePointsText();

////////////////////////////////////////////////////////////////////////////////
function void TeamRustlingInit()
{
    TeamBaseInit();

    InitTeamStartMarkers(); // musi byc tu a nie w MissionTeamBase.ech, bo w DM trzeba wziac pod uwage m_nMarkerShift
    InitPaddockMarkers();
    InitHorseMarkers();

    m_nMainStateTicksInterval = eRustlingMainStateTicksInterval;
    m_nTeam1GamePoints = 0;
    m_nTeam2GamePoints = 0;

    EnableShowLocalTeamMapSigns(true);
    EnableShowRemoteTeamMapSigns(false);
    EnableItemRespawns(true);
    InitRespawnItemMarkers();
    InitRespawnItems();
}//--------------------------------------------------------------------------------------|

function void InitTeamRustlingMapSigns()
{
    InitTeamMapSigns();
    InitPaddockMapSigns();
}//--------------------------------------------------------------------------------------|

function void InitPaddockMapSigns()
{
    int nMapSignNum;
    int nX, nY;
    int nTeamIndex;

    nMapSignNum = 0;

    for(nTeamIndex = eTeam1; nTeamIndex <= eTeam2; nTeamIndex++)
    {
        if( GetTeamPaddockCenterPoint(nTeamIndex, nX, nY) &&
            GetTeamPaddockMapSign(nTeamIndex, nMapSignNum) )
        {
            TRACE("team %d paddock: %d, %d\n", nTeamIndex, nX, nY);
            AddStaticMapSignToAll(nX, nY, nMapSignNum);
        }
    }
}//--------------------------------------------------------------------------------------|

function int InitPaddockMarkers()
{
    InitMarkers(eMarkerTeam1Paddock, eMarkerTeamPaddockNum, m_arrTeam1PaddockX, m_arrTeam1PaddockY);
    InitMarkers(eMarkerTeam2Paddock, eMarkerTeamPaddockNum, m_arrTeam2PaddockX, m_arrTeam2PaddockY);
    return 1;
}//--------------------------------------------------------------------------------------|

function int InitHorseMarkers()
{
    InitMarkers(eMarkerHorse, eMarkerHorseNum, m_arrHorseX, m_arrHorseY, m_arrHorseAngle);
    return 1;
}//--------------------------------------------------------------------------------------|

function void InitTeams()
{
    InitTeam(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1HeroRespawnTicks, m_arrTeam1KilledCount);
    InitTeam(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2HeroRespawnTicks, m_arrTeam2KilledCount);
}//--------------------------------------------------------------------------------------|

function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrKilledCount[])
{
    int nPlayerIndex;

    InitTeam(arrHeroNumber, arrRankPoints, arrRespawnTicks);

    arrKilledCount.RemoveAll();
    for(nPlayerIndex = 0; nPlayerIndex < arrHeroNumber.GetSize(); nPlayerIndex++)
    {
        arrKilledCount.Add(0);
    }
}//--------------------------------------------------------------------------------------|

function int InitHorses()
{
    int nMarkerIndex;

    for(nMarkerIndex = 0; nMarkerIndex < m_arrHorseX.GetSize(); nMarkerIndex++)
    {
        if( !CreateHorse(GetRandomHorseName(), m_arrHorseX[nMarkerIndex], m_arrHorseY[nMarkerIndex], m_arrHorseAngle[nMarkerIndex]) )
        {
            break;    
        }
    }
    return 1;    
}//--------------------------------------------------------------------------------------|

function int CanCreateHorse()
{
    if( m_arrHorses.GetSize() >= eMaxHorseCount )
    {
        return 0;
    }
    return 1;
}//--------------------------------------------------------------------------------------|

function int CreateHorse(string strHorseName, int nHorseX, int nHorseY, int nHorseAngle)
{
    unit pHorse;
    if( !CanCreateHorse() )
    {
        return 0;
    }
    m_pCurrentMission.CreateObject(TELE_IN_EFFECT, nHorseX, nHorseY, 0, 0);
    pHorse = m_pCurrentMission.CreateObject(strHorseName, nHorseX, nHorseY, 0, nHorseAngle);
    if( pHorse )
    {
        m_arrHorses.Add(pHorse);
        m_arrHorsePaddockTicks.Add(0);
        m_arrHorseRespawnTicks.Add(0);
        m_arrHorseInPaddock.Add(eNoTeam);
        m_arrHorseMoveRandomParam.Add(-1);

        SetHorseMoveRandomParam(pHorse, true);
    }
    else
    {
        __ASSERT_FALSE();    
    }
    return 1;
}//--------------------------------------------------------------------------------------|

function void SetHorseMoveRandomParam(unit pHorse, int nParam)
{
    int nHorseIndex;
    
    if( !pHorse || !pHorse.IsHorseUnit() )
    {
        return;
    }
    nHorseIndex = FindHorseIndex(pHorse);
    if( nHorseIndex == -1)
    {
        return;
    }
    if( m_arrHorseMoveRandomParam[nHorseIndex] != nParam )
    {
        m_arrHorseMoveRandomParam[nHorseIndex] = nParam;
        m_arrHorses[nHorseIndex].CommandUserOneParam0(nParam);
    }
}//--------------------------------------------------------------------------------------|

function void InitGameCountdownTime()
{
    m_nGameCountdownTicks = eGameCountdownTicks;
}//--------------------------------------------------------------------------------------|

function int ProcessGameCountdownTime()
{
    if( m_nGameCountdownTicks > 0 )
    {
        m_nGameCountdownTicks -= m_nMainStateTicksInterval;
        return 0;
    }
    m_nGameCountdownTicks = 0;
    return 1;
}//--------------------------------------------------------------------------------------|

function void CheckHorsesLocation()
{
    int nHorseIndex;
    int nHeroIndex;
    unit pHero;
    int nInPaddock;
    int nSetCommandUserParam;

    for(nHorseIndex = 0; nHorseIndex < m_arrHorses.GetSize(); nHorseIndex++)
    {
        if( !m_arrHorses[nHorseIndex].IsLive() ) // niezywych koni nie bierzemy pod uwage
        {
            continue;    
        }
        nInPaddock = IsHorseInTeamPaddock(nHorseIndex);
        if( nInPaddock != eNoTeam ) // kon jest w czyims wybiegu
        {
            // wczesniej nie byl na zadnym
            if( m_arrHorseInPaddock[nHorseIndex] == eNoTeam ) // wlasnie wszedl
            {
                m_arrHorsePaddockTicks[nHorseIndex] = 0; // reset tickow konia
                m_arrHorses[nHorseIndex].SetPartyNum(nInPaddock);
                SetHorseMoveRandomParam(m_arrHorses[nHorseIndex], false);
            }
            // juz byl na wybiegu, dodanie tickow i sprawdzenie czy jest dluzej niz 5 sek
            if( m_arrHorseInPaddock[nHorseIndex] == nInPaddock )
            {
                m_arrHorsePaddockTicks[nHorseIndex] += m_nMainStateTicksInterval;
                if( m_arrHorsePaddockTicks[nHorseIndex] >= ePointInterval )
                {
                    AddGamePoint(nInPaddock);         // przyznajemy punkt teamowi
                    m_arrHorsePaddockTicks[nHorseIndex] = 0; // reset tickow konia
                }
            }
        }
        else
        {
            // konia nie ma na wybiegu
            if( m_arrHorseInPaddock[nHorseIndex] != eNoTeam ) // wlasnie z niego wyszedl
            {
                m_arrHorses[nHorseIndex].SetPartyNum(eNeutralParty);
            }            
            // sprawdzamy, czy ktorys z hero jest blisko niego
            nSetCommandUserParam = true;
            for(nHeroIndex = 0; nHeroIndex < GetCampaign().GetPlayersCnt(); nHeroIndex++)
            {
                if( !IsPlayer(nHeroIndex) )
                {
                    continue;
                }
                pHero = GetCampaign().GetPlayerHeroUnit(nHeroIndex);
                if( !pHero || !pHero.IsLive() )
                {
                    continue;
                }
                if( m_arrHorses[nHorseIndex].DistanceTo(pHero) < e10m )
                {
                   nSetCommandUserParam = false;
                }
            }
            SetHorseMoveRandomParam( m_arrHorses[nHorseIndex], nSetCommandUserParam);
        }
        m_arrHorseInPaddock[nHorseIndex] = nInPaddock;
    }
}//--------------------------------------------------------------------------------------|

function void CheckHorsesCount()
{
    int nIndex;
    int nMarkerIndex;
    int nInPaddocksCount;
    
    if( !CanCreateHorse() )
    {
        return;
    }
    for(nIndex = 0; nIndex < m_arrHorses.GetSize(); nIndex++)
    {
        if( m_arrHorseInPaddock[nIndex] != eNoTeam )
        {
            nInPaddocksCount++;
        }
    }
    if( m_arrHorses.GetSize() - nInPaddocksCount < 5 ) // jezeli na wolnosci jest <= 5 koni to tworz nastepne az do max
    {
        TRACE("creating additional horse\n");
        nMarkerIndex  = Rand(m_arrHorseX.GetSize());
        CreateHorse(GetRandomHorseName(), m_arrHorseX[nMarkerIndex], m_arrHorseY[nMarkerIndex], m_arrHorseAngle[nMarkerIndex]);
    }
    
}//--------------------------------------------------------------------------------------|

function void RespawnHorses()
{
    int nIndex;
    for(nIndex = 0; nIndex < m_arrHorses.GetSize(); nIndex++)
    {
        if( m_arrHorses[nIndex].IsLive() )
        {
            continue;
        }
        if( m_arrHorseRespawnTicks[nIndex] > 0 )
        {
            m_arrHorseRespawnTicks[nIndex] -= m_nMainStateTicksInterval;
        }
        else
        {
            RespawnHorse(nIndex);
        }
    }
}//--------------------------------------------------------------------------------------|

function int RespawnHorse(int nHorseIndex)
{
    if( (nHorseIndex >= m_arrHorses.GetSize()) || !m_arrHorses[nHorseIndex] || !m_arrHorses[nHorseIndex].IsHorseUnit() )
    {
        TRACE("!!! Niepawidlowy kon do respawnu !!!\n");
        return 0;
    }
    if( m_arrHorses[nHorseIndex].IsLive() )
    {
        TRACE("!!! Proba respawnowania zyjacego koina !!!\n");
        return 0;
    }
    
    m_arrHorses[nHorseIndex].ResurrectUnit();
    MoveHorseToStartMarker(nHorseIndex);
    return 1;
}//--------------------------------------------------------------------------------------|

function int MoveHorseToStartMarker(int nHorseIndex)
{
    int nMarkerIndex;
    int nX, nY, nAngle;

    if( (nHorseIndex >= m_arrHorses.GetSize()) || !m_arrHorses[nHorseIndex] || !m_arrHorses[nHorseIndex].IsHorseUnit() )
    {
        TRACE("!!! Niepawidlowy kon !!!\n");
        return 0;
    }

    nMarkerIndex = Rand( m_arrHorseX.GetSize() );
    nX     = m_arrHorseX[nMarkerIndex];
    nY     = m_arrHorseY[nMarkerIndex];
    nAngle = m_arrHorseAngle[nMarkerIndex];

    m_pCurrentMission.CreateObject(TELE_OUT_EFFECT, m_arrHorses[nHorseIndex].GetLocationX(), m_arrHorses[nHorseIndex].GetLocationY(), 0, 0);
    m_arrHorses[nHorseIndex].SetImmediatePosition( nX, nY, 0, nAngle, true);
    m_pCurrentMission.CreateObject(TELE_IN_EFFECT, m_arrHorses[nHorseIndex].GetLocationX(), m_arrHorses[nHorseIndex].GetLocationY(), 0, 0);
    
    return 1;
}//--------------------------------------------------------------------------------------|

function void PrepareToRespawnHorse(int nHorseIndex)
{
    m_arrHorseRespawnTicks[nHorseIndex] = eHorseRespawnTicks;
}//--------------------------------------------------------------------------------------|

function int IsHorseInTeamPaddock(int nHorseIndex)
{
    int nX, nY;
    if( (nHorseIndex < 0) || (nHorseIndex >= m_arrHorses.GetSize()) || 
        !m_arrHorses[nHorseIndex].IsHorseUnit() ||
        !m_arrHorses[nHorseIndex].IsLive() )
    {
        return eNoTeam;    
    }
    nX = m_arrHorses[nHorseIndex].GetLocationX();
    nY = m_arrHorses[nHorseIndex].GetLocationY();
    if( IsPointInPolygon(m_arrTeam1PaddockX, m_arrTeam1PaddockY, nX, nY) )
    {
        return eTeam1;
    }
    else if( IsPointInPolygon(m_arrTeam2PaddockX, m_arrTeam2PaddockY, nX, nY) )
    {
        return eTeam2;
    }
    return eNoTeam;
}//--------------------------------------------------------------------------------------|

function void AddGamePoint(int nTeamNum)
{
    if( nTeamNum == eTeam1 )
    {
        m_nTeam1GamePoints++;
    }
    else if( nTeamNum == eTeam2 )
    {
        m_nTeam2GamePoints++;
    }
    else
    {
        __ASSERT_FALSE();
    }
}//--------------------------------------------------------------------------------------|

function void RemoveHorses()
{
    int nIndex;
    for(nIndex = 0; nIndex < m_arrHorses.GetSize(); nIndex++)
    {
        if( m_arrHorses[nIndex].IsLive() )
        {
            m_pCurrentMission.CreateObject(TELE_OUT_EFFECT, m_arrHorses[nIndex].GetLocationX(), m_arrHorses[nIndex].GetLocationY(), 0, 0);
            m_arrHorses[nIndex].RemoveObject();
        }
    }
}//--------------------------------------------------------------------------------------|

function void DecideAboutWinner()
{
    if( m_nTeam1GamePoints > m_nTeam2GamePoints )
    {
        SetWinningTeam(eTeam1);
    }
    else if( m_nTeam1GamePoints < m_nTeam2GamePoints )
    {
        SetWinningTeam(eTeam2);
    }
    else
    {
        SetWinningTeam(eDrawGame);
    }
}//--------------------------------------------------------------------------------------|

function void DistributePoints()
{
#ifdef _XBOX
    DistributeXBOXPoints_TeamRustling();
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
    if( m_nWinner == eTeam1 )
    {
        DistributeEarthNetPlayerPoints(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1KilledCount);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeEarthNetPlayerPoints(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2KilledCount);
    }
    else if( m_nWinner == eDrawGame )
    {
        ReturnEarthNetPlayerPointsAfterDrawGame(m_arrTeam1HeroNumber, m_arrTeam1RankPoints);
        ReturnEarthNetPlayerPointsAfterDrawGame(m_arrTeam2HeroNumber, m_arrTeam2RankPoints);
    }
    else
    {
        TRACE("!!! Unknown winner !!!");
    }
}//--------------------------------------------------------------------------------------|

function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrKilledCount[])
{
    int nIndex;
    int nPrizePointsPerPlayer;
    int nPlayersCount;
    int nMinKilledHeroIndex;
    unit pHero;
    int nOverallPrizePoints;
    int arrPoints[];         // bezwzgledna liczba punktow za wygrana rozgrywke (wlacznie z zainwestowanymi)

    if( IsGuildsGame() )
    {
        return;
    }
// liczenie liczby zwycieskich herosow, ktoregos moze juz nie byc
// przy okazji szukanie herosa z maksymalna liczba zyc
    nPlayersCount = 0;
    for(nIndex = 0; nIndex < arrHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer( arrHeroNum[nIndex] ) )
        {
            continue;
        }
        nPlayersCount++;
    }
// kto ma najmniej smierci na koncie
    nMinKilledHeroIndex = GetIndexOfMinValueInArray(arrKilledCount);
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
// jezeli po rozdysponowaniu punktow cos jeszcze zostalo to daj to playerowi z najwieksza liczba zyc
    if( m_nEarthNetPlayerPointsPool > 0 )
    {
        TRACE("Bonus points (%d) goes to %d\n", m_nEarthNetPlayerPointsPool, nMinKilledHeroIndex);
        ASSERT( (nMinKilledHeroIndex >= 0) && (nMinKilledHeroIndex < arrPoints.GetSize()) );
        arrPoints[nMinKilledHeroIndex] += m_nEarthNetPlayerPointsPool;
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

function void DistributeXBOXPoints_TeamRustling()
{
    if( m_nWinner == eTeam1 )
    {
        DistributeXBOXPoints_TeamRustling(m_arrTeam1HeroNumber, m_arrTeam2HeroNumber);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeXBOXPoints_TeamRustling(m_arrTeam2HeroNumber, m_arrTeam1HeroNumber);
    }
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_TeamRustling(int arrWinningHeroNum[], int arrLosingHeroNum[])
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
        GetCampaign().GetPlayerHeroUnit(arrWinningHeroNum[nIndex]).AddHeroNetworkGameModePoints(eGameModePointsHorsesstealing, nGamePoints);
        if (IsRankedGame())
        {
            strText.FormatTrl(TEXT_GETPOINTS, nGamePoints);
            ShowTextToPlayer(arrWinningHeroNum[nIndex], strText, eResultsConsoleTextTime, true);
        }
    }
}//--------------------------------------------------------------------------------------|

function int GetTeamPaddockMapSign(int nTeamNum, int &nMapSign)
{
    if( nTeamNum == eTeam1 )
    {
        nMapSign = eMapSignTeam1Paddock;
    }
    else if( nTeamNum == eTeam2 )
    {
        nMapSign = eMapSignTeam2Paddock;
    }
    else
    {
        __ASSERT_FALSE();
        return false;
    }
    return true;
}//--------------------------------------------------------------------------------------|

function int GetTeamPaddockCenterPoint(int nTeamNum, int &nCenterX, int &nCenterY)
{
    if( nTeamNum == eTeam1 )
    {
        GetTeamPaddockCenterPoint(m_arrTeam1PaddockX, m_arrTeam1PaddockY, nCenterX, nCenterY);
    }
    else if( nTeamNum == eTeam2 )
    {
        GetTeamPaddockCenterPoint(m_arrTeam2PaddockX, m_arrTeam2PaddockY, nCenterX, nCenterY);
    }
    else
    {
        return false;
    }
    return true;
}//--------------------------------------------------------------------------------------|

function void GetTeamPaddockCenterPoint(int arrPaddockX[], int arrPaddockY[], int &nCenterX, int &nCenterY)
{
    int nIndex;

    nCenterX = 0;
    nCenterY = 0;
    for(nIndex = 0; nIndex < arrPaddockX.GetSize(); nIndex++)
    {
        nCenterX += arrPaddockX[nIndex];
        nCenterY += arrPaddockY[nIndex];
    }
    nCenterX /= arrPaddockX.GetSize();
    nCenterY /= arrPaddockX.GetSize();
}//--------------------------------------------------------------------------------------|

function int FindHorseIndex(unit pHorse)
{
    int nIndex;
    if( !pHorse.IsHorseUnit() )
    {
        return -1;
    }
    for(nIndex = 0; nIndex < m_arrHorses.GetSize(); nIndex++)
    {
        if( pHorse == m_arrHorses[nIndex] )
        {
            return nIndex;
        }
    }
    return -1;
}//--------------------------------------------------------------------------------------|

function void IncreaseKilledCount(int nTeamNum, int nHeroIndex)
{
    if( nTeamNum == eTeam1 )
    {
        IncreaseKilledCount(m_arrTeam1KilledCount, nHeroIndex);
    }
    else if( nTeamNum == eTeam2 )
    {
        IncreaseKilledCount(m_arrTeam2KilledCount, nHeroIndex);
    }
    else
    {
        TRACE("!!! Nieznany team !!!\n");
    }
}//--------------------------------------------------------------------------------------|

function void IncreaseKilledCount(int arrKilledCount[], int nHeroIndex)
{
    ASSERT( (nHeroIndex >= 0) && (nHeroIndex < arrKilledCount.GetSize()) );
    arrKilledCount[nHeroIndex] += 1;
}//--------------------------------------------------------------------------------------|

function void ShowBringText()
{
    stringW strText;
    strText.Translate(TEXT_BRING);
    ShowTextToTeam(eTeam1, strText, eBringHorsesConsoleTextTime, false);
    ShowTextToTeam(eTeam2, strText, eBringHorsesConsoleTextTime, false);
}//--------------------------------------------------------------------------------------|

function void ShowRustlingGamePointsText()
{
    stringW strTime;
    stringW strTeam1, strTeam2;
    stringW strText;
    int nM, nS, nMs;

    strTeam1.Translate(TEXT_TEAM1);
    strTeam2.Translate(TEXT_TEAM2);

    strText.FormatTrl(TEXT_GAMEPOINTS, strTeam1, m_nTeam1GamePoints, m_nTeam2GamePoints, strTeam2);

    ShowBottomTextToTeam(eTeam1, strText, eResultsConsoleTextTime, false);
    ShowBottomTextToTeam(eTeam2, strText, eResultsConsoleTextTime, false);
// czas
    if( m_nGameCountdownTicks > 0 )
    {
        ConvertTicksToTime(m_nGameCountdownTicks, nM, nS, nMs);
        FormatTime(strTime, nM, nS);
        ShowBottomTextToTeam(eTeam1, strTime, eResultsConsoleTextTime, true);
        ShowBottomTextToTeam(eTeam2, strTime, eResultsConsoleTextTime, true);
    }
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
event RemovedNetworkPlayer(int nPlayerNum)
{
    stringW strText;
    TRACE("TeamRustling::RemovedNetworkPlayer(%d)\n", nPlayerNum);
    
    strText.FormatTrl(TEXT_LEFTTHEGAME, m_arrHeroNames[nPlayerNum]);
    ShowTextToAll(strText, eDefaultConsoleTextTime, true);
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event RemovedUnit(unit uKilled, unit uAttacker, int a)
{
    int nKilledTeamNum;
    int nKilledHeroIndex;
    int nKilledHeroNum;
    int nAttackTeamNum;
    int nAttackHeroIndex;
    int nAttackHeroNum;    
    int nKilledHorseIndex;
    int nStatueOwner;
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
    // zabity jest hero
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
            IncreaseKilledCount(nKilledTeamNum, nKilledHeroIndex);
            PrepareToRespawnHero(nKilledTeamNum, nKilledHeroIndex);
        }
        else // na wszelki wypadek gdyby komus udalo sie zginac po walce
        {
//          RespawnTeamHero(uKilled);
        }
    }
    else if( uKilled.IsHorseUnit() )
    {
        nKilledHorseIndex = FindHorseIndex(uKilled);
        if( nKilledHorseIndex != -1 )
        {
            PrepareToRespawnHorse(nKilledHorseIndex);
        }
        else
        {
            TRACE("!!! Nie mozna znalezc konia !!!");    
        }
    }
    return true;
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
state Initialize
{
    TRACE("------------------------------------------------\n");
    TRACE("STATE: Initialize\n");
    TeamRustlingInit();
    
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
        InitGuilds();
        InitHorses();
        InitGameCountdownTime();
        MoveTeamsToTeamStartMarkers();
        InitTeamRustlingMapSigns();
        TRACE("STATE: Fight\n");
        ShowBringText();
        return Fight, 0;
    }
    return CountdownBeforeFight, 0;
}//--------------------------------------------------------------------------------------|

state Fight
{
    RespawnItems();
    RespawnTeamHeroesAtNoCondition();
    RespawnHorses();
    CheckHorsesLocation();
    CheckHorsesCount();
    CheckIfBothTeamsArePresent();
    ShowRustlingGamePointsText();

    if( ProcessGameCountdownTime() )
    {
        DecideAboutWinner();    
    }

    if( m_nWinner != eNoWinnerYet )
    {
        TRACE("STATE: Results\n");
        ShowTeamResultsText();
        DistributePoints();
        return Results, 0;
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
            TRACE("%d vs %d (team rustling)\n", m_arrTeam1HeroNumber.GetSize(), m_arrTeam2HeroNumber.GetSize());
            TRACE("Team1:\n");
            for(nIndex = 0; nIndex < m_arrTeam1HeroNumber.GetSize(); nIndex++)
            {
                TRACE("num %d guild %d rank %d killed %d\n", m_arrTeam1HeroNumber[nIndex],
                                                    GetCampaign().GetPlayerHeroUnit(m_arrTeam1HeroNumber[nIndex]).GetHeroNetworkGuildNum(),                
                                                    m_arrTeam1RankPoints[nIndex],
                                                    m_arrTeam1KilledCount[nIndex] );
            }
            TRACE("Team2:\n");
            for(nIndex = 0; nIndex < m_arrTeam2HeroNumber.GetSize(); nIndex++)
            {
                TRACE("num %d guild %d rank %d killed %d\n", m_arrTeam2HeroNumber[nIndex],
                                                    GetCampaign().GetPlayerHeroUnit(m_arrTeam2HeroNumber[nIndex]).GetHeroNetworkGuildNum(),
                                                    m_arrTeam2RankPoints[nIndex],
                                                    m_arrTeam2KilledCount[nIndex] );
            }
        }
    }
    else if (!strnicmp(strCommand, "AddTime", strlen("AddTime")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("AddTime") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d", nIndex);
        m_nGameCountdownTicks += nIndex * 30;
    }
    else if (!strCommand.CompareNoCase("PrintTeamPoints"))
    {
        TRACE("Points: %d : %d\n", m_nTeam1GamePoints, m_nTeam2GamePoints);
    }
    else if (!strCommand.CompareNoCase("PrintHorseCount"))
    {
        TRACE("Horse count: %d/%d\n", m_arrHorses.GetSize(), eMaxHorseCount );
    }
    else
    {
        return TeamBaseCommandDebug(strCommand);
    }
    return 1;
}//--------------------------------------------------------------------------------------|

}
