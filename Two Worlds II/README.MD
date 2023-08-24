# Two worlds 2 SDK
By [HeliX666](https://github.com/Helix666)

## Parameters Editor

Now what this tool allows you to do:
- edit any parameters in file;
- add new string constant (explanation below);
- search parameters in file;

What i planning to do in near future:
- add injection to TW2.exe process and allow to do live changes in the game;
- add ability for adding new data rows(items);
- and some interface improvement.

Now explanation how it work and how to use it (read it before use this tool):

The buttons:
- Folder with arrow allow you to open a .par file;
- Blue disc save your changes to the new par file;
- Two arrows with line opens constant editor and objects list;
- The gear wheel open option windows (at this moment only one option )
- The green disc save your current settings (groups names and column names);
- For the search you should select column in grid and use search button or F3;

When file opens in the left side appears a list with the group names. The group list allows selecting group with same data column. You can give groups any name that you want and save them in options file (for your accommodation) by clicking the green disc button.
When group selected you will see data grind in the right side. You can select and change all parameters, but there is some type restriction for editing:

- The Integer/byte/word type can be edited as is or like as Hex data(to switch view in hex type – right click on the column header and select view type);
- The float value be edited as float or like hex ;
- Reference to the string constant, it’s an integer type refers to the string section by the index, to edit it you should set correct index value. All constants can be found in “Constant editor”. You can’t change constants, but you always add a new one and set refer to it.
- An object index - an integer type refers to the other object from parameters (ID), you can find all indexes in the “Constant editor” “Objects ID’s” tab.
- The sets, the sets have the same types as described above , but in can contain more that one value for example(hero inventory as string set): INV_PLACEHOLDER_MAP;INV_PLACEHOLDER_QUESTLOG;INV_P LACEHOLDER_REPUTATION;PERSONAL_TELEPORT;LOCKPICK;L OCKPICK;LOCKPICK;LOCKPICK;LOCKPICK;ART_TORCH_01;PO TION_HEALING_01;POTION_MANA_01;POTION_HEALING_01;P OTION_MANA_01;POTION_HEALING_01;POTION_MANA_01;POT ION_HEALING_01;POTION_MANA_01;POTION_HEALING_01;PO TION_MANA_01;POTION_HEALING_02;POTION_MANA_02;FLYI NGEYE4
Or an integer values : 1132;1133;1134;1135;1136;1137;1138;1139;1140;1141; 1142;1132;1136;688;640;641;642;643;644;645;646;647 ;648;649;650;640;644

I.e. you should separate sets values by “;” sign (don’t place it to the end of the string)

Don’t forget that the objects id’s and reference got an integer value when you edit it, you should search for correct value in the “Constant editor”.


Also you can select type of the view, for the columns with refers:
- Show name – shows a name of the values of the constants;
- Show ID – shows an integer values;
For the integer/float type:
- signed integer – default type;
- unsigned integer;
- hex value;

You can select view type for the column by clicking on it header with right mouse button.
Also you can set name for the columns a save it in option file, this helps to discover columns meaning and share it with others.

Some columns have the same meaning as in the TW1 , so it’s possible them by comparing parameters with a XLS parameters file from TW1 SDK.

I hope that my small instruction was readable and understandable. 

## WD files Tool(packer/unpacker)

-To unpack just select WD file and select destination folder for unpacking files.
-To build a new package just select folder with source files(with original dir tree inside this folder) and write name for new package.

It also can unpack protected files from Startup.wd file (some games parameters/configs/scripts and ect was crypted not only packed).
