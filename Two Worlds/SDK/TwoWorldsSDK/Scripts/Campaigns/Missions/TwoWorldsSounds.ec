global "Sounds Script"
{
    #include "..\\..\\Common\\Generic.ech"
    #include "..\\..\\Common\\Enums.ech"
    #include "..\\..\\Common\\Quest.ech"
    #include "..\\..\\Common\\Levels.ech"
    #include "..\\..\\Common\\Messages.ech"
        
consts
{
    eFirstEAX = 0;
    
    eEndDeepNight = 15;
    eEndNight = 20;
    eEndMorning = 70;
    eEndDay =  200;
    eEndEvening = 237;
    eEndNightStart = 245;
}    
    
state Initialize;
state Nothing;

string asSounds[];
int anSoundLoops[];
int anSoundWeight[];
int anIndex[];
int anDelayMax[52]; //4*13 - zwiekszyc jak przybedzie EAXow
int anDelayMin[52];
int bTrace;
int nMultiplayer;
function void AddSoundMarker(string strSound, int nLoops, int nWeight)
{
    asSounds.Add(strSound);
    anSoundLoops.Add(nLoops);
    anSoundWeight.Add(nWeight);
}
function void SetEAXDelay(int nIndex,int nPhase, int nMin, int nMax)
{
anDelayMin[nPhase*nIndex]=nMin;
anDelayMax[nPhase*nIndex]=nMax-nMin;;
}

function int SoundObjectsCreated(mission pMission) 
{
    int nSOC;
    pMission.GetAttribute("SOC",nSOC);
    return nSOC;
}

function void SetSoundObjectsCreated(mission pMission, int nSOC)
{
    pMission.SetAttribute("SOC",nSOC);
}

#define L2M(a,b) Level2MissionNum(a,b,0)
//#define CSO(x,y) pMission.CreateSoundObject("AMB_MARK_RIVER",x << 8,y << 8,0,0,-1)
#define CSO(x,y) pMission.CreateObject("AMB_MARK_RIVER",x << 8,y << 8,0,0)

function void CreateSoundObjects(mission pMission)
{
//    string strMissionName;
    int nMission;
    if (nMultiplayer) 
    {
//        GetCampaign().CommandMessageGet(eMsgGetMissionName,strMissionName);               
    }   
    else
    {
        nMission = pMission.GetMissionNum();
        if (nMission == L2M('I',3)) 
        {
            CSO(119,57);
            CSO(51,71);
            CSO(91,58);
            CSO(1,63);
            CSO(23,62);
        }
        else if (nMission == L2M('H',3))
        {
            CSO(102,66);
            CSO(76,62);
            CSO(59,43);
            CSO(38,13);
            CSO(43,33);
        }
        else if (nMission == L2M('H',4))
        {
            CSO(28,124);
            CSO(15,109);
        }
        else if (nMission == L2M('G',4))
        {
            CSO(114,107);
            CSO(90,100);
            CSO(70,95);
            CSO(28,81);
            CSO(23,59);
            CSO(9,42);
        }
        else if (nMission == L2M('F',4))
        {
            CSO(118,57);
            CSO(89,35);
            CSO(54,15);
            CSO(107,39);
            CSO(75,18);
            CSO(35,6);
        }
        else if (nMission == L2M('F',5))
        {
            CSO(32,86);
            CSO(52,52);
            CSO(56,11);
            CSO(37,66);
            CSO(57,33);
        }
        else if (nMission == L2M('F',6))
        {
            CSO(48,120);
            CSO(18,92);
            CSO(25,52);
            CSO(65,26);
            CSO(96,0);
            CSO(33,108);
            CSO(15,71);
            CSO(42,37);
            CSO(75,8);
            CSO(77,35);
        }
        else if (nMission == L2M('F',7))
        {
            CSO(115,119);
            CSO(86,15);
            CSO(38,2);
            CSO(106,23);
            CSO(61,6);
        }
        else if (nMission == L2M('G',7))
        {
            CSO(4,105);
            CSO(6,60);
            CSO(8,84);
            CSO(0,37);
        }
        else if (nMission == L2M('F',8))
        {
            CSO(53,120);
            CSO(2,115);
        }
        else if (nMission == L2M('E',8))
        {
            CSO(97,119);
            CSO(106,81);
            CSO(63,63);
            CSO(29,69);
            CSO(106,102);
            CSO(90,65);
            CSO(46,78);
            CSO(27,100);
            CSO(9,109);
        }
        else if (nMission == L2M('C',8))
        {
            CSO(127,73);
            CSO(103,59);
            CSO(7,1);
            CSO(92,41);
            CSO(78,29);
            CSO(58,16);
            CSO(30,8);
        }
        else if (nMission == L2M('D',8))
        {
            CSO(127,62);
            CSO(120,41);
            CSO(103,10);
            CSO(90,10);
            CSO(86,99);
            CSO(66,11);
            CSO(42,15);
            CSO(108,100);
            CSO(18,20);
            CSO(13,4);
            CSO(125,108);
            CSO(4,48);
            CSO(18,62);
            CSO(33,78);
            CSO(52,82);
            CSO(72,97);
            CSO(13,90);
        }
        else if (nMission == L2M('C',9))
        {
            CSO(113,121);
            CSO(92,119);
            CSO(72,124);
            CSO(48,122);
            CSO(24,117);
            CSO(6,106);
        }
        else if (nMission == L2M('B',9))
        {
            CSO(103,119);
        }
        else if (nMission == L2M('B',10))
        {
            CSO(91,60);
        }
        
    } 
    
    SetSoundObjectsCreated(pMission,true);
    
}

function void InitializeSounds()
{
    int i, nType;
    
    SetEAXDelay(0,0, 4, 8);//poranek
    SetEAXDelay(0,1, 4, 8);//dzien
    SetEAXDelay(0,2, 4, 8);//pocz. nocy
    SetEAXDelay(0,3, 4, 8);//noc
    
    SetEAXDelay(1,0, 5, 9);
    SetEAXDelay(1,1, 4, 8);
    SetEAXDelay(1,2, 6, 9);
    SetEAXDelay(1,3, 5, 9);
    
    SetEAXDelay(2,0, 4, 8);
    SetEAXDelay(2,1, 4, 8);
    SetEAXDelay(2,2, 4, 8);
    SetEAXDelay(2,3, 4, 8);
    
    SetEAXDelay(3,0, 4, 8);
    SetEAXDelay(3,1, 4, 8);
    SetEAXDelay(3,2, 4, 8);
    SetEAXDelay(3,3, 4, 8);
    
    SetEAXDelay(4,0, 4, 8);
    SetEAXDelay(4,1, 4, 8);
    SetEAXDelay(4,2, 4, 8);
    SetEAXDelay(4,3, 4, 8);
    
    SetEAXDelay(5,0, 4, 8);
    SetEAXDelay(5,1, 4, 8);
    SetEAXDelay(5,2, 4, 8);
    SetEAXDelay(5,3, 4, 8);
    
    SetEAXDelay(6,0, 4, 8);
    SetEAXDelay(6,1, 4, 8);
    SetEAXDelay(6,2, 4, 8);
    SetEAXDelay(6,3, 4, 8);
    
    SetEAXDelay(7,0, 7, 11);
    SetEAXDelay(7,1, 6, 10);
    SetEAXDelay(7,2, 7, 11);
    SetEAXDelay(7,3, 6, 10);
    
    SetEAXDelay(8,0, 4, 8);
    SetEAXDelay(8,1, 4, 8);
    SetEAXDelay(8,2, 4, 8);
    SetEAXDelay(8,3, 4, 8);
    
    SetEAXDelay(9,0, 4, 8);
    SetEAXDelay(9,1, 4, 8);
    SetEAXDelay(9,2, 4, 8);
    SetEAXDelay(9,3, 4, 8);
    
    SetEAXDelay(10,0, 4, 8);
    SetEAXDelay(10,1, 4, 8);
    SetEAXDelay(10,2, 4, 8);
    SetEAXDelay(10,3, 4, 8);
    
    SetEAXDelay(11,0, 4, 8);
    SetEAXDelay(11,1, 4, 8);
    SetEAXDelay(11,2, 4, 8);
    SetEAXDelay(11,3, 4, 8);
    
    SetEAXDelay(12,0, 4, 8);
    SetEAXDelay(12,1, 4, 8);
    SetEAXDelay(12,2, 4, 8);
    SetEAXDelay(12,3, 4, 8);
    
    SetEAXDelay(13,0, 4, 8);
    SetEAXDelay(13,1, 4, 8);
    SetEAXDelay(13,2, 4, 8);
    SetEAXDelay(13,3, 4, 8);
    
    
    
    
// ????????     =====================================================    
    anIndex.Add(0);
    
    
    //                +---------------- nazwa markera z Passive
    //                |     +---------- ilosc loopow    
    //                |     |  +------- waga
    //                |     |  | 
    //EAX==0 Day
    AddSoundMarker("AMB_BIRD1",5,18);
    AddSoundMarker("AMB_BIRD_FOREST",8,18);
    AddSoundMarker("AMB_WOODPECKER",8,18);
    AddSoundMarker("AMB_WOODPECKER2",8,18);
    AddSoundMarker("AMB_SMALL_BIRD",8,27);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
   
   //EAX==0 Night deep
    AddSoundMarker("AMB_OWL2",8,17);
    AddSoundMarker("AMB_BAT_FLY",8,26);
    AddSoundMarker("AMB_BATS_VOICE",8,27);
    AddSoundMarker("AMB_OWL1",8,26);
    i=asSounds.GetSize();
    anIndex.Add(i);
   
//forest small==========================================================

      
    //EAX==1 Day
    AddSoundMarker("AMB_BIRD1",2,18);
    AddSoundMarker("AMB_BIRD_FOREST",2,27);
    AddSoundMarker("AMB_WOODPECKER",2,8);
    AddSoundMarker("AMB_WOODPECKER2",2,8);
    AddSoundMarker("AMB_SMALL_BIRD",8,22);
    i=asSounds.GetSize();
    anIndex.Add(i);
     
    //EAX==1 Night deep
    AddSoundMarker("AMB_OWL2",2,17);
    AddSoundMarker("AMB_BAT_FLY",2,26);
    AddSoundMarker("AMB_BATS_VOICE",2,27);
    AddSoundMarker("AMB_OWL1",2,26);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
//forest==============================================================

    
    //EAX==2 Day
    AddSoundMarker("AMB_BIRD_FOREST",2,20);
    AddSoundMarker("AMB_WOODPECKER",2,8);
    AddSoundMarker("AMB_WOODPECKER2",2,8);
    AddSoundMarker("AMB_BIRD_GRASS",3,21);
    AddSoundMarker("AMB_FROG",2,16);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
 
    //EAX==2 Night
    AddSoundMarker("AMB_GHOST",2,10);
    AddSoundMarker("AMB_WOLF_LOOP",1,4);
    AddSoundMarker("AMB_WOLF",2,6);
    AddSoundMarker("AMB_BATS_VOICE",2,16);
    AddSoundMarker("AMB_OWL1",2,16);
    AddSoundMarker("AMB_BATS2",2,16);
    AddSoundMarker("AMB_BAT_FLY",2,20);
    AddSoundMarker("AMB_OWL2",2,16);
    i=asSounds.GetSize();
    anIndex.Add(i);


// ????????     =====================================================
  
    //EAX==3 Day
    i=asSounds.GetSize();
    anIndex.Add(i);

   
    //EAX==3 Night
    i=asSounds.GetSize();
    anIndex.Add(i);
    
//valley green=======================================================

  
    //EAX==4 Day
    AddSoundMarker("AMB_BIRD_CREEPY",2,10);
    AddSoundMarker("AMB_LOON",2,14);
    AddSoundMarker("AMB_HAWK",2,20);
    AddSoundMarker("AMB_HAWK_1",2,20);
    AddSoundMarker("AMB_HAWK_2",2,20);
    AddSoundMarker("AMB_BIRD_HIGH",2,19);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
  
    //EAX==4 Night
    AddSoundMarker("AMB_BIRD_CREEPY",2,42);
    AddSoundMarker("AMB_NIGHT_BIRD",2,57);
    i=asSounds.GetSize();
    anIndex.Add(i);

// ????????     =====================================================

 
 //EAX==5 Day
    AddSoundMarker("AMB_BIRD_CREEPY",8,10);
    AddSoundMarker("AMB_LOON",8,15);
    AddSoundMarker("AMB_HAWK_1",8,18);
    AddSoundMarker("AMB_HAWK_2",8,18);
    AddSoundMarker("AMB_BIRD_HIGH",7,19);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
    //EAX==5 Night
    AddSoundMarker("AMB_BIRD_CREEPY",8,42);
    AddSoundMarker("AMB_NIGHT_BIRD",8,57);
    i=asSounds.GetSize();
    anIndex.Add(i);

 

//hills===========================================================

    //EAX==6 Day
    AddSoundMarker("AMB_HAWK",3,40);
    AddSoundMarker("AMB_HAWK_1",3,33);
    AddSoundMarker("AMB_HAWK_2",3,33);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
   
    //EAX==6 Night
    AddSoundMarker("AMB_OWL4",3,50);
    AddSoundMarker("AMB_BIRD_CREEPY",2,50);
    i=asSounds.GetSize();
    anIndex.Add(i);
//desert==========================================================AMB_bats3_11.wav

    //EAX==7 Day
    AddSoundMarker("AMB_BIRD_CREEPY",3,35);
    AddSoundMarker("AMB_BIRD_HIGH",2,30);
    AddSoundMarker("AMB_BATS3",2,51);
    i=asSounds.GetSize();
    anIndex.Add(i);
     //EAX==7 Night
    AddSoundMarker("AMB_OWL4",2,33);
    AddSoundMarker("AMB_BAT_VOICE",2,33);
    AddSoundMarker("AMB_BAT_FLY",2,33);
    i=asSounds.GetSize();
    anIndex.Add(i);
// ????????     =====================================================

   //EAX==8 Day
    i=asSounds.GetSize();
    anIndex.Add(i);

  
    //EAX==8 Night
    i=asSounds.GetSize();
    anIndex.Add(i);
  
//beach===========================================================

    //EAX==9 Day
    AddSoundMarker("AMB_BIRD_HIGH",3,100);
    i=asSounds.GetSize();
    anIndex.Add(i);
  
  //EAX==9 Night
    AddSoundMarker("AMB_OWL4",2,33);
    AddSoundMarker("AMB_BAT_VOICE",2,33);
    AddSoundMarker("AMB_BAT_FLY",2,33);
    i=asSounds.GetSize();
    anIndex.Add(i);

// ????????     =====================================================

    //EAX==10 Day
    i=asSounds.GetSize();
    anIndex.Add(i);
   //EAX==10 Night
    i=asSounds.GetSize();
    anIndex.Add(i);

// ????????     =====================================================

    //EAX==11 Day
    i=asSounds.GetSize();
    anIndex.Add(i);
 
    //EAX==11 Night
    i=asSounds.GetSize();
    anIndex.Add(i);

//meadow=====================================================

    //EAX==12 Day
    AddSoundMarker("AMB_CROW",2,8);
    AddSoundMarker("AMB_SMALL_BIRD",2,20);
    AddSoundMarker("AMB_VULTURE",2,9);
    AddSoundMarker("AMB_BIRD",2,20);
    AddSoundMarker("AMB_BIRD1",3,20);
    AddSoundMarker("AMB_LOON",2,12);
    i=asSounds.GetSize();
    anIndex.Add(i);
    
     //EAX==12 Night
    AddSoundMarker("AMB_bats3",2,17);
    AddSoundMarker("AMB_BATS",3,17);
    AddSoundMarker("AMB_BAT_FLY",2,24);
    AddSoundMarker("AMB_NIGHT_BIRD2",2,15);
    AddSoundMarker("AMB_NIGHT_BIRD",2,15);
    i=asSounds.GetSize();
    anIndex.Add(i);

//scarry======================================================


    //EAX==13 Day
    AddSoundMarker("AMB_GHOST_LONG",1,7);
    AddSoundMarker("AMB_GHOST_RARE",2,15);
    AddSoundMarker("AMB_GHOST",2,22);
    AddSoundMarker("AMB_BIRD_CREEPY",2,25);
    i=asSounds.GetSize();
    anIndex.Add(i);
     //EAX==13 Night
    AddSoundMarker("AMB_GHOST_LONG",1,7);
    AddSoundMarker("AMB_GHOST_RARE",1,15);
    AddSoundMarker("AMB_GHOST",1,22);
    AddSoundMarker("AMB_OWL3",3,25);

    i=asSounds.GetSize();
    anIndex.Add(i);
}
function int GetDayPhase()
{
    int nTime;
    nTime = GetCampaign().GetDayTime();
    
    
    //0 = morning, evening
    //1 - day
    //2 - start/end night
    //3 - night
    if(nTime>eEndNightStart) return 3;//noc
    if(nTime>eEndEvening) return 2;   //poczatek nocy
    if(nTime>eEndDay) return 1;       // wieczor
    if(nTime>eEndMorning) return 0;   //dzien
    if(nTime>eEndNight) return 1;    //poranek
    if(nTime>eEndDeepNight) return 2;// koniec nocy
    return 3; //noc
}


function int CalculateIndex(int nIndexLow,int nIndexHi)
{
    int i, nSum;
    
    nSum=0;
    for(i=nIndexLow;i<=nIndexHi;i++)nSum+=anSoundWeight[i];
    
    nSum=Rand(nSum);
    for(i=nIndexLow;i<=nIndexHi;i++)
    {
        if(nSum<anSoundWeight[i]) return i;
        nSum-=anSoundWeight[i];
    }
    return nIndexHi;
}
int nIndex;   
function void PlaySound(mission pMission,unit uHero)
{
    int i,nX,nY,nDx,nDy,nIndex,nIndexLow,nIndexHi;
    int nAngle,nRadius;
    int nType;//,nTime;
    string sSound;
    
//    nTime = GetCampaign().GetDayTime();
    uHero.GetLocation(nX,nY);

    nType = pMission.GetEAXEnvironment( nX, nY) - eFirstEAX;//
    if(bTrace)
    {
       TRACE("EAX = %d ",nType);   
    }
    //XXXMD wstawione na razie zanim nie zostana pomalowane plansze  12==meadow
    if(nType<1)nType=12;
    
    if(nType>28)nType-=28;

    
    
    nIndex = nType;
    
    nType*=2;
    if(!IsDay())nType++;
    
    
    
    if(nType >= anIndex.GetSize())return; 
    nIndexLow = anIndex[nType];
    nIndexHi = anIndex[nType+1]; //(p) tutaj zmienilem, bo indeks wychodzil -1
    if(nIndexHi>0)nIndexHi--;
    if(nIndexHi>=asSounds.GetSize())return; 
    if(nIndexLow==nIndexHi || nIndexHi<1) return;
    nIndex = CalculateIndex(nIndexLow,nIndexHi);
    
    // stworzenie  markera dzwiekowego  w rzestrzeni przed graczem     
    // liczenie nX ny zaleznego od ruchu bohatera -zrobic
    nAngle = uHero.GetDirectionAlpha();
    
    nAngle += Rand(50)-25;// +-35stopni od kierunkiu patrzenia bohatera
    nRadius = 7+Rand(5); //16-44 metry
    
    TurnRadiusByAngle(nRadius, nAngle, nDx, nDy);
    
    nX+=nDx*256;
    nY+=nDy*256;
    nX=MIN(pMission.GetWorldWidth()-1,MAX(0,nX));
    nY=MIN(pMission.GetWorldHeight()-1,MAX(0,nY));
    pMission.CreateSoundObject(asSounds[nIndex],nX,nY,0,0,anSoundLoops[nIndex]);
    if(bTrace)
    {
        TRACE("Time %d",GetDayPhase());
        TRACE("....%s x%d   at %d,%d [%d,%d]                                  \n",asSounds[nIndex],anSoundLoops[nIndex],nX/256,nY/256,nDx,nDy);   
    }
    
}
int nLastPhase;
state Initialize
{
    ENABLE_TRACE(true);
    InitializeSounds();
    nLastPhase=GetDayPhase();
    return Nothing,1;
}


state Nothing
{
    unit uHero, uSecondHero;
    mission pMission, pSecondMission;
    int nPhase;
    int nFirstIndex, nSecondIndex;
    int nOtherHeroIsNearby;

// granie dzwiekow dla wielu herosow - jezeli sa oddaleni conajmniej o 50 m
    for(nFirstIndex = 0; nFirstIndex < GetCampaign().GetPlayersCnt(); nFirstIndex++)
    {
        if( !IsPlayer(nFirstIndex) )
        {
            continue;    
        }
        
        uHero = GetCampaign().GetPlayerHeroUnit(nFirstIndex);
        pMission = uHero.GetMission();

        if (!SoundObjectsCreated(pMission))
        {
            CreateSoundObjects(pMission);            
        }
        
        if( uHero.IsObjectInHouse() )
            continue;
        if( pMission.IsUndergroundLevel() )
            continue;
    
        nOtherHeroIsNearby = false;
        for(nSecondIndex = 0; nSecondIndex < nFirstIndex; nSecondIndex++)
        {
            if( !IsPlayer(nSecondIndex) )
            {
                continue;
            }
            uSecondHero = GetCampaign().GetPlayerHeroUnit(nSecondIndex);
            pSecondMission = uSecondHero.GetMission();
            if( pMission == pSecondMission && uHero.DistanceTo(uSecondHero) < 50 * e1m )
            {
                nOtherHeroIsNearby = true;
                break;
            }
        }
        if( nOtherHeroIsNearby == false )
        {
            PlaySound(pMission,uHero);
        }
    }
    
    nPhase=GetDayPhase();
    if((nPhase==0 && nLastPhase==2)||(nPhase==2 && nLastPhase==0))
    {
        nLastPhase=nPhase;
        return Nothing, 60*30; // przerwa 60sec pomiedzy dniem a noca
    }
    
    nLastPhase=nPhase;
    nIndex*=nPhase;
    return Nothing,30*(anDelayMin[nIndex]+Rand(anDelayMax[nIndex]));
}

command Message(int nParam, int nValue) 
{
    if (nParam == eMsgSetMultiplayer)
    {
        nMultiplayer = nValue;
        return true;
    }
    return 0;   
}

command CommandDebug(string strLine)
{
    if (!stricmp(strLine, "straceon"))
    {
        bTrace=true;
        TRACE("***************************        \n***   Sound trace on ******        \n***************************        \n");
    }
    else if (!stricmp(strLine, "straceoff"))
    {
        bTrace=false;
        TRACE("***************************        \n***   Sound trace off *****        \n***************************        \n");
    }
    else
    {
        return false;
    }
    return true;
}



}
