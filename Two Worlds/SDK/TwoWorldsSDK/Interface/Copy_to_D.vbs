'### Skrypt uruchamiany po kompilacji interface'u.                 ###

'=====================================================================
Sub CopyFiles(GamePath)
' create directory D:\Games\TwoWorlds\Interface before use
	InterfacePath = GamePath + "Interface\"
	IngameTexPath = GamePath + "Textures\Interface\GameInterface\"
	If (FS.FileExists("GameInterface.dat")) Then
	   FS.CopyFile "GameInterface.dat", InterfacePath
	End If
	If (FS.FileExists("GameInterfaceX.dat")) Then
	   FS.CopyFile "GameInterfaceX.dat", InterfacePath
	End If
' uncomment and create dir D:\Games\TwoWorlds\Textures\Interface\GameInterface\ if you change files below
'	FS.CopyFile "GameInterface_1.dds", IngameTexPath
'	FS.CopyFile "GameInterface_2.dds", IngameTexPath
'	FS.CopyFile "GameInterface_3.dds", IngameTexPath
'	FS.CopyFile "DlgMessageBox.dds", IngameTexPath
'	FS.CopyFile "DlgBackground.dds", IngameTexPath
End Sub

'=====================================================================
Set FS = CreateObject("Scripting.FileSystemObject")
Set objNet = CreateObject("WScript.NetWork") 

If objNet.ComputerName = "OBELIKS" Then
	CopyFiles("D:\Games\TwoWorlds\")
	CopyFiles("D:\TwoWorlds\Game\")
'Else If
' ... mozna dopisac wlasne komputery ...

Else
	CopyFiles("D:\Games\TwoWorlds\")
End If

'FS.DeleteFile "GameInterface.dat"
'FS.DeleteFile "GameInterfaceX.dat"
Set FS = Nothing
Set objNet = Nothing
'=====================================================================
