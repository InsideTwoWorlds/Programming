mission ""
{
#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Mission.ech"
#include "..\\..\\Common\\Levels.ech"


consts
{
    eMarkerHero = 1;
}


int nState;

stringW strText[6];

function void ChangeGateState(int nMarker, int bOpen)
{
    unit uGate;
    uGate = GetObjectMarker("MARKER_GATE",nMarker);
    if (uGate != null) {
            if(bOpen)
            {
                uGate.SetGateScriptOwnerUID(-1);
                uGate.SetAttribute("Open",0);
            }
            else 
            {
                uGate.SetGateScriptOwnerUID(GetScriptUID());
                uGate.SetAttribute("Open",2);
            }
            
    }
}
#ifndef _DEMO
state Initialize;
state Nothing;
state Idle;

state Initialize
{
    unit uGate;
    nState=0;
    GetPlayerInterface(0).FadeOutScreen(3*30,0,0,0);
    ChangeGateState(2,false);
    
    return Nothing, 2*30;
}

#define PrepareText(a) \
    if (GetPlayerInterface(0).IsLocalHeroXPadControlled()) \
        str.Format("translateXTutE01_%d",a+1); \
    else \
        str.Format("translateTutE01_%d",a+1); \
    strAdd.Translate(str); \
    strText.Format("<F6>%s",strAdd);

state Nothing
{
    stringW strText,strAdd;
    string str;
    unit uHero;
    unit uUnit;
    mission pMission;
    int nX,nY;
    
    uHero=GetHero();
    if(uHero.GetMission() != GetThis())
    {
        ChangeGateState(2,true);
        GetPlayerInterface(0).SetConsoleText("");
        return Idle,30;
    }
    
    if(nState==0)//text poruszaj postacia
    {
        PrepareText(0);
        GetPlayerInterface(0).SetConsoleText(strText);
        nState++;
        return state, 15;
    }
    else if(nState==1)// text dobrze
    {
        uHero=GetHero();
        uHero.GetLocation(nX,nY);
        nX/=256;
        nY/=256;
        if(nX<70 ||nX>70 ||nY<52||nY>52)
        {

            PrepareText(1);
            GetPlayerInterface(0).SetConsoleText(strText,2*30);
            nState++;
        }
        return state, 1*30;
    }
    else if(nState==2)// text wyciag bron 
    {
        PrepareText(2);
        GetPlayerInterface(0).SetConsoleText(strText);
        nState++;
        return state, 0;
    }
    else if(nState==3)// text otwórz brame i prejdze za nia
    {
    
        if(uHero.IsInArmedMode())
        {
            ChangeGateState(2,true);
            PrepareText(3);
            GetPlayerInterface(0).SetConsoleText(strText);
            nState++;
        }
        return state, 30;
    }
    else if(nState==4)// text odszukaj i rozwal gobliny
    {
        uHero.GetLocation(nX,nY);
        nX/=256;
        nY/=256;
        if(nY>54)
        {
            PrepareText(4);
            GetPlayerInterface(0).SetConsoleText(strText);
            nState++;
        }
        return state, 3*30;
    }
    else if(nState==5)// wyjdz na zewnatrz i odnajdz zleceniodawce.
    {
        pMission=uHero.GetMission();
        if(!pMission.IsUnitInArea(64*256,64*356,40*256,GetSinglePartyArray(ePartyBandits))) 
        {
            PrepareText(5);
          //  ChangeGateState(3,true);
          //  OpenGate(GetThis(), 3,false);
            
            
        //uUnit = pMission.GetObjectMarker("MARKER_GATE",3);
        //uUnit.SetGateOpen(true,false);
        
            
            
            GetPlayerInterface(0).SetConsoleText(strText);
            nState++;
        }
        return state, 3*30;
    }
    else if(nState==6)// znikniecie tekstu wyjdz na zewnatrz i odnajdz zleceniodawce.
    {
        uHero.GetLocation(nX,nY);
        nX/=256;
        nY/=256;
        if(nX>67 &&nX<71 && nY>33 && nY<37)
        {
            GetPlayerInterface(0).SetConsoleText("");
            nState++;
        }
        return state, 3*30;
    }
    return Idle,10*30;
}
#endif
state Idle
{
    return state,10*30;
}



}
