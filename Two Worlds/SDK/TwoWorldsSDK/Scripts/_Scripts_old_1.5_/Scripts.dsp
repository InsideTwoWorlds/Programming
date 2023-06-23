# Microsoft Developer Studio Project File - Name="Scripts" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Generic Project" 0x010a

CFG=Scripts - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Scripts.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Scripts.mak" CFG="Scripts - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Scripts - Win32 Debug" (based on "Win32 (x86) Generic Project")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
MTL=midl.exe
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# Begin Target

# Name "Scripts - Win32 Debug"
# Begin Group "Common"

# Begin Source File

SOURCE=.\Common\Achievements.ech

# End Source File
# Begin Source File

SOURCE=.\Common\CreateStrings.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Debug.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Enemies.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Enums.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Generic.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Ghosts.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Guilds.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Levels.ech

# End Source File
# Begin Source File

SOURCE=.\Common\LocalRand.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Lock.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Messages.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Mission.ech

# End Source File
# Begin Source File

SOURCE=.\Common\NPCAndEnemies.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Party.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Quest.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Shops.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Stealing.ech

# End Source File
# Begin Source File

SOURCE=.\Common\Treners.ech

# End Source File
# Begin Source File

SOURCE=.\Common\UnitInfo.ech

# End Source File
# End Group
# Begin Group "Campaigns"

# Begin Group "TwoWorlds"

# Begin Source File

SOURCE=.\Campaigns\Missions\EmptyMission.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Campaigns\Missions\EmptyMission.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Campaigns\Missions\EmptyMission.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\missions\Mission_E01.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\missions\Mission_E01.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\missions\Mission_E01.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Campaigns\Missions\TwoWorldsAchievements.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Campaigns\Missions\TwoWorldsAchievements.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Campaigns\Missions\TwoWorldsAchievements.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Campaigns\TwoWorldsCampaign.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Campaigns\TwoWorldsCampaign.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Campaigns\TwoWorldsCampaign.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\TwoWorldsContainers.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsContainers.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsContainers.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\TwoWorldsEnemies.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsEnemies.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsEnemies.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Campaigns\Missions\TwoWorldsHeroControl.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Campaigns\Missions\TwoWorldsHeroControl.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Campaigns\Missions\TwoWorldsHeroControl.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\TwoWorldsLights.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsLights.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsLights.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Campaigns\Missions\TwoWorldsMusic.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Campaigns\Missions\TwoWorldsMusic.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Campaigns\Missions\TwoWorldsMusic.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\TwoWorldsSounds.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsSounds.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsSounds.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\TwoWorldsTeleports.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsTeleports.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsTeleports.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\TwoWorldsWeather.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsWeather.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\TwoWorldsWeather.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "Pienia"

# Begin Group "Inc"

# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PActivity.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PCamps.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PCommon.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PContainers.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PCrime.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PDailyState.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PEnums.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PFileParser.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PGates.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PGreetings.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PGuard.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PLocations.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PMission.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PQuestActions.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PQuestLoader.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PQuestsCommon.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PQuestUnits.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PRewards.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PTownGenerator.ech

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PInc\PUnitInfo.ech

# End Source File
# End Group
# Begin Source File

SOURCE=.\campaigns\Missions\PBandits.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\PBandits.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\PBandits.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PDialogUnits.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\PDialogUnits.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\PDialogUnits.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PNames.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\PNames.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\PNames.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PQuests.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\PQuests.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\PQuests.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PQuestsMulti.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\PQuestsMulti.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\PQuestsMulti.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\Missions\PTown.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\Missions\PTown.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\Missions\PTown.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "MainMenu"

# Begin Source File

SOURCE=.\campaigns\MainMenu\MainMenuCampaign_1.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\MainMenu\MainMenuCampaign_1.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\MainMenu\MainMenuCampaign_1.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\campaigns\missions\MainMenuMission.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\campaigns\missions\MainMenuMission.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\campaigns\missions\MainMenuMission.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# End Group
# Begin Group "Network"

# Begin Source File

SOURCE=.\Network\Levels.ech

# End Source File
# Begin Source File

SOURCE=.\Network\MissionBase.ech

# End Source File
# Begin Source File

SOURCE=.\Network\MissionCampaign.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\MissionCampaign.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\MissionCampaign.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\MissionCommon.ech

# End Source File
# Begin Source File

SOURCE=.\Network\MissionHorseRacing.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\MissionHorseRacing.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\MissionHorseRacing.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\MissionTeamAssault.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\MissionTeamAssault.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\MissionTeamAssault.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\MissionTeamBase.ech

# End Source File
# Begin Source File

SOURCE=.\Network\MissionTeamDeathmatch.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\MissionTeamDeathmatch.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\MissionTeamDeathmatch.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\MissionTeamMonsterHunt.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\MissionTeamMonsterHunt.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\MissionTeamMonsterHunt.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\MissionTeamRustling.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\MissionTeamRustling.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\MissionTeamRustling.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\TownCampaign.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\TownCampaign.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\TownCampaign.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Network\Towns.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Network\Towns.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Network\Towns.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "Units"

# Begin Group "Includes"

# Begin Source File

SOURCE=.\Units\Activity.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Alarm.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Attack.ech

# End Source File
# Begin Source File

SOURCE=.\Units\CommonUnits.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Items.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Magic.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Move.ech

# End Source File
# Begin Source File

SOURCE=.\Units\MoveAttack.ech

# End Source File
# Begin Source File

SOURCE=.\Units\MoveRandom.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Other.ech

# End Source File
# Begin Source File

SOURCE=.\Units\Skill.ech

# End Source File
# End Group
# Begin Source File

SOURCE=.\Units\Hero.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Units\Hero.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Units\Hero.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Units\Unit.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Units\Unit.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Units\Unit.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Units\UnitBase.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\Units\UnitBase.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\Units\UnitBase.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Group "RPGCompute"

# Begin Group "Includes"

# Begin Source File

SOURCE=.\RPGCompute\Alchemy.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\DefaultEvents.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\Equipment.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\Info.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\Magic.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\Magic2.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\Unit.ech

# End Source File
# Begin Source File

SOURCE=.\RPGCompute\Weapon.ech

# End Source File
# End Group
# Begin Source File

SOURCE=.\RPGCompute\RPGCompute.ec

!IF  "$(CFG)" == "Scripts - Win32 Debug"

# Begin Custom Build
InputPath=.\RPGCompute\RPGCompute.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath) -debug

# End Custom Build

!ELSEIF  "$(CFG)" == "Scripts - Win32 Release"

# Begin Custom Build
InputPath=.\RPGCompute\RPGCompute.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC.bat $(InputPath)

# End Custom Build

!ENDIF 

# End Source File
# End Group
# End Target
# End Project
