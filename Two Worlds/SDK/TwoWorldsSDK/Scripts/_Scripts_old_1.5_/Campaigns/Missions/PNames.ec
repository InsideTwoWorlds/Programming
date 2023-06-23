global "PNames" 
{

#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Quest.ech"
#include "..\\..\\Common\\Levels.ech"
#include "..\\..\\Common\\Messages.ech"
#include "PInc\\PEnums.ech"
#include "PInc\\PUnitInfo.ech"

//======================================        

state Initialize;
state Nothing;

//======================================        

consts {

    eUnknownType        = 0;
    eMaleDwarven        = 1;
    eFemaleDwarven      = 2;
    eMaleHuman          = 3;
    eFemaleHuman        = 4;
    eMaleCathalon       = 5;
    eFemaleCathalon     = 6;
    eMaleQudinaar       = 7;
    eFemaleQudinaar     = 8;
    eMaleAshos          = 9;
    eFemaleAshos        = 10;
    eTotalTypes         = 11;

}

//======================================        

int anMinNumber[eTotalTypes];
int anMaxNumber[eTotalTypes];
int anCurrentNumber[eTotalTypes];

//======================================        

function int GetMissionType(int nMission) {

    int nCol;
    int nRow;
    int nLayer;
    
    MissionNum2Level(nMission,nCol,nRow,nLayer);
    if ((nCol == 'E') && (nRow == 3)) return eMaleDwarven;
    if ((nCol == 'F') && (nRow == 7)) return eMaleCathalon;
    if ((nCol == 'D') && (nRow == 8)) return eMaleQudinaar;
    if ((nCol == 'B') && (nRow == 10)) return eMaleAshos;
    
    if (nRow <= 4) return eMaleDwarven;
    return eMaleHuman;
}

function void SetType(int nType, int nMin, int nMax) {

    anMinNumber[nType] = nMin;
    anMaxNumber[nType] = nMax;
    anCurrentNumber[nType] = nMin;

}

function void InitializeNames() {
    
    SetType(eMaleDwarven,1000,1049);
    SetType(eFemaleDwarven,1050,1099);
    SetType(eMaleHuman,1100,1149);
    SetType(eFemaleHuman,1150,1199);
    SetType(eMaleCathalon,1200,1249);
    SetType(eFemaleCathalon,1250,1299);
    SetType(eMaleQudinaar,1300,1349);
    SetType(eFemaleQudinaar,1350,1399);
    SetType(eMaleAshos,1400,1449);
    SetType(eFemaleAshos,1450,1499);

}

//======================================        

function int ChooseNPCNameNum(unit uUnit) {

    int i;
    int nMission;
    int nType;
    int nNumber;
    string str;
    
    nType = GetMissionType(uUnit.GetMission().GetMissionNum());
    
    if (nType == eUnknownType) {
#ifdef NAMES_DEBUG    
        TRACE("ChooseNPCNameNum: unknown type for mission %d         \n",nMission);
#endif        
        return 0;
    }

    if (IsFemale(uUnit)) nType++;
    nNumber = anCurrentNumber[nType];
    anCurrentNumber[nType] += 1;
    if (anCurrentNumber[nType] > anMaxNumber[nType]) anCurrentNumber[nType] = anMinNumber[nType];
    
    return nNumber;
    
}

//======================================        

state Initialize {

    ENABLE_TRACE(true);
    InitializeNames();
    return Nothing;
    
}

state Nothing {

    return Nothing, 300;

}

//======================================        

command Message(int nParam, unit uUnit) {

    if (nParam == eMsgSetNPCNameNum) {
        
        uUnit.SetNPCNameNum(ChooseNPCNameNum(uUnit));
        return 0;
    
    }

    return false;

}

//======================================        

}
