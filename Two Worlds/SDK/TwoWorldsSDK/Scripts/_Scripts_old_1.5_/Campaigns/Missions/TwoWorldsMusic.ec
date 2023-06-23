global "Music Script"
{

#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Enums.ech"
#include "..\\..\\Common\\Levels.ech"
#include "..\\..\\Common\\Messages.ech"
#include "..\\..\\Common\\LocalRand.ech"

// grane w swiatyni na poczatku gry
#define START_MUSIC            "MUSIC_1M3_OPEN_FOREST_SLOW_C"
// grane na koncu podczas walki z gandohare/palladynami
#define END_MUSIC              "MUSIC_11M1_END_CREDITS"
// defaultowy track
#define DEFAULT_MUSIC          "MUSIC_3M2_INSIDE_TOWNS_SLOW_B"
// towns, grane raz przy dojsciu do miasta
#define CATHALON               "MUSIC_8M1_CATHALON"
#define THARBAKIN              "MUSIC_5M1_THARBAKIN"
//#define QUDINAAR               "MUSIC_9M1_ASHOS"
//#define ASHOS                  "MUSIC_7M1_QUDINAAR"

#define ASHOS                  "MUSIC_9M1_ASHOS"  //wyglada ze te 2 tracki sa zamienione
#define QUDINAAR               "MUSIC_7M1_QUDINAAR"

// custom places, jw
#define GOBLINS_VILLAGE        "MUSIC_6M1_GOBLINS_VILLAGE"
#define GORGAMAAR              "MUSIC_10M1_GORGAMAAR"
// towns, zapetlone po zagraniu kawalka danego miasta
#define INSIDE_TOWNS_SLOW_A    "MUSIC_3M1_INSIDE_TOWNS_SLOW_A"
#define INSIDE_TOWNS_SLOW_B    "MUSIC_3M2_INSIDE_TOWNS_SLOW_B"
#define INSIDE_TOWNS_SLOW_C    "MUSIC_3M3_INSIDE_TOWNS_SLOW_C"
#define INSIDE_TOWNS_MEDIUM_A  "MUSIC_3M4_INSIDE_TOWNS_MEDIUM_A"
#define INSIDE_TOWNS_MEDIUM_B  "MUSIC_3M5_INSIDE_TOWNS_MEDIUM_B"
#define INSIDE_TOWNS_FAST      "MUSIC_3M7_INSIDE_TOWNS_FAST"
#define INSIDE_TOWNS_DANGEROUS "MUSIC_3M6_INSIDE_TOWNS_DANGEROUS"
// forest
#define OPEN_FOREST_SLOW_A     "MUSIC_1M1_OPEN_FOREST_SLOW_A"
#define OPEN_FOREST_SLOW_B     "MUSIC_1M2_OPEN_FOREST_SLOW_B"
#define OPEN_FOREST_SLOW_C     "MUSIC_1M3_OPEN_FOREST_SLOW_C"
#define OPEN_FOREST_MEDIUM_A   "MUSIC_1M4_OPEN_FOREST_MEDIUM_A"
#define OPEN_FOREST_MEDIUM_B   "MUSIC_1M5_OPEN_FOREST_MEDIUM_B"
#define FOREST_FAST            "MUSIC_1M7_FOREST_FAST"
#define FOREST_DANGEROUS       "MUSIC_1M6_FOREST_DANGEROUS"
// deadland
#define DEADLAND_SLOW_A        "MUSIC_2M1_DEADLAND_SLOW_A"
#define DEADLAND_SLOW_B        "MUSIC_2M2_DEADLAND_SLOW_B"
#define DEADLAND_SLOW_C        "MUSIC_2M3_DEADLAND_SLOW_C"
#define DEADLAND_MEDIUM_A      "MUSIC_2M4_DEADLAND_MEDIUM_A"
#define DEADLAND_MEDIUM_B      "MUSIC_2M5_DEADLAND_MEDIUM_B"
#define DEADLAND_FAST          "MUSIC_2M7_DEADLAND_FAST"
#define DEADLAND_DANGEROUS     "MUSIC_2M6_DEADLAND_DANGEROUS"
// desert
#define DESERT_SLOW_A          "MUSIC_4M1_DESERT_SLOW_A"
#define DESERT_SLOW_B          "MUSIC_4M2_DESERT_SLOW_B"
#define DESERT_SLOW_C          "MUSIC_4M3_DESERT_SLOW_C"
#define DESERT_MEDIUM_A        "MUSIC_4M4_DESERT_MEDIUM_A"
#define DESERT_MEDIUM_B        "MUSIC_4M5_DESERT_MEDIUM_B"
#define DESERT_FAST            "MUSIC_4M7_DESERT_FAST"
#define DESERT_DANGEROUS       "MUSIC_4M6_DESERT_DANGEROUS"
// cave
#define DEADLAND_SLOW_CAVE     "MUSIC_2M3-A_DEADLAND_SLOW_CAVE"
// misc
#define MAINTHEME              "MUSIC_1M0_MAINTHEME"

consts
{
// inne
    eTownMargin         = 8,    // dodatkowy obszar dookola miasta
    eCombatRange        = 10,   // odleglosc do markerow ponizej ktorej grany jest fast
// priorytety muzyki
    ePriorityUndefined  = 0,    // na poczatku albo jak track sie skonczy
    ePriorityNormal     = 1,    // melodia dla lasow, pustyni itd, nic sie nie dzieje w dzien lub w nocy
    ePriorityHigher     = 2,    // po wejsciu do miasta, wioski
    ePriorityHighest    = 3,    // po wejsciu do custom place'a i przy niebezpieczenstwie
    ePriorityStartTrack = 4,    // track startowy
    ePriorityEndTrack   = 4,    // track koncowy
// typy trackow
    eMusicForest        = 0,
    eMusicDesert        = 1,
    eMusicDeadLand      = 2,
    eMusicTown          = 3,
    eMusicCave          = 4,
    eMusicDefault       = eMusicForest,
}

/////////////////////////////////////////////////
state Initialize;
state PostInitialize;
state Nothing;

function void InitState();
function void InitMapTracks();
function void InitTownTracks();
function void InitMapAreas();
function void UpdateState();
function int StateCheck_IsDay();
function int StateCheck_GetMapType();
function int StateCheck_IsHeroInsideTown();
function int StateCheck_IsHeroInDanger();
function int StateCheck_IsHeroInCombat();
function int GetTownIndexWithHeroInside();
function int FindValue(int nVal, int arrArray[]);
function int ChooseAndPlayNewTrack();

function int PlayDedicatedTrackForTown();
function int PlayCommonTrackForTown();
function int PlayTrackForMapType(string arrTracks[], int arrIndices[]);
function int PlayRandom(string arrTracks[], int nStart, int nEnd, int nPriority);
function int Play(string strTrackName, int nTrackPriority);
function int IsPlaying();

function void __TraceTowns();
function void __TraceDangerousPlaces();
////////////////////////////////////////////////////////////

// tracks
string arrForestTracks[];
int    arrForestIndices[];
string arrDesertTracks[];
int    arrDesertIndices[];
string arrDeadLandTracks[];
int    arrDeadLandIndices[];
string arrCaveTracks[];
int    arrCaveIndices[];
string arrCommonTownTracks[];
int    arrCommonTownIndices[];

//towns
string arrTownTracks[];
int    arrTownMissionNum[];
int    arrTownType[];
int    arrTownX1[];
int    arrTownX2[];
int    arrTownY1[];
int    arrTownY2[];
int    arrTownPlayInsideTownTracks[];

// dangerous places
int    arrDangerousPlaceMissionNum[];
int    arrDangerousPlaceX[];
int    arrDangerousPlaceY[];
int    arrDangerousPlaceRange[];

// areas
int    arrDesertMissionNum[];
int    arrDeadLandMissionNum[];

// enemy markers
string arrEnemyMarkers[];

// current track
int nLevelType;
string strCurrentTrack;
int nCurrentTrackPriority;

// STAN GRY NA PODSTAWIE KTOREGO WYBIERANE SA TRACKI
int nDanger, nPrevDanger;         // niebezpieczne miejsce
int nCombat, nPrevCombat;         // walka
int nInsideTown, nPrevInsideTown; // wskazuje czy hero jest w miescie (lub jego poblizu)
int nMapType, nPrevMapType;       // typ srodowiska (forest, desert, deadland, cave)
int nDay, nPrevDay;               // pora dnia
// czy stan jest zmieniony
int nChangedDanger;
int nChangedState;
int nChangedCombat;
int nChangedInsideTown;
int nChangedMapType;
int nChangedDay;

int nDemonMarker;

/////////////////////////////////////////////////////////////////

function void InitState()
{
    strCurrentTrack = "";
    nCurrentTrackPriority = ePriorityUndefined;
    
    nDanger = false;
    nCombat = false;
    nInsideTown = false;
    nMapType = eMusicForest;
    nDay = true;
// i inne zmienne stanu...

    nChangedState = 0;
    
    nChangedDanger = 0;
    nChangedCombat = 0;
    nChangedInsideTown = 0;   
    nChangedMapType = 0;
    nChangedDay = 0;
}

// levele na ktorych beda grane tracki danego rodzaju
function void InitMapAreas()
{
    if( nLevelType != eSingleplayerMap )
    {
        return;    
    }
 // desert
    arrDesertMissionNum.Add( MIS(G8).GetMissionNum() );
    arrDesertMissionNum.Add( MIS(H8).GetMissionNum() );
    arrDesertMissionNum.Add( MIS(I8).GetMissionNum() );
    arrDesertMissionNum.Add( MIS(G9).GetMissionNum() );
    arrDesertMissionNum.Add( MIS(H9).GetMissionNum() );
    arrDesertMissionNum.Add( MIS(I9).GetMissionNum() );
// deadland
    // okolice Oswaroth
    arrDeadLandMissionNum.Add( MIS(G6).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(H6).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(I6).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(G7).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(H7).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(I7).GetMissionNum() );

    // okolice wulkanu, GorGamaar i Burnt Forest
    arrDeadLandMissionNum.Add( MIS(E11).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(F11).GetMissionNum() );

    arrDeadLandMissionNum.Add( MIS(D12).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(E12).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(F12).GetMissionNum() );

    arrDeadLandMissionNum.Add( MIS(G10).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(H10).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(I10).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(G11).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(H11).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(I11).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(G12).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(H12).GetMissionNum() );
    arrDeadLandMissionNum.Add( MIS(I12).GetMissionNum() );
}

// markery przy ktorych beda grane tracki 'fast'
function void InitEnemyMarkers()
{
    arrEnemyMarkers.Add("MARKER_ENEMY_UNDEAD");
    arrEnemyMarkers.Add("MARKER_ENEMY_DRAGON");
    arrEnemyMarkers.Add("MARKER_ENEMY_DRAGON2");
    arrEnemyMarkers.Add("MARKER_ENEMY_DRAGON3");
    arrEnemyMarkers.Add("MARKER_ENEMY_NECRO");
    arrEnemyMarkers.Add("MARKER_ENEMY_DAEMON");
    arrEnemyMarkers.Add("MARKER_ENEMY_HELLMASTER");
    arrEnemyMarkers.Add("MARKER_ENEMY_DEADKNIGHT");
    arrEnemyMarkers.Add("MARKER_ENEMY_OGR");
    arrEnemyMarkers.Add("MARKER_ENEMY_CYCLOPE");
    arrEnemyMarkers.Add("MARKER_ENEMY_HIDEOUS");
}

function void InitMapTracks()
{
    // miedzy 1 a 3 - noc
    // miedzy 2 a 4 - dzien
    // przed 5      - niebezpieczenstwo
    
    // 21.06.2007 zmiany:
    // FAST do walki
    // DANGEROUS za dnia
    arrForestIndices.Add( arrForestTracks.GetSize() );
        arrForestTracks.Add(OPEN_FOREST_SLOW_C);
    arrForestIndices.Add( arrForestTracks.GetSize() );
        arrForestTracks.Add(OPEN_FOREST_SLOW_B);
    arrForestIndices.Add( arrForestTracks.GetSize() );
        arrForestTracks.Add(OPEN_FOREST_SLOW_C);
        arrForestTracks.Add(OPEN_FOREST_MEDIUM_A);
        arrForestTracks.Add(OPEN_FOREST_MEDIUM_B);
        arrForestTracks.Add(FOREST_DANGEROUS);
    arrForestIndices.Add( arrForestTracks.GetSize() );
        arrForestTracks.Add(FOREST_FAST);
    arrForestIndices.Add( arrForestTracks.GetSize() );

    arrDesertIndices.Add( arrDesertTracks.GetSize() );
        arrDesertTracks.Add(DESERT_SLOW_A);
    arrDesertIndices.Add( arrDesertTracks.GetSize() );
        arrDesertTracks.Add(DESERT_SLOW_B);
        arrDesertTracks.Add(DESERT_SLOW_B);
        arrDesertTracks.Add(DESERT_SLOW_C);
        arrDesertTracks.Add(DESERT_SLOW_C);
        arrDesertTracks.Add(DESERT_MEDIUM_A);
        arrDesertTracks.Add(DESERT_MEDIUM_A);
        arrDesertTracks.Add(DESERT_MEDIUM_B);
    arrDesertIndices.Add( arrDesertTracks.GetSize() );
        arrDesertTracks.Add(DESERT_DANGEROUS);
    arrDesertIndices.Add( arrDesertTracks.GetSize() );
        arrDesertTracks.Add(DESERT_FAST);
    arrDesertIndices.Add( arrDesertTracks.GetSize() );
    
    arrDeadLandIndices.Add( arrDeadLandTracks.GetSize() );
        arrDeadLandTracks.Add(DEADLAND_SLOW_A);
    arrDeadLandIndices.Add( arrDeadLandTracks.GetSize() );
        arrDeadLandTracks.Add(DEADLAND_SLOW_B);
        arrDeadLandTracks.Add(DEADLAND_SLOW_B);
        arrDeadLandTracks.Add(DEADLAND_SLOW_C);
        arrDeadLandTracks.Add(DEADLAND_SLOW_C);
        arrDeadLandTracks.Add(DEADLAND_MEDIUM_A);
        arrDeadLandTracks.Add(DEADLAND_MEDIUM_B);
        arrDeadLandTracks.Add(DEADLAND_MEDIUM_B);
    arrDeadLandIndices.Add( arrDeadLandTracks.GetSize() );
        arrDeadLandTracks.Add(DEADLAND_DANGEROUS);
    arrDeadLandIndices.Add( arrDeadLandTracks.GetSize() );
        arrDeadLandTracks.Add(DEADLAND_FAST);
    arrDeadLandIndices.Add( arrDeadLandTracks.GetSize() );

    arrCommonTownIndices.Add( arrCommonTownTracks.GetSize() );
        arrCommonTownTracks.Add(INSIDE_TOWNS_SLOW_A);
    arrCommonTownIndices.Add( arrCommonTownTracks.GetSize() );
        arrCommonTownTracks.Add(OPEN_FOREST_SLOW_A); // muzyka jarmarczna, nie nadaje sie do miasta
        arrCommonTownTracks.Add(INSIDE_TOWNS_SLOW_B);
        arrCommonTownTracks.Add(INSIDE_TOWNS_SLOW_B);
        arrCommonTownTracks.Add(INSIDE_TOWNS_SLOW_C);
        arrCommonTownTracks.Add(INSIDE_TOWNS_MEDIUM_A);
        arrCommonTownTracks.Add(INSIDE_TOWNS_MEDIUM_A);
        arrCommonTownTracks.Add(INSIDE_TOWNS_MEDIUM_B);
    arrCommonTownIndices.Add( arrCommonTownTracks.GetSize() );
        arrCommonTownTracks.Add(INSIDE_TOWNS_DANGEROUS);
    arrCommonTownIndices.Add( arrCommonTownTracks.GetSize() );
        arrCommonTownTracks.Add(INSIDE_TOWNS_FAST);
    arrCommonTownIndices.Add( arrCommonTownTracks.GetSize() );

    arrCaveIndices.Add( arrCaveTracks.GetSize() );
        arrCaveTracks.Add(DEADLAND_SLOW_CAVE);
    arrCaveIndices.Add( arrCaveTracks.GetSize() );
        arrCaveTracks.Add(DEADLAND_SLOW_CAVE);
    arrCaveIndices.Add( arrCaveTracks.GetSize() );
    arrCaveIndices.Add( arrCaveTracks.GetSize() );
        arrCaveTracks.Add(DEADLAND_FAST);
    arrCaveIndices.Add( arrCaveTracks.GetSize() );
}

function void InitTownTracks()
{
    int i;
// przypisanie zdefinowanym miastom odpowieniego tracka
    for( i = 0; i < arrTownType.GetSize(); i++ )
    {
        if( arrTownType[i] == eTownTypeCathalon )
            arrTownTracks.Add(CATHALON);
        else if( arrTownType[i] == eTownTypeTharbakin )
            arrTownTracks.Add(THARBAKIN);
        else if( arrTownType[i] == eTownTypeQudinaar )
            arrTownTracks.Add(QUDINAAR);
        else if( arrTownType[i] == eTownTypeAshos )
            arrTownTracks.Add(ASHOS);
        else if( arrTownType[i] == eTownTypeGorGamar )
            arrTownTracks.Add(GORGAMAAR);
        else if( arrTownType[i] == eTownTypeGromsCamp )
            arrTownTracks.Add(GOBLINS_VILLAGE);
        else // miasto, wioska nieznana lub bez wlasnej muzyki
            arrTownTracks.Add("");
    }
#ifdef _DEBUG        
    __TraceTowns();
#endif// _DEBUG           
}

function void UpdateState()
{
    nPrevDanger     = nDanger;
    nDanger         = StateCheck_IsHeroInDanger();
    nPrevCombat     = nCombat;
    nCombat         = StateCheck_IsHeroInCombat();
    nPrevInsideTown = nInsideTown;
    nInsideTown     = StateCheck_IsHeroInsideTown();
    nPrevMapType    = nMapType;
    nMapType        = StateCheck_GetMapType();
    nPrevDay        = nDay;
    nDay            = StateCheck_IsDay();
// i inne zmienne stanu...

// sprawdzanie czy stan sie zmienil
    nChangedDanger       = !!(nPrevDanger ^ nDanger);
    nChangedCombat       = !!(nPrevCombat ^ nCombat);
    nChangedInsideTown   = !!(nPrevInsideTown ^ nInsideTown);
    nChangedMapType      = !!(nPrevMapType ^ nMapType);
    nChangedDay          = !!(nPrevDay ^ nDay);
// i inne zmienne stanu...
    nChangedState = nChangedDanger | nChangedCombat | nChangedInsideTown | nChangedMapType | nChangedDay;

    if( nChangedState )
    {
        TRACE("STATE CHANGED: dcimt %d%d%d%d%d   ", nChangedDanger, nChangedCombat, nChangedInsideTown, nChangedMapType, nChangedDay );
        TRACE("dng(%d, %d) cmb(%d, %d) twn(%d, %d) map(%d, %d) day(%d, %d)\n",
                                nPrevDanger,     nDanger,
                                nPrevCombat,     nCombat,
                                nPrevInsideTown, nInsideTown,
                                nPrevMapType,    nMapType,
                                nPrevDay,        nDay
// i inne zmienne stanu...
                                 );
    }
}

function int HasStateChanged()
{
    return nChangedState;
}

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

function int StateCheck_IsHeroInDanger()
{
    int i, nX, nY, nMinX, nMaxX, nMinY, nMaxY;
    unit uHero;
    int nMissionNum;
    
    if( nLevelType == eSingleplayerMap )
    {
        uHero = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum());
        nMissionNum = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetMission().GetMissionNum();
        for(i = 0; i < arrDangerousPlaceMissionNum.GetSize(); i++)
        {
            if( nMissionNum == arrDangerousPlaceMissionNum[i] ) // hero jest na levelu z tym miejscem
            {
                if( uHero.DistanceTo(G2A(arrDangerousPlaceX[i]),G2A(arrDangerousPlaceY[i])) < arrDangerousPlaceRange[i])
                {
                    return true;
                }
            }
        }
    }
    else
    {
        return false; // w multi nie bierzemy pod uwage
    }
    return false;
}

//////////////////////////////////////////////////////////////////

function int StateCheck_IsHeroInCombat()
{
    int i, nUnitCount, nMarkersCount;
    int nRange;
    unit uHero;
    int arrTarget[];
    mission pMission;

    uHero = GetCampaign().GetPlayerHeroUnit( GetLocalPlayerNum() );
    pMission = uHero.GetMission();
    nRange = eCombatRange * 256;
        
    nUnitCount = 0;     
    if(uHero.SearchUnits(nRange, uHero.GetEnemiesParties() ) )
        nUnitCount = uHero.GetSearchUnitsCount();
    uHero.ClearSearchUnitsArray();
    if( !nUnitCount )  // jezeli nie ma zadnych unitow w poblizu to nie ma zagrozenia
    {
        return 0;    
    }
    for(i = 0; i < arrEnemyMarkers.GetSize(); i++)
    {
        nMarkersCount = pMission.GetMarkersCountInRange(arrEnemyMarkers[i], uHero.GetLocationX(), uHero.GetLocationY(), nRange);
        if( nMarkersCount )
        {
            return 1;             // sa unity i sa markery wiec jest zagrozenie
        }
    }
    return 0;
}

//////////////////////////////////////////////////////////////////

function int StateCheck_IsHeroInsideTown()
{
    if( nLevelType == eSingleplayerMap )
    {
        if( GetTownIndexWithHeroInside() == -1 )
            return false;
        return true;
    }
    else if( nLevelType == eMultiplayerMapTown )
    {
        return true;
    }
    return false;
}

///////////////////////////////////////////////////////////////

function void StateCheck_GetMapType()
{
    unit uHero;
    mission pMission;
    int nX,nY;
    int nType;

    uHero = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum());
    uHero.GetLocation(nX, nY);
    pMission = uHero.GetMission();

    // jaskinia
    if( pMission.IsUndergroundLevel() )
       return eMusicCave;
    if( nLevelType == eSingleplayerMap )
    {
        // pustynia
        if( FindValue( pMission.GetMissionNum(), arrDesertMissionNum ) )
            return eMusicDesert;
        // deadland
        else if( FindValue( pMission.GetMissionNum(), arrDeadLandMissionNum ) )
            return eMusicDeadLand;
        // las
        else
            return eMusicForest;
    }
    else if( nLevelType == eMultiplayerMapTown )
    {
    }
    else if( nLevelType == eMultiplayerMapMission )
    {
        nType = pMission.GetEAXEnvironment(nX, nY);
        if( nType == 35 )
        {
            return eMusicDesert;
        }
        else if( nType == 39 )
        {
            return eMusicDeadLand;
        }
    }
    return eMusicDefault;
}

///////////////////////////////////////////////////////////////

function int StateCheck_IsDay()
{
    int nTime, nRet;
    nTime = GetCampaign().GetDayTime();
    if( nTime > 20 && nTime < 237)
        return true;
    return false;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

function int GetTownIndexWithHeroInside()
{
    int i, nX, nY, nMinX, nMaxX, nMinY, nMaxY;
    unit uHero;
    int nMissionNum;
    
    if( nLevelType == eSingleplayerMap )
    {
        uHero = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum());
        nMissionNum = GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetMission().GetMissionNum();
        for(i = 0; i < arrTownMissionNum.GetSize(); i++)
        {
            if( nMissionNum == arrTownMissionNum[i] ) // hero jest na levelu z miastem
            {
                nX = A2G( uHero.GetLocationX() );
                nY = A2G( uHero.GetLocationY() );
                if( (nX >= arrTownX1[i] - eTownMargin ) && (nY >= arrTownY1[i] - eTownMargin ) &&
                    (nX <= arrTownX2[i] + eTownMargin ) && (nY <= arrTownY2[i] + eTownMargin ) )
                    return i;
            }
        }
    }
    else if( nLevelType == eMultiplayerMapTown )
    {
        return 0; // tylko jedno miasto jest na liscie
    }
    return -1;
}

function int FindValue(int nVal, int arrArray[])
{
    int i;
    for(i = 0; i < arrArray.GetSize(); i++)
    {
        if( nVal == arrArray[i] )
            return true;
    }
    return false;
}

///////////////////////////////////////////////////////////////////////////////

function int ChooseAndPlayNewTrack()
{
    if( nInsideTown ) // jezeli bohater jest w miescie
    {
         if( nChangedInsideTown ) // i dopiero co do niego wszedl
            return PlayDedicatedTrackForTown();   // gramy utwor miasta
        return PlayCommonTrackForTown();// gramy losowy z puli miast i wsi
    }
    if( nMapType == eMusicForest )
        PlayTrackForMapType(arrForestTracks, arrForestIndices);
    else if( nMapType == eMusicDesert )
        PlayTrackForMapType(arrDesertTracks, arrDesertIndices);
    else if( nMapType == eMusicDeadLand )
        PlayTrackForMapType(arrDeadLandTracks, arrDeadLandIndices);
    else if( nMapType == eMusicCave )
        PlayTrackForMapType(arrCaveTracks, arrCaveIndices);
    return 0;
}

function int PlayDedicatedTrackForTown()
{
    int nTownIndex;

    nTownIndex = GetTownIndexWithHeroInside();
    // jezeli nie ma tracka dedykowanego to gramy losowy z puli miast i wsi    
    if( nTownIndex == -1 || arrTownTracks[nTownIndex].IsEmpty() )
        return PlayCommonTrackForTown(); 
    if( nLevelType == eSingleplayerMap )
    {
        // jezeli to miasto, to graj z priorytetem ePriorityHigher
        if( arrTownPlayInsideTownTracks[nTownIndex] )
            return Play(arrTownTracks[nTownIndex], ePriorityHigher);
    }
    // jezeli custom place to z ePriorityHighest
    return Play(arrTownTracks[nTownIndex], ePriorityHighest);
}

function int PlayCommonTrackForTown()
{
    int nTownIndex;

    nTownIndex = GetTownIndexWithHeroInside();
    
    // na wszelki wypadek
    if( nTownIndex == -1 )
    {
        return PlayTrackForMapType(arrForestTracks, arrForestIndices);
    }
    //graj common tracki dla miasta tylko w miastach a nie w custom places
    if( arrTownPlayInsideTownTracks[nTownIndex] )
    {
        return PlayTrackForMapType(arrCommonTownTracks, arrCommonTownIndices);
    }
    // tracki grane w miastach lub custom places po zagraniu kawalka dedykowanego
    // gorgamaar ma deadland
    // reszta (cathalon, tharbakin, ashos, qudinaar, grom camps) ma forest
    if( arrTownType[nTownIndex] == eTownTypeGorGamar )
    {
        return PlayTrackForMapType(arrDeadLandTracks, arrDeadLandIndices);
    }
    return PlayTrackForMapType(arrForestTracks, arrForestIndices);
}

function int PlayTrackForMapType(string arrTracks[], int arrIndices[])
{
    int nStart, nEnd;
    int nPriority;
    
    // ma wszelki wypadek
    if( (arrTracks.GetSize() == 0) || (arrIndices.GetSize() < 5) )
    {
        __ASSERT_FALSE();
        return Play(DEFAULT_MUSIC, ePriorityNormal);
    }
    
    if( nCombat )
    {
        nStart = nEnd = arrIndices[4] - 1;     // bierze tylko fast
        return Play(arrTracks[nStart], ePriorityHighest);
    }
    else if( nDanger )
    {
        // w miejscach niebezpiecznych gra tylko 1 track deadlandowy (cmentarze)
        return Play(DEADLAND_DANGEROUS, ePriorityHigher);
    }
    else
    {
        nStart = arrIndices[nDay];
        nEnd   = arrIndices[nDay + 2];
        if( nStart == nEnd)
        {
            return Play(arrTracks[nStart], ePriorityNormal);
        }
        return PlayRandom(arrTracks, nStart, nEnd, ePriorityNormal);
    }
    return 1;
}

function int PlayRandom(string arrTracks[], int nStart, int nEnd, int nPriority)
{
    int nIndex, nValue, nCnt;
    string arrAvailableTracks[];
    
    if( nStart > nEnd )
    {
        __ASSERT_FALSE();
        return 0;
    }

    for(nIndex = nStart; nIndex < nEnd; nIndex++)
    {
        arrAvailableTracks.Add(arrTracks[nIndex]);
    }
    // na wszelki wypadek
    if( arrAvailableTracks.GetSize() == 0 )
    {
        return Play(DEFAULT_MUSIC, nPriority);
    }
    nValue = local_rand(nEnd - nStart);
    if( nStart != nEnd ) // jezeli sa do wyboru co najmniej dwa utwory (ale moga byc takie same!)
    {
        nCnt = 0;
        while( !strcmp( arrAvailableTracks[nValue], strCurrentTrack) && (nCnt < arrAvailableTracks.GetSize()) ) // to losuj sposrod nich tak zeby sie nie powtarzaly
        {
            nValue = (nValue + 1) % arrAvailableTracks.GetSize();
            nCnt++;
        }
    }
    return Play(arrAvailableTracks[nValue], nPriority);
}

function int PlayEndFightTrack()
{
    return Play(END_MUSIC, ePriorityEndTrack);
}

function int Play(string strTrackName, int nTrackPriority)
{
    if( nCurrentTrackPriority > nTrackPriority )
    {
        TRACE("TRYING TO PLAY TRACK WITH LOWER PRIORITY: %s(%d)\n", strTrackName, nTrackPriority);
        return 0;
    }
    if( IsPlaying() && !strCurrentTrack.Compare(strTrackName) )
    {
        TRACE("TRYING TO PLAY CURRENT TRACK: %s\n", strTrackName);
        return 0;
    }
    if( strlen(strTrackName) == 0 )
    {
        TRACE("TRYING TO PLAY EMPTY TRACK\n");
        return 0;
    }

    strCurrentTrack = strTrackName;
    nCurrentTrackPriority = nTrackPriority;
    GetPlayerInterface(GetLocalPlayerNum()).PlayGameMusic(strCurrentTrack);    
    TRACE("PLAYING TRACK: %s with priority %d\n", strCurrentTrack, nCurrentTrackPriority);
    return 1;
}

function int Stop()
{
    GetPlayerInterface(GetLocalPlayerNum()).StopGameMusic();
    TRACE("STOP PLAYING TRACK\n", strCurrentTrack, nCurrentTrackPriority);
    return 1;
}

function int IsPlaying()
{
    return GetCampaign().GetPlayerInterface(GetLocalPlayerNum()).IsPlayingGameMusic();
}

function int IsMusicEnabled()
{
    return GetPlayerInterface(GetLocalPlayerNum()).IsPlayMusicEnabled();
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

state Initialize
{
    int i;
    nDemonMarker = 1;
    nLevelType = eSingleplayerMap; // domyslnie singleplayer

    local_srand(Rand(0x7FFF));

    ENABLE_TRACE(false);
    if( IsMusicEnabled() && IsPlaying() )
    {
        Stop(); // na wszelki wypadek
    }

    InitState();
    InitMapTracks();
    InitEnemyMarkers();
    return PostInitialize, 1; // potrzebne zeby przed wejsciem do nothing
}                             // zainicjowal miasta w skrypcie kampanii

state PostInitialize
{
    InitTownTracks();
    if( nLevelType == eSingleplayerMap )
    {
        InitMapAreas();
    }
    // jezeli to single i mapa ze swiatynia to graj tracka startowego
    if( IsMusicEnabled() && 
        (nLevelType == eSingleplayerMap) &&
        (GetCampaign().GetPlayerHeroUnit(GetLocalPlayerNum()).GetMission().GetMissionNum() == MIS(E1).GetMissionNum()) )
    {
        Play(START_MUSIC, ePriorityStartTrack);
    }
    return Nothing, 1;
}

state Nothing
{
    if( !IsMusicEnabled() )
    {
        return Nothing,30;
    }
    UpdateState();
    if( HasStateChanged() ) // stan sie zmienil
    {
        ChooseAndPlayNewTrack();
    }
    else if( !IsPlaying() ) // skonczyl sie track
    {
        TRACE("Track ended\n" );
        nCurrentTrackPriority = ePriorityUndefined;
        ChooseAndPlayNewTrack();
    }
    return Nothing,30;
}

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////

function void __TraceTowns()
{
    int i;
    string strTown;

    TRACE("MIASTA (%d):\n", arrTownMissionNum.GetSize());
    for( i = 0; i < arrTownMissionNum.GetSize(); i++ )
    {
        strTown = arrTownTracks[i];
        if( strTown.IsEmpty() )
           strTown = "<undefined>";
        TRACE("   -\"%s\" ", strTown );
        TRACE("num %d type %d play %d (%d, %d) (%d, %d)\n", arrTownMissionNum[i], arrTownType[i], arrTownPlayInsideTownTracks[i], arrTownX1[i], arrTownY1[i], arrTownX2[i], arrTownY2[i] );
    }
    
}

function void __TraceDangerousPlaces()
{
    int i;
    TRACE("NIEBEZPIECZNE MIEJSCA (%d):\n", arrDangerousPlaceMissionNum.GetSize());
    for( i = 0; i < arrDangerousPlaceMissionNum.GetSize(); i++ )
    {
        TRACE("   -num %d (%d, %d, %d)\n", arrDangerousPlaceMissionNum[i], arrDangerousPlaceX[i], arrDangerousPlaceY[i], arrDangerousPlaceRange[i]);
    }
    
}

function void AddEnemyMarker()
{
    unit uHero;
    mission pMission;
    int nX,nY;

    uHero = GetCampaign().GetPlayerHeroUnit(0);
    uHero.GetLocation(nX, nY);
    pMission = uHero.GetMission();
    
    pMission.AddMarker("MARKER_ENEMY_DAEMON", nDemonMarker++, nX, nY,0,0,"");
    
    TRACE("demon marker created\n");
    
}

function void CreateEnemy()
{
    int i, nX, nY;
    int arrMarkers[];
    mission pMission;
    unit uUnit;

    pMission = GetCampaign().GetPlayerHeroUnit(0).GetMission();
    pMission.FillMarkersNums("MARKER_ENEMY_DAEMON", arrMarkers);
    
    for(i = 0; i < arrMarkers.GetSize(); i++ )
    {
        if( pMission.GetMarker("MARKER_ENEMY_DAEMON", arrMarkers[i], nX, nY) )
        {
            uUnit = pMission.CreateObject("GOBLIN_01", nX, nY, 0, eFaceNorth);
            uUnit.SetPartyNum(ePartyEnemies);
        }   
    }
    TRACE("demons put on markers\n");
}

command CommandDebug(string strLine)
{
    string strCommand;
    unit pHero;
    UnitValues unVal;
    mission pMission;
    int nX, nY;
    
    strCommand = strLine;
    if (!strCommand.CompareNoCase("musicTraceOn"))
    {
        ENABLE_TRACE(true);
    }
    else if (!strCommand.CompareNoCase("musicTraceOff"))
    {
        ENABLE_TRACE(false);
    }
    else if( !strCommand.CompareNoCase("PrintIsPlaying") )
    {
        TRACE("%d\n", IsPlaying() );
    }
    else if( !strCommand.CompareNoCase("PrintCurrentTrack") )
    {
        TRACE("%s(%d)\n", strCurrentTrack, nCurrentTrackPriority);
    }
    else if( !strCommand.CompareNoCase("PrintEAXEnvironment") )
    {
        pHero    = GetCampaign().GetPlayerHeroUnit(0);
        pHero.GetLocation(nX, nY);
        pMission = pHero.GetMission();
        ENABLE_TRACE(true);
        TRACE("eax: %d\n", pMission.GetEAXEnvironment( nX, nY));
        ENABLE_TRACE(false);
    }
    else if( !strCommand.CompareNoCase("play1") )
    {
        return Play(THARBAKIN, ePriorityHighest);
    }
    else if( !strCommand.CompareNoCase("play2") )
    {
        return Play(DESERT_DANGEROUS, ePriorityHighest);
    }
    else if( !strCommand.CompareNoCase("play3") )
    {
        return Play(END_MUSIC, ePriorityHighest);
    }
    else if (!strnicmp(strCommand, "jump", strlen("jump")))
    {
        strCommand = strLine;
        strCommand.Mid(strlen("jump") + 1);
        strCommand.TrimLeft();
        pMission = GetMission(strCommand);
        if (pMission != null)
        {
            GetCampaign().GetPlayerHeroUnit(0).SetImmediatePosition(pMission, pMission.GetWorldWidth()/2, pMission.GetWorldHeight()/2, 0, 0, true);
        }
    }    
    else if( !strCommand.CompareNoCase("addmarker") )
    {
         AddEnemyMarker();
    }
    else if( !strCommand.CompareNoCase("putdemons") )
    {
         CreateEnemy();
    }
    else if( !strCommand.CompareNoCase("superman") )
    {
        pHero = GetCampaign().GetPlayerHeroUnit(0);
        unVal = pHero.GetUnitValues();
        unVal.SetBasicPoint(ePointsVitality, 10000);
        unVal.SetBasicPoint(ePointsStrength, 10000);
        unVal.SetBasicPoint(ePointsDexterity, 10000);
        unVal.SetBasicPoint(ePointsMagic, 10000);
        pHero.UpdateChangedUnitValues();        
    }
    else if( !strCommand.CompareNoCase("PrintTowns") )
    {
        __TraceTowns();
    }
    else if( !strCommand.CompareNoCase("PrintDangerousPlaces") )
    {
        __TraceDangerousPlaces();
    }
    else
        return false;    
    return true;    
}

command Message(int nParam)
{
    if( nParam == eMsgPlayEndFightTrack ) { PlayEndFightTrack(); return true; }
    return 0;
}

command Message(int nParam, int nValue)
{
    if( nParam == eMsgSetLevelType )        { nLevelType = nValue; }

    if( nParam == eMsgSetMissionNum )     { arrTownMissionNum.Add(nValue); return true;}
    if( nParam == eMsgSetTownType )       { arrTownType.Add(nValue); return true;}
    if( nParam == eMsgSetTownX1 )         { arrTownX1.Add(nValue); return true;}
    if( nParam == eMsgSetTownX2 )         { arrTownX2.Add(nValue); return true;}
    if( nParam == eMsgSetTownY1 )         { arrTownY1.Add(nValue); return true;}
    if( nParam == eMsgSetTownY2 )         { arrTownY2.Add(nValue); return true;}
    if( nParam == eMsgSetPlayInsideTown ) { arrTownPlayInsideTownTracks.Add(nValue); return true;}
    if( nParam == eMsgAddDesertMission )  { arrDesertMissionNum.Add(nValue); return true; }
    if( nParam == eMsgAddDeadLandMission ){ arrDeadLandMissionNum.Add(nValue); return true; }

    if( nParam == eMsgSetDangerousPlaceMissionNum ){ arrDangerousPlaceMissionNum.Add(nValue); return true;}
    if( nParam == eMsgSetDangerousPlaceX )         { arrDangerousPlaceX.Add(nValue); return true;}
    if( nParam == eMsgSetDangerousPlaceY )         { arrDangerousPlaceY.Add(nValue); return true;}
    if( nParam == eMsgSetDangerousPlaceRange )     { arrDangerousPlaceRange.Add(nValue); return true;}
    
    return 0;
}

}
