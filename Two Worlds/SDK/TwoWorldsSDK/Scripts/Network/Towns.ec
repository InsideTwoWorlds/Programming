//osobna kampania uzywana tylko do pobrania listy miast

campaign "NetworkTownsList"
{
#include "..\\Common\\Generic.ech"
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

}
