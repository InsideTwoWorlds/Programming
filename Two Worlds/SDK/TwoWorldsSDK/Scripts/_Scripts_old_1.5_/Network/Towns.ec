//osobna kampania uzywana tylko do pobrania listy miast

campaign "NetworkTownsList"
{
#include "Levels.ech"

state Nothing;

state Nothing
{
    return Nothing;
}

command FillNetworkChannelLevelsList(string& strMapTexture, string arrChannels[], string arrScripts[], string arrScriptParams[], stringW arrTooltips[], int arrButtonTemplNum[], int arrMapPosition[], int arrAvailable[])
{
    FillNetworkChannelLevelsList(strMapTexture, arrChannels, arrScripts, arrScriptParams, arrTooltips, arrButtonTemplNum, arrMapPosition, arrAvailable);
    return true;
}

command FillNetworkXMissionsList(int bRPGMode, string arrScripts[], string arrScriptParams[], string arrNames[], int arrPointsGame[], int arrGuildsGame[], int arrAllowDynConn[], int arrMinPlayersCnt[], int arrAvailable[])
{
    FillNetworkXMissionsList(bRPGMode, arrScripts, arrScriptParams, arrNames, arrPointsGame, arrGuildsGame, arrAllowDynConn, arrMinPlayersCnt, arrAvailable);
    return true;
}

command FillNetworkXMissionModes(string strScriptParam, string arrModeParams[], string arrModeNames[], int arrModeXDefineNum[])
{
    FillNetworkXMissionModes(strScriptParam, arrModeParams, arrModeNames, arrModeXDefineNum);
    return true;
}

}
