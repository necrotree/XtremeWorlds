Attribute VB_Name = "modGlobals"
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/16/2005  Shannara   Created module.
' ****************************************************************

Option Explicit

' Scripting Globals
Global MyScript As clsSadScript
Public clsScriptCommands As clsCommands
Public DebugScripting As Boolean

' Player Saving Constants
Global PlayerI As Byte

' Use for Banns
Public MAX_BANS As Integer

' Used for respawning items
Public SpawnSeconds As Long

' Used for weather effects
Public GameWeather As Long
Public WeatherSeconds As Long
Public GameTime As Long
Public TimeSeconds As Long

' Used for closing key doors again
Public KeyTimer As Long

' Used for gradually giving back players and npcs hp
Public GiveHPTimer As Long
Public GiveNPCHPTimer As Long

' Used for logging
Public ServerLog As Boolean

' Used for Player Looping
Public HighIndex As Long

' Used to keep track of server shutdown
Public ShutOn As Boolean

' Used for keeping track of current shop, either NPC or Map
Public CurrentShop As Long

' Used to store the MOTD
Public MOTD As String

' Used for parsing
Public SEP_CHAR As String * 1
Public END_CHAR As String * 1

' Maximum classes
Public Max_Classes As Byte

' Text variabls
Public vbQuote As String



