Attribute VB_Name = "modConstants"
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Created module, added GAME_IP, Log vars,
' *            raised GAME_PORT due to XP bug.
' ****************************************************************

Option Explicit

' Encryption Key
Public Const ENC_KEY = "¦£»-Å¦%ôtgq|\=+-_`~€ƒ…Šª©®¬§«±º¾¿Á¯õþøðæç¼½*-/+><;;:)(*^@$%^&@($GhdgbfkmsdKJGuyfkjesgf654765145674944?âF¦†ÿ?¢Ç"

' Music Extension
Public MUSIC_EXT As String

' Website
Public WEBSITE As String

' Sound Path
Public Const SOUND_PATH  As String = "\sound\"

' Music Path
Public Const MUSIC_PATH  As String = "\music\"

' Data Path
Public Const DATA_PATH As String = "\data\"

' Varriables for Moving Forms
Public Const WM_NCLBUTTONDOWN As Long = &HA1

' Font variables
Public Const FONT_NAME As String = "Verdana Bold"
Public Const FONT_SIZE As Byte = 16

' Log Path and variables
Public Const LOG_DEBUG As String = "debug.txt"
Public Const LOG_PATH As String = "\logs\"

' Map Path and variables
Public Const MAP_PATH As String = "\maps\"
Public Const MAP_EXT As String = ".map"

' Gfx Path and variables
Public Const GFX_PATH As String = "\gfx\"
Public Const GFX_EXT As String = ".bmp"

' API constants
Public Const SRCAND As Long = &H8800C6
Public Const SRCCOPY As Long = &HCC0020
Public Const SRCPAINT As Long = &HEE0086

' Key constants
Public Const VK_UP As Long = &H26
Public Const VK_DOWN As Long = &H28
Public Const VK_LEFT As Long = &H25
Public Const VK_RIGHT As Long = &H27
Public Const VK_SHIFT As Long = &H10
Public Const VK_RETURN As Long = &HD
Public Const VK_CONTROL As Long = &H11

' Menu states
Public Const MENU_STATE_NEWACCOUNT As Byte = 0
Public Const MENU_STATE_DELACCOUNT As Byte = 1
Public Const MENU_STATE_LOGIN As Byte = 2
Public Const MENU_STATE_GETCHARS As Byte = 3
Public Const MENU_STATE_NEWCHAR As Byte = 4
Public Const MENU_STATE_ADDCHAR As Byte = 5
Public Const MENU_STATE_DELCHAR As Byte = 6
Public Const MENU_STATE_USECHAR As Byte = 7
Public Const MENU_STATE_INIT As Byte = 8

' Speed moving vars
Public Const WALK_SPEED As Byte = 2
Public Const RUN_SPEED As Byte = 4

' Sound constants
Public Const SND_SYNC As Long = &H0
Public Const SND_ASYNC As Long = &H1
Public Const SND_NODEFAULT As Long = &H2
Public Const SND_MEMORY As Long = &H4
Public Const SND_LOOP As Long = &H8
Public Const SND_NOSTOP As Long = &H10

Public Const Black As Byte = 0
Public Const Blue As Byte = 1
Public Const Green As Byte = 2
Public Const Cyan As Byte = 3
Public Const Red As Byte = 4
Public Const Magenta As Byte = 5
Public Const Brown As Byte = 6
Public Const Grey As Byte = 7
Public Const DarkGrey As Byte = 8
Public Const BrightBlue As Byte = 9
Public Const BrightGreen As Byte = 10
Public Const BrightCyan As Byte = 11
Public Const BrightRed As Byte = 12
Public Const Pink As Byte = 13
Public Const Yellow As Byte = 14
Public Const White As Byte = 15

Public Const SayColor As Byte = Grey
Public Const GlobalColor As Byte = BrightGreen
Public Const BroadcastColor As Byte = Pink
Public Const TellColor As Byte = Yellow
Public Const EmoteColor As Byte = BrightCyan
Public Const AdminColor As Byte = BrightCyan
Public Const HelpColor As Byte = Yellow
Public Const WhoColor As Byte = Pink
Public Const JoinLeftColor As Byte = White
Public Const NpcColor As Byte = Cyan
Public Const AlertColor As Byte = BrightRed
Public Const NewMapColor As Byte = Yellow

' General constants
Public GAME_NAME As String
Public MAX_NPCS As Long
Public MAX_ITEMS As Long
Public MAX_PLAYERS As Long
Public MAX_SHOPS As Long
Public MAX_SPELLS As Long
Public MAX_SIGNS As Long
Public MAX_MAPS As Long
Public MAX_GUILDS As Long

Public Const BASE_MAX_PLAYERS As Integer = 500
Public Const BASE_MAX_ITEMS As Integer = 500
Public Const BASE_MAX_NPCS As Integer = 500
Public Const MAX_INV As Integer = 75
Public Const MAX_MAP_ITEMS As Integer = 20
Public Const MAX_MAP_NPCS As Integer = 10
Public Const BASE_MAX_SHOPS As Integer = 500
Public Const BASE_MAX_SIGNS As Integer = 500
Public Const MAX_PLAYER_SPELLS As Integer = 40
Public Const BASE_MAX_SPELLS As Integer = 500
Public Const MAX_TRADES As Integer = 8
Public MAX_GUILD_MEMBERS As Long

Public Const NO As Byte = 0
Public Const YES As Byte = 1

' Account constants
Public Const NAME_LENGTH As Byte = 50
Public Const MAX_CHARS As Byte = 3

' Sex constants
Public Const SEX_MALE As Byte = 0
Public Const SEX_FEMALE As Byte = 1

' Map constants
Public Const BASE_MAX_MAPS As Integer = 500
Public Const MAX_MAPX As Byte = 15
Public Const MAX_MAPY As Byte = 11
Public Const MAP_MORAL_NONE As Byte = 0
Public Const MAP_MORAL_SAFE As Byte = 1
Public Const MAP_MORAL_INN As Byte = 2
Public Const MAP_MORAL_ARENA As Byte = 3

' Image constants
Public Const PIC_X As Integer = 32
Public Const PIC_Y As Integer = 32

' Tile consants
Public Const TILE_TYPE_WALKABLE As Byte = 0
Public Const TILE_TYPE_BLOCKED As Byte = 1
Public Const TILE_TYPE_WARP As Byte = 2
Public Const TILE_TYPE_ITEM As Byte = 3
Public Const TILE_TYPE_NPCAVOID As Byte = 4
Public Const TILE_TYPE_KEY As Byte = 5
Public Const TILE_TYPE_KEYOPEN As Byte = 6
Public Const TILE_TYPE_HEAL As Byte = 7
Public Const TILE_TYPE_KILL As Byte = 8
Public Const TILE_TYPE_DOOR As Byte = 9
Public Const TILE_TYPE_SIGN As Byte = 10
Public Const TILE_TYPE_MSG As Byte = 11
Public Const TILE_TYPE_SPRITE As Byte = 12
Public Const TILE_TYPE_NPCSPAWN As Byte = 13
Public Const TILE_TYPE_NUDGE As Byte = 14

' Item constants
Public Const ITEM_TYPE_NONE As Byte = 0
Public Const ITEM_TYPE_WEAPON As Byte = 1
Public Const ITEM_TYPE_ARMOR As Byte = 2
Public Const ITEM_TYPE_HELMET As Byte = 3
Public Const ITEM_TYPE_SHIELD As Byte = 4
Public Const ITEM_TYPE_POTIONADDHP As Byte = 5
Public Const ITEM_TYPE_POTIONADDMP As Byte = 6
Public Const ITEM_TYPE_POTIONADDSP As Byte = 7
Public Const ITEM_TYPE_POTIONSUBHP As Byte = 8
Public Const ITEM_TYPE_POTIONSUBMP As Byte = 9
Public Const ITEM_TYPE_POTIONSUBSP As Byte = 10
Public Const ITEM_TYPE_KEY As Byte = 11
Public Const ITEM_TYPE_CURRENCY As Byte = 12
Public Const ITEM_TYPE_SPELL As Byte = 13
Public Const ITEM_TYPE_WARP As Byte = 14

' Direction constants
Public Const DIR_UP As Byte = 0
Public Const DIR_DOWN As Byte = 1
Public Const DIR_LEFT As Byte = 2
Public Const DIR_RIGHT As Byte = 3

' Constants for player movement
Public Const MOVING_WALKING As Byte = 1
Public Const MOVING_RUNNING As Byte = 2
Public Const SPTick As Integer = 250
Public SPDrain As Long

' Weather constants
Public Const WEATHER_NONE As Byte = 0
Public Const WEATHER_RAINING As Byte = 1
Public Const WEATHER_SNOWING As Byte = 2

' Time constants
Public Const TIME_DAY As Byte = 0
Public Const TIME_NIGHT As Byte = 1

' Admin constants
Public Const ADMIN_MONITER As Byte = 1
Public Const ADMIN_MAPPER As Byte = 2
Public Const ADMIN_DEVELOPER As Byte = 3
Public Const ADMIN_CREATOR As Byte = 4

' NPC constants
Public Const NPC_BEHAVIOR_ATTACKONSIGHT As Byte = 0
Public Const NPC_BEHAVIOR_ATTACKWHENATTACKED As Byte = 1
Public Const NPC_BEHAVIOR_FRIENDLY As Byte = 2
Public Const NPC_BEHAVIOR_SHOPKEEPER As Byte = 3
Public Const NPC_BEHAVIOR_GUARD As Byte = 4

' Spell constants
Public Const SPELL_TYPE_ADDHP As Byte = 0
Public Const SPELL_TYPE_ADDMP As Byte = 1
Public Const SPELL_TYPE_ADDSP As Byte = 2
Public Const SPELL_TYPE_SUBHP As Byte = 3
Public Const SPELL_TYPE_SUBMP As Byte = 4
Public Const SPELL_TYPE_SUBSP As Byte = 5
Public Const SPELL_TYPE_GIVEITEM As Byte = 6
Public Const SPELL_TYPE_WARP As Byte = 7

