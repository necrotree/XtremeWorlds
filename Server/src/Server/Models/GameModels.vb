Imports System.Text.Json.Serialization

Public Module GameLimits
    Public Const NameLength As Integer = 50
    Public Const MaxCharacters As Integer = 3
    Public Const MaxInventory As Integer = 75
    Public Const MaxPlayerSpells As Integer = 40
    Public Const MaxMapX As Integer = 15
    Public Const MaxMapY As Integer = 11
    Public Const MaxMapNpcs As Integer = 10
    Public Const MaxMapItems As Integer = 20
    Public Const MaxTrades As Integer = 8
End Module

Public Class PlayerInventory
    Public Property Num As Integer
    Public Property Value As Integer
    Public Property Durability As Short
End Class

Public Class PlayerCharacter
    Public Property Name As String = ""
    Public Property Sex As Byte
    Public Property ClassId As Byte
    Public Property Sprite As Short
    Public Property Level As Integer
    Public Property Exp As Integer
    Public Property Access As Byte
    Public Property PK As Byte
    Public Property Guild As Integer
    Public Property HP As Integer
    Public Property MP As Integer
    Public Property SP As Integer
    Public Property Strength As Integer
    Public Property Defense As Integer
    Public Property Speed As Integer
    Public Property Magic As Integer
    Public Property Points As Integer
    Public Property ArmorSlot As Integer
    Public Property WeaponSlot As Integer
    Public Property HelmetSlot As Integer
    Public Property ShieldSlot As Integer
    Public Property Inventory As New List(Of PlayerInventory)()
    Public Property Spells As New List(Of Integer)()
    Public Property Map As Short
    Public Property X As Byte
    Public Property Y As Byte
    Public Property Direction As Byte
End Class

Public Class TileDefinition
    Public Property Ground As Short
    Public Property Mask As Short
    Public Property Anim As Short
    Public Property Mask2 As Short
    Public Property M2Anim As Short
    Public Property Fringe As Short
    Public Property FAnim As Short
    Public Property Fringe2 As Short
    Public Property F2Anim As Short
    Public Property Type As Byte
    Public Property Data1 As Short
    Public Property Data2 As Short
    Public Property Data3 As Short
End Class

Public Class MapDefinition
    Public Property Name As String = ""
    Public Property Revision As Integer
    Public Property Moral As Byte
    Public Property Up As Short
    Public Property Down As Short
    Public Property Left As Short
    Public Property Right As Short
    Public Property Music As Short
    Public Property BootMap As Short
    Public Property BootX As Byte
    Public Property BootY As Byte
    Public Property Shop As Integer
    Public Property Indoors As Byte
    Public Property Respawn As Byte
    Public Property Tileset As Byte
    Public Property Tiles As New List(Of TileDefinition)()
    Public Property Npcs As New List(Of Integer)()
    Public Property LayerTileset As New List(Of Byte)()
End Class

Public Class ClassDefinition
    Public Property Name As String = ""
    Public Property MaleSprite As Short
    Public Property FemaleSprite As Short
    Public Property Strength As Byte
    Public Property Defense As Byte
    Public Property Speed As Byte
    Public Property Magic As Byte
    Public Property Map As Short
    Public Property X As Byte
    Public Property Y As Byte
End Class

Public Class ItemDefinition
    Public Property Name As String = ""
    Public Property Pic As Short
    Public Property Type As Byte
    Public Property Data1 As Short
    Public Property Data2 As Short
    Public Property Data3 As Short
    Public Property ClassReq As Short
    Public Property LevelReq As Short
    Public Property GuildReq As Short
    Public Property Sound As Short
End Class

Public Class NpcDefinition
    Public Property Name As String = ""
    Public Property AttackSay As String = ""
    Public Property MaxHP As Integer
    Public Property GiveEXP As Integer
    Public Property ShopCall As Integer
    Public Property Sprite As Short
    Public Property SpawnSecs As Integer
    Public Property Behavior As Byte
    Public Property Range As Byte
    Public Property DropChance As Short
    Public Property DropItem As Integer
    Public Property DropItemValue As Short
    Public Property Strength As Short
    Public Property Defense As Short
    Public Property Speed As Short
    Public Property Magic As Short
    Public Property Stationary As Byte
End Class

Public Class ShopTrade
    Public Property GiveItem As Integer
    Public Property GiveValue As Integer
    Public Property GiveItem2 As Integer
    Public Property GiveValue2 As Integer
    Public Property GetItem As Integer
    Public Property GetValue As Integer
End Class

Public Class ShopDefinition
    Public Property Name As String = ""
    Public Property JoinSay As String = ""
    Public Property LeaveSay As String = ""
    Public Property FixesItems As Byte
    Public Property Trades As New List(Of ShopTrade)()
End Class

Public Class SpellDefinition
    Public Property Name As String = ""
    Public Property ClassReq As Byte
    Public Property LevelReq As Short
    Public Property MPReq As Integer
    Public Property Type As Byte
    Public Property Data1 As Short
    Public Property Data2 As Short
    Public Property Data3 As Short
    Public Property Graphic As Short
    Public Property Sound As Short
End Class

Public Class SignDefinition
    Public Property Name As String = ""
    Public Property Line1 As String = ""
    Public Property Line2 As String = ""
    Public Property Line3 As String = ""
    Public Property Background As Byte
End Class

Public Class GuildDefinition
    Public Property Name As String = ""
    Public Property Founder As String = ""
    Public Property Abbreviation As String = ""
    Public Property Members As New List(Of String)()
End Class

Public Class QuestDefinition
    Public Property Name As String = ""
    Public Property Players As New List(Of String)()
End Class

Public Class ArrowDefinition
    Public Property Name As String = ""
    Public Property Sprite As Integer
    Public Property Range As Integer
End Class

Public Class BanDefinition
    Public Property BannedIP As String = ""
    Public Property BannedCharacter As String = ""
    Public Property BannedBy As String = ""
    Public Property BannedHardwareId As String = ""
End Class
