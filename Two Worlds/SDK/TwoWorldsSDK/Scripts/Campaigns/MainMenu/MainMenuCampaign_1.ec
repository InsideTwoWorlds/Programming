campaign "Main Menu"
{
state Initialize;
state Nothing;

state Initialize {
    
    SetLevelsHorizon("Levels\\horizont.hor");
    CreateMission("Levels\\MainMenu2.lnd", "Scripts\\Campaigns\\Missions\\MainMenuMission.eco", 0);
    GetMission(0).SetHorizonOffset(-450,900);
    GetMission(0).LoadLevel();
    
    SetDayTime(180);
    return Nothing;
    
}

state Nothing {

	return Nothing,0;

}
}
