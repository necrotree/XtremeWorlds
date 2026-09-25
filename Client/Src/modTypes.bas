Attribute VB_Name = "modTypes"
'****************************************************************
'* WHEN    WHO    WHAT
'* ----    ---    ----
'* 07/12/2005  Shannara   Trimmed module.
'****************************************************************

Option Explicit

' Public structure variables
Public Map As MapRec
Public TempTile(0 To MAX_MAPX, 0 To MAX_MAPY) As TempTileRec
Public Player() As PlayerRec
Public Class() As ClassRec
Public Item() As ItemRec
Public Npc() As NpcRec
Public MapItem(1 To MAX_MAP_ITEMS) As MapItemRec
Public MapNpc(1 To MAX_MAP_NPCS) As MapNpcRec
Public Shop() As ShopRec
Public Sign() As SignRec
Public Spell() As SpellRec
Public Guild() As GuildRec
Public GameData As DataRec

Public Type TextSize
    Width As Long
    Height As Long
End Type

Type DataRec
  IP As String * NAME_LENGTH
  Port As Integer
  Autoupdater As Byte
  SaveLogin As Byte
  Username As String * NAME_LENGTH
  Password As String * NAME_LENGTH
  Music As Byte
  Sound As Byte
  PlayerNames As Byte
  NpcNames As Byte
  SpellGFX As Byte
  PlayerX As Integer
  PlayerY As Integer
  XOffset As Byte
  YOffset As Byte
End Type
  
Type PlayerInvRec
  Num As Long
  Value As Long
  Dur As Integer
End Type

Type PlayerRec
  ' General
  name As String * NAME_LENGTH
  Class As Byte
  Sprite As Integer
  Level As Long
  Exp As Long
  Access As Byte
  PK As Byte
  Guild As Long
  
  ' Vitals
  HP As Long
  MP As Long
  SP As Long
  
  ' Stats
  STR As Long
  DEF As Long
  speed As Long
  MAGI As Long
  POINTS As Long
  
  ' Worn equipment
  ArmorSlot As Byte
  WeaponSlot As Byte
  HelmetSlot As Byte
  ShieldSlot As Byte
  
  ' Inventory
  Inv(1 To MAX_INV) As PlayerInvRec
  Spell(1 To MAX_PLAYER_SPELLS) As Long
     
  ' Position
  Map As Integer
  X As Byte
  Y As Byte
  Dir As Byte
  
  ' Client use only
  MaxHP As Long
  MaxMP As Long
  MaxSP As Long
  XOffset As Integer
  YOffset As Integer
  Moving As Byte
  Attacking As Byte
  AttackTimer As Long
  MapGetTimer As Long
  CastedSpell As Byte
  
  Anim As Byte
End Type
  
Type TileRec
  Ground As Integer
  Mask As Integer
  Anim As Integer
  Mask2 As Integer
  M2Anim As Integer
  Fringe As Integer
  FAnim As Integer
  Fringe2 As Integer
  F2Anim As Integer
  Type As Byte
  Data1 As Integer
  Data2 As Integer
  Data3 As Integer
End Type

Type MapRec
  name As String * NAME_LENGTH
  Revision As Long
  Moral As Byte
  Up As Integer
  Down As Integer
  Left As Integer
  Right As Integer
  Music As Integer
  BootMap As Integer
  BootX As Byte
  BootY As Byte
  Shop As Long
  Indoors As Byte
  Tile(0 To MAX_MAPX, 0 To MAX_MAPY) As TileRec
  Npc(1 To MAX_MAP_NPCS) As Long
  Respawn As Byte
End Type

Type ClassRec
  name As String * NAME_LENGTH
  Sprite As Integer
  FSprite As Integer
  
  STR As Byte
  DEF As Byte
  speed As Byte
  MAGI As Byte
  
  ' For client use
  HP As Long
  MP As Long
  SP As Long
End Type

Type ItemRec
  name As String * NAME_LENGTH
  
  Pic As Integer
  Type As Byte
  Data1 As Integer
  Data2 As Integer
  Data3 As Integer
  ClassReq As Integer
  LevelReq As Integer
  GuildReq As Integer
  Sound As Integer
End Type

Type MapItemRec
  Num As Long
  Value As Long
  Dur As Integer
  
  X As Byte
  Y As Byte
End Type

Type NpcRec
  name As String * NAME_LENGTH
  AttackSay As String * 255
  
  MaxHP As Long
  GiveEXP As Long
  ShopCall As Long
  
  Sprite As Integer
  SpawnSecs As Long
  Behavior As Byte
  Range As Byte
  
  DropChance As Integer
  DropItem As Long
  DropItemValue As Integer
  
  STR  As Integer
  DEF As Integer
  speed As Integer
  MAGI As Integer
  
  Stationary As Byte
End Type

Type SignRec
  name As String * NAME_LENGTH
  
  Line1 As String * NAME_LENGTH
  Line2 As String * NAME_LENGTH
  Line3 As String * NAME_LENGTH
  
  Background As Byte
  
End Type

Type MapNpcRec
  Num As Byte
  
  Target As Byte
  
  HP As Long
  MaxHP As Long
  MP As Long
  SP As Long
    
  Map As Integer
  X As Byte
  Y As Byte
  Dir As Integer

  ' Client use only
  XOffset As Integer
  YOffset As Integer
  Moving As Byte
  Attacking As Byte
  AttackTimer As Long
End Type

Type TradeItemRec
  GiveItem As Long
  GiveValue As Long
  GiveItem2 As Long
  GiveValue2 As Long
  GetItem As Long
  GetValue As Long
End Type

Type ShopRec
  name As String * NAME_LENGTH
  JoinSay As String * 255
  LeaveSay As String * 255
  FixesItems As Byte
  TradeItem(1 To MAX_TRADES) As TradeItemRec
End Type

Type SpellRec
  name As String * NAME_LENGTH
  ClassReq As Byte
  LevelReq As Integer
  MPReq As Long
  Type As Byte
  Data1 As Integer
  Data2 As Integer
  Data3 As Integer
  Graphic As Integer
  Sound As Integer
End Type

Type TempTileRec
  DoorOpen As Byte
End Type

Type GuildRec
  name As String * NAME_LENGTH
  Abbreviation As String * 10
  Founder As String * NAME_LENGTH
  Member() As String * NAME_LENGTH
End Type

