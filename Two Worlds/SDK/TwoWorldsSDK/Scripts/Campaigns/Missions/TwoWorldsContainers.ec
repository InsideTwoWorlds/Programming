global "Container script"
{
    #include "..\\..\\Common\\Generic.ech"
    #include "..\\..\\Common\\Quest.ech"
    #include "..\\..\\Common\\Lock.ech"
    #include "..\\..\\Common\\Messages.ech"
    #include "PInc\\PEnums.ech"
    #include "PInc\\PCommon.ech"
    #include "PInc\\PUnitInfo.ech"
    
state Initialize;
state Nothing;

function void FillUnitWith(unit uUnit, string strItems) {

    int i;
    string str;    
    string astrItems[];
        
    uUnit.GetAttribute(strItems,str);
    if (str.EqualNoCase("")) return;    
    StrSplit(str,astrItems);
    for (i = 0; i < astrItems.GetSize(); i++) uUnit.AddObjectToDeadBody(astrItems[i]);
        
}

function void AddAndRemoveUnitItems(unit uUnit) {

    int i;
    string str;    
    string astrItems[];
    
    for (i = 0; i < GetCampaign().GetGlobalScriptsCnt(); i++) GetCampaign().GetGlobalScript(i).CommandMessage(eMsgSetUnitItemsAttribute,0,uUnit);
    
    uUnit.GetAttribute("UnitItemsAdd",str);
    if (!str.EqualNoCase("")) {    
        StrSplit(str,astrItems);
        for (i = 0; i < astrItems.GetSize(); i++) uUnit.AddObjectToDeadBody(astrItems[i]);
    }
    
    uUnit.GetAttribute("UnitItemsRemove",str);
    if (!str.EqualNoCase("")) {    
        StrSplit(str,astrItems);
        for (i = 0; i < astrItems.GetSize(); i++) if (uUnit.IsObjectInDeadBody(astrItems[i])) uUnit.RemoveObjectFromDeadBody(astrItems[i]);    
    }
    
}

function void SetUnitItemsAttribute(unit uUnit) {

    int i;
    string str;    
    string astrItems[];

    uUnit.GetAttribute("UnitItems",str);
    if (str.EqualNoCase("")) return;
    
    StrSplit(str,astrItems);
    for (i = 0; i < astrItems.GetSize(); i++) if (!uUnit.IsObjectInDeadBody(astrItems[i])) str = RemoveTextFromString(astrItems[i],str);
    
    uUnit.SetAttribute("UnitItems",str);

}

function void AddAndRemoveContainerItems(unit uContainer) {

    int i;
    string str;    
    string astrItems[];
    
    for (i = 0; i < GetCampaign().GetGlobalScriptsCnt(); i++) GetCampaign().GetGlobalScript(i).CommandMessage(eMsgSetContainerItemsAttribute,0,uContainer);
    
    uContainer.GetAttribute("ContainerItemsAdd",str);
    if (!str.EqualNoCase("")) {    
        StrSplit(str,astrItems);
        for (i = 0; i < astrItems.GetSize(); i++) uContainer.AddObjectToContainer(astrItems[i]);
    }
    
    uContainer.GetAttribute("ContainerItemsRemove",str);
    if (!str.EqualNoCase("")) {    
        StrSplit(str,astrItems);
        for (i = 0; i < astrItems.GetSize(); i++) if (uContainer.IsObjectInContainer(astrItems[i])) uContainer.RemoveObjectFromContainer(astrItems[i]);    
    }
    
}

function int CheckObjectString(string strObject) {

    string str;
    str = strObject;
    if (str.EqualNoCase("") || str.EqualNoCase("null") || str.EqualNoCase("NULL")) return false;
    return true;
    
}   

function void SafeAddObjectToContainer(unit uContainer, string strObject, int nLine) {

    string str;
    str = strObject;
    
    if (!CheckObjectString(strObject)) {
        __ASSERT_FALSE();
        TRACE("TwoWorldsContainer: wrong object ID in line: %d                \n",nLine);
        return;
    }
    
    uContainer.AddObjectToContainer(str);    

}

event RemovedUnit(unit uUnit, unit pKilledByObject, int nNotifyType)
{
    int i, j;
    if (uUnit.IsUnit() && !uUnit.IsHeroUnit())
    {
        //TRACE("                      BODY FOUND             \n");
        uUnit.GetAttribute("Reward",i);
        uUnit.GetAttribute("Mage",j);
        if(i || j || IsQuestUnit(uUnit)) uUnit.SetDeadBodyScriptOwnerUID(GetScriptUID());
    }
    return false;
}

event OpenContainerObject(unit uHero, unit uContainerObject, int bFirstOpen, int bFirstHeroOpen, int& bClosedLockSound, int& bOpenLockSound, int& bBrokenLockpickSound)
{
    int i,j,nLevel;
    string str;
    TRACE("                      CONTAINER OPENED             \n");
    nLevel=uHero.GetUnitValues().GetLevel();
    if (uContainerObject.IsShopUnit() && uContainerObject.IsLive())
    {
        return false;
    }
    else if (uContainerObject.IsUnit() && !uContainerObject.IsLive())
    {
        if (bFirstOpen)
        {
            uContainerObject.AddObjectsFromParamsToDeadBody();
            TRACE("                      FILLING CONTAINER             \n");
            uContainerObject.GetAttribute("Reward",i);
            if(i>0)
            {
                uContainerObject.AddObjectToDeadBody(CreateGoldString(nLevel));
                if(Rand(2))uContainerObject.AddObjectToDeadBody(CreateRewardString(nLevel,false,2));
            }
            if(i>1)
            {
                uContainerObject.AddObjectToDeadBody(CreateRewardString(nLevel*120/100,false));
                if(Rand(2))uContainerObject.AddObjectToDeadBody(CreateRewardString(nLevel*130/100,false,4));
            }
            if(i>2)
            {
                uContainerObject.AddObjectToDeadBody(CreateRewardString(nLevel*140/100,false));
                if(Rand(2))uContainerObject.AddObjectToDeadBody(CreateRewardString(nLevel*150/100,false,8));
            }
            //XXXMD-dodac karty magii
            if(i>0)//musi byc i reward i mage
            {
                i=0;
                uContainerObject.GetAttribute("Mage",i);
                if(i)
                {
                    TRACE("\n\n  dodawanie karty magii %d   \n",i);
                    uContainerObject.AddObjectToDeadBody(GetSimpleMagicCardString(i));
                    if(!Rand(10))uContainerObject.AddObjectToDeadBody(GetPowerUpCardString(Rand(5)));
                    //XXXMD  ^ zmienic na 10
                }
            }
            FillUnitWith(uContainerObject,"RewardGold");
            FillUnitWith(uContainerObject,"RewardItems");
        }
        AddAndRemoveUnitItems(uContainerObject);
        return true;
    }
    else if (uContainerObject.IsUnitBase() && !uContainerObject.IsLive())
    {
        if (bFirstOpen)
        {
            uContainerObject.AddObjectsFromParamsToDeadBody();
        }
        return true;
    }
    else if (uContainerObject.IsContainer())
    {
        if (bFirstOpen)
        {
            if (!TryOpenLock(uContainerObject, uHero, bClosedLockSound, bOpenLockSound, bBrokenLockpickSound))
            {
                return false;
            }
        }
        //-> uChest.SetContainerScriptOwnerUID(GetScriptUID());
        if (bFirstOpen)
        {
            TRACE("                      FILLING CONTAINER             \n");
            j=0;
            uContainerObject.GetAttribute("BOMB",j);
            if(j>0)
            {
                SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel,false,0),__LINE__);
                if(!Rand(2))SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel,false,j),__LINE__);
            }
            else
            {
                j=uContainerObject.GetLockLevel();
                SafeAddObjectToContainer(uContainerObject,CreateGoldString(nLevel),__LINE__);
                SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel,false,j),__LINE__);
                SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel,false,j),__LINE__);
                SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel,false,j),__LINE__);
                if(!Rand(1)) SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel,false,j),__LINE__);
                if(!Rand(2)) SafeAddObjectToContainer(uContainerObject,CreateRewardString(1+nLevel,false,j),__LINE__);
                if(!Rand(3)) SafeAddObjectToContainer(uContainerObject,CreateRewardString(3+nLevel,false,j),__LINE__);
                if(!Rand(3)) SafeAddObjectToContainer(uContainerObject,CreateRewardString(5+nLevel,false,j),__LINE__);
                for(i=0;i<j;i++) SafeAddObjectToContainer(uContainerObject,CreateRewardString(nLevel+2+Rand(5),false,j),__LINE__);
            }
        }
        AddAndRemoveContainerItems(uContainerObject);
        return true;
    }
    __ASSERT_FALSE();
    return false;
}

event CloseContainerObject(unit uHero, unit uShopUnit, int nBuyMoney, int nSellMoney)
{
    if (uShopUnit.IsUnit()) SetUnitItemsAttribute(uShopUnit);
    return false;
}

function void SetContainersRegistered(mission pMission, int nFlag)
{
    pMission.SetAttribute("ContainersReg",nFlag);
}

function int ContainersRegistered(mission pMission)
{
    int nFlag;
    pMission.GetAttribute("ContainersReg",nFlag);
    return nFlag;
}


function void RegisterContainers(mission pMission)
{
    int i, nMaxNum;
    unit uChest;

    nMaxNum = pMission.GetMaxMarkerNum("MARKER_CHEST");
    for (i=1;i<=nMaxNum;i++)
    {
        // przeszukac wszystkie markery typu chest, pobrac z nich  unity i ustawic im
        //-> uChest.SetContainerScriptOwnerUID(GetScriptUID());
        if(pMission.HaveMarker("MARKER_CHEST",i))
        {
            TRACE("                      CHEST FOUND %d            \n",i);
            uChest=pMission.GetObjectMarker("MARKER_CHEST",i);
            if (uChest!=null) {
                uChest.SetContainerScriptOwnerUID(GetScriptUID());
                uChest.SetAttribute("ContainerNumber",i);                
            }
            else
            {
                TRACE("Can't find object at MARKER_CHEST %d                \n",i);
            }
        }
    }
    SetContainersRegistered(pMission,true);
}

state Initialize
{
    ENABLE_TRACE(false);
    return Nothing,10;
}
state Nothing
{
    int i;
    mission pMission;
    
    for (i = 0; i < GetPlayersCnt(); i++)
    {
        if (!IsPlayer(i)) continue;
        pMission = GetHero(i).GetMission();
        if (ContainersRegistered(pMission)) continue;
        if (!pMission.IsLevelLoaded()) continue;
        RegisterContainers(pMission);
    }
                
    return Nothing,30*5;
}

event OnUnloadLevel(mission m)
{
    SetContainersRegistered(m,false);
    return true;
}

}
