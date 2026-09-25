Attribute VB_Name = "modRecordIO"
Option Explicit
' Generated from modTypes by tools/Generate-RecordCodecs.ps1. Disk fields are explicit; no raw UDT memory is serialized.
Public Sub ReadPlayerInvRec(ByVal file As clsDataFile, ByRef value As PlayerInvRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Num = file.ReadLong()
    value.Value = file.ReadLong()
    value.Dur = file.ReadInteger()
End Sub

Public Sub WritePlayerInvRec(ByVal file As clsDataFile, ByRef value As PlayerInvRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteLong value.Num
    file.WriteLong value.Value
    file.WriteInteger value.Dur
End Sub

Public Sub ResetPlayerInvRec(ByRef value As PlayerInvRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Num = 0
    value.Value = 0
    value.Dur = 0
End Sub

Public Sub ReadPlayerRec(ByVal file As clsDataFile, ByRef value As PlayerRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Sex = file.ReadByte()
    value.Class = file.ReadByte()
    value.Sprite = file.ReadInteger()
    value.Level = file.ReadLong()
    value.Exp = file.ReadLong()
    value.Access = file.ReadByte()
    value.PK = file.ReadByte()
    value.Guild = file.ReadLong()
    value.HP = file.ReadLong()
    value.MP = file.ReadLong()
    value.SP = file.ReadLong()
    value.STR = file.ReadLong()
    value.DEF = file.ReadLong()
    value.SPEED = file.ReadLong()
    value.MAGI = file.ReadLong()
    value.POINTS = file.ReadLong()
    value.ArmorSlot = file.ReadLong()
    value.WeaponSlot = file.ReadLong()
    value.HelmetSlot = file.ReadLong()
    value.ShieldSlot = file.ReadLong()
    For i0 = 1 To MAX_INV
    ReadPlayerInvRec file, value.Inv(i0)
    Next i0
    For i0 = 1 To MAX_PLAYER_SPELLS
    value.Spell(i0) = file.ReadLong()
    Next i0
    value.Map = file.ReadInteger()
    value.X = file.ReadByte()
    value.y = file.ReadByte()
    value.Dir = file.ReadByte()
End Sub

Public Sub WritePlayerRec(ByVal file As clsDataFile, ByRef value As PlayerRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteByte value.Sex
    file.WriteByte value.Class
    file.WriteInteger value.Sprite
    file.WriteLong value.Level
    file.WriteLong value.Exp
    file.WriteByte value.Access
    file.WriteByte value.PK
    file.WriteLong value.Guild
    file.WriteLong value.HP
    file.WriteLong value.MP
    file.WriteLong value.SP
    file.WriteLong value.STR
    file.WriteLong value.DEF
    file.WriteLong value.SPEED
    file.WriteLong value.MAGI
    file.WriteLong value.POINTS
    file.WriteLong value.ArmorSlot
    file.WriteLong value.WeaponSlot
    file.WriteLong value.HelmetSlot
    file.WriteLong value.ShieldSlot
    For i0 = 1 To MAX_INV
    WritePlayerInvRec file, value.Inv(i0)
    Next i0
    For i0 = 1 To MAX_PLAYER_SPELLS
    file.WriteLong value.Spell(i0)
    Next i0
    file.WriteInteger value.Map
    file.WriteByte value.X
    file.WriteByte value.y
    file.WriteByte value.Dir
End Sub

Public Sub ResetPlayerRec(ByRef value As PlayerRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Sex = 0
    value.Class = 0
    value.Sprite = 0
    value.Level = 0
    value.Exp = 0
    value.Access = 0
    value.PK = 0
    value.Guild = 0
    value.HP = 0
    value.MP = 0
    value.SP = 0
    value.STR = 0
    value.DEF = 0
    value.SPEED = 0
    value.MAGI = 0
    value.POINTS = 0
    value.ArmorSlot = 0
    value.WeaponSlot = 0
    value.HelmetSlot = 0
    value.ShieldSlot = 0
    For i0 = 1 To MAX_INV
    ResetPlayerInvRec value.Inv(i0)
    Next i0
    For i0 = 1 To MAX_PLAYER_SPELLS
    value.Spell(i0) = 0
    Next i0
    value.Map = 0
    value.X = 0
    value.y = 0
    value.Dir = 0
End Sub

Public Sub ReadTileRec(ByVal file As clsDataFile, ByRef value As TileRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Ground = file.ReadInteger()
    value.Mask = file.ReadInteger()
    value.Anim = file.ReadInteger()
    value.Mask2 = file.ReadInteger()
    value.M2Anim = file.ReadInteger()
    value.Fringe = file.ReadInteger()
    value.FAnim = file.ReadInteger()
    value.Fringe2 = file.ReadInteger()
    value.F2Anim = file.ReadInteger()
    value.Type = file.ReadByte()
    value.Data1 = file.ReadInteger()
    value.Data2 = file.ReadInteger()
    value.Data3 = file.ReadInteger()
End Sub

Public Sub WriteTileRec(ByVal file As clsDataFile, ByRef value As TileRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteInteger value.Ground
    file.WriteInteger value.Mask
    file.WriteInteger value.Anim
    file.WriteInteger value.Mask2
    file.WriteInteger value.M2Anim
    file.WriteInteger value.Fringe
    file.WriteInteger value.FAnim
    file.WriteInteger value.Fringe2
    file.WriteInteger value.F2Anim
    file.WriteByte value.Type
    file.WriteInteger value.Data1
    file.WriteInteger value.Data2
    file.WriteInteger value.Data3
End Sub

Public Sub ResetTileRec(ByRef value As TileRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Ground = 0
    value.Mask = 0
    value.Anim = 0
    value.Mask2 = 0
    value.M2Anim = 0
    value.Fringe = 0
    value.FAnim = 0
    value.Fringe2 = 0
    value.F2Anim = 0
    value.Type = 0
    value.Data1 = 0
    value.Data2 = 0
    value.Data3 = 0
End Sub

Public Sub ReadOldMapRec(ByVal file As clsDataFile, ByRef value As OldMapRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Revision = file.ReadLong()
    value.Moral = file.ReadByte()
    value.Up = file.ReadInteger()
    value.Down = file.ReadInteger()
    value.Left = file.ReadInteger()
    value.Right = file.ReadInteger()
    value.Music = file.ReadByte()
    value.BootMap = file.ReadInteger()
    value.BootX = file.ReadByte()
    value.BootY = file.ReadByte()
    value.Shop = file.ReadByte()
    For i1 = 0 To MAX_MAPY
    For i0 = 0 To MAX_MAPX
    ReadTileRec file, value.Tile(i0, i1)
    Next i0
    Next i1
    For i0 = 1 To MAX_MAP_NPCS
    value.Npc(i0) = file.ReadByte()
    Next i0
End Sub

Public Sub WriteOldMapRec(ByVal file As clsDataFile, ByRef value As OldMapRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteLong value.Revision
    file.WriteByte value.Moral
    file.WriteInteger value.Up
    file.WriteInteger value.Down
    file.WriteInteger value.Left
    file.WriteInteger value.Right
    file.WriteByte value.Music
    file.WriteInteger value.BootMap
    file.WriteByte value.BootX
    file.WriteByte value.BootY
    file.WriteByte value.Shop
    For i1 = 0 To MAX_MAPY
    For i0 = 0 To MAX_MAPX
    WriteTileRec file, value.Tile(i0, i1)
    Next i0
    Next i1
    For i0 = 1 To MAX_MAP_NPCS
    file.WriteByte value.Npc(i0)
    Next i0
End Sub

Public Sub ResetOldMapRec(ByRef value As OldMapRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Revision = 0
    value.Moral = 0
    value.Up = 0
    value.Down = 0
    value.Left = 0
    value.Right = 0
    value.Music = 0
    value.BootMap = 0
    value.BootX = 0
    value.BootY = 0
    value.Shop = 0
    For i1 = 0 To MAX_MAPY
    For i0 = 0 To MAX_MAPX
    ResetTileRec value.Tile(i0, i1)
    Next i0
    Next i1
    For i0 = 1 To MAX_MAP_NPCS
    value.Npc(i0) = 0
    Next i0
End Sub

Public Sub ReadMapRec(ByVal file As clsDataFile, ByRef value As MapRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Revision = file.ReadLong()
    value.Moral = file.ReadByte()
    value.Up = file.ReadInteger()
    value.Down = file.ReadInteger()
    value.Left = file.ReadInteger()
    value.Right = file.ReadInteger()
    value.Music = file.ReadInteger()
    value.BootMap = file.ReadInteger()
    value.BootX = file.ReadByte()
    value.BootY = file.ReadByte()
    value.Shop = file.ReadLong()
    value.Indoors = file.ReadByte()
    For i1 = 0 To MAX_MAPY
    For i0 = 0 To MAX_MAPX
    ReadTileRec file, value.Tile(i0, i1)
    Next i0
    Next i1
    For i0 = 1 To MAX_MAP_NPCS
    value.Npc(i0) = file.ReadLong()
    Next i0
    value.Respawn = file.ReadByte()
End Sub

Public Sub WriteMapRec(ByVal file As clsDataFile, ByRef value As MapRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteLong value.Revision
    file.WriteByte value.Moral
    file.WriteInteger value.Up
    file.WriteInteger value.Down
    file.WriteInteger value.Left
    file.WriteInteger value.Right
    file.WriteInteger value.Music
    file.WriteInteger value.BootMap
    file.WriteByte value.BootX
    file.WriteByte value.BootY
    file.WriteLong value.Shop
    file.WriteByte value.Indoors
    For i1 = 0 To MAX_MAPY
    For i0 = 0 To MAX_MAPX
    WriteTileRec file, value.Tile(i0, i1)
    Next i0
    Next i1
    For i0 = 1 To MAX_MAP_NPCS
    file.WriteLong value.Npc(i0)
    Next i0
    file.WriteByte value.Respawn
End Sub

Public Sub ResetMapRec(ByRef value As MapRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Revision = 0
    value.Moral = 0
    value.Up = 0
    value.Down = 0
    value.Left = 0
    value.Right = 0
    value.Music = 0
    value.BootMap = 0
    value.BootX = 0
    value.BootY = 0
    value.Shop = 0
    value.Indoors = 0
    For i1 = 0 To MAX_MAPY
    For i0 = 0 To MAX_MAPX
    ResetTileRec value.Tile(i0, i1)
    Next i0
    Next i1
    For i0 = 1 To MAX_MAP_NPCS
    value.Npc(i0) = 0
    Next i0
    value.Respawn = 0
End Sub

Public Sub ReadClassRec(ByVal file As clsDataFile, ByRef value As ClassRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Sprite = file.ReadInteger()
    value.FSprite = file.ReadInteger()
    value.STR = file.ReadByte()
    value.DEF = file.ReadByte()
    value.SPEED = file.ReadByte()
    value.MAGI = file.ReadByte()
End Sub

Public Sub WriteClassRec(ByVal file As clsDataFile, ByRef value As ClassRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteInteger value.Sprite
    file.WriteInteger value.FSprite
    file.WriteByte value.STR
    file.WriteByte value.DEF
    file.WriteByte value.SPEED
    file.WriteByte value.MAGI
End Sub

Public Sub ResetClassRec(ByRef value As ClassRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Sprite = 0
    value.FSprite = 0
    value.STR = 0
    value.DEF = 0
    value.SPEED = 0
    value.MAGI = 0
End Sub

Public Sub ReadItemRec(ByVal file As clsDataFile, ByRef value As ItemRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Pic = file.ReadInteger()
    value.Type = file.ReadByte()
    value.Data1 = file.ReadInteger()
    value.Data2 = file.ReadInteger()
    value.Data3 = file.ReadInteger()
    value.ClassReq = file.ReadInteger()
    value.LevelReq = file.ReadInteger()
    value.GuildReq = file.ReadInteger()
    value.Sound = file.ReadInteger()
End Sub

Public Sub WriteItemRec(ByVal file As clsDataFile, ByRef value As ItemRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteInteger value.Pic
    file.WriteByte value.Type
    file.WriteInteger value.Data1
    file.WriteInteger value.Data2
    file.WriteInteger value.Data3
    file.WriteInteger value.ClassReq
    file.WriteInteger value.LevelReq
    file.WriteInteger value.GuildReq
    file.WriteInteger value.Sound
End Sub

Public Sub ResetItemRec(ByRef value As ItemRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Pic = 0
    value.Type = 0
    value.Data1 = 0
    value.Data2 = 0
    value.Data3 = 0
    value.ClassReq = 0
    value.LevelReq = 0
    value.GuildReq = 0
    value.Sound = 0
End Sub

Public Sub ReadNpcRec(ByVal file As clsDataFile, ByRef value As NpcRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.AttackSay = file.ReadText(255)
    value.MaxHP = file.ReadLong()
    value.GiveEXP = file.ReadLong()
    value.ShopCall = file.ReadLong()
    value.Sprite = file.ReadInteger()
    value.SpawnSecs = file.ReadLong()
    value.Behavior = file.ReadByte()
    value.Range = file.ReadByte()
    value.DropChance = file.ReadInteger()
    value.DropItem = file.ReadLong()
    value.DropItemValue = file.ReadInteger()
    value.STR = file.ReadInteger()
    value.DEF = file.ReadInteger()
    value.SPEED = file.ReadInteger()
    value.MAGI = file.ReadInteger()
    value.Stationary = file.ReadByte()
End Sub

Public Sub WriteNpcRec(ByVal file As clsDataFile, ByRef value As NpcRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteText value.AttackSay, 255
    file.WriteLong value.MaxHP
    file.WriteLong value.GiveEXP
    file.WriteLong value.ShopCall
    file.WriteInteger value.Sprite
    file.WriteLong value.SpawnSecs
    file.WriteByte value.Behavior
    file.WriteByte value.Range
    file.WriteInteger value.DropChance
    file.WriteLong value.DropItem
    file.WriteInteger value.DropItemValue
    file.WriteInteger value.STR
    file.WriteInteger value.DEF
    file.WriteInteger value.SPEED
    file.WriteInteger value.MAGI
    file.WriteByte value.Stationary
End Sub

Public Sub ResetNpcRec(ByRef value As NpcRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.AttackSay = vbNullString
    value.MaxHP = 0
    value.GiveEXP = 0
    value.ShopCall = 0
    value.Sprite = 0
    value.SpawnSecs = 0
    value.Behavior = 0
    value.Range = 0
    value.DropChance = 0
    value.DropItem = 0
    value.DropItemValue = 0
    value.STR = 0
    value.DEF = 0
    value.SPEED = 0
    value.MAGI = 0
    value.Stationary = 0
End Sub

Public Sub ReadSignRec(ByVal file As clsDataFile, ByRef value As SignRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Line1 = file.ReadText(NAME_LENGTH)
    value.Line2 = file.ReadText(NAME_LENGTH)
    value.Line3 = file.ReadText(NAME_LENGTH)
    value.Background = file.ReadByte()
End Sub

Public Sub WriteSignRec(ByVal file As clsDataFile, ByRef value As SignRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteText value.Line1, NAME_LENGTH
    file.WriteText value.Line2, NAME_LENGTH
    file.WriteText value.Line3, NAME_LENGTH
    file.WriteByte value.Background
End Sub

Public Sub ResetSignRec(ByRef value As SignRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Line1 = vbNullString
    value.Line2 = vbNullString
    value.Line3 = vbNullString
    value.Background = 0
End Sub

Public Sub ReadQuestRec(ByVal file As clsDataFile, ByRef value As QuestRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(255)
    count = file.ReadArrayCount(NAME_LENGTH)
    capacity = MAX_QUEST_PLAYERS
    If count > capacity Then capacity = count
    ReDim value.Player(1 To capacity) As String * NAME_LENGTH
    For i0 = 1 To capacity
        value.Player(i0) = vbNullString
    Next i0
    For i0 = 1 To count
    value.Player(i0) = file.ReadText(NAME_LENGTH)
    Next i0
End Sub

Public Sub WriteQuestRec(ByVal file As clsDataFile, ByRef value As QuestRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, 255
    count = UBound(value.Player)
    If LBound(value.Player) <> 1 Then Err.Raise 5, "modRecordIO", "Invalid array lower bound"
    file.WriteArrayCount count
    For i0 = 1 To count
    file.WriteText value.Player(i0), NAME_LENGTH
    Next i0
End Sub

Public Sub ResetQuestRec(ByRef value As QuestRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    count = MAX_QUEST_PLAYERS
    If count < 1 Then count = 1
    ReDim value.Player(1 To count) As String * NAME_LENGTH
    For i0 = 1 To count
    value.Player(i0) = vbNullString
    Next i0
End Sub

Public Sub ReadTradeItemRec(ByVal file As clsDataFile, ByRef value As TradeItemRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.GiveItem = file.ReadLong()
    value.GiveValue = file.ReadLong()
    value.GiveItem2 = file.ReadLong()
    value.GiveValue2 = file.ReadLong()
    value.GetItem = file.ReadLong()
    value.GetValue = file.ReadLong()
End Sub

Public Sub WriteTradeItemRec(ByVal file As clsDataFile, ByRef value As TradeItemRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteLong value.GiveItem
    file.WriteLong value.GiveValue
    file.WriteLong value.GiveItem2
    file.WriteLong value.GiveValue2
    file.WriteLong value.GetItem
    file.WriteLong value.GetValue
End Sub

Public Sub ResetTradeItemRec(ByRef value As TradeItemRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.GiveItem = 0
    value.GiveValue = 0
    value.GiveItem2 = 0
    value.GiveValue2 = 0
    value.GetItem = 0
    value.GetValue = 0
End Sub

Public Sub ReadShopRec(ByVal file As clsDataFile, ByRef value As ShopRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.JoinSay = file.ReadText(255)
    value.LeaveSay = file.ReadText(255)
    value.FixesItems = file.ReadByte()
    For i0 = 1 To MAX_TRADES
    ReadTradeItemRec file, value.TradeItem(i0)
    Next i0
End Sub

Public Sub WriteShopRec(ByVal file As clsDataFile, ByRef value As ShopRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteText value.JoinSay, 255
    file.WriteText value.LeaveSay, 255
    file.WriteByte value.FixesItems
    For i0 = 1 To MAX_TRADES
    WriteTradeItemRec file, value.TradeItem(i0)
    Next i0
End Sub

Public Sub ResetShopRec(ByRef value As ShopRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.JoinSay = vbNullString
    value.LeaveSay = vbNullString
    value.FixesItems = 0
    For i0 = 1 To MAX_TRADES
    ResetTradeItemRec value.TradeItem(i0)
    Next i0
End Sub

Public Sub ReadSpellRec(ByVal file As clsDataFile, ByRef value As SpellRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.ClassReq = file.ReadByte()
    value.LevelReq = file.ReadInteger()
    value.MPReq = file.ReadLong()
    value.Type = file.ReadByte()
    value.Data1 = file.ReadInteger()
    value.Data2 = file.ReadInteger()
    value.Data3 = file.ReadInteger()
    value.Graphic = file.ReadInteger()
    value.Sound = file.ReadInteger()
End Sub

Public Sub WriteSpellRec(ByVal file As clsDataFile, ByRef value As SpellRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteByte value.ClassReq
    file.WriteInteger value.LevelReq
    file.WriteLong value.MPReq
    file.WriteByte value.Type
    file.WriteInteger value.Data1
    file.WriteInteger value.Data2
    file.WriteInteger value.Data3
    file.WriteInteger value.Graphic
    file.WriteInteger value.Sound
End Sub

Public Sub ResetSpellRec(ByRef value As SpellRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.ClassReq = 0
    value.LevelReq = 0
    value.MPReq = 0
    value.Type = 0
    value.Data1 = 0
    value.Data2 = 0
    value.Data3 = 0
    value.Graphic = 0
    value.Sound = 0
End Sub

Public Sub ReadGuildRec(ByVal file As clsDataFile, ByRef value As GuildRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = file.ReadText(NAME_LENGTH)
    value.Founder = file.ReadText(NAME_LENGTH)
    value.Abbreviation = file.ReadText(10)
    count = file.ReadArrayCount(NAME_LENGTH)
    capacity = MAX_GUILD_MEMBERS
    If count > capacity Then capacity = count
    ReDim value.Member(1 To capacity) As String * NAME_LENGTH
    For i0 = 1 To capacity
        value.Member(i0) = vbNullString
    Next i0
    For i0 = 1 To count
    value.Member(i0) = file.ReadText(NAME_LENGTH)
    Next i0
End Sub

Public Sub WriteGuildRec(ByVal file As clsDataFile, ByRef value As GuildRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    file.WriteText value.Name, NAME_LENGTH
    file.WriteText value.Founder, NAME_LENGTH
    file.WriteText value.Abbreviation, 10
    count = UBound(value.Member)
    If LBound(value.Member) <> 1 Then Err.Raise 5, "modRecordIO", "Invalid array lower bound"
    file.WriteArrayCount count
    For i0 = 1 To count
    file.WriteText value.Member(i0), NAME_LENGTH
    Next i0
End Sub

Public Sub ResetGuildRec(ByRef value As GuildRec)
    Dim i0 As Long, i1 As Long, count As Long, capacity As Long
    value.Name = vbNullString
    value.Founder = vbNullString
    value.Abbreviation = vbNullString
    count = MAX_GUILD_MEMBERS
    If count < 1 Then count = 1
    ReDim value.Member(1 To count) As String * NAME_LENGTH
    For i0 = 1 To count
    value.Member(i0) = vbNullString
    Next i0
End Sub

Public Sub EnsureDataFolders(ByVal root As String)
    Dim folder As Variant, path As String, attributes As Long
    For Each folder In Array("data", "maps", "data\accounts", "data\guilds", "data\quests", "data\Shops", "data\Npcs", "data\Spells", "data\items", "data\Signs")
        path = root & "\" & CStr(folder)
        attributes = WinDevLib.GetFileAttributes(path)
        If attributes = -1 Then
            If WinDevLib.CreateDirectory(path, ByVal vbNullPtr) = 0 Then Err.Raise 75, "EnsureDataFolders", "Cannot create data directory: " & path
        ElseIf (attributes And WinDevLib.FILE_ATTRIBUTE_DIRECTORY) = 0 Then
            Err.Raise 75, "EnsureDataFolders", "Expected a directory: " & path
        End If
    Next folder
End Sub