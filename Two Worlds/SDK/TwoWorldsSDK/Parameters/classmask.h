// classmask.h:
//
//////////////////////////////////////////////////////////////////////

#define OTHER                        0x00000001
//w EarthCVM.h jest: EARTHCVM        0x00000011         //derived from OTHER
#define WORLD                        0x00000021         //derived from OTHER
#define PLAYER                       0x00000041         //derived from OTHER
#define COMMAND                      0x00000081         //derived from OTHER
#define UNITLAND                     0x00000101         //derived from OTHER
#define UNITFLYABLE                  0x00000201         //derived from OTHER
#define TRAILCONTROL                 0x00000401         //derived from OTHER
#define UNITLANDSLOT                 0x00000801         //derived from OTHER
#define UNITLANDREQUEST              0x00001001         //derived from OTHER
#define UNITLANDGROUP                0x00002001         //derived from OTHER
#define CAMPAIGNSCRIPTOBJECT         0x00004001         //derived from OTHER
#define WORLDSCRIPTOBJECT            0x00008001         //derived from OTHER
#define GLOBALSCRIPTOBJECT           0x00010001         //derived from OTHER
#define PLAYERINTERFACE              0x00020001         //derived from OTHER
#define UNITHERO                     0x01000101         //derived from UNITLAND
#define UNITHORSE                    0x02000101         //derived from UNITLAND

#define GENERIC                      0x00000002
#define STOREABLE                    0x00000012         //derived from GENERIC
#define EQUIPMENT                    0x00000022         //derived from GENERIC

#define WEAPON                       0x00000122         //derived from EQUIPMENT
#define MAGICCLUB                    0x00010122         //derived from WEAPON
#define MAGICCARD                    0x00000422         //derived from EQUIPMENT

#define VIRTUAL                      0x00000112         //derived from STOREABLE
#define UNITBASE                     0x00000212         //derived from STOREABLE
#define DYNAMIC                      0x00000412         //derived from STOREABLE
#define SIMPLEPASSIVE                0x00000812         //derived from STOREABLE
#define MISSILE                      0x00001012         //derived from STOREABLE

#define UNIT                         0x00010212         //derived from UNITBASE
#define HERO                         0x01010212         //derived from UNIT
#define SHOPUNIT                     0x02010212         //derived from UNIT

#define PASSIVE                      0x00010812         //derived from SIMPLEPASSIVE
#define ROLLINGSTONE                 0x00030812         //derived from PASSIVE
#define ARTEFACT                     0x00050812         //derived from PASSIVE
#define TRAP                         0x00090812         //derived from PASSIVE
#define GATE                         0x00110812         //derived from PASSIVE
#define TELEPORT                     0x00210812         //derived from PASSIVE
#define HOUSE                        0x00410812         //derived from PASSIVE
#define CONTAINER                    0x00810812         //derived from PASSIVE

#define EQUIPMENTARTEFACT            0x01050812         //derived from ARTEFACT
#define POTIONARTEFACT               0x02050812         //derived from ARTEFACT
#define SPECIALARTEFACT              0x04050812         //derived from ARTEFACT
#define CUSTOMARTEFACT               0x08050812         //derived from ARTEFACT
#define ALCHEMYFORMULAARTEFACT       0x10050812         //derived from ARTEFACT
