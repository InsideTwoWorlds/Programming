if not exist D:\Games\TwoWorlds\Levels\MipMaps\ mkdir D:\Games\TwoWorlds\Levels\MipMaps\

SET COMMON_PT=D:\Games\TwoWorldsSDK\Tools\TexConv.exe -m 1 -f DXT1 -if POINT -o D:\Games\TwoWorlds\Levels\MipMaps -ft DDS -nologo
SET COMMON=D:\Games\TwoWorldsSDK\Tools\TexConv.exe -m 1 -f DXT1 -if BOX_DITHER -o D:\Games\TwoWorlds\Levels\MipMaps -ft DDS -nologo

for %%f in (D:\Games\TwoWorlds\Levels\*.bmp) do %COMMON_PT% -w 512 -h 512 -sx @0 "%%f"
for %%f in (D:\Games\TwoWorlds\Levels\*.bmp) do %COMMON% -w 256 -h 256 -sx @1 "%%f"
for %%f in (D:\Games\TwoWorlds\Levels\*.bmp) do %COMMON% -w 128 -h 128 -sx @2 "%%f"
for %%f in (D:\Games\TwoWorlds\Levels\*.bmp) do %COMMON% -w  64 -h  64 -sx @3 "%%f"
