Attribute VB_Name = "modTypes"
Option Explicit

' public data structures
Public Map() As MapRec
Public TempTile() As TempTileRec
Public PlayersOnMap() As Long
Public Player() As AccountRec
Public Class() As ClassRec
Public Item() As ItemRec
Public Npc() As NpcRec
Public MapItem() As MapItemRec
Public MapNpc() As MapNpcRec
Public Shop() As ShopRec
Public Sign() As SignRec
Public Spell() As SpellRec
Public Guild() As GuildRec
Public Quest() As QuestRec
Public Ban() As BanRec

Type PlayerInvRec
  Num As Long
  Value As Long
  Dur As Integer
End Type

Type PlayerRec
  ' General
  Name As String * NAME_LENGTH
  Sex As Byte
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
  SPEED As Long
  MAGI As Long
  POINTS As Long
  
  ' Worn equipment
  ArmorSlot As Long
  WeaponSlot As Long
  HelmetSlot As Long
  ShieldSlot As Long
  
  ' Inventory
  Inv(1 To MAX_INV) As PlayerInvRec
  Spell(1 To MAX_PLAYER_SPELLS) As Long
  
  ' Position
  Map As Integer
  X As Byte
  y As Byte
  Dir As Byte
End Type
  
Type AccountRec
  ' Account
  Login As String * NAME_LENGTH
  Password As String * NAME_LENGTH
  EncKey As String
     
  ' Characters (we use 0 to prevent a crash that still needs to be figured out)
  Char(0 To MAX_CHARS) As PlayerRec
  
  ' None saved local vars
  Buffer As String
  IncBuffer As String
  CharNum As Byte
  InGame As Boolean
  AttackTimer As Long
  DataTimer As Long
  DataBytes As Long
  DataPackets As Long
  PartyPlayer As Long
  InParty As Byte
  TargetType As Byte
  Target As Byte
  CastedSpell As Byte
  PartyStarter As Byte
  GettingMap As Byte
  HDSerial As String
  WarpTick As Long
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

Type OldMapRec
  Name As String * NAME_LENGTH
  Revision As Long
  Moral As Byte
  Up As Integer
  Down As Integer
  Left As Integer
  Right As Integer
  Music As Byte
  BootMap As Integer
  BootX As Byte
  BootY As Byte
  Shop As Byte
  Tile(0 To MAX_MAPX, 0 To MAX_MAPY) As TileRec
  Npc(1 To MAX_MAP_NPCS) As Byte
End Type

Type MapRec
  Name As String * NAME_LENGTH
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
  Name As String * NAME_LENGTH
  Sprite As Integer
  FSprite As Integer
  
  STR As Byte
  DEF As Byte
  SPEED As Byte
  MAGI As Byte
End Type

Type ItemRec
  Name As String * NAME_LENGTH
  
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
  y As Byte
End Type

Type NpcRec
  Name As String * NAME_LENGTH
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
  SPEED As Integer
  MAGI As Integer
  
  Stationary As Byte
End Type

Type SignRec
  Name As String * NAME_LENGTH
  
  Line1 As String * NAME_LENGTH
  Line2 As String * NAME_LENGTH
  Line3 As String * NAME_LENGTH
  
  Background As Byte
  
End Type

Type QuestRec
    Name As String * 255
    Player() As String * NAME_LENGTH
End Type

Type MapNpcRec
  Num As Integer
  
  Target As Integer
  
  HP As Long
  MaxHP As Long
  MP As Long
  SP As Long
    
  X As Byte
  y As Byte
  Dir As Integer
  
  ' For server use only
  SpawnWait As Long
  AttackTimer As Long
  Moveable As Byte
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
  Name As String * NAME_LENGTH
  JoinSay As String * 255
  LeaveSay As String * 255
  FixesItems As Byte
  TradeItem(1 To MAX_TRADES) As TradeItemRec
End Type
  
Type SpellRec
  Name As String * NAME_LENGTH
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
  DoorOpen(0 To MAX_MAPX, 0 To MAX_MAPY) As Byte
  DoorTimer As Long
End Type

Type GuildRec
  Name As String * NAME_LENGTH
  Founder As String * NAME_LENGTH
  Abbreviation As String * 10
  Member() As String * NAME_LENGTH
End Type

Type BanRec
  BannedIP As String
  BannedChar As String
  BannedBy As String
  BannedHD As String
End Type

