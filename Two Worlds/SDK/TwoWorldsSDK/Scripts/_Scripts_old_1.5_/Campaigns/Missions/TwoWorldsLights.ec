global "Lights Script"
{
    #include "..\\..\\Common\\Generic.ech"
    #include "..\\..\\Common\\Enums.ech"
    #include "..\\..\\Common\\Quest.ech"
        
consts
{
    eMaxLights =4;
    eLighTtime=5; //sec
}    
    
state Initialize;
state Nothing;

int anLightX[eMaxLights];
int anLightY[eMaxLights];
int anLastTime[eMaxLights];
int bTrace;

int nLTimer; 

function void ShowLight(mission pMission,unit uHero)
{
    int i,a,b,nX,nY,nDx,nDy,nAngle,nRadius;
    int nType;
    
    
    nLTimer++;
    for(i=0;i<eMaxLights;i++) 
    {
        if(anLastTime[i]+eLighTtime<nLTimer) break;
    }
    if(i==eMaxLights) return;
    
    uHero.GetLocation(nX,nY);
    
    nAngle = uHero.GetDirectionAlpha();
    
    nAngle += Rand(20)-10;// +-35stopni od kierunkiu patrzenia bohatera
    nRadius = 7+Rand(5); //16-44 metry
    
    if(uHero.IsMoving())
    {
        
        TurnRadiusByAngle(nRadius, nAngle, nDx, nDy);
        nX+=nDx*256;
        nY+=nDy*256;
    }
    else
    {
        if(IsDay())return;
        if(i%4==0){a=1;b=1;}
        if(i%4==1){a=-1;b=1;}
        if(i%4==2){a=1;b=-1;}
        if(i%4==3){a=-1;b=-1;}
    
        nX = nX+(a*(2+Rand(3))*256);
        nY = nY+(b*(2+Rand(3))*256);
    }
    
    nX=MIN(pMission.GetWorldWidth()-1,MAX(0,nX));
    nY=MIN(pMission.GetWorldHeight()-1,MAX(0,nY));
    
    // swiatelka tylko w lesie
    nType = pMission.GetEAXEnvironment( nX, nY);//
    if(nType>28)nType-=28;
    if(bTrace)
    {
       TRACE("EAX = %d ",nType);   
    }
    if(nType<6 && nType!=3&& nType!=4) {} else return;

    anLastTime[i]=nLTimer;
    if(IsDay())pMission.CreateObject("DAY_LIGHT",nX,nY,0,0);
    else pMission.CreateObject("NIGHT_LIGHT",nX,nY,0,0);
    
    //============= END fake ambient lights===============
    if(bTrace)
    {
        TRACE(" Light %d at  %d,%d  [%d]                                  \n",i,nX/256,nY/256,nLTimer);   
    }
    
}

function int IsMapType(mission pMission,int nType)
{
    int x;
    pMission.GetAttribute(WEATHER_TYPE_ATTR, x);
    if(x==nType)
    {
       return true;
    }
    return false;
}

state Initialize
{
    nLTimer=0;
    return Nothing,30;
}


state Nothing
{
    unit uHero;
    mission pMission;
    
    uHero = GetHeroMulti();
    
    if(uHero.IsObjectInHouse())return Nothing,30*5;
    pMission = uHero.GetMission();
    if(pMission.IsUndergroundLevel())return Nothing,30*5;
    if(IsMapType(pMission,eMapTypeDesert) &&IsDay())return Nothing,30*5;
    
    
    
    ShowLight(pMission,uHero);    
        return Nothing,30;
}



command CommandDebug(string strLine)
{
    if (!stricmp(strLine, "ltraceon"))
    {
        bTrace=true;
        TRACE("***************************        \n***   Light trace on ******        \n***************************        \n");
    }
    else if (!stricmp(strLine, "ltraceoff"))
    {
        bTrace=false;
        TRACE("***************************        \n***   Light trace off *****        \n***************************        \n");
    }
    else
    {
        return false;
    }
    return true;
}



}
