global "Team Deathmatch script"
{

#include "MissionTeamBase.ech"

////////////////////////////////////////////////////////////////////////////////
consts
{
// gameplay
    eKillsLimitMultiplier = 5,
// interfejs
    eFightConsoleTextTime =  5 * 30,
    eDeathmatchMainStateTicksInterval = 30,
}

////////////////////////////////////////////////////////////////////////////////
// TEAMY
int m_arrTeam1KillsCount[], m_arrTeam2KillsCount[];
int m_nTeam1Kills, m_nTeam2Kills;
// inne zmienne
int m_nArenaCount;  // liczba aren ustalana na podstawie markerow
int m_nKillsLimit;
////////////////////////////////////////////////////////////////////////////////
state Initialize;
state JoiningTeams;
state CountdownBeforeFight;
state Fight;
state Results;
state GameOver;

function void TeamDeathmatchInit();
function void InitTeamDeathmatchMapSigns();
function void FindArenaCount();
function void InitTeams();
function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrLivesCount[]);
function void CheckIfAnyTeamWins();
function void DistributePoints();
function void DistributeEarthNetPlayerPoints();
function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrKillsCount[]);
function void DistributeXBOXPoints_TeamDeathmatch();
function void DistributeXBOXPoints_TeamDeathmatch(int arrWinningHeroNum[], int arrLosingHeroNum[]);

function void IncreaseHeroKillsCount(int nTeamNum, int nHeroIndex);
function void IncreaseHeroKillsCount(int arrKillsCount[], int nHeroIndex);
function void IncreaseTeamKillsCount(int nTeamNum);

function void ShowFightText();
function void ShowDeathmatchGamePointsText();

////////////////////////////////////////////////////////////////////////////////////
// TYMCZASOWO DO TESTOW, SKASOWAC JEZELI WSZYSTKO JEST OK
/*function void __OutputDebugString(stringW strText)
{
    stringW strTextToShow, strColorStart, strColorEnd;
    strColorStart.Copy("<0xFFFFFF00>");
    strColorEnd.Copy("<*>");
    
    strTextToShow.Append(strColorStart);
    strTextToShow.Append(strText);
    strTextToShow.Append(strColorEnd);
    ShowTextToAll(strTextToShow, eDefaultConsoleTextTime, true);
}//--------------------------------------------------------------------------------------|*/
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function void TeamDeathmatchInit()
{
    TeamBaseInit();

// inne zmienne
    m_nTeam1Kills = 0;
    m_nTeam2Kills = 0;
    m_nKillsLimit = GetCampaign().GetPlayersCnt() * eKillsLimitMultiplier;

    m_nMainStateTicksInterval = eDeathmatchMainStateTicksInterval;
    FindArenaCount();

    EnableShowLocalTeamMapSigns(true);
    EnableShowRemoteTeamMapSigns(false);
    EnableItemRespawns(true);
    InitRespawnItems();

// po wybraniu areny ustalenie przesuniecia
    m_nMarkerShift = Rand(m_nArenaCount);
    TRACE("random markershift: %d\n", m_nMarkerShift);
}//--------------------------------------------------------------------------------------|

function void InitTeamDeathmatchMapSigns()
{
    InitTeamMapSigns();
}//--------------------------------------------------------------------------------------|

function void FindArenaCount()
{
    int nMaxMarkerNum;

    nMaxMarkerNum = m_pCurrentMission.GetMaxMarkerNum(DEFAULT_MARKER);
    m_nArenaCount = (nMaxMarkerNum / MARKER_SHIFT_VALUE) + 1;
    TRACE("max marker number: %d, expected number of DM arenas: %d\n", nMaxMarkerNum, m_nArenaCount );
}//--------------------------------------------------------------------------------------|

function void InitTeams()
{
    InitTeam(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1HeroRespawnTicks, m_arrTeam1KillsCount);
    InitTeam(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2HeroRespawnTicks, m_arrTeam2KillsCount);
}//--------------------------------------------------------------------------------------|

function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrLivesCount[])
{
    int nPlayerIndex;

    InitTeam(arrHeroNumber, arrRankPoints, arrRespawnTicks);

    arrLivesCount.RemoveAll();
    for(nPlayerIndex = 0; nPlayerIndex < arrHeroNumber.GetSize(); nPlayerIndex++)
    {
        arrLivesCount.Add(0); // inicjuj zycia
    }
}//--------------------------------------------------------------------------------------|

function void CheckIfAnyTeamWins()
{
    int nTeam1Alive, nTeam2Alive;
    
    if( m_nWinner != eNoWinnerYet )
    {
        return; // juz jest zwyciezca
    }

    if( (m_nTeam1Kills < m_nKillsLimit) && (m_nTeam2Kills < m_nKillsLimit) )
    {
        return;
    }
    if( m_nTeam1Kills == m_nTeam2Kills )
    {
        m_nWinner = eDrawGame;
        return;
    }
    else if( m_nTeam1Kills >= m_nKillsLimit )
    {
        TRACE("Team1 wins!\n");
        m_nWinner = eTeam1;
    }
    else if( m_nTeam2Kills >= m_nKillsLimit )
    {
        TRACE("Team2 wins!\n");
        m_nWinner = eTeam2;
    }
}//--------------------------------------------------------------------------------------|

function void DistributePoints()
{
#ifdef _XBOX
    DistributeXBOXPoints_TeamDeathmatch();
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
        DistributeEarthNetPlayerPoints(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1KillsCount);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeEarthNetPlayerPoints(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2KillsCount);
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

function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrKillsCount[]) // w przypadku wygranej jednego teamu
{
    int nIndex;
    int nPrizePointsPerPlayer;
    int nPlayersCount;
    int nMaxKillsHeroIndex;
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
// szukanie herosa z maksymalna liczba zyc
    nMaxKillsHeroIndex = GetIndexOfMaxValueInArray(arrKillsCount);
// ile pkt przypada na pojedynczego playera
    nPrizePointsPerPlayer = m_nEarthNetPlayerPointsPool / nPlayersCount;
    
    TRACE("DISTRIBUTING EN PLAYER POINTS\n");
    TRACE("pool: %d, players num: %d: points per player: %d, bonus points: %d\n", m_nEarthNetPlayerPointsPool, nPlayersCount, nPrizePointsPerPlayer, m_nEarthNetPlayerPointsPool % nPlayersCount);
// dodanie punktow zwycieskim playerom
    for(nIndex = 0; nIndex < arrHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer( arrHeroNum[nIndex] ) )
        {
            arrPoints.Add(0); // musi byc zeby zgadzaly sie indeksy
            continue;
        }
        arrPoints.Add(nPrizePointsPerPlayer);
        TRACE("hero num: %d, POINTS WON: %d\n", arrHeroNum[nIndex], arrPoints[nIndex] );
        m_nEarthNetPlayerPointsPool -= nPrizePointsPerPlayer;
        ASSERT( m_nEarthNetPlayerPointsPool >= 0 );
    }
 // jezeli po rozdysponowaniu punktow cos jeszcze zostalo to daj to playerowi z najwieksza liczba zyc
    if( m_nEarthNetPlayerPointsPool > 0 )
    {
        TRACE("Bonus points (%d) goes to %d\n", m_nEarthNetPlayerPointsPool, nMaxKillsHeroIndex);
        ASSERT( (nMaxKillsHeroIndex >= 0) && (nMaxKillsHeroIndex < arrPoints.GetSize()) );
        arrPoints[nMaxKillsHeroIndex] += m_nEarthNetPlayerPointsPool;
    }
// zapis z tablicy do playera
    TRACE("ADDING TO SCORES\n");
    for(nIndex = 0; nIndex < arrHeroNum.GetSize(); nIndex++)
    {
        if( !IsPlayer( arrHeroNum[nIndex] ) )
        {
            continue;
        }
        pHero = GetCampaign().GetPlayerHeroUnit(arrHeroNum[nIndex]);
        TRACE("hero num: %d, CURRENT POINTS: %d, ", arrHeroNum[nIndex], pHero.GetHeroNetworkRankPoints() );

        if( GetGameType() == eGamePvP )
        {
            pHero.AddHeroNetworkRankPoints(arrPoints[nIndex]);
        }
        else if( GetGameType() == eGameRPGArena )
        {
            pHero.SetMoney( pHero.GetMoney() + arrPoints[nIndex] );
        }

        arrPrizePoints[nIndex] += arrPoints[nIndex]; // korekta tego co bedzie wyswietlane (zdobyte punkty bez swoich odzyskanych)
        TRACE("OVERALL POINTS: %d, drawn points: %d\n", pHero.GetHeroNetworkRankPoints(), arrPrizePoints[nIndex] );
    }
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_TeamDeathmatch()
{
    if( m_nWinner == eTeam1 )
    {
        DistributeXBOXPoints_TeamDeathmatch(m_arrTeam1HeroNumber, m_arrTeam2HeroNumber);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeXBOXPoints_TeamDeathmatch(m_arrTeam2HeroNumber, m_arrTeam1HeroNumber);
    }
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_TeamDeathmatch(int arrWinningHeroNum[], int arrLosingHeroNum[])
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
        GetCampaign().GetPlayerHeroUnit(arrWinningHeroNum[nIndex]).AddHeroNetworkGameModePoints(eGameModePointsPlayerkilling, nGamePoints);
        if (IsRankedGame())
        {
            strText.FormatTrl(TEXT_GETPOINTS, nGamePoints);
            ShowTextToPlayer(arrWinningHeroNum[nIndex], strText, eResultsConsoleTextTime, true);
        }
    }
}//--------------------------------------------------------------------------------------|

function void IncreaseHeroKillsCount(int nTeamNum, int nHeroIndex)
{
    if( nTeamNum == eTeam1 )
    {
        IncreaseHeroKillsCount(m_arrTeam1KillsCount, nHeroIndex);
    }
    else if( nTeamNum == eTeam2 )
    {
        IncreaseHeroKillsCount(m_arrTeam2KillsCount, nHeroIndex);
    }
    else
    {
        TRACE("!!! Nieznany team !!!\n");
    }
}//--------------------------------------------------------------------------------------|

function void IncreaseHeroKillsCount(int arrKillsCount[], int nHeroIndex)
{
    ASSERT( (nHeroIndex >= 0) && (nHeroIndex < arrKillsCount.GetSize()) );
    arrKillsCount[nHeroIndex] += 1;
}//--------------------------------------------------------------------------------------|

function void IncreaseTeamKillsCount(int nTeamNum)
{
    if( nTeamNum == eTeam1 )
    {
        m_nTeam1Kills++;
    }
    else if( nTeamNum == eTeam2 )
    {
        m_nTeam2Kills++;
    }
    else
    {
        TRACE("!!! Nieznany team !!!\n");
    }
}//--------------------------------------------------------------------------------------|

function void ShowFightText()
{
    stringW strTextFight, strTextLimit;
    strTextFight.Translate(TEXT_FIGHT);
    strTextLimit.FormatTrl(TEXT_KILLLIMIT, m_nKillsLimit);
    ShowTextToTeam(eTeam1, strTextFight, eFightConsoleTextTime, false);
    ShowTextToTeam(eTeam1, strTextLimit, eFightConsoleTextTime, true);
    ShowTextToTeam(eTeam2, strTextFight, eFightConsoleTextTime, false);
    ShowTextToTeam(eTeam2, strTextLimit, eFightConsoleTextTime, true);
}//--------------------------------------------------------------------------------------|

function void ShowDeathmatchGamePointsText()
{
    stringW strTeam1, strTeam2;
    stringW strText;

    strTeam1.Translate(TEXT_TEAM1);
    strTeam2.Translate(TEXT_TEAM2);

    strText.FormatTrl(TEXT_GAMEPOINTS, strTeam1, m_nTeam1Kills, m_nTeam2Kills, strTeam2);

    ShowBottomTextToTeam(eTeam1, strText, eResultsConsoleTextTime, false);
    ShowBottomTextToTeam(eTeam2, strText, eResultsConsoleTextTime, false);
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
event RemovedNetworkPlayer(int nPlayerNum)
{
    stringW strText;
    TRACE("TeamDeathmatch::RemovedNetworkPlayer(%d)\n", nPlayerNum);
    
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
    stringW strKilledInfo;

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

    if( uKilled.IsHeroUnit() ) // na wypadek gdyby zabity zostal np summonowany zwierz
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
            // to wypisz info i sprawdz czy ktos nie wygral
            if( uAttacker )
            {
                // jezeli atakujacym nie byl hero a np summonowany potwor
                if( !uAttacker.IsHeroUnit() )
                {
                    strKilledInfo.FormatTrl(TEXT_WASKILLED, m_arrHeroNames[nKilledHeroNum] );
                }
                else
                {
                    // jezeli atakujacym byl hero z innego zespolu
                    if( nAttackTeamNum != nKilledTeamNum )
                    {
                        strKilledInfo.FormatTrl(TEXT_WASKILLEDBY, m_arrHeroNames[nKilledHeroNum], m_arrHeroNames[nAttackHeroNum] );
                        IncreaseHeroKillsCount(nAttackTeamNum, nAttackHeroIndex); // tylko w przypadku zabicia przeciwika
                    }
                    // jezeli atakujacym byl hero z tego samego zespolu
                    else
                    {
                        strKilledInfo.FormatTrl(TEXT_WASKILLEDBY_FF, m_arrHeroNames[nKilledHeroNum], m_arrHeroNames[nAttackHeroNum] );
                    }
                    IncreaseTeamKillsCount( GetOppositeTeam(nKilledTeamNum) ); // punkt otrzymuje druzyna przeciwna
                    CheckIfAnyTeamWins();
                }
                ShowTextToAll(strKilledInfo, eKilledConsoleTextTime, true);
            }
            PrepareToRespawnHero(nKilledTeamNum, nKilledHeroIndex);
        }
        else // na wszelki wypadek gdyby komus udalo sie zginac po walce
        {
//            RespawnTeamHero(uKilled);
        }
    }
    return false;
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
state Initialize
{
    TRACE("------------------------------------------------\n");
    TRACE("STATE: Initialize\n");
    TeamDeathmatchInit();
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
//----- te funkcje musza byc tutaj, bo biora pod uwage zmieniony m_nMarkerShift ------
        InitTeamStartMarkers();
        InitRespawnItemMarkers();
//------------------------------------------------------------------------------------
        MoveTeamsToTeamStartMarkers();
        InitTeamDeathmatchMapSigns();
        TRACE("STATE: Fight\n");
        ShowFightText();
        return Fight, 0;
    }
    return CountdownBeforeFight, 0;
}//--------------------------------------------------------------------------------------|

state Fight
{
    RespawnItems();
    RespawnTeamHeroesAtNoCondition();
    ShowDeathmatchGamePointsText();
    CheckIfBothTeamsArePresent();

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
            TRACE("%d vs %d (team deathmatch)\n", m_arrTeam1HeroNumber.GetSize(), m_arrTeam2HeroNumber.GetSize());
            TRACE("Team1:\n");
            for(nIndex = 0; nIndex < m_arrTeam1HeroNumber.GetSize(); nIndex++)
            {
                TRACE("num %d guild %d rank %d kills %d\n", m_arrTeam1HeroNumber[nIndex],
                                                            GetCampaign().GetPlayerHeroUnit(m_arrTeam1HeroNumber[nIndex]).GetHeroNetworkGuildNum(),
                                                            m_arrTeam1RankPoints[nIndex],
                                                            m_arrTeam1KillsCount[nIndex] );
            }
            TRACE("Team2:\n");
            for(nIndex = 0; nIndex < m_arrTeam2HeroNumber.GetSize(); nIndex++)
            {
                TRACE("num %d guild %d rank %d kills %d\n", m_arrTeam2HeroNumber[nIndex],
                                                            GetCampaign().GetPlayerHeroUnit(m_arrTeam2HeroNumber[nIndex]).GetHeroNetworkGuildNum(), 
                                                            m_arrTeam2RankPoints[nIndex],
                                                            m_arrTeam2KillsCount[nIndex] );
            }
        }
    }
    else if (!strnicmp(strCommand, "SetMarkerShift", strlen("SetMarkerShift")))
    {
        if( (state != Initialize) &&
            (state != JoiningTeams) &&
            (state != CountdownBeforeFight) )
        {
            TRACE("Nie mozna ustawic m_nMarkerShift w obecnym stanie\n");
            return true;
        }
        strCommand.Mid(strlen("SetMarkerShift") + 1);
        strCommand.TrimLeft();
        sscanf(strCommand, "%d", nIndex);
        if( (nIndex >= 0) && (nIndex < m_nArenaCount) )
        {
            m_nMarkerShift = nIndex;
            TRACE("Ustawiono m_nMarkerShift na %d\n", m_nMarkerShift);
        }
        else
        {
            TRACE("Nie mozna ustawic m_nMarkerShift na %d (m_nArenaCount: %d)\n", nIndex, m_nArenaCount);
        }
    }
    else if (!strCommand.CompareNoCase("PrintMarkerShift"))
    {
        TRACE("MarkerShift: %d\n", m_nMarkerShift);
    }
    else if (!strCommand.CompareNoCase("PrintArenaCount"))
    {
        TRACE("Arena count: %d\n", m_nArenaCount);
    }
    
    else
    {
        return TeamBaseCommandDebug(strCommand);
    }
    return 1;
}//--------------------------------------------------------------------------------------|

}
