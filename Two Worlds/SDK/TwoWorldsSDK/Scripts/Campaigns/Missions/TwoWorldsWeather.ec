global "Weather Script"
{
    #include "..\\..\\Common\\Generic.ech"
    #include "..\\..\\Common\\Quest.ech"
    #include "..\\..\\Common\\Levels.ech"
    //#include "..\\..\\Common\\MapData.ech"

#define CHANGE_TIME  300   
#define DELAY_TIME  305  

consts
{
    eWeatherClouds0 = 0;
    eWeatherClouds25 = 1;
    eWeatherClouds50 = 2;
    
    eWeatherDenseFog  = 3;
    eWeatherLightRain = 4;
    eWeatherStorm = 5;
    
    eLastWeather = 8;
    
    eWeatherDesert = 6;
    eWeatherSnow = 7;
    eWeatherBarrow = 8;
    eWeatherForest = 9;  //burntforest
    eWeatherClouds25near = 10;
    eWeatherClouds25Town = 11;
    eWeatherVolcano = 12;
    eWeatherSwamp=13;
    eUnderground=14;
    eWeatherTower=15;
    eWeatherOswaroth=16;
    

}
    
state Initialize;
state Nothing;
int bImmediateChange;
int bShowFogParticle;
int nTimer,nNextTimer,nNextSnowTimer,nCurrentWeather, nTimerWeather;
int nRainIntensity,nRainMaxIntensity;
int nWindForce, nCurrentWindForce, nCurrentWindDirection;
int bMapType;
int bInForest;



function int IsMapType(mission pMission,int nType)
{
    int x;
    pMission.GetAttribute(WEATHER_TYPE_ATTR, x);
    if(x==nType)
    {
       bMapType=nType;
       return true;
    }
    return false;
}

function void ChangeWeather(int nWeather)
{
    
    //if(nWeather == eWeatherClouds75) nWeather = eWeatherClouds0;
    //if(nWeather == eWeatherClouds100) nWeather = eWeatherClouds25;
   int nDelay;
    
    nDelay = CHANGE_TIME;
    if(bImmediateChange)
    {
        bImmediateChange=false;
        nDelay=1;
    }
    
    if(nWeather==nCurrentWeather)
    {
        TRACE("  ChangeWeatherTo : %d Cancelled: the same weather     \n",nWeather);
        return;
    }
    if(nWeather == eUnderground)
    {
        nCurrentWeather = nWeather;
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Underground-dark.cfg", true, true, 1);
        return;
    }
    
    if(GetCampaign().IsMorphingDayNightSkyTexture(30*30))
    {
        TRACE("  ChangeWeatherTo : %d Cancelled: morphing in progress     \n",nWeather);
        return;
    }
    TRACE("  ChangeWeatherTo : %d      \n",nWeather);
    nCurrentWeather = nWeather;
    
    
    nRainMaxIntensity=0;
    if(nDelay<30)GetCampaign().SetRain(nRainIntensity);
    
    nWindForce = 30+Rand(30);
    
    GetCampaign().SetSkyBoxColorFadeFromFog(false);
    if(nWeather == eWeatherSnow)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Snow.cfg", true, true, nDelay);
        GetCampaign().SetSnow(30+Rand(70));
        return;
    }
    GetCampaign().SetSnow(0);
    if(nWeather == eWeatherForest)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Forest.cfg", true, true, nDelay);
        GetCampaign().SetSkyBoxColorFadeFromFog(true);
        return;
    }
    else if(nWeather == eWeatherBarrow)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Barrow.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherOswaroth)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Oswaroth.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherTower)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Tower.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherVolcano)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Volcano.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherClouds0)
    {
        //LoadLevelConfiguration(CGameScriptObject* pObject, LPCTSTR pszConfigFile, int bLoadDayState, int bLoadSkyTextures, int nMorphTicks)
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Clouds0.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherClouds25)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Clouds25.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherClouds25near)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Clouds25near.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherClouds25Town)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Clouds25Town.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherClouds50)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Clouds50.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherDenseFog)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\DenseFog.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherSwamp)
    {
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Swamp.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherLightRain)
    {
        nRainMaxIntensity = 50;
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\LightRain.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherStorm)
    {
        nWindForce = 80+Rand(20);
        nRainMaxIntensity = 80;
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Storm.cfg", true, true, nDelay);
    }
    else if(nWeather == eWeatherDesert)
    {
        nWindForce = 40+Rand(40);
        GetCampaign().LoadLevelConfiguration("Editor\\WorldConf\\Desert.cfg", true, true, nDelay);
    }
}


function void LightingControl(mission pMission,unit uHero)
{
int i,nX,nY;


    if(nCurrentWeather != eWeatherStorm || Rand(6)) return; //to wolane co 5 s czyli srednio co 30 sekund blyskawica

    
    uHero.GetLocation(nX,nY);
    nX-=e16m;
    nX+=Rand(e16m);
    nX=CLAMP(nX, 0, pMission.GetWorldWidth()-1);
    nY-=e16m;
    nY+=Rand(e16m);
    nY=CLAMP(nY, 0, pMission.GetWorldHeight()-1);
    pMission.CreateObject("LIGHTING",nX,nY,0,0);
    TRACE("  Lighting at : %d %d      \n",A2G(nX), A2G(nY));
}

int nDustTimer;
int nRainFogTimer;
int nFogTimer;
    
function void DustControl(mission pMission,unit uHero)
{
    int i,j,nX,nY,x,y,nWidth,nHeight;
    if(!bShowFogParticle)return;
    if(nCurrentWeather != eWeatherDesert || uHero.IsObjectInHouse()) return; //to wolane co 1 s czyli co 5 sekund fog
    
    uHero.GetLocation(nX,nY);
    nWidth=pMission.GetWorldWidth();
    nHeight=pMission.GetWorldHeight();
    for(i=-4;i<=4;i++)
    for(j=-4;j<=4;j++)
    {
        x=nX+i*e20m; y=nY+j*e20m;
        if(x>0 &&x<nWidth && y>0 &&y<nHeight)
            pMission.CreateObject("DESERT_DUST",x,y,0,0);
    }
    
    if(!Rand(4))
    {
        i=Rand(3)-1;
        x=nX+i*e40m;
        if(i!=0) i=Rand(3)-1; else i=1;
        y=nY+i*e40m;
        if(x>0 &&x<nWidth && y>0 &&y<nHeight)
        {
            i=Rand(3);
            if(i==0)pMission.CreateObject("SAND_TWISTER1",x,y,0,0);
            else if(i==2)pMission.CreateObject("SAND_TWISTER2",x,y,0,0);
            else pMission.CreateObject("SAND_TWISTER3",x,y,0,0);
        }
    }
}

function void FogControl(mission pMission,unit uHero)
{
    int i,j,nX,nY,x,y,nWidth,nHeight;
    if(!bShowFogParticle)return;
    if(((nCurrentWeather != eWeatherDenseFog && 
        nCurrentWeather != eWeatherBarrow && 
        nCurrentWeather != eWeatherForest &&
        nCurrentWeather != eWeatherTower &&
        nCurrentWeather != eWeatherOswaroth))
    || uHero.IsObjectInHouse()) return; //to wolane co 1 s czyli co 5 sekund fog
    
    uHero.GetLocation(nX,nY);
    nWidth=pMission.GetWorldWidth();
    nHeight=pMission.GetWorldHeight();
    TRACE("  Create DenseFog at: %d,%d      \n",A2G(nX), A2G(nY));
    for(i=-1;i<=1;i++)
    for(j=-1;j<=1;j++)
    {
        x=nX+i*e45m; y=nY+j*e45m;
        if(x>0 &&x<nWidth && y>0 &&y<nHeight)
            pMission.CreateObject("DENSE_FOG",x,y,0,0);
    }
}

function void RainFogControl(mission pMission,unit uHero)
{
    int i,j,nX,nY,x,y,nWidth,nHeight;
    if(!bShowFogParticle) return;
    if(nRainIntensity<40 || uHero.IsObjectInHouse()) return;
    nRainFogTimer++;
    if(nRainFogTimer<5)return;
    nRainFogTimer=0;
    
    uHero.GetLocation(nX,nY);
    nWidth=pMission.GetWorldWidth();
    nHeight=pMission.GetWorldHeight();
    TRACE("  Create RainFog at: %d,%d      \n",A2G(nX), A2G(nY));
    for(i=-1;i<=1;i++)
    for(j=-1;j<=1;j++)
    {
        x=nX+i*e40m; y=nY+j*e40m;
        if(x>0 &&x<nWidth && y>0 &&y<nHeight)
            pMission.CreateObject("RAIN_FOG",x,y,0,0);
        
    }
}




//

function void RainControl()
{
    if(nRainIntensity==nRainMaxIntensity)return;
    
    if(nRainIntensity<nRainMaxIntensity)
    {
        nRainIntensity+=10;
        nRainIntensity = MIN(nRainMaxIntensity,nRainIntensity);
    }
    if(nRainIntensity>nRainMaxIntensity)
    {
        nRainIntensity-=10;
        nRainIntensity = MAX(0,nRainIntensity);
    }
    /*
    WEATHER_RAIN_BIG_OPEN
    WEATHER_RAIN_FOREST 
    WEATHER_RAIN_MEDIUM
    WEATHER_RAIN_SMALL
*/
    GetCampaign().SetRain(nRainIntensity);
    if(nRainIntensity<50)GetCampaign().SetRainWav("WEATHER_RAIN_SMALL", 255);
    else if(nRainIntensity<150)GetCampaign().SetRainWav("WEATHER_RAIN_MEDIUM", 255);
    else if(nRainIntensity<200)GetCampaign().SetRainWav("WEATHER_RAIN_FOREST", 255);
    else GetCampaign().SetRainWav("WEATHER_RAIN_BIG_OPEN", 255);
    GetCampaign().SetRainWavVolume(255);
    //GetCampaign().SetRainWavVolume(nRainIntensity);
    TRACE("  SetRain : %d      \n",nRainIntensity);
}
function void WindControl()
{
    nCurrentWindDirection=(nCurrentWindDirection+Rand(3)-1)%255;
    if(nWindForce>nCurrentWindForce)nCurrentWindForce++;
    if(nWindForce<nCurrentWindForce)nCurrentWindForce--;
    
    if(nCurrentWindForce<40)                              GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_1",255);
    else if(nCurrentWindForce>=40 &&nCurrentWindForce<45) GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_2",255);
    else if(nCurrentWindForce>=45 &&nCurrentWindForce<55) GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_3",255);
    else if(nCurrentWindForce>=55 &&nCurrentWindForce<70) GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_4",255);
    else if(nCurrentWindForce>=70 &&nCurrentWindForce<90) GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_5",255);
    else if(nCurrentWindForce>=90 &&nCurrentWindForce<98) GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_6",255);
    else if(nCurrentWindForce>=98)                        GetCampaign().SetWind(nCurrentWindForce,nCurrentWindDirection,"WEATHER_WIND_7",255);
    
    //GetCampaign().SetWindWavVolume(nCurrentWindForce);
}


function int IsInForest(mission pMission,unit uHero)
{
    int nType,nX,nY;
    uHero.GetLocation(nX,nY);
    nType = pMission.GetEAXEnvironment( nX, nY);//
    if(nType>28)nType-=28;
    if(nType<6 && nType!=3&& nType!=4) return true;  // las, las duzy, dolina skalista
    return false;
}
function int IsInTown(mission pMission,unit uHero)
{
    int nType,nX,nY;
    uHero.GetLocation(nX,nY);
    nType = pMission.GetEAXEnvironment( nX, nY);//
    if(nType>28)nType-=28;
    if(nType==8) return true;  // las, las duzy, dolina skalista
    return false;
}

function int IsPentagramActive()
{
    int i;
    int nPentagramActive;
    for (i = 0; i < GetCampaign().GetGlobalScriptsCnt(); i++) GetCampaign().GetGlobalScript(i).CommandMessageGet(eMsgIsPentagramActive,nPentagramActive);    
    return nPentagramActive;
}


int bInDungeon;
int bBrighter;
state Initialize
{
    bShowFogParticle=true;
    nRainFogTimer=5;
    nFogTimer=5;
    nDustTimer=9;
    SetTimer(0,3*60*30);//co 3 min zmiana pogody
    SetTimer(1,5);//co 5 tickow sprawdzanie czy ie wyszedl na powierzchnie
    SetTimer(2,5*30);//co 5 sec fog control
    nTimer=0;
    nNextTimer=0;
    nNextSnowTimer=0;
    nCurrentWeather=-1;
    nCurrentWindDirection=0;
    nWindForce=10;
    nCurrentWindForce=10;
    bInDungeon=false;
    bImmediateChange=false;
    bInForest=false;
    ENABLE_TRACE(false);
    GetCampaign().SetRainWav("WEATHER_RAIN_MEDIUM", 255);
    GetCampaign().SetWindWav("WEATHER_WIND_2", 255);
    /*
    SetWind(vol, dir);
    SetWind(vol, dir, "wave", waveVolume);
    SetWindWav("wave", waveVolume);
    SetWindWavVolume(waveVolume);
    SetRain(vol);
    SetRain(vol, "wave", waveVolume);
    SetRainWav("wave", waveVolume);
    SetRainWavVolume(waveVolume);
    */
    
    nNextTimer = 5*60;//zmiana pogody co 3-5 minut 
    ChangeWeather(eWeatherClouds25); 
    bBrighter=false;
    return Nothing,1;
}

event Timer1()
{
    
    unit uHero;
    mission pMission;
    
    uHero = GetHeroMulti();
    
    pMission = uHero.GetMission();
    if(pMission.IsUndergroundLevel())
    {
        if(!bInDungeon){SetStateDelay(1);nNextTimer=0;}
    }
    else 
    {
        if(bInDungeon){SetStateDelay(1);nNextTimer=0;}
    }
    return false;    
}
event Timer2()//co 5 sec
{
    
    unit uHero;
    mission pMission;
    
    uHero = GetHeroMulti();
    pMission = uHero.GetMission();
    if(pMission.IsUndergroundLevel())return false;
    LightingControl(pMission,uHero);
    RainControl();
    RainFogControl(pMission, uHero);
    FogControl(pMission, uHero);
    DustControl(pMission,uHero);
    return false;    
}

state Nothing
{
    unit uHero;
    mission pMission;
    uHero = GetHeroMulti();
    
    pMission = uHero.GetMission();
    if(pMission.IsUndergroundLevel())
    {
        ChangeWeather(eUnderground);
        bInDungeon=true;
        bMapType=0;
        return Nothing,5;
    }
    else if(bInDungeon)
    {
        bImmediateChange=true;
        bInDungeon=false;
        nNextTimer=0;        
    }
    
    if(uHero.IsObjectInHouse())return Nothing,30*5;
    
    if(!IsMapType(pMission,bMapType))
    {
        nNextTimer=0;        
    }
    if(IsPentagramActive())
    {
        ChangeWeather(eWeatherTower); 
        FogControl(pMission, uHero);
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    
    if(IsInForest(pMission, uHero))
    {
        if(!bInForest){nNextTimer=0;bInForest=true; }
    }
    else
        if(bInForest){nNextTimer=0;bInForest=false; }
    
    
    WindControl();
    
    if(IsInTown(pMission, uHero))
    {
        ChangeWeather(eWeatherClouds25Town);
        return Nothing,CHANGE_TIME;
    }
    
    if(IsMapType(pMission,eMapTypeCommon))
    {
        
    }
    else if(IsMapType(pMission,eMapTypeDesert))
    {
        ChangeWeather(eWeatherDesert); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeStart))
    {
        ChangeWeather(eWeatherClouds0); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeOswaroth))
    {
        ChangeWeather(eWeatherOswaroth); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeTower))
    {
        ChangeWeather(eWeatherTower); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeVolcano))
    {
        ChangeWeather(eWeatherVolcano); 
        //DustControl(pMission,uHero);
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeSwamp))
    {
        ChangeWeather(eWeatherSwamp); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeSnow))
    {
        ChangeWeather(eWeatherSnow); 
        nNextTimer=0;
        if(nTimer<nNextSnowTimer)
        {
            nTimer++;
            return Nothing,DELAY_TIME;
        }
        nNextSnowTimer = 60;
        GetCampaign().SetSnow(10+Rand(90));
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeBarrow))
    {
        ChangeWeather(eWeatherBarrow); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeDenseFog))
    {
        ChangeWeather(eWeatherDenseFog); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    else if(IsMapType(pMission,eMapTypeForest))//burnt forest
    {
        ChangeWeather(eWeatherForest); 
        nNextTimer=0;
        return state,DELAY_TIME;   
    }
    
    if(nTimer<nNextTimer)
    {
        nTimer++;
        return Nothing,30;
    }
    nTimer = 0;
    nNextTimer = 60*(7+Rand(6));//zmiana pogody co 7-12 minut 
    
    if(IsMapType(pMission,eMapTypeVillage) && nTimerWeather>eWeatherDenseFog)nTimerWeather=eWeatherDenseFog;
    
    if(bInForest && nTimerWeather<=eWeatherClouds50) ChangeWeather(eWeatherClouds25near);
    else ChangeWeather(nTimerWeather);    
    
    return Nothing,DELAY_TIME;
}

event Timer0()
{
    if(!Rand(5))//  brzydka pogoda  
    {
       nTimerWeather = eWeatherDenseFog+Rand(3);    
    }
    else // ladna pogoda
    {
       nTimerWeather = Rand(eWeatherClouds50);    
    }
    return true;    
}
command CommandDebug(string strLine)
{
    
    if (!stricmp(strLine, "FogOff"))
    {
        bShowFogParticle=false;
    }
    else if (!stricmp(strLine, "FogOn"))
    {
        bShowFogParticle=true;
    }
    else if (!stricmp(strLine, "Brighter"))
    {
        bBrighter=true;
    }
    else if (!stricmp(strLine, "Darker"))
    {
        bBrighter=false;
    }
    else if (!stricmp(strLine, "Clouds0"))
    {
        nTimerWeather=eWeatherClouds0;
        ChangeWeather(eWeatherClouds0);    
    }
    else if (!stricmp(strLine, "Clouds25"))
    {
        nTimerWeather=eWeatherClouds25;
        ChangeWeather(eWeatherClouds25);    
    }
    else if (!stricmp(strLine, "Clouds25n"))
    {
        nTimerWeather=eWeatherClouds25near;
        ChangeWeather(eWeatherClouds25near);    
    }
    else if (!stricmp(strLine, "Clouds50"))
    {
        nTimerWeather=eWeatherClouds50;
        ChangeWeather(eWeatherClouds50);    
    }
    else if (!stricmp(strLine, "Storm"))
    {
        nTimerWeather=eWeatherStorm;
        ChangeWeather(eWeatherStorm);    
    }
    else if (!stricmp(strLine, "Snow"))
    {
        nTimerWeather=eWeatherSnow;
        ChangeWeather(eWeatherSnow);    
    }
    else if (!stricmp(strLine, "DenseFog"))
    {
        nTimerWeather=eWeatherDenseFog;
        ChangeWeather(eWeatherDenseFog);    
    }
    else if (!stricmp(strLine, "wtraceon"))
    {
    
     ENABLE_TRACE(true);
    }
    else if (!stricmp(strLine, "wtraceoff"))
    {
     
     ENABLE_TRACE(false);
    }
    else
    {
        return false;
    }
    return true;
}

}
