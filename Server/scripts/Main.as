'**************************************************************************
'* This is a sample Main.as script for Playerworlds. You may modify this  *
'* to suit the needs of your server.                      *
'**************************************************************************

'**************************
'* Edit the values below. *
'**************************
Public Const GAME_NAME = "Playerworlds" ' Name of game
Public Const WEB_SITE = "http://www.playerworlds.com" ' Website

Public Const GAME_PORT = 7234 ' Run off What Port?
Public Const MAX_PLAYERS = 50 ' Max Players
Public Const MAX_MAPS = 50 ' Max Maps
Public Const MAX_ITEMS = 255 ' Max Items
Public Const MAX_SHOPS = 255 ' Max Shops
Public Const MAX_SPELLS = 255 ' Max Spells
Public Const MAX_SIGNS = 255 ' Max Signs
Public Const MAX_NPCS = 255 ' Max NPCs
Public Const MAX_GUILDS = 255 ' Max Guilds
Public Const MAX_GUILD_MEMBERS = 255 ' Max Guild Members
Public Const MAX_QUESTS = 255 ' Max Quests
Public Const MAX_QUEST_PLAYERS = 255 ' Max People Who Can Complete the Quest


' Where will New Players begin?
Public Const START_MAP = 1
Public Const START_X = 5
Public Const START_Y = 8

Public Const DEBUG = YES ' Find errors in script file

'************************
'* Game core constants. *
'************************

' Map constants [DO NOT EDIT]
Public Const MAP_MORAL_NONE = 0
Public Const MAP_MORAL_SAFE = 1
Public Const MAP_MORAL_INN = 2
Public Const MAP_MORAL_ARENA = 3


' Item constants [DO NOT EDIT]
Public Const ITEM_TYPE_NONE = 0
Public Const ITEM_TYPE_WEAPON = 1
Public Const ITEM_TYPE_ARMOR = 2
Public Const ITEM_TYPE_HELMET = 3
Public Const ITEM_TYPE_SHIELD = 4
Public Const ITEM_TYPE_POTIONADDHP = 5 ' The rest may not be needed
Public Const ITEM_TYPE_POTIONADDMP = 6
Public Const ITEM_TYPE_POTIONADDSP = 7
Public Const ITEM_TYPE_POTIONSUBHP = 8
Public Const ITEM_TYPE_POTIONSUBMP = 9
Public Const ITEM_TYPE_POTIONSUBSP = 10
Public Const ITEM_TYPE_KEY = 11
Public Const ITEM_TYPE_CURRENCY = 12
Public Const ITEM_TYPE_SPELL = 13
Public Const ITEM_TYPE_WARP = 14

' Color constants [DO NOT EDIT]
Public Const BLACK = 0
Public Const BLUE = 1
Public Const GREEN = 2
Public Const CYAN = 3
Public Const RED = 4
Public Const MAGENTA = 5
Public Const BROWN = 6
Public Const GREY = 7
Public Const DARKGREY = 8
Public Const BRIGHTBLUE = 9
Public Const BRIGHTGREEN = 10
Public Const BRIGHTCYAN = 11
Public Const BRIGHTRED = 12
Public Const PINK = 13
Public Const YELLOW = 14
Public Const WHITE = 15

' Boolean values [DO NOT EDIT]
Public Const NO = 0 ' False
Public Const YES = 1 ' True


Sub ServerSet()
'**************************************************
'* This event is fired to setup your information. *
'**************************************************

    ' Initialize server
    Call SetServerName(GAME_NAME)
    Call SetWebsite(WEB_SITE)
    Call SetServerPort(GAME_PORT)
    Call SetMaxPlayers(MAX_PLAYERS)
    Call SetMaxMaps(MAX_MAPS)
    Call SetMaxItems(MAX_ITEMS)
    Call SetMaxShops(MAX_SHOPS)
    Call SetMaxSpells(MAX_SPELLS)
    Call SetMaxSigns(MAX_SIGNS)
    Call SetMaxNPCs(MAX_NPCS)
    Call SetMaxGuilds(MAX_GUILDS)
    Call SetMaxGuildMembers(MAX_GUILD_MEMBERS)
    Call SetMaxQuests(MAX_QUESTS)
    Call SetMaxQuestPlayers(MAX_QUEST_PLAYERS)
    Call SetStartPosition(START_MAP, START_X, START_Y)

    Call SetDebugScripting(DEBUG)

End Sub


Sub JoinGame(Player)
'**********************************************************
'* This event is fired when a player has joined the game. *
'**********************************************************

    ' Send a global message that he/she joined
    If GetPlayerAccess(Player) <= 1 Then
        Call GlobalMsg(GetPlayerName(Player) & " has joined " & GetServerName & "!", WHITE)
    Else
        Call GlobalMsg(GetPlayerName(Player) & " has joined " & GetServerName & "!", WHITE)
    End If

End Sub


Sub LeftGame(Player)
'********************************************************
'* This event is fired when a player has left the game. *
'********************************************************

    ' Send a global message that he/she left
    If GetPlayerAccess(Player) <= 1 Then
        Call GlobalMsg(GetPlayerName(Player) & " has left " & GetServerName & "!", DARKGREY)
    Else
        Call GlobalMsg(GetPlayerName(Player) & " has left " & GetServerName & "!", WHITE)
    End If

End Sub


Sub JoinMap(Player)
'****************************************************************
'* This event is fired when a player steps on a particular map. *
'****************************************************************


End Sub


Sub LeaveMap(Player)
'***************************************************************
'* This event is fired when a player leaves a particular map.  *
'***************************************************************


End Sub


Sub OnScriptedTile(Player)
'*****************************************************************
'* This event is fired when a player steps on a particular tile. *
'*****************************************************************


End Sub


Sub OnNpcDeath(Attacker, NpcNum, MapNum, NpcNumOnMap)
'***************************************************
'* This event is fired when a player kills an NPC. *
'***************************************************


End Sub


Sub OnDeathByNpc(Victim, NpcNum, MapNum, NpcNumOnMap)
'***************************************************
'* This event is fired when an NPC kills a player. *
'***************************************************
Dim Exp
Dim strStart
Dim strLate


    ' Tell the victim that the damage that has been done and let everyone know they are dead.
    If IsVowel(GetNpcName(NpcNum)) Then
        strStart = "An "
        strLate = "an "
    Else
        strStart = "A "
        strLate = "a "
    End If

    'Actually send the messages.
    Call PlayerMsg(Victim, strStart & GetNpcName(NpcNum) & " hit you for " & Damage & " hit points, killing you.", BRIGHTRED)
    Call GlobalMsg(GetPlayerName(Victim) & " has been killed by " & strLate & GetNpcName(NpcNum), BRIGHTRED)


    ' Calculate exp the victim will loose.
    Exp = CInt(GetPlayerExp(Victim) / 3)

    ' Make sure we dont set it to less then 0
    If Exp < 0 Then
        Exp = 0
    End If

    If Exp = 0 Then
        Call PlayerMsg(Victim, "You lost no experience points.", BRIGHTRED)
    Else
        Call SetPlayerExp(Victim, GetPlayerExp(Victim) - Exp)
        Call PlayerMsg(Victim, "You lost " & Exp & " experience points.", BRIGHTRED)
    End If

End Sub


Sub OnDeathByPlayer(Victim, Attacker, MapNum, MapMoral)
'******************************************************
'* This event is fired when an player kills a player. *
'******************************************************
Dim Exp

    If MapMoral = MAP_MORAL_ARENA Then
        Call GlobalMsg(GetPlayerName(Victim) & " was defeated in an arena by " & GetPlayerName(Attacker) & "!", YELLOW)
    Else
        Call GlobalMsg(GetPlayerName(Victim) & " has been killed by " & GetPlayerName(Attacker), BRIGHTRED)
    End If

    ' If map is an arena then don't drop items or lose exp, else do that stuff
    If MapMoral <> MAP_MORAL_ARENA Then

        ' Drop all worn items by victim
        If GetPlayerWeaponSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerWeaponSlot(Victim), 0)
        End If
        If GetPlayerArmorSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerArmorSlot(Victim), 0)
        End If
        If GetPlayerHelmetSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerHelmetSlot(Victim), 0)
        End If
        If GetPlayerShieldSlot(Victim) > 0 Then
            Call PlayerMapDropItem(Victim, GetPlayerShieldSlot(Victim), 0)
        End If

        ' Calculate exp to give attacker
        Exp = CInt(GetPlayerExp(Victim) / 10)

        ' Make sure we dont get less then 0
        If Exp < 0 Then
            Exp = 0
        End If

        If Exp = 0 Then
            Call PlayerMsg(Victim, "You lost no experience points.", BRIGHTRED)
            Call PlayerMsg(Attacker, "You received no experience points from that weak insignificant player.", BRIGHTBLUE)
        Else
            Call SetPlayerExp(Victim, GetPlayerExp(Victim) - Exp)
            Call PlayerMsg(Victim, "You lost " & Exp & " experience points.", BRIGHTRED)
            Call SetPlayerExp(Attacker, GetPlayerExp(Attacker) + Exp)
            Call PlayerMsg(Attacker, "You got " & Exp & " experience points for killing " & GetPlayerName(Victim) & ".", BRIGHTBLUE)
        End If
    End If

End Sub


Sub OnLevelUp(Player)
'*********************************************************
'* This event is fired when a player has gained a level. *
'*********************************************************
Dim I
Dim ExtraEXP

    If GetPlayerExp(Player) > GetPlayerNextLevel(Player) Then
        ExtraEXP = (GetPlayerExp(Player) - GetPlayerNextLevel(Player))
    Else
        ExtraEXP = 0
    End If

    Call SetPlayerLevel(Player, GetPlayerLevel(Player) + 1)

    ' Get the ammount of skill points to add
    I = Int(GetPlayerSPEED(Player) / 10)
    If I < 1 Then I = 1
    If I > 3 Then I = 3
    If I > 5 Then I = 4
    If I > 9 Then I = 5

    Call SetPlayerPOINTS(Player, GetPlayerPOINTS(Player) + I)
    Call SetPlayerExp(Player, ExtraEXP)
    Call GlobalMsg(GetPlayerName(Player) & " has gained a level!", BROWN)
    Call PlayerMsg(Player, "You have gained a level!  You now have " & GetPlayerPOINTS(Player) & " stat points to distribute.", BRIGHTBLUE)

End Sub


Sub OnEquipItem(Player, InvNum, ItemType, ItemNum)
'*****************************************************
'* This event is fired when a player equips an item. *
'*****************************************************


End Sub


Sub OnUnEquipItem(Player, InvNum, ItemType, ItemNum)
'*******************************************************
'* This event is fired when a player unequips an item. *
'*******************************************************


End Sub


Sub OnUseItem(Player, InvNum, ItemType, ItemNum)
'***************************************************************************
'* This event is fired when a player uses an item that cannot be equipped. *
'***************************************************************************


End Sub


Sub OnItemDrop(Player, ItemNum, ItemVal, ItemDur, InvSlot)
'****************************************************
'* This event is fired when a player drops an item. *
'****************************************************


End Sub


Sub OnTime(tTime, tSeconds)
'***************************************************************
'* This event is fired when the appropriate time has happened. *
'***************************************************************

    Select Case tTime

        Case 0 'second ** Currently not supported **

        Case 1 'minute

        Case 2 'hour
            Call AdminMessage("The time is now " & Time & ".", WHITE)
            
        Case 3 'day
            Call GlobalMessage("Today's date is " & Date & ".", WHITE)
            
        Case 4 'week

        Case 5 'month ** Currently not supported **

        Case 6 'year

    End Select

End Sub