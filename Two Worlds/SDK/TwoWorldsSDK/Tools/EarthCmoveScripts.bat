@echo off

ECHO Moving Scripts to %2:

SET SCRIPTS_PATH=%1
SET OUTPUT_PATH=%2

SET DIRS=Campaigns Campaigns\Missions Campaigns\MainMenu Network Units RPGCompute

for %%d in (%DIRS%) do if not exist %OUTPUT_PATH%\%%d\ mkdir %OUTPUT_PATH%\%%d\

for %%d in (%DIRS%) do if exist %SCRIPTS_PATH%\%%d\*.eco move %SCRIPTS_PATH%\%%d\*.eco %OUTPUT_PATH%\%%d\

pause
