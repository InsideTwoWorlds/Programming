---------------------------
TwoWorlds exporter
---------------------------

Supported maya versions are:

+ 7.0 32Bit (with all updates) -> PolanieExporter_m7.mll  
+ 8.5 32Bit (with all updates) -> PolanieExporter_m85.mll 
+ 8.5 64Bit (with all updates) -> PolanieExporter_m85_x64.mll 

Instalation steps:

1] copy apriopriate *.mll file to maya/bin/plug-ins folder

2] adjust settings in registry to point to /Shaders directory
   NOTE: 32bit version uses HKLM, 64bit uses HKCU entry

3] run maya, go to plugins manager and load the plugin


First of all when you begin new scene you need to create 'SCENE_INFO' object
(just execute sceneinfo.mel)
This is a special object that have some properties like destination object type (animation, vertexes, both)
information about animation len, etc., etc.

When you create new object, you need to assign MXPolanieShader to it (as a shading node).
You olso need to add special property called ExportName (type:string) to object.
For example if you created sphere named pSphere1,
you need to execute something like this (while object is still selected !)

addAttr -ln ExportName -dt "string";

Now you could enter for example 'test' in a textfield of this new property, and export.
final object will be in [destination_path_from_the_reg]\test.vdf (if you selected 'all' export mode)


REMEMBER !!! Object must be triangulated before export (or check 'triangulate before export' in sceneinfo props)

There are other properties for object respected by game engine and exporter:

SubName     (string) => Name of subobject
LODLevel    (int)    => 0 is a base, 1, 2 for graphics, 3 for physx
Floor       (bool)   => marked as floor
NotWalkable (bool    => marked as not walkable
NotMergeable(bool)   => cannot be merged 

additional props for box templates:
GPFlag      (int)    => flag passed to game
Vis         (bool)   => for occ
VisHard     (bool)   => for occ
LodBox      (bool)   => force lod transition at specified size
Floor       (bool)   => define floor
Interior    (bool)   => define interior
Ceiling     (bool)   => define ceil

Note that some properties (ExportName, NotWalkable, LODLevel, SubName) have hierarchy, and are inherited by child objects.

To create 'gameplay' box just check 'template' property in display tab (in TRANSFORM not in SHAPE !)

Locator names supported by game engine:

  "BPLUG1",
  "BPLUG2",
  "BPLUG3",
  "BPLUG4",
  "BPLUG5",
  "BPLUG6",
  "BPLUG7",
  "BPLUG8",
  "BPLUG9",
  "BRIDLE_0",
  "BRIDLE_1",
  "BRIDLE_2",
  "CAMERA",
  "CENTER",
  "DOOR",
  "GROUND",
  "HANDLE",
  "PLACE1",
  "PLACE2",
  "PLACE3",
  "PLACE4",
  "PLACE5",
  "PLACE6",
  "PLACE7",
  "PLACE8",
  "PLACE9",
  "QUIVER",
  "SIT",
  "SLEEP",
  "TRAILBEG_0",
  "TRAILBEG_1",
  "TRAILBEG_2",
  "TRAILBEG_3",
  "TRAILEND_0",
  "TRAILEND_1",
  "TRAILEND_2",
  "TRAILEND_3",
  "WEAPON1",
  "WEAPON2",
  "WEAPON3",
  "WEAPON4",
  "SADDLE",
  "Head",
  "RightTool",
  "LeftTool",
  "Hips",
  "SELECT",
  "HIT",      
  "GROUND",   
  "FXEFFECT", 
  "TRACK1",   
  "TRACK2",  
  "TRACK3",  
  "TRACK4",
  "PIVOT",




---------------------------
TwoWorlds Maya shading node
---------------------------

Supported maya versions are:

+ 7.0 32Bit (with all updates) -> PolanieShader_m7.mll 
+ 8.5 32Bit (with all updates) -> PolanieShader_m85.mll 
+ 8.5 64Bit (with all updates) -> PolanieShader_m85_x64.mll 

Instalation steps:

1] copy apriopriate *.mll file to maya/bin/plug-ins folder

2] copy AEMXPolanieShaderTemplate.mel to maya/scripts/aetemplates

3] adjust settings in registry to point to /Shaders directory
   NOTE: 32bit version uses HKLM, 64bit uses HKCU entry

4] run maya, go to plugins manager and load the plugin

5] now you should have new shading node in maya :)

Ps. Change vertexcolor to green to get BiNormal mirroring
    Change vertexcolor to red to get 2 sided faces
    Some of the materials need 2nd uv set to work, brief description of shaders is in Shaders/shaders.txt



---------------------------
SHADERS description:
---------------------------

 + Green  -- mirroring
 + Red    -- double side faces


 + Metal
   + Base texture without alpha
   + Bump texture with specular map on alpha
   + Destruction texture
   + Takes specular color and specular strength from parameters
   + Takes DestructionTileX, DestructionTileY, DestructionColor i DestructionFactor
   + Destruction factor modifies only texture, not vertices

 + Metal Alpha
   + Base texture with alpha (alphatest is don on this channel so alpha should by 1 bit (DXT1))
   + Bump texture with specular map on alpha
   + Destruction texture
   + Takes specular color and specular strength from parameters
   + Takes DestructionTileX, DestructionTileY, DestructionColor i DestructionFactor
   + Destruction factor modifies only texture, not vertices

 + Metal Character
   + Base texture without alpha
   + Bump texture with specular map on alpha
   + Destruction texture
   + Takes specular color and specular strength from parameters
   + Takes DestructionTileX, DestructionTileY, DestructionColor i DestructionFactor
   + Destruction factor modifies only texture, not vertices
   + Color texture and PC0Color, PC1Color, PC2Color, PC3Color - for object colouring

 + Chrome
   + Base texture with alpha (alpha = 1 -- full cubemap reflextion, alpha = 0 full base texture, 0-1 - transition)
   + Bump texture with specular map on alpha
   + Cube texture (checkbox set ON - this cubemap is reflected; OFF - sky cubemap reflected)
   + Takes specular color and specular strength from parameters
   + Without Destruction

 + Chrome with destruction
   + Base texture with alpha (alpha = 1 -- full cubemap reflextion, alpha = 0 full base texture, 0-1 - transition)
   + Bump texture with specular map on alpha
   + Cube texture (checkbox set ON - this cubemap is reflected; OFF - sky cubemap reflected)
   + Destruction texture
   + Takes specular color and specular strength from parameters
   + Takes DestructionTileX, DestructionTileY, DestructionColor i DestructionFactor
   + Destruction factor modifies only texture, not vertices

 + Fur
   + Base texture without alpha
   + Bump texture with specular map on alpha
   + Destruction texture
   + Takes specular color and specular strength from parameters
   + Takes DestructionTileX, DestructionTileY, DestructionColor i DestructionFactor
   + Destruction factor modifies only texture, not vertices
   + FurNoiseX, FurNoiseY FurNoiseZ defines fur density
   + FurLayers defines how many layers contains fur
   + FurLayerDistance defines distance between layers
     * This material is damn slow, so use carefully!

 + Alien
   + Take same like metal
   + Noise controlled by parameters from fur (gFurFactor.xyz)
   + Move speed controlled by FurLayerDistance
   + sparkle's controlled by DestructionColor
   + Alpha controlled AlphaFactor

 + Light
   + Base texture (alphatest on alpha so DXT1 with alpha is OK)
   + This texture is not modified by any lighting etc.

 + Blend
   + Base texture with alpha
   + This texture will be blended on alpha, not modified by lighting

 + Blend Add
   + Base texture without alpha
   + This texture will be blended additive, not modified by lighting

 + Paralax mapping
   + Base texture with alpha (specular map on alpha)
   + Bump texture with heightfield on alpha channel

 + Metal fade
   + Like metal 
   + Outline color -> Destruction color, depends on cosinus of camera angle
   + outline size modified by Alpha factor
   + outline presence modified by diffuse map' alpha
   + Fur noise x controls bias
   + Experimental! :)

 + Hair
   + Another experiment :)
   
 + Lightmap
   + Lightmap takes uv from second set
   + Rest like metal, no destruction
   
 + Metal blend
   + for stained glass
   
 + Human skin
   + Destruction texture - Lightmap (with second UV) [but it depends on helmet in game]
   + Alpha               - SubSurface rolloff (set to 0.4)
   + DestructionColor    - SubSurface color
   + Color factor 0      - Skin color [set in game]
   + Color texture       - Anisotrophic light [diffuse after X  (0 -> -1, 1 -> 1)] => Red
					      [specular after Y (0 -> -1, 1 -> 1)] => Green
   Rest like in metal character
   
 + Fire
   + Additonal flame texture (can be small, np.64px. RGB) should be created.
   + Shader draws smimming pieces in blend mode on this texture.
     All is shining and shows on white alpha of diffuse texture.
     --Settings--
   + Destruction Color = color of pieces.
   + Fur Layer Distance = speed of moving pieces.
   + Fur noise X,Y,Z = size of pieces and noise/deflection of fire texture
   + Destruction Tile X (between -10 do +10) = pieces shining force
   
 + Chrome alpha
   + chrom with alpha
   + transparency on diffuse alpha
   + reflexivity on bump alpha
   + this material doesn't contain specular !!!!
   
 + Metal flag
   + material for flaunt banners.
