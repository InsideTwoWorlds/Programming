@echo off

set GCC_EXEC_PREFIX=D:\Games\TwoWorldsSDK\Tools\gcc
set PATH=%GCC_EXEC_PREFIX%\libexec\gcc\mingw32\3.4.2;%PATH%


set DEL_PARAM=
if "%OS%" == "Windows_NT" set DEL_PARAM=/F

Echo Compiling...

if '%2' == '-debug' set CL_PARAM=-D _DEBUG

D:\Games\TwoWorldsSDK\Tools\gcc\bin\cpp.exe %1 %CL_PARAM% > %1-pp
if not errorlevel 1 D:\Games\TwoWorldsSDK\Tools\EarthC.exe -w- -nologo -noresult -echofilename %2 %3 %1-pp %1o
del %DEL_PARAM% %1-pp
