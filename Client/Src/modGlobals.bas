Attribute VB_Name = "modGlobals"
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Created module.
' ****************************************************************

Option Explicit

' for MyEtxt

Public TxtHasFocus As Boolean

Public DmgDamage As Long
Public DmgTime As Long
Public NPCDmgDamage As Long
Public NPCDmgTime As Long
Public NPCWho As Long
Public II As Long, iii As Long

' HD Serial Stuff
Public oHDSN As New clsHDSN
Public HDSerial As String
Public HDModel As String

' Used for HighIndex
Public HighIndex As Long

' TCP variables
Public ServerIP As String
Public PlayerBuffer As String
Public InGame As Boolean

' Text variables
Public vbQuote As String


' Direct3D 11 textures and map layers
Public DD_SpriteSurf As clsDX11Surface
Public DD_TileSurf As clsDX11Surface
Public DD_ItemSurf As clsDX11Surface
Public DD_SpellSurf As clsDX11Surface
Public DD_ArrowSurf As clsDX11Surface
Public DD_BackBuffer As clsDX11Surface
Public DD_LowerBuffer As clsDX11Surface
Public DD_MiddleBuffer As clsDX11Surface
Public DD_UpperBuffer As clsDX11Surface


Public rec As RECT
Public rec_pos As RECT


' Text variables
Public TexthDC As Long
Public GameFont As Long


' Game direction vars
Public DirUp As Boolean
Public DirDown As Boolean
Public DirLeft As Boolean
Public DirRight As Boolean
Public ShiftDown As Boolean
Public ControlDown As Boolean

' Game text buffer
Public MyText As String

' Index of actual player
Public MyIndex As Long

' For Sprite Preview
Public TempCharSprite As Integer

' Map animation #, used to keep track of what map animation is currently on
Public MapAnim As Byte
Public MapAnimTimer As Long

' Used to freeze controls when getting a new map
Public GettingMap As Boolean

' Used to check if FPS needs to be drawn
Public BFPS As Boolean
Public BLoc As Boolean


' Used to check if in editor or not and variables for use in editor
Public InEditor As Boolean
Public EditorTileX As Long
Public EditorTileY As Long
Public EditorWarpMap As Long
Public EditorWarpX As Long
Public EditorWarpY As Long
Public EditorscrlPicture As Long
Public EditorBlockPlayer As Long
Public EditorBlockNPC As Long
Public EditorBlockFlight As Long
Public EditorNudge As Long

' Used for map sign number
Public SignNum As Integer

' Used for map sprite number
Public SpriteNum As Integer

' Used for map item editor
Public ItemEditorNum As Long
Public ItemEditorValue As Long

' Used for map damage editor
Public KillValue As Long
Public KillVoidItem As Long

' Used for Map Message editor
Public MsgEditorText As String
Public MsgEditorType As Byte

' Used for map key editor
Public KeyEditorNum As Long
Public KeyEditorTake As Long

' Used for map key opene ditor
Public KeyOpenEditorX As Long
Public KeyOpenEditorY As Long

' Used for SpawnNpc editor
Public SpawnNpcNum As Long
Public SpawnNpcDir As Long
Public SpawnNpcStill As Long

' Map for local use
Public SaveMap As MapRec
Public SaveMapItem(1 To MAX_MAP_ITEMS) As MapItemRec
Public SaveMapNpc(1 To MAX_MAP_NPCS) As MapNpcRec

' Used for index based editors
Public InItemsEditor As Boolean
Public InNpcEditor As Boolean
Public InShopEditor As Boolean
Public InSpellEditor As Boolean
Public EditorIndex As Long
Public InSignEditor As Boolean

' Game fps
Public GameFPS As Long

' Loc of pointer
Public CurX As Integer
Public CurY As Integer

' Used for atmosphere
Public GameWeather As Long
Public GameTime As Long

' Used for parsing
Public SEP_CHAR As String * 1
Public END_CHAR As String * 1

' Maximum classes
Public Max_Classes As Byte

' Spell Animation
Public VicX As Byte
Public VicY As Byte
Public SpellAnim As Byte
Public SpellVar As Byte
Public SpellAnimTimer As Long

