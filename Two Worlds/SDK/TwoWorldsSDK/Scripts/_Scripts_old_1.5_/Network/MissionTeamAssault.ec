global "Team Assault script"
{

#include "MissionTeamBase.ech"

#define TEAMASSAULT_TEAM1TARGETNAME  "MU_BOSS_BLUE"
#define TEAMASSAULT_TEAM2TARGETNAME  "MU_BOSS_RED"
#define TEAMASSAULT_TEAM1TARGETGLOWNAME "BOSS_BLUE_AURA"
#define TEAMASSAULT_TEAM2TARGETGLOWNAME "BOSS_RED_AURA"
#define TEAMASSAULT_TARGETOWNER "TeamAssaultTargetOwner"

////////////////////////////////////////////////////////////////////////////////
consts
{
// dodatkowe markery
    eMarkerTeam1Target = 19,  // 19
    eMarkerTeam2Target = 29,  // 29
// interfejs    
    eDestroyConsoleTextTime =  5 * 30,
// stany
    eAssaultMainStateTicksInterval = 30,
// gameplay
    eTargetGlowRemoveDelay = 8 * 30;
}

////////////////////////////////////////////////////////////////////////////////
// dodatkowe markery
int m_arrTeamTargetX[]; // broniony unit
int m_arrTeamTargetY[];
int m_arrTeamTargetAngle[];
// dodatkowe zmienne herosow
int m_arrTeam1KilledCount[]; // ile razy zostal zabity
int m_arrTeam2KilledCount[];
// dodatkowe zmienne
unit m_arrTarget[];
unit m_arrTargetGlow[];

////////////////////////////////////////////////////////////////////////////////
state Initialize;
state JoiningTeams;
state CountdownBeforeFight;
state Fight;
state Results;
state GameOver;

function void TeamAssaultInit();
function int  InitTargetMarkers();
function void InitTeams();
function void InitTeam(int arrHeroNumber[], int arrRankPoints[], int arrRespawnTicks[], int arrKilledCount[]);
function int  InitTargets();
function int  InitTarget(int nTargetOwner);
function int  GetTeamStatueHealthPercent(int nTeamNum);
function int  GetTeamStatueDamagePercent(int nTeamNum);
function int  GetTeamStatueLocation(int nTeamNum, int &nX, int &nY);
function int  GetTeamStatueMapSign(int nTeamNum, int &nMapSign);
function void DistributePoints();
function void DistributeEarthNetPlayerPoints();
function void DistributeEarthNetPlayerPoints(int arrHeroNum[], int arrPrizePoints[], int arrKilledCount[]);
function void DistributeXBOXPoints_TeamAssault();
function void DistributeXBOXPoints_TeamAssault(int arrWinningHeroNum[], int arrLosingHeroNum[]);

function void InitTeamAssaultMapSigns();
function void InitStatueMapSigns();

function void IncreaseKilledCount(int nTeamNum, int nHeroIndex);
function void IncreaseKilledCount(int arrKilledCount[], int nHeroIndex);

function void ShowDestroyText();
function void ShowTeamStatuesDamagedText();

////////////////////////////////////////////////////////////////////////////////
function void TeamAssaultInit()
{
    TeamBaseInit();
    InitTeamStartMarkers(); // musi byc tu a nie w MissionTeamBase.ech, bo w DM trzeba wziac pod uwage m_nMarkerShift
    InitTargetMarkers();

    m_nMainStateTicksInterval = eAssaultMainStateTicksInterval;

    EnableShowLocalTeamMapSigns(true);
    EnableShowRemoteTeamMapSigns(false);
    EnableItemRespawns(true);
    InitRespawnItemMarkers();
    InitRespawnItems();
}//--------------------------------------------------------------------------------------|

function void InitTeamAssaultMapSigns()
{
    InitTeamMapSigns();
    InitStatueMapSigns();
}//--------------------------------------------------------------------------------------|

function void InitStatueMapSigns()
{
    int nMapSignNum;
    int nX, nY;
    int nTeamIndex;

    nMapSignNum = 1;

    for(nTeamIndex = eTeam1; nTeamIndex <= eTeam2; nTeamIndex++)
    {
        if( GetTeamStatueLocation(nTeamIndex, nX, nY) &&
            GetTeamStatueMapSign(nTeamIndex, nMapSignNum) )
        {
            AddStaticMapSignToAll(nX, nY, nMapSignNum);
        }
    }
}//--------------------------------------------------------------------------------------|

function int InitTargetMarkers()
{
    InitMarkers(eMarkerTeam1Target, 1, m_arrTeamTargetX, m_arrTeamTargetY, m_arrTeamTargetAngle);
    InitMarkers(eMarkerTeam2Target, 1, m_arrTeamTargetX, m_arrTeamTargetY, m_arrTeamTargetAngle);
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

function int InitTargets()
{
    m_arrTarget.SetSize(2);          // dwa teamy
    m_arrTargetGlow.SetSize(2);

    InitTarget(eTeam1);
    InitTarget(eTeam2);
    
    return 1;
}//--------------------------------------------------------------------------------------|

function int InitTarget(int nTargetOwner)
{
    unit pTarget, pTargetGlow;
    string strTargetName;
    string strTargetGlowName;

    if( m_arrTeamTargetX.GetSize() <= nTargetOwner )
    {
        TRACE("!!! Nie ma target markera nr %d !!!\n", nTargetOwner);
        return 0;
    }
    if( nTargetOwner == eTeam1 )
    {
        strTargetName     = TEAMASSAULT_TEAM1TARGETNAME;
        strTargetGlowName = TEAMASSAULT_TEAM1TARGETGLOWNAME;
    }
    else if( nTargetOwner == eTeam2 )
    {
        strTargetName     = TEAMASSAULT_TEAM2TARGETNAME;
        strTargetGlowName = TEAMASSAULT_TEAM2TARGETGLOWNAME;
    }
    else
    {
        __ASSERT_FALSE();    
        return 0;
    }
// tworzenie pomnika
    pTarget = m_pCurrentMission.CreateObject(strTargetName, m_arrTeamTargetX[nTargetOwner], m_arrTeamTargetY[nTargetOwner], 0, m_arrTeamTargetAngle[nTargetOwner]);
    pTarget.SetAttribute(TEAMASSAULT_TARGETOWNER, nTargetOwner); // czyj jelonek
    pTarget.SetPartyNum(nTargetOwner);
    m_arrTarget[nTargetOwner] = pTarget;
// tworzenie aury wokol pomnika
    TRACE("creating %s for team %d at %d, %d\n", strTargetGlowName, nTargetOwner, m_arrTeamTargetX[nTargetOwner], m_arrTeamTargetY[nTargetOwner]);
    pTargetGlow = m_pCurrentMission.CreateObject(strTargetGlowName, m_arrTeamTargetX[nTargetOwner], m_arrTeamTargetY[nTargetOwner], pTarget.GetLocationZ(), m_arrTeamTargetAngle[nTargetOwner]);
    m_arrTargetGlow[nTargetOwner] = pTargetGlow;
    return 1;    
}//--------------------------------------------------------------------------------------|

function int GetTeamStatueHealthPercent(int nTeamNum)
{
    if( nTeamNum != eTeam1 && nTeamNum != eTeam2 || nTeamNum >= m_arrTarget.GetSize() )
    {
        __ASSERT_FALSE();
        return 0;    
    }
    return 100 * m_arrTarget[nTeamNum].GetHP() / m_arrTarget[nTeamNum].GetMaxHP();
}//--------------------------------------------------------------------------------------|

function int GetTeamStatueDamagePercent(int nTeamNum)
{
    if( nTeamNum != eTeam1 && nTeamNum != eTeam2 || nTeamNum >= m_arrTarget.GetSize() )
    {
        __ASSERT_FALSE();
        return 0;    
    }
    return 100 - 100 * m_arrTarget[nTeamNum].GetHP() / m_arrTarget[nTeamNum].GetMaxHP();
}//--------------------------------------------------------------------------------------|

function int GetTeamStatueLocation(int nTeamNum, int &nX, int &nY)
{
    if( (nTeamNum < eTeam1) || (nTeamNum > eTeam2) || (nTeamNum >= m_arrTarget.GetSize()) )
    {
        __ASSERT_FALSE();
        return 0;    
    }
    nX = m_arrTarget[nTeamNum].GetLocationX();
    nY = m_arrTarget[nTeamNum].GetLocationY();
    return 1;
}//--------------------------------------------------------------------------------------|

function int GetTeamStatueMapSign(int nTeamNum, int &nMapSign)
{
    if( nTeamNum == eTeam1 )
    {
        nMapSign = eMapSignTeam1Statue;
    }
    else if( nTeamNum == eTeam2 )
    {
        nMapSign = eMapSignTeam2Statue;
    }
    else
    {
        __ASSERT_FALSE();
        return false;
    }
    return true;
}//--------------------------------------------------------------------------------------|

function void DistributePoints()
{
#ifdef _XBOX
    DistributeXBOXPoints_TeamAssault();
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
        DistributeEarthNetPlayerPoints(m_arrTeam1HeroNumber, m_arrTeam1RankPoints, m_arrTeam1KilledCount);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeEarthNetPlayerPoints(m_arrTeam2HeroNumber, m_arrTeam2RankPoints, m_arrTeam2KilledCount);
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

function void DistributeXBOXPoints_TeamAssault()
{
    if( m_nWinner == eTeam1 )
    {
        DistributeXBOXPoints_TeamAssault(m_arrTeam1HeroNumber, m_arrTeam2HeroNumber);
    }
    else if( m_nWinner == eTeam2 )
    {
        DistributeXBOXPoints_TeamAssault(m_arrTeam2HeroNumber, m_arrTeam1HeroNumber);
    }
}//--------------------------------------------------------------------------------------|

function void DistributeXBOXPoints_TeamAssault(int arrWinningHeroNum[], int arrLosingHeroNum[])
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
        GetCampaign().GetPlayerHeroUnit(arrWinningHeroNum[nIndex]).AddHeroNetworkGameModePoints(eGameModePointsFlagcapturing, nGamePoints);
        if (IsRankedGame())
        {
            strText.FormatTrl(TEXT_GETPOINTS, nGamePoints);
            ShowTextToPlayer(arrWinningHeroNum[nIndex], strText, eResultsConsoleTextTime, true);
        }
    }
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

function void ShowDestroyText()
{
    stringW strText;
    strText.Translate(TEXT_DESTROY);
    ShowTextToTeam(eTeam1, strText, eDestroyConsoleTextTime, false);
    ShowTextToTeam(eTeam2, strText, eDestroyConsoleTextTime, false);
}//--------------------------------------------------------------------------------------|

function void ShowTeamStatuesDamagedText()
{
    stringW strTeam1Percent, strTeam2Percent;
    stringW strTeam1ColoredPercent, strTeam2ColoredPercent;
    stringW strTeam1, strTeam2;
    stringW strTeam1Statue, strTeam2Statue;
    
    strTeam1Percent.Format("%d%%", GetTeamStatueDamagePercent(eTeam1) );
    strTeam2Percent.Format("%d%%", GetTeamStatueDamagePercent(eTeam2) );
    strTeam1ColoredPercent.FormatTrl(TEXT_TEAM1TEXT, strTeam1Percent);
    strTeam2ColoredPercent.FormatTrl(TEXT_TEAM2TEXT, strTeam2Percent);
    strTeam1.Translate(TEXT_TEAM1);
    strTeam2.Translate(TEXT_TEAM2);

    strTeam1Statue.FormatTrl(TEXT_TEAMSTATUEDAMAGED, strTeam1, strTeam1ColoredPercent );
    strTeam2Statue.FormatTrl(TEXT_TEAMSTATUEDAMAGED, strTeam2, strTeam2ColoredPercent );

    ShowBottomTextToAll(strTeam1Statue, eResultsConsoleTextTime, false);
    ShowBottomTextToAll(strTeam2Statue, eResultsConsoleTextTime, true);
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
event RemovedNetworkPlayer(int nPlayerNum)
{
    stringW strText;
    TRACE("TeamAssault::RemovedNetworkPlayer(%d)\n", nPlayerNum);
    
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
    // zniszczony jest posag i nie ma jeszcze zwyciezcy
    else if( uKilled.GetAttribute(TEAMASSAULT_TARGETOWNER, nStatueOwner) )
    {
        if( m_nWinner == eNoWinnerYet )
        {
            // atakowal monster
            if( !uAttacker.IsHeroUnit() )
            {
                if( nStatueOwner == eTeam1 )
                {
                    strTeam1Text.Translate(TEXT_YOURSTATUEDESTROYED);
                    strTeam2Text.Translate(TEXT_ENEMYSTATUEDESTROYED);
                }
                else if( nStatueOwner == eTeam2 )
                {
                    strTeam1Text.Translate(TEXT_ENEMYSTATUEDESTROYED);
                    strTeam2Text.Translate(TEXT_YOURSTATUEDESTROYED);
                }
                else
                {
                    __ASSERT_FALSE();
                }
            }
            // atakowal hero
            else
            {
                if( nStatueOwner == eTeam1 )
                {
                    strTeam1Text.FormatTrl(TEXT_YOURSTATUEDESTROYEDBY, m_arrHeroNames[nAttackHeroNum]);
                    strTeam2Text.FormatTrl(TEXT_ENEMYSTATUEDESTROYEDBY, m_arrHeroNames[nAttackHeroNum]);
                }
                else if( nStatueOwner == eTeam2 )
                {
                    strTeam1Text.FormatTrl(TEXT_ENEMYSTATUEDESTROYEDBY, m_arrHeroNames[nAttackHeroNum]);
                    strTeam2Text.FormatTrl(TEXT_YOURSTATUEDESTROYEDBY, m_arrHeroNames[nAttackHeroNum]);
                }
                else
                {
                    __ASSERT_FALSE();
                }
            }
            ShowTextToTeam(eTeam1, strTeam1Text, eKilledConsoleTextTime, true);
            ShowTextToTeam(eTeam2, strTeam2Text, eKilledConsoleTextTime, true);
            SetWinningTeam( GetOppositeTeam(nStatueOwner) );
            TRACE("Zniszczono posag zespolu (%d)\n", nStatueOwner);
        }
        if( m_arrTargetGlow[nStatueOwner] )
        {
            m_arrTargetGlow[nStatueOwner].RemoveObject();
        }
    }
    return true;
}//--------------------------------------------------------------------------------------|

////////////////////////////////////////////////////////////////////////////////
state Initialize
{
    TRACE("------------------------------------------------\n");
    TRACE("STATE: Initialize\n");
    TeamAssaultInit();

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
        InitTargets();
        InitTeamAssaultMapSigns();

        MoveTeamsToTeamStartMarkers();
        TRACE("STATE: Fight\n");
        ShowDestroyText();
        return Fight, 0;
    }
    return CountdownBeforeFight, 0;
}//--------------------------------------------------------------------------------------|

state Fight
{
    RespawnItems();
    RespawnTeamHeroesAtNoCondition();
    ShowTeamStatuesDamagedText();
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
            TRACE("%d vs %d (team assault)\n", m_arrTeam1HeroNumber.GetSize(), m_arrTeam2HeroNumber.GetSize());
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
    else if (!strCommand.CompareNoCase("PrintTeamStatueHealth"))
    {
        TRACE("Statue health: %d : %d\n", GetTeamStatueHealthPercent(eTeam1), GetTeamStatueHealthPercent(eTeam2) );
    }
    else if (!strCommand.CompareNoCase("KillBlueStatue"))
    {
        if( m_arrTarget[0] )
        {
            m_arrTarget[0].SetHP(0);
        }
    }
    else if (!strCommand.CompareNoCase("KillRedStatue"))
    {
        if( m_arrTarget[1] )
        {
            m_arrTarget[1].SetHP(0);
        }
    }
    else
    {
        return TeamBaseCommandDebug(strCommand);
    }
    return 1;
}//--------------------------------------------------------------------------------------|

}
