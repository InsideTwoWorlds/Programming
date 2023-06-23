mission "Empty Mission"
{
#include "..\\..\\Common\\Generic.ech"
#include "..\\..\\Common\\Mission.ech"

    state Initialize;
    state Nothing;
 /*   
unit auUnit[10];
int anLastMarker[5];
    

function void IncreaseLastMarker(int i)
{
    if(anLastMarker[i]<5)
        anLastMarker[i] += 1;
    else 
        anLastMarker[i]=1;
}
                    
function void FindNextMarker(int i,int&nX,int&nY)
{
    int j;
    for(j=0;j<5;j++)
    {
        IncreaseLastMarker(i);
        if (GetMarker(DEFAULT_MARKER, i*10 + anLastMarker[i], nX, nY))
        {
            return;
        }
    }
}
function void SetupCharacter(int i)
{
        auUnit[i].SetPartyNum(ePartyPlayer);
        auUnit[i].CommandSetArmedMode(1);
        auUnit[i].SetRunMode(1);
}
int nTimer;
*/
state Initialize
{
    /*
    int i,nX,nY;
    nTimer=0;
    for(i=0;i<10;i++)auUnit[i]=null; 
    for(i=0;i<5;i++)anLastMarker[i]=1;
    
    
    if (GetMarker(DEFAULT_MARKER, 1, nX, nY))
    {
        auUnit[0] = CreateObject("THE_OLD(30)#WP_SWORD_1(10,0),AR_BUCKLER(10,0),NULL,AR_CHAIN_ARMOUR(9,0,14),AR_CHAIN_GLOVES(9,0,14),AR_CHAIN_TROUSERS(9,0,14),AR_CHAIN_BOOTS(9,0,14)",  nX, nY, 0, eFaceEast);
        SetupCharacter(0);
    }
    if (GetMarker(DEFAULT_MARKER, 11, nX, nY))
    {
        auUnit[1] = CreateObject("THE_YOUNG(30)#WP_AXE_1(7,0),NULL,NULL,AR_CHAIN_ARMOUR(7,0,11),AR_CHAIN_GLOVES(7,0,11),AR_CHAIN_TROUSERS(7,0,11),AR_CHAIN_BOOTS(7,0,11)",  nX, nY, 0, eFaceWest);
        SetupCharacter(1);
    }
    if (GetMarker(DEFAULT_MARKER, 21, nX, nY))
    {
        auUnit[2] = CreateObject("CITIZEN_01(30)#WP_SWORD_0(1,0),NULL,NULL,AR_LEATHER_ARMOUR(1,0),AR_LEATHER_GLOVES(1,0) ,AR_LEATHER_TROUSERS(1,0),AR_LEATHER_BOOTS(1,0,1)", nX,nY, 0, 0);
        SetupCharacter(2);
    }
    if (GetMarker(DEFAULT_MARKER, 31, nX, nY))
    {
        auUnit[3] = CreateObject("ORC_06(30)#WP_MACE_1(10,0)", nX,nY, 0, 0);
        SetupCharacter(3);
    }
    if (GetMarker(DEFAULT_MARKER, 41, nX, nY))
    {
        auUnit[4] = CreateObject("MINION_03(30)#WP_MACE_1(10,0)", nX,nY, 0, 0);
        SetupCharacter(4);
    }
    //boty biegajace za graczem
    if (GetMarker(DEFAULT_MARKER, 51, nX, nY))
    {
        auUnit[5] = CreateObject("THE_OLD(30)#WP_SWORD_1(10,0),AR_BUCKLER(10,0),NULL,AR_CHAIN_ARMOUR(9,0,14),AR_CHAIN_GLOVES(9,0,14),AR_CHAIN_TROUSERS(9,0,14),AR_CHAIN_BOOTS(9,0,14)",  nX, nY, 0, eFaceEast);
        SetupCharacter(5);
    }
    if (GetMarker(DEFAULT_MARKER, 52, nX, nY))
    {
        auUnit[6] = CreateObject("THE_YOUNG(30)#WP_AXE_1(7,0),NULL,NULL,AR_CHAIN_ARMOUR(7,0,11),AR_CHAIN_GLOVES(7,0,11),AR_CHAIN_TROUSERS(7,0,11),AR_CHAIN_BOOTS(7,0,11)",  nX, nY, 0, eFaceWest);
        SetupCharacter(6);
    }
    if (GetMarker(DEFAULT_MARKER, 53, nX, nY))
    {
        auUnit[7] = CreateObject("CITIZEN_01(30)#WP_SWORD_0(1,0),NULL,NULL,AR_LEATHER_ARMOUR(1,0),AR_LEATHER_GLOVES(1,0) ,AR_LEATHER_TROUSERS(1,0),AR_LEATHER_BOOTS(1,0,1)", nX,nY, 0, 0);
        SetupCharacter(7);
    }
    if (GetMarker(DEFAULT_MARKER, 54, nX, nY))
    {
        auUnit[8] = CreateObject("ORC_06(30)#WP_MACE_1(10,0)", nX,nY, 0, 0);
        SetupCharacter(8);
    }
    if (GetMarker(DEFAULT_MARKER, 55, nX, nY))
    {
        auUnit[9] = CreateObject("MINION_03(30)#WP_MACE_1(10,0)", nX,nY, 0, 0);
        SetupCharacter(9);
    }*/
    return Nothing;
}

state Nothing
{
    /*int i,nX,nY;
    unit uHero;
    for(i=0;i<5;i++)
    {
        if(auUnit[i]!=null && auUnit[i].IsLive())
        {
            
            if (GetMarker(DEFAULT_MARKER, i*10 + anLastMarker[i], nX, nY))
            {
                if(IsUnitNearMarker(auUnit[i],i*10 + anLastMarker[i], eRange2))
                {
                    FindNextMarker(i,nX,nY);
                    auUnit[i].CommandMoveAttack(nX, nY,0);
                }
            }
            else
            {
                IncreaseLastMarker(i);
            }
    
        }
    }
    nTimer++;
    if(nTimer>4)
    {
        nTimer=0;
    }
    
    i=5+nTimer;
    if(auUnit[i]!=null && auUnit[i].IsLive())
    {
        uHero = GetHero();
        uHero.GetLocation(nX,nY);
        auUnit[i].CommandMoveAttack(nX+128*(Rand(10)-5), nY+(Rand(10)-5),0);
    }
*/
    return Nothing,30;
}
}

