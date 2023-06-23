mission "Main menu"
{
state Idle;  

state Initialize
{
    //GetPlayerInterface(0).FadeOutScreen(3*30,0,0,0);
    GetCampaign().SetWind(20,0,"WEATHER_WIND_1",0);
    GetPlayerInterface(0).PlayCutscene(GetScriptUID(), 0, 
                     ePauseCallingScriptState | 
                     eDisableInterface | eHideInterface, 
                     GetThis(), "MainMenu2.trc");
    return Idle,0;
}

state Idle
{
    GetPlayerInterface(0).PlayCutscene(GetScriptUID(), 0, 
                     ePauseCallingScriptState | 
                     eDisableInterface | eHideInterface, 
                     GetThis(), "MainMenu2.trc");
    return state, 0;
}
}
