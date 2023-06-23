Dungeons editor


1.keyboard

tab - next mode
f2 - save to file
f3 - load from file
f4 - setting offset for map
f5 - generating console script for editor
f6 - load "old" dungeon
f8 - reset everything
escape - end
pageup/pagedown - zoom
arrows - przesuwanie


2. setting dungeons mode

left mouse button - drawing
right mouse button - removing

error:
red color - invalid block, cannot find any good set of blocks
green - hole. Blocks must be added
blue/violet - block set on other (fe. 2 H block) and one must be moved

if block have more versions we change it by clicking left clicking on that blick.


3. setting height mode

block versions are set by clicking on it.
values means height of block.
white text - block doesn't change height.
yellow text - block changes height.

errors:
violet colour is show in place where are different heights on block joint (we must change block version/height), or in place where dungeon is too height.


4. setting dungeons type mode

left mouse button - selecting single block
right mouse button - selecting group of blocks
mouse wheel - setting dungeons type

selected blocks are painted in colour respondent to version od dungeons (see config)


5. setting objects mode

left mouse button - insert object
left mouse button + Ctrl - pickup object type
left mouse button + shift - remove last inserted object
left mouse button + shift + Ctrl - remove all objects of currently selected type
kolko - zmiana rodzaju obiektu


6. config: dungeon.txt

Addons Name {

	Name1 ObjectID1 MeshType1 Bitmap1 Range1 [R G B]
	Name2 ObjectID2 MeshType2 Bitmap2 Range2 [R G B]
	...

}

defining group of objects
Name - name of group
NameX - object name
ObjectIDX - parameter's ID of object
MeshTypeX - type of mesh for object
BitmapX - bitmap which will be drawn in editor
RangeX - if different then 0 - object contains light with such a range
R G B - colour of light

Dungeon Name BlocksName BlocksNumber R G B {

	AddonsGroup1
	AddonsGroup2
	...

}

defining type of dungeons.

Name - dungeons name
BlocksName - name of blocks group (np. "DUN", "CAVE")
BlocksNumber - number of blocks group (np. "01", "07b")
R G B - colours for dungeon type (RGB z zakresu 0-255)
AddonsGroupX - group of addons (objects) for duneons type.


7. Creating level
Console script created by this editor should be run in TwoWorldEditor on empty underground level.
It will create some startup of level which should be later filled with objects and markers.
@edundgr.txt should be executed on underground level to reset terrain color to black and disable unavailable places.

