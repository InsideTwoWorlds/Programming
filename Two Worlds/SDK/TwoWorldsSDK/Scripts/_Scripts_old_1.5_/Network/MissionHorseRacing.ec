global "Horse Racing script"
{

#include "MissionBase.ech"

////////////////////////////////////////////////////////////////////////////////
consts
{
// gameplay
    eHorseMarkerRange    = 1 * 256,
// interfejs
    eRaceConsoleTextTime =  5 * 30,
// markery
    eMarkerHorse     = 91, // 91-98
    eMarkerHorseNum  = 8,
    eMarkerFinish    = 101, // 101-104
    eMarkerFinishNum = 4,
    eMarkerGate      = 1,  // 1-8 typ MARKER_GATE
    eMarkerGateNum   = 8,

    eRaceCountdownStateOverallTime     = 8 * 30, // calkowity czas odliczania
    eRaceCountdownStateShowTime = 5 * 30; // widoczny czas odliczania
    
    eExtraTicks = 15 * 30; // dodatkowy czas trwania wyscigu po ukonczeniu wyscigu gracza na ostatnim z premiowanych miejsc
    
// stany
    eRaceStateInterval      = 1,   // interwal miedzy stepami wyscigu (potrzebne do respawnu przedmiotow i ludzi oraz do liczenia czasu)
}

////////////////////////////////////////////////////////////////////////////////
// dodatkowe markery
int m_arrHorseX[];  // markery boxow startowych
int m_arrHorseY[];
int m_arrHorseAngle[];
int m_arrGateX[]; // markery bram w boksach
int m_arrGateY[];
int m_arrFinishX[]; // markery obszaru wyznaczajacego mete
int m_arrFinishY[];
// dodatkowe zmienne
int m_arrHeroRaceTicks[];
int m_arrHeroFinalPlace[];
// inne zmienne
unit m_arrHorses[];
int  m_arrHorseRespawnTicks[];
unit m_arrGates[];
int  m_nRaceTicks;          // ticki liczone od rozpoczecia wyscigu
int  m_nExtraTicksElapsing; // zmienna wskazujaca czy ma byc mierzony dodatkowy czas
int  m_nExtraTicks;         // dodatkowe ticki, po ich uplywie wyscig sie konczy niezaleznie od tego czy wszyscy dotarli do mety
int m_arrPoints1Player[]; // tablice zawierajace procent punktow wejsciowych otrzymanaych za zajete miejsca
int m_arrPoints2Players[];
int m_arrPoints3Players[];
int m_arrPoints4Players[];
int m_arrPoints5Players[];
int m_arrPoints6Players[];
int m_arrPoints7Players[];
int m_arrPoints8Players[];

////////////////////////////////////////////////////////////////////////////////
state Initialize;
state CountdownBeforeRace;
state Race;
state Results;
state GameOver;

function void HorseRacingInit();
function int  InitHorseMarkers();
function int  InitGateMarkers();
function int  InitFinishMarkers();
function void InitPointsForPlaces();
function void InitGates();
function void InitHeroes(int arrRankPoints[], int arrRespawnTicks[], int arrRaceTicks[], int arrFinalPlace[]);
function int  MoveHeroesToStartMarkersAndCreateHorses(int nShowTeleOutEffect, int nShowTeleInEffect);
function void CureHorses();
function void OpenGates();

function void RespawnHorses();
function int  RespawnHorse(int nHorseIndex);
function void PrepareToRespawnHorse(int nHorseIndex);
function int  FindHorseIndex(unit pHorse);

function void CheckIfPlayersFinishedRace();
function int  CheckRaceEndConditions();
function int  DidEveryoneFinishRace();
function int  IsExtraTimeElapsing();
function int  IsExtraTimeElapsed();
function void ProcessExtraTime();
function void ProcessRaceTime();
function int  IsItPremiumPlace(int nPlace);
function int  IsItLastPremiumPlace(int nPlace);
function int  GetLastPremiumPlace();
function int  GetPercentMultiplier(int nPlace);
function int  GetRaceTime();
function int  GetNextPlace();
function void DistributePoints();
function void DistributeEarthNetPlayerPoints();
function void DistributeEarthNetGuildPoints();
function void DistributeXBOXPoints_HorseRacing();

function void ShowWelcomeText();
function void ShowResultsText();
function void ShowTimeText();

////////////////////////////////////////////////////////////////////////////////
function void HorseRacingInit()
{
    BaseInit();
    
    m_nMainStateTicksInterval = eRaceStateInterval;
    m_nCountdownCounter     = eRaceCountdownStateOverallTime;
    m_nShowCountdownCounter = eRaceCountdownStateShowTime;
    m_nExtraTicksElapsing = false;
    m_nExtraTicks = eExtraTicks;
    m_nRaceTicks = 0;
    
    EnableShowHeroMapSigns(true);
    EnableItemRespawns(false);

    InitHorseMarkers();
    InitGateMarkers();
    InitFinishMarkers();
    InitGates();
    InitPointsForPlaces();
}//--------------------------------------------------------------------------------------|

function void InitRacingMapSigns()
{
    InitHeroMapSigns();
}//--------------------------------------------------------------------------------------|

function int InitHorseMarkers()
{
    InitMarkers(eMarkerHorse, eMarkerHorseNum, m_arrHorseX, m_arrHorseY, m_arrHorseAngle);
    return 1;
}//--------------------------------------------------------------------------------------|

function int InitGateMarkers()
{
    InitMarkers(eMarkerGate, eMarkerGateNum, m_arrGateX, m_arrGateY);
    return 1;
}//--------------------------------------------------------------------------------------|

function int InitFinishMarkers()
{
    InitMarkers(eMarkerFinish, eMarkerFinishNum, m_arrFinishX, m_arrFinishY);
    return 1;
}//--------------------------------------------------------------------------------------|

#define CHECK_POINTS(arr, num) if( (arr.GetSize() != num) || (SumValuesInArray(arr) != num * 100) ) \
                               { TRACE("!!! Niewlasciwa liczba punktow za kolejne miejsca dla %d graczy !!!\n", num); }

function void InitPointsForPlaces()
{
// procent wlozonych punktow za kolejne miejsca w wyscigu
// suma liczb w kazdej tablicy musi byc rowna 100 * liczba graczy
    m_arrPoints1Player.RemoveAll();
    m_arrPoints2Players.RemoveAll();
    m_arrPoints3Players.RemoveAll();
    m_arrPoints4Players.RemoveAll();
    m_arrPoints5Players.RemoveAll();
    m_arrPoints6Players.RemoveAll();
    m_arrPoints7Players.RemoveAll();
    m_arrPoints8Players.RemoveAll();
//
    m_arrPoints1Player.Add(100);
//
    m_arrPoints2Players.Add(200);
    m_arrPoints2Players.Add(0);
//
    m_arrPoints3Players.Add(200);
    m_arrPoints3Players.Add(100);
    m_arrPoints3Players.Add(0);
//
    m_arrPoints4Players.Add(250);
    m_arrPoints4Players.Add(150);
    m_arrPoints4Players.Add(0);
    m_arrPoints4Players.Add(0);
//
    m_arrPoints5Players.Add(250);
    m_arrPoints5Players.Add(150);
    m_arrPoints5Players.Add(100);
    m_arrPoints5Players.Add(0);
    m_arrPoints5Players.Add(0);
//
    m_arrPoints6Players.Add(300);
    m_arrPoints6Players.Add(170);
    m_arrPoints6Players.Add(130);
    m_arrPoints6Players.Add(0);
    m_arrPoints6Players.Add(0);
    m_arrPoints6Players.Add(0);
//
    m_arrPoints7Players.Add(300);
    m_arrPoints7Players.Add(170);
    m_arrPoints7Players.Add(130);
    m_arrPoints7Players.Add(100);
    m_arrPoints7Players.Add(0);
    m_arrPoints7Players.Add(0);
    m_arrPoints7Players.Add(0);
//
    m_arrPoints8Players.Add(300);
    m_arrPoints8Players.Add(200);
    m_arrPoints8Players.Add(170);
    m_arrPoints8Players.Add(130);
    m_arrPoints8Players.Add(0);
    m_arrPoints8Players.Add(0);
    m_arrPoints8Players.Add(0);
    m_arrPoints8Players.Add(0);
    
    CHECK_POINTS(m_arrPoints1Player,  1);
    CHECK_POINTS(m_arrPoints2Players, 2);
    CHECK_POINTS(m_arrPoints3Players, 3);
    CHECK_POINTS(m_arrPoints4Players, 4);
    CHECK_POINTS(m_arrPoints5Players, 5);
    CHECK_POINTS(m_arrPoints6Players, 6);
    CHECK_POINTS(m_arrPoints7Players, 7);
    CHECK_POINTS(m_arrPoints8Players, 8);
}//--------------------------------------------------------------------------------------|

function void InitGates()
{
    int nIndex;
    unit uGate;
    for(nIndex = eMarkerGate; nIndex < eMarkerGate + eMarkerGateNum; nIndex++)
    {
        if( m_pCurrentMission.HaveMarker(MARKER_GATE, nIndex) )
        {
            uGate = m_pCurrentMission.GetObjectMarker(MARKER_GATE, nIndex);
            m_arrGates.Add(uGate);
        }    
        else
        {
            TRACE("!!! Brak MARKER_GATE nr %d !!!\n", nIndex);    
        }
    }
}//--------------------------------------------------------------------------------------|

function void InitHeroes()
{
    InitHeroes(m_arrHeroRankPoints, m_arrHeroRespawnTicks, m_arrHeroRaceTicks, m_arrHeroFinalPlace);
}//--------------------------------------------------------------------------------------|

function void InitHeroes(int arrRankPoints[], int arrRespawnTicks[], int arrRaceTicks[], int arrFinalPlace[])
{
    int nPlayerIndex;

    InitHeroes(arrRankPoints, arrRespawnTicks);

    arrRaceTicks.RemoveAll();
    for(nPlayerIndex = 0; nPlayerIndex < arrRankPoints.GetSize(); nPlayerIndex++)
    {
        arrRaceTicks.Add(0);   // inicjuje czas wyscigu dla kazdego gracza
        arrFinalPlace.Add(-1); // inicjuje miejsce (-1 = nie wiadomo jeszcze, 0 = DNF, 1-8 = zakonczyl wyscig)
    }
}//--------------------------------------------------------------------------------------|

function int MoveHeroesToStartMarkersAndCreateHorses(int nShowTeleOutEffect, int nShowTeleInEffect)
{
    int arrStartX[], arrStartY[], arrStartAngle[];
    int arrHorseX[], arrHorseY[], arrHorseAngle[];
    int nIndex;
    int nX, nY, nAngle;
    int nMarkerIndex;
    unit pHero, pHorse;

    arrStartX.Copy(m_arrStartX);
    arrStartY.Copy(m_arrStartY);
    arrStartAngle.Copy(m_arrStartAngle);

    arrHorseX.Copy(m_arrHorseX);
    arrHorseY.Copy(m_arrHorseY);
    arrHorseAngle.Copy(m_arrHorseAngle);

    ASSERT( (arrStartX.GetSize() == arrStartY.GetSize()) && (arrStartX.GetSize() == arrStartAngle.GetSize()) );

    if( arrStartX.GetSize() < GetCampaign().GetPlayersCnt() )
    {
        TRACE("!!! Jest mniej markerow startowych niz graczy (%d < %d) !!!\n", arrStartX.GetSize(), GetCampaign().GetPlayersCnt() );
    }
    
    for(nIndex = 0; nIndex < GetCampaign().GetPlayersCnt(); nIndex++)
    {
        if( !IsPlayer(nIndex) )
        {
            continue;
        }
        pHero = GetCampaign().GetPlayerHeroUnit(nIndex);
        if( arrStartX.GetSize() > 0 )
        {
            nMarkerIndex = Rand( arrStartX.GetSize() );
            nX = arrStartX[nMarkerIndex];
            nY = arrStartY[nMarkerIndex];
            nAngle = arrStartAngle[nMarkerIndex];
        }
        else // jezeli zabraklo markerow startowych to jest problem
        {
            __ASSERT_FALSE();
            continue;
        }
        if( nShowTeleOutEffect )
        {
            m_pCurrentMission.CreateObject(TELE_OUT_EFFECT, pHero.GetLocationX(), pHero.GetLocationY(), 0, 0);
        }
        pHero.SetImmediatePosition( nX, nY, 0, nAngle, true);
        if( nShowTeleInEffect )
        {
            m_pCurrentMission.CreateObject(TELE_IN_EFFECT, pHero.GetLocationX(), pHero.GetLocationY(), 0, nAngle);
        }
        arrStartX.RemoveAt(nMarkerIndex);
        arrStartY.RemoveAt(nMarkerIndex);
        arrStartAngle.RemoveAt(nMarkerIndex);
// tworzenie konia tam gdzie zostal przeniesiony player
        pHorse = m_pCurrentMission.CreateObject(GetRandomHorseName(), arrHorseX[nMarkerIndex], arrHorseY[nMarkerIndex], 0, arrHorseAngle[nMarkerIndex]);
        m_arrHorses.Add(pHorse);
        m_arrHorseRespawnTicks.Add(0);

        arrHorseX.RemoveAt(nMarkerIndex);
        arrHorseY.RemoveAt(nMarkerIndex);
        arrHorseAngle.RemoveAt(nMarkerIndex);
    }
    return 1;
}//--------------------------------------------------------------------------------------|

function void CureHorses()
{
    int nIndex;
    unit pHorse;

    for(nIndex = 0; nIndex < m_arrHorses.GetSize(); nIndex++)
    {
        m_arrHorses[nIndex].SetHP( m_arrHorses[nIndex].GetMaxHP() );
    }
}//--------------------------------------------------------------------------------------|

function void OpenGates()
{
    int nIndex;
    for(nIndex = 0; nIndex < m_arrGates.GetSize(); nIndex++)
    {
        if( (m_arrGates[nIndex] != null) && m_arrGates[nIndex].IsGateClosed() )
        {
            m_arrGates[nIndex].SetGateOpen(true);  
        }            
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
    m_pCurrentMission.CreateObject(TELE_IN_EFFECT, m_arrHorses[nHorseIndex].GetLocationX(), m_arrHorses[nHorseIndex].GetLocationY(), 0, 0);
    return 1;
}//--------------------------------------------------------------------------------------|

function void PrepareToRespawnHorse(int nHorseIndex)
{
    m_arrHorseRespawnTicks[nHorseIndex] = eHorseRespawnTicks;
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

function void CheckIfPlayersFinishedRace()
{
    int nPlayerIndex;
    int nStillRacing;
    stringW strText, strTime;
    int nM, nS, nMs;

    nStillRacing = false;

    for(nPlayerIndex = 0; nPlayerIndex < GetCampaign().GetPlayersCnt(); nPlayerIndex++)
    {
        if( !IsPlayer(nPlayerIndex) ) // playera nie ma
        {
            continue;    
        }
        else if( m_arrHeroFinalPlace[nPlayerIndex] > -1 ) // player dotarl juz do mety (1-8) lub wyszedl z gry (0) wiec nie bierzemy go pod uwage
        {
            continue;
        }
        // player jeszcze sie sciga
        if( IsPointInPolygon(m_arrFinishX, m_arrFinishY,
                           GetCampaign().GetPlayerHeroUnit(nPlayerIndex).GetLocationX(),
                           GetCampaign().GetPlayerHeroUnit(nPlayerIndex).GetLocationY() ) )
        {
            // player wlasnie dotarl do mety
            m_arrHeroRaceTicks[nPlayerIndex]  = GetRaceTime();
            m_arrHeroFinalPlace[nPlayerIndex] = GetNextPlace();
            ConvertTicksToTime(m_arrHeroRaceTicks[nPlayerIndex], nM, nS, nMs);
            FormatTime(strTime, nM, nS, nMs);
            strText.FormatTrl(TEXT_FINISHEDATPLACEWITHTIME, m_arrHeroNames[nPlayerIndex],
                                                            m_arrHeroFinalPlace[nPlayerIndex],
                                                            strTime);
            ShowTextToAll(strText, eDefaultConsoleTextTime, true);

            if( IsItLastPremiumPlace(m_arrHeroFinalPlace[nPlayerIndex]) )
            {
                // zaczynamy liczyc extra time
                m_nExtraTicks = eExtraTicks;
                m_nExtraTicksElapsing = true;
                TRACE("EXTRA TIME STARTED\n");
            }
        }
    }
}//--------------------------------------------------------------------------------------|

function int CheckRaceEndConditions()
{
    if( DidEveryoneFinishRace() )
    {
        return 1; // wszyscy skonczyli wyscig
    }
    if( IsExtraTimeElapsing() ) // dodatkowy czas mija tylko gdy zostala ustawiona flaga
    {
        ProcessExtraTime(); 
        if( IsExtraTimeElapsed() )
        {
            return 1; // nie wszyscy skonczyli wyscig, ale skonczyl sie czas
        }
    }
    return 0; // wyscig trwa
}//--------------------------------------------------------------------------------------|

function int DidEveryoneFinishRace()
{
    int nPlayerIndex;
    int nCount;

    nCount = 0;
    for(nPlayerIndex = 0; nPlayerIndex < m_arrHeroFinalPlace.GetSize(); nPlayerIndex++)
    {
        if( m_arrHeroFinalPlace[nPlayerIndex] > -1 )
        {
            nCount++;
        }
    }
    if( nCount == m_arrHeroFinalPlace.GetSize() )
    {
        return true;    
    }
    return false;
}//--------------------------------------------------------------------------------------|

function int IsExtraTimeElapsing()
{
    return m_nExtraTicksElapsing;
}//--------------------------------------------------------------------------------------|

function int IsExtraTimeElapsed()
{
    if( m_nExtraTicks < 0 )
    {
        return 1;
    }
    return 0;
}//--------------------------------------------------------------------------------------|

function void ProcessExtraTime()
{
    m_nExtraTicks -= m_nMainStateTicksInterval;
}//--------------------------------------------------------------------------------------|

function void ProcessRaceTime()
{
    m_nRaceTicks += m_nMainStateTicksInterval;
}//--------------------------------------------------------------------------------------|

function int IsItPremiumPlace(int nPlace)
{
    if( (nPlace >= 0) && (nPlace <= GetLastPremiumPlace()) )
    {
        return true;
    }
    return false;
}//--------------------------------------------------------------------------------------|

function int IsItLastPremiumPlace(int nPlace)
{
    if( nPlace == GetLastPremiumPlace() )
    {
        return true;
    }
    return false;
}//--------------------------------------------------------------------------------------|

function int GetLastPremiumPlace()
{
    int nPlayerCount;
// szuka pierwszego wystapienia 0 w tablicy i zwraca poprzednie miejsce
    nPlayerCount = GetCampaign().GetPlayersCnt();
    if( nPlayerCount == 1 )        return 1; // jest tylko jedno premiowane miejsce
    else if( nPlayerCount == 2 )   return GetIndexOfValueInArray(0, m_arrPoints2Players);
    else if( nPlayerCount == 3 )   return GetIndexOfValueInArray(0, m_arrPoints3Players);
    else if( nPlayerCount == 4 )   return GetIndexOfValueInArray(0, m_arrPoints4Players);
    else if( nPlayerCount == 5 )   return GetIndexOfValueInArray(0, m_arrPoints5Players);
    else if( nPlayerCount == 6 )   return GetIndexOfValueInArray(0, m_arrPoints6Players);
    else if( nPlayerCount == 7 )   return GetIndexOfValueInArray(0, m_arrPoints7Players);
    else if( nPlayerCount == 8 )   return GetIndexOfValueInArray(0, m_arrPoints8Players);
    __ASSERT_FALSE();
    return -1;
}//--------------------------------------------------------------------------------------|

function int GetPercentMultiplier(int nPlace)
{
    int nPlayerCount;
// szuka pierwszego wystapienia 0 w tablicy i zwraca poprzednie miejsce
    nPlayerCount = GetCampaign().GetPlayersCnt();
    if( nPlayerCount == 1 )        return m_arrPoints1Player[nPlace - 1];
    else if( nPlayerCount == 2 )   return m_arrPoints2Players[nPlace - 1];
    else if( nPlayerCount == 3 )   return m_arrPoints3Players[nPlace - 1];
    else if( nPlayerCount == 4 )   return m_arrPoints4Players[nPlace - 1];
    else if( nPlayerCount == 5 )   return m_arrPoints5Players[nPlace - 1];
    else if( nPlayerCount == 6 )   return m_arrPoints6Players[nPlace - 1];
    else if( nPlayerCount == 7 )   return m_arrPoints7Players[nPlace - 1];
    else if( nPlayerCount == 8 )   return m_arrPoints8Players[nPlace - 1];
    __ASSERT_FALSE();
    return -1;
}//--------------------------------------------------------------------------------------|

function int GetNextPlace()
{
    int nPlayerIndex;
    int nLastPlaceFound;

    nLastPlaceFound = 0;

    for(nPlayerIndex = 0; nPlayerIndex < m_arrHeroFinalPlace.GetSize(); nPlayerIndex++)
    {
        // sprawdzanie tylko m_arrHeroFinalPlace
        // bez sprawdzania IsPlayer, bo gracz mogl skonczyc wyscig i wyjsc
        if( m_arrHeroFinalPlace[nPlayerIndex] > nLastPlaceFound )
        {
            nLastPlaceFound = m_arrHeroFinalPlace[nPlayerIndex];
        }
    }
    return nLastPlaceFound + 1;
}//--------------------------------------------------------------------------------------|

function int GetRaceTime()
{
    return m_nRaceTicks;    
}//--------------------------------------------------------------------------------------|

function void DistributePoints()
{
#ifdef _XBOX
    DistributeXBOXPoints_HorseRacing();
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
    int nPlayerIndex;
    unit pHero;
    int nPointPercent;
    int nAverageEntryPoints;
    int nPointsForPlayer;

    if( IsGuildsGame() )
    {
        return;
    }
    nAverageEntryPoints = m_nEarthNetPlayerPointsPool / GetCampaign().GetPlayersCnt();
    TRACE("DISTRIBUTING EN PLAYER POINTS\n");
    TRACE("pool: %d players num: %d avg entry pts: %d\n", m_nEarthNetPlayerPointsPool, GetCampaign().GetPlayersCnt(), nAverageEntryPoints);

    for(nPlayerIndex = 0; nPlayerIndex < GetCampaign().GetPlayersCnt(); nPlayerIndex++)
    {
        if( !IsPlayer(nPlayerIndex) ||
            !IsItPremiumPlace(m_arrHeroFinalPlace[nPlayerIndex]) ) // miejsce za ktore dostaje sie pkt
        {
            continue;
        }
        nPointPercent = GetPercentMultiplier( m_arrHeroFinalPlace[nPlayerIndex] );
        ASSERT(nPointPercent > 0);

        TRACE("heronum: %d place: %d pts percent: %d ", nPlayerIndex, m_arrHeroFinalPlace[nPlayerIndex], nPointPercent);

        nPointsForPlayer = nAverageEntryPoints * nPointPercent / 100;
        TRACE("POINTS WON: %d current pts: %d ", nPointsForPlayer, GetCampaign().GetPlayerHeroUnit(nPlayerIndex).GetHeroNetworkRankPoints() );

        m_nEarthNetPlayerPointsPool -= nPointsForPlayer;
        ASSERT(m_nEarthNetPlayerPointsPool >= 0);
        pHero = GetCampaign().GetPlayerHeroUnit(nPlayerIndex);

        if( GetGameType() == eGamePvP )
        {
            pHero.AddHeroNetworkRankPoints( nPointsForPlayer );
        }
        else if( GetGameType() == eGameRPGArena )
        {
            pHero.SetMoney( pHero.GetMoney() + nPointsForPlayer );
        }

        m_arrHeroRankPoints[nPlayerIndex] += nPointsForPlayer; // korekta tego co bedzie wyswietlane (zdobyte punkty bez swoich odzyskanych)
        TRACE("OVERALL POINTS: %d drawn points: %d\n", GetCampaign().GetPlayerHeroUnit(nPlayerIndex).GetHeroNetworkRankPoints(), m_arrHeroRankPoints[nPlayerIndex] );
    }
    if( m_nEarthNetPlayerPointsPool > 0 )
    {
        TRACE("pool %d\n", m_nEarthNetPlayerPointsPool);
    }
}//--------------------------------------------------------------------------------------|

function void DistributeEarthNetGuildPoints()
{
    int nGuildNum;
    int nGuildIndex;
    int nHeroNum;

    if( !IsGuildsGame() )
    {
        return;
    }
// znalezienie pierwszego miejsca
    nHeroNum = GetIndexOfValueInArray(1, m_arrHeroFinalPlace);
    if( (nHeroNum == -1) || !IsPlayer(nHeroNum) )
    {
        __ASSERT_FALSE();
        return;
    }
    nGuildNum = GetCampaign().GetPlayerHeroUnit(nHeroNum).GetHeroNetworkGuildNum();
    if( nGuildNum == -1 )
    {
        __ASSERT_FALSE();
        return;    
    }
    nGuildIndex = GetIndexOfValueInArray(nGuildNum, m_arrGuildsNum);
    if( nGuildIndex == -1 )
    {
        __ASSERT_FALSE();
        return;    
    }
    DistributeEarthNetGuildPoints(nGuildIndex);
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_HorseRacing()
{
    int nIndex;
    int nGamePoints;
    int nPointPercent;
    stringW strText;
    
    for(nIndex = 0; nIndex < GetCampaign().GetPlayersCnt(); nIndex++)
    {
        if( !IsPlayer(nIndex) ||
            !IsItPremiumPlace(m_arrHeroFinalPlace[nIndex]) ) // miejsce za ktore dostaje sie pkt
        {
            continue;
        }
        nPointPercent = GetPercentMultiplier( m_arrHeroFinalPlace[nIndex] );
        ASSERT(nPointPercent > 0);
// poprawka, jezeli jest tylko jeden gracz, nie przyznajemy zadnych punktow
        if( GetCampaign().GetPlayersCnt() == 1 )
        {
            nGamePoints = 0;
        }
        else
        {
            nGamePoints = 5 * nPointPercent / 100;
        }
        GetCampaign().GetPlayerHeroUnit(nIndex).AddHeroNetworkGameModePoints(eGameModePointsHorseracing, nGamePoints);
        if (IsRankedGame())
        {        
            strText.FormatTrl(TEXT_GETPOINTS, nGamePoints);
            ShowTextToPlayer(nIndex, strText, eResultsConsoleTextTime, true);
        }
    }
}//--------------------------------------------------------------------------------------|

function void ShowWelcomeText()
{
    int nIndex;
    stringW strText;
    strText.Translate(TEXT_MOUNTHORSEANDGO);
    ShowTextToAll(strText, eDefaultConsoleTextTime, true);
}//--------------------------------------------------------------------------------------|

function void ShowResultsText()
{
    int nPlayerIndex;
    int nIndex;
    int nM, nS, nMs;
    stringW strText;
    stringW strTime;
    stringW strDNF;
    
    ASSERT(m_arrHeroNames.GetSize() == m_arrHeroNames.GetSize());
    ASSERT(m_arrHeroNames.GetSize() == m_arrHeroFinalPlace.GetSize());

    strText.Translate(TEXT_RACERESULTS);
    ShowTextToAll(strText, eResultsConsoleTextTime, false);
// wypisanie tych ktorzy ukonczyli wyscig
    for(nPlayerIndex = 0; nPlayerIndex < m_arrHeroNames.GetSize(); nPlayerIndex++)
    {
        nIndex = GetIndexOfValueInArray(nPlayerIndex + 1, m_arrHeroFinalPlace);
        if( nIndex == -1 )
        {
            break;
        }
        ConvertTicksToTime(m_arrHeroRaceTicks[nIndex], nM, nS, nMs);
        FormatTime(strTime, nM, nS, nMs);
        strText.FormatTrl(TEXT_RACERESULTENTRY, m_arrHeroFinalPlace[nIndex], m_arrHeroNames[nIndex], strTime);
        ShowTextToAll(strText, eResultsConsoleTextTime, true);
    }
// wypisanie tych ktorzy nie ukonczyli wyscigu
    strDNF.Translate(TEXT_DIDNOTFINISH);
    for(nPlayerIndex = 0; nPlayerIndex < m_arrHeroNames.GetSize(); nPlayerIndex++)
    {
        if( m_arrHeroFinalPlace[nPlayerIndex] > 0 )
        {
            continue;
        }
        m_arrHeroFinalPlace[nPlayerIndex] = GetNextPlace();
        strText.FormatTrl(TEXT_RACERESULTENTRY, m_arrHeroFinalPlace[nPlayerIndex], m_arrHeroNames[nPlayerIndex], strDNF);
        ShowTextToAll(strText, eResultsConsoleTextTime, true);
    }
}//--------------------------------------------------------------------------------------|

function void ShowTimeText()
{
    stringW strText;
    int nM, nS, nMs;
    ConvertTicksToTime(m_nRaceTicks, nM, nS, nMs);
    FormatTime(strText, nM, nS, nMs);
    ShowBottomTextToAll(strText, eDefaultConsoleTextTime, false);
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
event RemovedNetworkPlayer(int nPlayerNum)
{
    stringW strText;
    TRACE("HorseRacing::RemovedNetworkPlayer(%d)\n", nPlayerNum);
    
    m_arrHeroFinalPlace[nPlayerNum] = 0; // DNF
    strText.FormatTrl(TEXT_LEFTTHEGAME, m_arrHeroNames[nPlayerNum]);
    ShowTextToAll(strText, eDefaultConsoleTextTime, true);
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

event RemovedUnit(unit uKilled, unit uAttacker, int a)
{
    int nKilledHeroNum;
    int nAttackHeroNum;
    int nKilledHorseIndex;
    stringW strKilledInfo;

    if( uKilled.IsHeroUnit() ) // na wypadek gdyby zabity zostal np summonowany zwierz
    {
        nKilledHeroNum = uKilled.GetHeroPlayerNum();

        if( state == Race )
        {
            // jezeli bohater zostal fizycznie zabity przez kogos
            // (a nie wyszedl z gry, utopil sie albo spadl z wysokosci)
            // to wypisz info
            if( uAttacker )
            {
                // jezeli atakujacym nie byl hero a np summonowany potwor
                if( !uAttacker.IsHeroUnit() )
                {
                    strKilledInfo.FormatTrl(TEXT_WASKILLED, m_arrHeroNames[nKilledHeroNum] );
                }
                // jezeli atakujacym byl inny hero
                else
                {
                    nAttackHeroNum = uAttacker.GetHeroPlayerNum();
                    strKilledInfo.FormatTrl(TEXT_WASKILLEDBY, m_arrHeroNames[nKilledHeroNum], m_arrHeroNames[nAttackHeroNum] );
                }
                ShowTextToAll(strKilledInfo, eKilledConsoleTextTime, true);
            }
            PrepareToRespawnHero(nKilledHeroNum);
        }
    }
    else if( uKilled.IsHorseUnit() ) // na wypadek gdyby zabity zostal kon
    {
        TRACE("zabito konika!!!\n");
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
    return false;
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
state Initialize
{
    TRACE("------------------------------------------------\n");
    TRACE("STATE: Initialize\n");
    HorseRacingInit();
    MoveHeroesToStartMarkersAndCreateHorses(false, true);
    ShowWelcomeText();
    InitRacingMapSigns();
    TRACE("STATE: CountdownBeforeRace\n");
    return CountdownBeforeRace, 0;
}//--------------------------------------------------------------------------------------|

state CountdownBeforeRace
{
    CureHeroes(); // na wypadek gdyby gracze ze soba zaczeli juz walczyc
    CureHorses();
    RespawnHorses();
    RespawnHeroesImmediately();
    CheckIfOtherPlayersArePresent();
    
    if( CheckIfCountdownEnded() )
    {
        __TraceCommonGamePoints(eStart);
//        SetBorderMargin(eDefaultBorder); // bez tego, trasa i tak jest ograniczona
        InitHeroes();   // inicjujemy zmienne herosow
        InitGuilds();
        OpenGates();    // otwieramy bramy i zaczynamy liczyc czas
        InitRacingMapSigns();
        TRACE("STATE: Race\n");
        return Race, 1;
    }
    return CountdownBeforeRace, 0;
}//--------------------------------------------------------------------------------------|

state Race
{
    RespawnHorses();
    ProcessRaceTime();
    ShowTimeText();
    RespawnHeroesAtNoCondition();
    CheckIfOtherPlayersArePresent();
    CheckIfPlayersFinishedRace();
    if( CheckRaceEndConditions() )
    {
        TRACE("STATE: Results\n");
        ShowResultsText();
        DistributePoints();
        return Results, 0;
    }
    return Race, m_nMainStateTicksInterval - 1;
}//--------------------------------------------------------------------------------------|

state Results
{
    __TraceCommonGamePoints(eEnd);
    CureHeroes();
    return GameOver, eResultsConsoleTextTime;
}//--------------------------------------------------------------------------------------|

state GameOver
{
    EndGame(eEndGameTextRace);
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
    
    if (!strCommand.CompareNoCase("PrintHeroes"))
    {
        if( state == CountdownBeforeRace )
        {
            TRACE("Heroes not initialized yet\n");
            TRACE("Heroes count: %d\n", m_arrHeroNames.GetSize());
        }
        
        TRACE("Heroes (horse racing):\n");
        for(nIndex = 0; nIndex < m_arrHeroFinalPlace.GetSize(); nIndex++)
        {
            TRACE("num %d place %d rank %d raceticks %d)\n", nIndex,
                                                             m_arrHeroFinalPlace[nIndex],
                                                             m_arrHeroRankPoints[nIndex],
                                                             m_arrHeroRaceTicks[nIndex] );
        }
    }
    else if (!strCommand.CompareNoCase("GoToFinish"))
    {
        GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).SetImmediatePosition(100 * 256, 116 * 256, 0, 0, true);
    }
    else
    {
        return BaseCommandDebug(strCommand);
    }
    return 1;
}//--------------------------------------------------------------------------------------|

}
