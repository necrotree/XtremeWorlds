--**************************************************************************
-- XtremeWorlds main server script.
-- Lua translation of the supplied Playerworlds Main.as script.
--**************************************************************************

-- Editable server values.
GAME_NAME = "XtremeWorlds"
WEB_SITE = "https://xtremeworlds.com/"
GAME_PORT = 7234
MAX_PLAYERS = 50
MAX_MAPS = 50
MAX_ITEMS = 255
MAX_SHOPS = 255
MAX_SPELLS = 255
MAX_SIGNS = 255
MAX_NPCS = 255
MAX_GUILDS = 255
MAX_GUILD_MEMBERS = 255
MAX_QUESTS = 255
MAX_ARROWS = 100
MAX_CLASS = 50
MAX_QUEST_PLAYERS = 255
DEBUG = YES

-- The supplied legacy script references these but does not define them.
-- Keep safe defaults until you choose a starting map/tile.
START_MAP = START_MAP or 1
START_X = START_X or 0
START_Y = START_Y or 0

-- Map constants.
MAP_MORAL_NONE = 0
MAP_MORAL_SAFE = 1
MAP_MORAL_INN = 2
MAP_MORAL_ARENA = 3

-- Item constants.
ITEM_TYPE_NONE = 0
ITEM_TYPE_WEAPON = 1
ITEM_TYPE_ARMOR = 2
ITEM_TYPE_HELMET = 3
ITEM_TYPE_SHIELD = 4
ITEM_TYPE_POTIONADDHP = 5
ITEM_TYPE_POTIONADDMP = 6
ITEM_TYPE_POTIONADDSP = 7
ITEM_TYPE_POTIONSUBHP = 8
ITEM_TYPE_POTIONSUBMP = 9
ITEM_TYPE_POTIONSUBSP = 10
ITEM_TYPE_KEY = 11
ITEM_TYPE_CURRENCY = 12
ITEM_TYPE_SPELL = 13
ITEM_TYPE_WARP = 14

function ServerSet()
    SetServerName(GAME_NAME)
    SetWebsite(WEB_SITE)
    SetServerPort(GAME_PORT)
    SetMaxPlayers(MAX_PLAYERS)
    SetMaxMaps(MAX_MAPS)
    SetMaxItems(MAX_ITEMS)
    SetMaxShops(MAX_SHOPS)
    SetMaxSpells(MAX_SPELLS)
    SetMaxSigns(MAX_SIGNS)
    SetMaxNPCs(MAX_NPCS)
    SetMaxGuilds(MAX_GUILDS)
    SetMaxGuildMembers(MAX_GUILD_MEMBERS)
    SetMaxQuests(MAX_QUESTS)
    SetMaxArrows(MAX_ARROWS)
    SetMaxClasses(MAX_CLASS)
    SetStartPosition(START_MAP, START_X, START_Y)
    SetDebugScripting(DEBUG)
end

function JoinGame(Player)
    GlobalMsg(GetPlayerName(Player) .. " has joined " .. GetServerName() .. "!", WHITE)
end

function LeftGame(Player)
    if GetPlayerAccess(Player) <= 1 then
        GlobalMsg(GetPlayerName(Player) .. " has left " .. GetServerName() .. "!", DARKGREY)
    else
        GlobalMsg(GetPlayerName(Player) .. " has left " .. GetServerName() .. "!", WHITE)
    end
end

function JoinMap(Player)
end

function LeaveMap(Player)
end

function OnScriptedTile(Player)
end

function OnNpcDeath(Attacker, NpcNum, MapNum, NpcNumOnMap)
end

function OnDeathByNpc(Victim, NpcNum, MapNum, NpcNumOnMap)
    local damage = Damage or 0
    local strStart
    local strLate

    if IsVowel(GetNpcName(NpcNum)) then
        strStart = "An "
        strLate = "an "
    else
        strStart = "A "
        strLate = "a "
    end

    PlayerMsg(Victim, strStart .. GetNpcName(NpcNum) .. " hit you for " .. damage .. " hit points, killing you.", BRIGHTRED)
    GlobalMsg(GetPlayerName(Victim) .. " has been killed by " .. strLate .. GetNpcName(NpcNum), BRIGHTRED)

    local Exp = math.floor(GetPlayerExp(Victim) / 3)
    if Exp < 0 then Exp = 0 end

    if Exp == 0 then
        PlayerMsg(Victim, "You lost no experience points.", BRIGHTRED)
    else
        SetPlayerExp(Victim, GetPlayerExp(Victim) - Exp)
        PlayerMsg(Victim, "You lost " .. Exp .. " experience points.", BRIGHTRED)
    end
end

function OnDeathByPlayer(Victim, Attacker, MapNum, MapMoral)
    if MapMoral == MAP_MORAL_ARENA then
        GlobalMsg(GetPlayerName(Victim) .. " was defeated in an arena by " .. GetPlayerName(Attacker) .. "!", YELLOW)
    else
        GlobalMsg(GetPlayerName(Victim) .. " has been killed by " .. GetPlayerName(Attacker), BRIGHTRED)
    end

    if MapMoral ~= MAP_MORAL_ARENA then
        if GetPlayerWeaponSlot(Victim) > 0 then PlayerMapDropItem(Victim, GetPlayerWeaponSlot(Victim), 0) end
        if GetPlayerArmorSlot(Victim) > 0 then PlayerMapDropItem(Victim, GetPlayerArmorSlot(Victim), 0) end
        if GetPlayerHelmetSlot(Victim) > 0 then PlayerMapDropItem(Victim, GetPlayerHelmetSlot(Victim), 0) end
        if GetPlayerShieldSlot(Victim) > 0 then PlayerMapDropItem(Victim, GetPlayerShieldSlot(Victim), 0) end

        local Exp = math.floor(GetPlayerExp(Victim) / 10)
        if Exp < 0 then Exp = 0 end

        if Exp == 0 then
            PlayerMsg(Victim, "You lost no experience points.", BRIGHTRED)
            PlayerMsg(Attacker, "You received no experience points from that weak insignificant player.", BRIGHTBLUE)
        else
            SetPlayerExp(Victim, GetPlayerExp(Victim) - Exp)
            PlayerMsg(Victim, "You lost " .. Exp .. " experience points.", BRIGHTRED)
            SetPlayerExp(Attacker, GetPlayerExp(Attacker) + Exp)
            PlayerMsg(Attacker, "You got " .. Exp .. " experience points for killing " .. GetPlayerName(Victim) .. ".", BRIGHTBLUE)
        end
    end
end

function OnLevelUp(Player)
    local ExtraEXP
    if GetPlayerExp(Player) > GetPlayerNextLevel(Player) then
        ExtraEXP = GetPlayerExp(Player) - GetPlayerNextLevel(Player)
    else
        ExtraEXP = 0
    end

    SetPlayerLevel(Player, GetPlayerLevel(Player) + 1)

    local I = math.floor(GetPlayerSPEED(Player) / 10)
    if I < 1 then I = 1 end
    if I > 3 then I = 3 end
    if I > 5 then I = 4 end
    if I > 9 then I = 5 end

    SetPlayerPOINTS(Player, GetPlayerPOINTS(Player) + I)
    SetPlayerExp(Player, ExtraEXP)
    GlobalMsg(GetPlayerName(Player) .. " has gained a level!", BROWN)
    PlayerMsg(Player, "You have gained a level!  You now have " .. GetPlayerPOINTS(Player) .. " stat points to distribute.", BRIGHTBLUE)
end

function OnEquipItem(Player, InvNum, ItemType, ItemNum)
end

function OnUnEquipItem(Player, InvNum, ItemType, ItemNum)
end

function OnUseItem(Player, InvNum, ItemType, ItemNum)
end

function OnItemDrop(Player, ItemNum, ItemVal, ItemDur, InvSlot)
end

function OnTime(tTime, tSeconds)
    if tTime == 2 then
        AdminMessage("The time is now " .. os.date("%X") .. ".", WHITE)
    elseif tTime == 3 then
        GlobalMessage("Today's date is " .. os.date("%x") .. ".", WHITE)
    end
end
