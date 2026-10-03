Imports System
Imports Eto.Forms
Imports Eto.Drawing
Imports XtremeWorlds.Client.UI
Imports XtremeWorlds.Client.Logic

Namespace XtremeWorlds.Client.Forms
    Public Class frmMainGame
        Inherits Form

        Private ReadOnly _client As IGameClientRuntime

        Public ReadOnly lblCharacterValue As LegacyLabel
        Public ReadOnly lblSkillsDetails As LegacyLabel
        Public ReadOnly imgLiveStats As ImageView
        Public ReadOnly picPlayerList As LegacyPictureBox
        Public ReadOnly lblFriend As LegacyLabel
        Public ReadOnly lblWeb As LegacyLabel
        Public ReadOnly picPM As LegacyLabel
        Public ReadOnly lstPlayers As LegacyListBox
        Public ReadOnly lstWho As LegacyListBox
        Public ReadOnly hostNotetext As LegacyPictureBox
        Public ReadOnly imgSkills As ImageView
        Public ReadOnly lblExperience As LegacyLabel
        Public ReadOnly picMapEditor As LegacyPictureBox
        Public ReadOnly picBack As LegacyPictureBox
        Public ReadOnly cmdProperties As LegacyButton
        Public ReadOnly cmdCancel As LegacyButton
        Public ReadOnly optAttribs As LegacyRadioButton
        Public ReadOnly optLayers As LegacyRadioButton
        Public ReadOnly SSTab1 As LegacyFrame
        Public ReadOnly Picture5 As LegacyPictureBox
        Public ReadOnly optWarp As LegacyRadioButton
        Public ReadOnly optDoor As LegacyRadioButton
        Public ReadOnly optKill As LegacyRadioButton
        Public ReadOnly optHeal As LegacyRadioButton
        Public ReadOnly optKeyOpen As LegacyRadioButton
        Public ReadOnly optBlocked As LegacyRadioButton
        Public ReadOnly optItem As LegacyRadioButton
        Public ReadOnly optNpcAvoid As LegacyRadioButton
        Public ReadOnly optKey As LegacyRadioButton
        Public ReadOnly optSign As LegacyRadioButton
        Public ReadOnly optMsg As LegacyRadioButton
        Public ReadOnly optSprite As LegacyRadioButton
        Public ReadOnly optNpcSpawn As LegacyRadioButton
        Public ReadOnly optFlight As LegacyRadioButton
        Public ReadOnly optNudge As LegacyRadioButton
        Public ReadOnly Picture6 As LegacyPictureBox
        Public ReadOnly optF2Anim As LegacyRadioButton
        Public ReadOnly optFringe2 As LegacyRadioButton
        Public ReadOnly optFAnim As LegacyRadioButton
        Public ReadOnly optM2Anim As LegacyRadioButton
        Public ReadOnly optMask2 As LegacyRadioButton
        Public ReadOnly optGround As LegacyRadioButton
        Public ReadOnly optMask As LegacyRadioButton
        Public ReadOnly optAnim As LegacyRadioButton
        Public ReadOnly optFringe As LegacyRadioButton
        Public ReadOnly cmdEditorLayers As LegacyButton
        Public ReadOnly cmdEditorAttribs As LegacyButton
        Public ReadOnly cmdFill As LegacyButton
        Public ReadOnly cmdClear As LegacyButton
        Public ReadOnly fraMapSettings As LegacyFrame
        Public ReadOnly lblMapY As LegacyLabel
        Public ReadOnly lblMapX As LegacyLabel
        Public ReadOnly Label16 As LegacyLabel
        Public ReadOnly lblMapNumber As LegacyLabel
        Public ReadOnly Label9 As LegacyLabel
        Public ReadOnly lblMapName As LegacyLabel
        Public ReadOnly Label2 As LegacyLabel
        Public ReadOnly cmdSend As LegacyButton
        Public ReadOnly scrlTileset As LegacyScrollBar
        Public ReadOnly picTrade As LegacyLabel
        Public ReadOnly picSpells As LegacyLabel
        Public ReadOnly picInventory As LegacyLabel
        Public ReadOnly picTrain As LegacyLabel
        Public ReadOnly picStats As LegacyLabel
        Public ReadOnly picQuit As LegacyLabel
        Public ReadOnly picBugReport As LegacyLabel
        Public ReadOnly lblKeepNotes As LegacyLabel
        Public ReadOnly lblGameName As LegacyLabel
        Public ReadOnly picOptions As LegacyLabel
        Public ReadOnly cmdMinimize As LegacyLabel
        Public ReadOnly lblPlayers As LegacyLabel
        Public ReadOnly lblMapInfo As LegacyLabel
        Public ReadOnly Label4 As LegacyLabel
        Public ReadOnly lblGUI As LegacyLabel
        Public ReadOnly Picture1 As LegacyPictureBox
        Public ReadOnly lblHP As LegacyLabel
        Public ReadOnly shpHP As LegacyPictureBox
        Public ReadOnly lblHP_0 As LegacyLabel
        Public ReadOnly txtMyTextBox As LegacyTextBox
        Public ReadOnly Picture2 As LegacyPictureBox
        Public ReadOnly lblSP As LegacyLabel
        Public ReadOnly Picture3 As LegacyPictureBox
        Public ReadOnly lblMP As LegacyLabel
        Public ReadOnly shpMP As LegacyPictureBox
        Public ReadOnly lblMP_0 As LegacyLabel
        Public ReadOnly shpEXP As LegacyPictureBox
        Public ReadOnly shpSP As LegacyPictureBox
        Public ReadOnly lblSP_0 As LegacyLabel
        Public ReadOnly picScreen As LegacyPictureBox
        Public ReadOnly hosttxtChat As LegacyPictureBox
        Public ReadOnly fralvl2 As LegacyFrame
        Public ReadOnly cmdSignEdit As LegacyButton
        Public ReadOnly cmdLOC As LegacyButton
        Public ReadOnly cmdBan As LegacyButton
        Public ReadOnly cmdMapreport As LegacyButton
        Public ReadOnly cmdRespawn As LegacyButton
        Public ReadOnly cmdPlayerSprite As LegacyButton
        Public ReadOnly cmdMapeditor As LegacyButton
        Public ReadOnly cmdWarpto As LegacyButton
        Public ReadOnly cmdSetSprite As LegacyButton
        Public ReadOnly fralvl1 As LegacyFrame
        Public ReadOnly cmdKick As LegacyButton
        Public ReadOnly fralvl3 As LegacyFrame
        Public ReadOnly cmdNpcEditor As LegacyButton
        Public ReadOnly cmdItemEditor As LegacyButton
        Public ReadOnly cmdShopEditor As LegacyButton
        Public ReadOnly cmdSpellEditor As LegacyButton
        Public ReadOnly cmdDelbanlist As LegacyButton
        Public ReadOnly cmdKill As LegacyButton
        Public ReadOnly cmbArrowEditor As LegacyButton
        Public ReadOnly cmbClassEditor As LegacyButton
        Public ReadOnly fralvl4 As LegacyFrame
        Public ReadOnly AccessLevel As LegacyLabel
        Public ReadOnly txtAccessLevel As LegacyTextBox
        Public ReadOnly cmdSetAccess As LegacyButton
        Public ReadOnly fraSpriteNum As LegacyFrame
        Public ReadOnly txtSpriteNum As LegacyTextBox
        Public ReadOnly fraPlayer As LegacyFrame
        Public ReadOnly txtPlayerName As LegacyTextBox
        Public ReadOnly fraMapNum As LegacyFrame
        Public ReadOnly txtMapNum As LegacyTextBox
        Public ReadOnly imgSign As ImageView
        Public ReadOnly lblLine1Btm As LegacyLabel
        Public ReadOnly lblLine2Btm As LegacyLabel
        Public ReadOnly lblLine3Btm As LegacyLabel
        Public ReadOnly lblNameBtm As LegacyLabel
        Public ReadOnly lblexit As LegacyLabel
        Public ReadOnly lblLine1Top As LegacyLabel
        Public ReadOnly lblLine2Top As LegacyLabel
        Public ReadOnly lblLine3Top As LegacyLabel
        Public ReadOnly Line1 As Drawable
        Public ReadOnly lblNameTop As LegacyLabel
        Public ReadOnly picGUI As LegacyPictureBox
        Public ReadOnly cmdGUI As LegacyButton
        Public ReadOnly txtGUI As LegacyTextBox
        Public ReadOnly chkGUI As LegacyCheckBox
        Public ReadOnly picWebsite As LegacyLabel
        Public ReadOnly picGuild As LegacyLabel
        Public ReadOnly imgWho As ImageView
        Public ReadOnly lblWhoMessage As LegacyLabel
        Public ReadOnly lblWhoFriend As LegacyLabel
        Public ReadOnly imgInventory As ImageView
        Public ReadOnly lstInv As LegacyListBox
        Public ReadOnly picItem As LegacyPictureBox
        Public ReadOnly imgNotes As ImageView
        Public ReadOnly lblNoteSave As LegacyLabel
        Public ReadOnly imgTraining As ImageView
        Public ReadOnly lblPlayerPoints As LegacyLabel
        Public ReadOnly lblTrain As LegacyLabel
        Public ReadOnly cmbStat As LegacyComboBox
        Public ReadOnly imgCharacter As ImageView
        Public ReadOnly lblGearName As LegacyLabel
        Public ReadOnly lblGearDur As LegacyLabel
        Public ReadOnly lblGearStr As LegacyLabel
        Public ReadOnly imgEquipment As ImageView
        Public ReadOnly imgEquipment_1 As ImageView
        Public ReadOnly imgEquipment_2 As ImageView
        Public ReadOnly imgEquipment_3 As ImageView
        Public ReadOnly lblCharacterValue_0 As LegacyLabel
        Public ReadOnly lblCharacterValue_2 As LegacyLabel
        Public ReadOnly lblCharacterValue_3 As LegacyLabel
        Public ReadOnly lblCharacterValue_4 As LegacyLabel
        Public ReadOnly lblCharacterValue_5 As LegacyLabel
        Public ReadOnly lblCharacterValue_6 As LegacyLabel
        Public ReadOnly lblCharacterValue_7 As LegacyLabel
        Public ReadOnly lblCharacterValue_8 As LegacyLabel
        Public ReadOnly lblCharacterValue_9 As LegacyLabel
        Public ReadOnly lblCharacterValue_10 As LegacyLabel
        Public ReadOnly lblCharacterValue_11 As LegacyLabel
        Public ReadOnly lblCharacterValue_12 As LegacyLabel
        Public ReadOnly lblCharacterValue_13 As LegacyLabel
        Public ReadOnly lblForget As LegacyLabel
        Public ReadOnly lstSpells As LegacyListBox
        Public ReadOnly lblSkillsNext As LegacyLabel
        Public ReadOnly lblSkillsPrevious As LegacyLabel
        Public ReadOnly lblSkillsUpgrade As LegacyLabel
        Public ReadOnly lblSkillName As LegacyLabel
        Public ReadOnly imgSkillIcon As ImageView
        Public ReadOnly lblSkillName_1 As LegacyLabel
        Public ReadOnly imgSkillIcon_1 As ImageView
        Public ReadOnly lblSkillName_2 As LegacyLabel
        Public ReadOnly imgSkillIcon_2 As ImageView
        Public ReadOnly lblSkillName_3 As LegacyLabel
        Public ReadOnly imgSkillIcon_3 As ImageView
        Public ReadOnly lblSkillName_4 As LegacyLabel
        Public ReadOnly imgSkillIcon_4 As ImageView
        Public ReadOnly lblSkillName_5 As LegacyLabel
        Public ReadOnly imgSkillIcon_5 As ImageView
        Public ReadOnly lblSkillName_6 As LegacyLabel
        Public ReadOnly imgSkillIcon_6 As ImageView
        Public ReadOnly lblSkillName_7 As LegacyLabel
        Public ReadOnly imgSkillIcon_7 As ImageView
        Public ReadOnly lblPoints As LegacyLabel
        Public ReadOnly lblBlock As LegacyLabel
        Public ReadOnly lblCHit As LegacyLabel
        Public ReadOnly lblTNL As LegacyLabel
        Public ReadOnly lblEXP As LegacyLabel
        Public ReadOnly lblSPEED As LegacyLabel
        Public ReadOnly lblMAGI As LegacyLabel
        Public ReadOnly lblDEF As LegacyLabel
        Public ReadOnly lblSTR As LegacyLabel
        Public ReadOnly lblLevel As LegacyLabel
        Public ReadOnly Label8 As LegacyLabel
        Public ReadOnly imgMap As ImageView
        Public ReadOnly Image1 As ImageView
        Public ReadOnly imgGlobal As ImageView
        Public ReadOnly imgGuild As ImageView
        Public ReadOnly imgPM As ImageView
        Public ReadOnly scrlPicture As LegacyScrollBar

        Public Sub New(Optional client As IGameClientRuntime = Nothing)
            _client = If(client, GameClientRuntime.Current)
            Title = "XtremeWorlds"
            Icon = AssetLoader.LoadIcon("Icon.ico")
            ClientSize = New Size(1396, 698)
            Dim rootLayout As New PixelLayout()
            Content = rootLayout

            lblCharacterValue = New LegacyLabel()
            lblCharacterValue.Caption = ""
            lblCharacterValue.Visible = False
            lblCharacterValue.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue, 789, 330)

            lblSkillsDetails = New LegacyLabel()
            lblSkillsDetails.Caption = "Select a spell."
            lblSkillsDetails.Visible = False
            lblSkillsDetails.Size = New Size(101, 143)
            rootLayout.Add(lblSkillsDetails, 820, 304)

            imgLiveStats = New ImageView()
            imgLiveStats.Visible = False
            imgLiveStats.Size = New Size(248, 266)
            rootLayout.Add(imgLiveStats, 677, 280)

            picPlayerList = New LegacyPictureBox()
            picPlayerList.Visible = False
            picPlayerList.Size = New Size(248, 266)
            rootLayout.Add(picPlayerList, 680, 281)
            Dim layout_picPlayerList As New PixelLayout()
            picPlayerList.Content = layout_picPlayerList
            lblFriend = New LegacyLabel()
            lblFriend.Caption = ""
            lblFriend.Size = New Size(106, 25)
            layout_picPlayerList.Add(lblFriend, 125, 227)

            lblWeb = New LegacyLabel()
            lblWeb.Caption = ""
            lblWeb.ToolTip = "Web Browser"
            lblWeb.Size = New Size(57, 25)
            layout_picPlayerList.Add(lblWeb, 96, 224)

            picPM = New LegacyLabel()
            picPM.Caption = ""
            picPM.ToolTip = "Send a personal message!"
            picPM.Visible = False
            picPM.Size = New Size(104, 25)
            layout_picPlayerList.Add(picPM, 15, 229)

            lstPlayers = New LegacyListBox()
            lstPlayers.Visible = False
            lstPlayers.Size = New Size(205, 128)
            layout_picPlayerList.Add(lstPlayers, 22, 80)


            lstWho = New LegacyListBox()
            lstWho.Visible = False
            lstWho.Size = New Size(216, 184)
            rootLayout.Add(lstWho, 692, 306)

            hostNotetext = New LegacyPictureBox()
            hostNotetext.Visible = False
            hostNotetext.Size = New Size(218, 127)
            rootLayout.Add(hostNotetext, 697, 306)

            imgSkills = New ImageView()
            imgSkills.Image = AssetLoader.LoadImage("frmMainGame/imgSkills.jpg")
            imgSkills.Visible = False
            imgSkills.Size = New Size(265, 382)
            rootLayout.Add(imgSkills, 677, 278)

            lblExperience = New LegacyLabel()
            lblExperience.Caption = "XP: 0 | TNL: --"
            lblExperience.ToolTip = "TNL: experience points remaining until the next level."
            lblExperience.Size = New Size(257, 12)
            rootLayout.Add(lblExperience, 670, 74)

            picMapEditor = New LegacyPictureBox()
            picMapEditor.Visible = False
            picMapEditor.Size = New Size(444, 595)
            rootLayout.Add(picMapEditor, 956, 5)
            Dim layout_picMapEditor As New PixelLayout()
            picMapEditor.Content = layout_picMapEditor
            picBack = New LegacyPictureBox()
            picBack.Size = New Size(384, 224)
            layout_picMapEditor.Add(picBack, 8, 7)

            cmdProperties = New LegacyButton()
            cmdProperties.Caption = "Properties"
            cmdProperties.Size = New Size(89, 26)
            layout_picMapEditor.Add(cmdProperties, 152, 439)

            cmdCancel = New LegacyButton()
            cmdCancel.Caption = "Cancel"
            cmdCancel.Size = New Size(113, 33)
            layout_picMapEditor.Add(cmdCancel, 136, 552)

            optAttribs = New LegacyRadioButton()
            optAttribs.Caption = "Attributes"
            optAttribs.Visible = False
            optAttribs.Size = New Size(105, 17)
            layout_picMapEditor.Add(optAttribs, 8, 472)

            optLayers = New LegacyRadioButton(optAttribs)
            optLayers.Caption = "Layers"
            optLayers.Value = True
            optLayers.Visible = False
            optLayers.Size = New Size(105, 17)
            layout_picMapEditor.Add(optLayers, 8, 456)

            SSTab1 = New LegacyFrame()
            SSTab1.Caption = ""
            SSTab1.Size = New Size(131, 281)
            layout_picMapEditor.Add(SSTab1, 8, 260)
            Dim layout_SSTab1 As New PixelLayout()
            SSTab1.Content = layout_SSTab1
            Picture5 = New LegacyPictureBox()
            Picture5.Visible = False
            Picture5.Size = New Size(89, 249)
            layout_SSTab1.Add(Picture5, 24, 32)
            Dim layout_Picture5 As New PixelLayout()
            Picture5.Content = layout_Picture5
            optWarp = New LegacyRadioButton()
            optWarp.Caption = "Warp"
            optWarp.Size = New Size(81, 17)
            layout_Picture5.Add(optWarp, 0, 16)

            optDoor = New LegacyRadioButton(optWarp)
            optDoor.Caption = "Door"
            optDoor.Size = New Size(81, 17)
            layout_Picture5.Add(optDoor, 0, 128)

            optKill = New LegacyRadioButton(optWarp)
            optKill.Caption = "Damage"
            optKill.Size = New Size(81, 17)
            layout_Picture5.Add(optKill, 0, 112)

            optHeal = New LegacyRadioButton(optWarp)
            optHeal.Caption = "Heal"
            optHeal.Size = New Size(81, 17)
            layout_Picture5.Add(optHeal, 0, 96)

            optKeyOpen = New LegacyRadioButton(optWarp)
            optKeyOpen.Caption = "Key Open"
            optKeyOpen.Size = New Size(81, 16)
            layout_Picture5.Add(optKeyOpen, 0, 80)

            optBlocked = New LegacyRadioButton(optWarp)
            optBlocked.Caption = "Blocked"
            optBlocked.Value = True
            optBlocked.Size = New Size(81, 17)
            layout_Picture5.Add(optBlocked, 0, 0)

            optItem = New LegacyRadioButton(optWarp)
            optItem.Caption = "Item"
            optItem.Size = New Size(81, 18)
            layout_Picture5.Add(optItem, 0, 32)

            optNpcAvoid = New LegacyRadioButton(optWarp)
            optNpcAvoid.Caption = "Npc Avoid"
            optNpcAvoid.Size = New Size(81, 18)
            layout_Picture5.Add(optNpcAvoid, 0, 48)

            optKey = New LegacyRadioButton(optWarp)
            optKey.Caption = "Key"
            optKey.Size = New Size(81, 18)
            layout_Picture5.Add(optKey, 0, 64)

            optSign = New LegacyRadioButton(optWarp)
            optSign.Caption = "Sign"
            optSign.Size = New Size(81, 17)
            layout_Picture5.Add(optSign, 0, 144)

            optMsg = New LegacyRadioButton(optWarp)
            optMsg.Caption = "Map Message"
            optMsg.Enabled = False
            optMsg.Size = New Size(89, 17)
            layout_Picture5.Add(optMsg, 0, 160)

            optSprite = New LegacyRadioButton(optWarp)
            optSprite.Caption = "Sprite Change"
            optSprite.Size = New Size(89, 17)
            layout_Picture5.Add(optSprite, 0, 176)

            optNpcSpawn = New LegacyRadioButton(optWarp)
            optNpcSpawn.Caption = "NPC Spawn"
            optNpcSpawn.Size = New Size(89, 17)
            layout_Picture5.Add(optNpcSpawn, 0, 192)

            optFlight = New LegacyRadioButton(optWarp)
            optFlight.Caption = "Flight"
            optFlight.Enabled = False
            optFlight.Size = New Size(89, 17)
            layout_Picture5.Add(optFlight, 0, 208)

            optNudge = New LegacyRadioButton(optWarp)
            optNudge.Caption = "Nudge"
            optNudge.Size = New Size(89, 17)
            layout_Picture5.Add(optNudge, 0, 224)


            Picture6 = New LegacyPictureBox()
            Picture6.Size = New Size(113, 257)
            layout_SSTab1.Add(Picture6, 8, 32)
            Dim layout_Picture6 As New PixelLayout()
            Picture6.Content = layout_Picture6
            optF2Anim = New LegacyRadioButton()
            optF2Anim.Caption = "Animation"
            optF2Anim.Size = New Size(81, 17)
            layout_Picture6.Add(optF2Anim, 16, 168)

            optFringe2 = New LegacyRadioButton(optF2Anim)
            optFringe2.Caption = "Fringe2"
            optFringe2.Size = New Size(81, 17)
            layout_Picture6.Add(optFringe2, 16, 152)

            optFAnim = New LegacyRadioButton(optF2Anim)
            optFAnim.Caption = "Animation"
            optFAnim.Size = New Size(81, 17)
            layout_Picture6.Add(optFAnim, 16, 136)

            optM2Anim = New LegacyRadioButton(optF2Anim)
            optM2Anim.Caption = "Animation"
            optM2Anim.Size = New Size(81, 17)
            layout_Picture6.Add(optM2Anim, 16, 104)

            optMask2 = New LegacyRadioButton(optF2Anim)
            optMask2.Caption = "Mask2"
            optMask2.Size = New Size(81, 17)
            layout_Picture6.Add(optMask2, 16, 88)

            optGround = New LegacyRadioButton(optF2Anim)
            optGround.Caption = "Ground"
            optGround.Value = True
            optGround.Size = New Size(81, 17)
            layout_Picture6.Add(optGround, 16, 40)

            optMask = New LegacyRadioButton(optF2Anim)
            optMask.Caption = "Mask"
            optMask.Size = New Size(81, 17)
            layout_Picture6.Add(optMask, 16, 56)

            optAnim = New LegacyRadioButton(optF2Anim)
            optAnim.Caption = "Animation"
            optAnim.Size = New Size(81, 17)
            layout_Picture6.Add(optAnim, 16, 72)

            optFringe = New LegacyRadioButton(optF2Anim)
            optFringe.Caption = "Fringe"
            optFringe.Size = New Size(81, 17)
            layout_Picture6.Add(optFringe, 16, 120)


            cmdEditorLayers = New LegacyButton()
            cmdEditorLayers.Caption = "Layers"
            cmdEditorLayers.Size = New Size(61, 25)
            layout_SSTab1.Add(cmdEditorLayers, 5, 9)

            cmdEditorAttribs = New LegacyButton()
            cmdEditorAttribs.Caption = "Attribs"
            cmdEditorAttribs.Size = New Size(61, 25)
            layout_SSTab1.Add(cmdEditorAttribs, 67, 9)


            cmdFill = New LegacyButton()
            cmdFill.Caption = "Fill"
            cmdFill.Size = New Size(89, 25)
            layout_picMapEditor.Add(cmdFill, 152, 472)

            cmdClear = New LegacyButton()
            cmdClear.Caption = "Clear"
            cmdClear.Size = New Size(89, 25)
            layout_picMapEditor.Add(cmdClear, 152, 504)

            fraMapSettings = New LegacyFrame()
            fraMapSettings.Caption = "-- Map Settings --"
            fraMapSettings.Size = New Size(97, 162)
            layout_picMapEditor.Add(fraMapSettings, 142, 272)
            Dim layout_fraMapSettings As New PixelLayout()
            fraMapSettings.Content = layout_fraMapSettings
            lblMapY = New LegacyLabel()
            lblMapY.Caption = "10"
            lblMapY.Size = New Size(49, 17)
            layout_fraMapSettings.Add(lblMapY, 48, 80)

            lblMapX = New LegacyLabel()
            lblMapX.Caption = "10"
            lblMapX.Size = New Size(41, 17)
            layout_fraMapSettings.Add(lblMapX, 8, 80)

            Label16 = New LegacyLabel()
            Label16.Caption = "MapX:       MapY:"
            Label16.Size = New Size(113, 17)
            layout_fraMapSettings.Add(Label16, 8, 64)

            lblMapNumber = New LegacyLabel()
            lblMapNumber.Caption = "10"
            lblMapNumber.Size = New Size(97, 17)
            layout_fraMapSettings.Add(lblMapNumber, 0, 120)

            Label9 = New LegacyLabel()
            Label9.Caption = "Map Number:"
            Label9.Size = New Size(81, 17)
            layout_fraMapSettings.Add(Label9, 8, 104)

            lblMapName = New LegacyLabel()
            lblMapName.Caption = "Map Name"
            lblMapName.Size = New Size(113, 17)
            layout_fraMapSettings.Add(lblMapName, 24, 40)

            Label2 = New LegacyLabel()
            Label2.Caption = "Map Name:"
            Label2.Size = New Size(81, 17)
            layout_fraMapSettings.Add(Label2, 8, 24)


            cmdSend = New LegacyButton()
            cmdSend.Caption = "Send"
            cmdSend.Size = New Size(113, 33)
            layout_picMapEditor.Add(cmdSend, 8, 552)

            scrlTileset = New LegacyScrollBar()
            scrlTileset.MinValue = 0
            scrlTileset.MaxValue = 6
            scrlTileset.Value = 1
            scrlTileset.Orientation = Orientation.Horizontal
            scrlTileset.SmallChange = 1
            scrlTileset.LargeChange = 1
            scrlTileset.Size = New Size(383, 19)
            layout_picMapEditor.Add(scrlTileset, 7, 230)


            picTrade = New LegacyLabel()
            picTrade.Caption = "Trade"
            picTrade.Size = New Size(35, 36)
            rootLayout.Add(picTrade, 671, 119)

            picSpells = New LegacyLabel()
            picSpells.Caption = ""
            picSpells.ToolTip = "View your spells."
            picSpells.Size = New Size(42, 42)
            rootLayout.Add(picSpells, 827, 179)

            picInventory = New LegacyLabel()
            picInventory.Caption = ""
            picInventory.ToolTip = "View your inventory."
            picInventory.Size = New Size(42, 42)
            rootLayout.Add(picInventory, 735, 179)

            picTrain = New LegacyLabel()
            picTrain.Caption = "Train"
            picTrain.ToolTip = "Train your character."
            picTrain.Size = New Size(35, 36)
            rootLayout.Add(picTrain, 745, 118)

            picStats = New LegacyLabel()
            picStats.Caption = ""
            picStats.ToolTip = "View your current stats."
            picStats.Size = New Size(42, 42)
            rootLayout.Add(picStats, 687, 179)

            picQuit = New LegacyLabel()
            picQuit.Caption = ""
            picQuit.ToolTip = "Quit the Game"
            picQuit.Size = New Size(121, 29)
            rootLayout.Add(picQuit, 799, 665)

            picBugReport = New LegacyLabel()
            picBugReport.Caption = "Bug"
            picBugReport.ToolTip = "Report a Bug!"
            picBugReport.Size = New Size(35, 36)
            rootLayout.Add(picBugReport, 819, 119)

            lblKeepNotes = New LegacyLabel()
            lblKeepNotes.Caption = "Notes"
            lblKeepNotes.ToolTip = "Edit your player notes."
            lblKeepNotes.Size = New Size(35, 36)
            rootLayout.Add(lblKeepNotes, 782, 119)

            lblGameName = New LegacyLabel()
            lblGameName.Caption = "Game Name"
            lblGameName.Visible = False
            lblGameName.Size = New Size(161, 17)
            rootLayout.Add(lblGameName, 96, 52)

            picOptions = New LegacyLabel()
            picOptions.Caption = ""
            picOptions.ToolTip = "Change user settings."
            picOptions.Size = New Size(42, 42)
            rootLayout.Add(picOptions, 875, 179)

            cmdMinimize = New LegacyLabel()
            cmdMinimize.Caption = "_"
            cmdMinimize.Size = New Size(35, 36)
            rootLayout.Add(cmdMinimize, 894, 118)

            lblPlayers = New LegacyLabel()
            lblPlayers.Caption = "Who"
            lblPlayers.ToolTip = "View the list of online players."
            lblPlayers.Size = New Size(35, 36)
            rootLayout.Add(lblPlayers, 708, 119)

            lblMapInfo = New LegacyLabel()
            lblMapInfo.Caption = "Map Name"
            lblMapInfo.Size = New Size(420, 16)
            rootLayout.Add(lblMapInfo, 20, 508)

            Label4 = New LegacyLabel()
            Label4.Caption = "POWERED BY PLAYERWORLDS"
            Label4.Visible = False
            Label4.Size = New Size(193, 9)
            rootLayout.Add(Label4, 40, 595)

            lblGUI = New LegacyLabel()
            lblGUI.Caption = ""
            lblGUI.Visible = False
            lblGUI.Size = New Size(25, 25)
            rootLayout.Add(lblGUI, 72, 616)

            Picture1 = New LegacyPictureBox()
            Picture1.Size = New Size(206, 11)
            rootLayout.Add(Picture1, 699, 39)
            Dim layout_Picture1 As New PixelLayout()
            Picture1.Content = layout_Picture1
            lblHP = New LegacyLabel()
            lblHP.Caption = "0%"
            lblHP.Size = New Size(211, 12)
            layout_Picture1.Add(lblHP, 0, 0)


            shpHP = New LegacyPictureBox()
            shpHP.Size = New Size(211, 12)
            rootLayout.Add(shpHP, 696, 39)
            Dim layout_shpHP As New PixelLayout()
            shpHP.Content = layout_shpHP
            lblHP_0 = New LegacyLabel()
            lblHP_0.Caption = "0%"
            lblHP_0.Size = New Size(211, 12)
            layout_shpHP.Add(lblHP_0, 1, 0)


            txtMyTextBox = New LegacyTextBox()
            txtMyTextBox.Text = ""
            txtMyTextBox.Size = New Size(640, 24)
            rootLayout.Add(txtMyTextBox, 18, 658)

            Picture2 = New LegacyPictureBox()
            Picture2.Size = New Size(206, 11)
            rootLayout.Add(Picture2, 699, 92)
            Dim layout_Picture2 As New PixelLayout()
            Picture2.Content = layout_Picture2
            lblSP = New LegacyLabel()
            lblSP.Caption = "0%"
            lblSP.Size = New Size(211, 12)
            layout_Picture2.Add(lblSP, 0, 0)


            Picture3 = New LegacyPictureBox()
            Picture3.Size = New Size(206, 11)
            rootLayout.Add(Picture3, 699, 57)
            Dim layout_Picture3 As New PixelLayout()
            Picture3.Content = layout_Picture3
            lblMP = New LegacyLabel()
            lblMP.Caption = "0%"
            lblMP.Size = New Size(211, 12)
            layout_Picture3.Add(lblMP, 0, 0)


            shpMP = New LegacyPictureBox()
            shpMP.Size = New Size(211, 12)
            rootLayout.Add(shpMP, 696, 56)
            Dim layout_shpMP As New PixelLayout()
            shpMP.Content = layout_shpMP
            lblMP_0 = New LegacyLabel()
            lblMP_0.Caption = "0%"
            lblMP_0.Size = New Size(211, 12)
            layout_shpMP.Add(lblMP_0, 1, 0)


            shpEXP = New LegacyPictureBox()
            shpEXP.Size = New Size(211, 12)
            rootLayout.Add(shpEXP, 696, 73)

            shpSP = New LegacyPictureBox()
            shpSP.Size = New Size(211, 12)
            rootLayout.Add(shpSP, 696, 90)
            Dim layout_shpSP As New PixelLayout()
            shpSP.Content = layout_shpSP
            lblSP_0 = New LegacyLabel()
            lblSP_0.Caption = "0%"
            lblSP_0.Size = New Size(211, 12)
            layout_shpSP.Add(lblSP_0, 0, 0)


            picScreen = New LegacyPictureBox()
            picScreen.Size = New Size(640, 480)
            rootLayout.Add(picScreen, 18, 18)

            hosttxtChat = New LegacyPictureBox()
            hosttxtChat.Size = New Size(640, 128)
            rootLayout.Add(hosttxtChat, 20, 524)

            fralvl2 = New LegacyFrame()
            fralvl2.Caption = "Mappers"
            fralvl2.Visible = False
            fralvl2.Size = New Size(97, 178)
            rootLayout.Add(fralvl2, 949, 183)
            Dim layout_fralvl2 As New PixelLayout()
            fralvl2.Content = layout_fralvl2
            cmdSignEdit = New LegacyButton()
            cmdSignEdit.Caption = "Sign Editor"
            cmdSignEdit.ToolTip = "Ban a player"
            cmdSignEdit.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdSignEdit, 8, 144)

            cmdLOC = New LegacyButton()
            cmdLOC.Caption = "Location"
            cmdLOC.ToolTip = "Find your location"
            cmdLOC.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdLOC, 8, 128)

            cmdBan = New LegacyButton()
            cmdBan.Caption = "Ban"
            cmdBan.ToolTip = "Ban a player"
            cmdBan.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdBan, 8, 112)

            cmdMapreport = New LegacyButton()
            cmdMapreport.Caption = "Map Report"
            cmdMapreport.ToolTip = "View all free maps"
            cmdMapreport.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdMapreport, 8, 96)

            cmdRespawn = New LegacyButton()
            cmdRespawn.Caption = "Respawn"
            cmdRespawn.ToolTip = "Respawn the map"
            cmdRespawn.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdRespawn, 8, 80)

            cmdPlayerSprite = New LegacyButton()
            cmdPlayerSprite.Caption = "Player Sprite"
            cmdPlayerSprite.ToolTip = "Change your sprite"
            cmdPlayerSprite.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdPlayerSprite, 8, 64)

            cmdMapeditor = New LegacyButton()
            cmdMapeditor.Caption = "MapEditor"
            cmdMapeditor.ToolTip = "Edit the map"
            cmdMapeditor.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdMapeditor, 8, 16)

            cmdWarpto = New LegacyButton()
            cmdWarpto.Caption = "Warpto"
            cmdWarpto.ToolTip = "Warp yourself to"
            cmdWarpto.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdWarpto, 8, 32)

            cmdSetSprite = New LegacyButton()
            cmdSetSprite.Caption = "Set Sprite"
            cmdSetSprite.ToolTip = "Change your sprite"
            cmdSetSprite.Size = New Size(81, 17)
            layout_fralvl2.Add(cmdSetSprite, 8, 48)


            fralvl1 = New LegacyFrame()
            fralvl1.Caption = "Monitors"
            fralvl1.Visible = False
            fralvl1.Size = New Size(97, 37)
            rootLayout.Add(fralvl1, 949, 144)
            Dim layout_fralvl1 As New PixelLayout()
            fralvl1.Content = layout_fralvl1
            cmdKick = New LegacyButton()
            cmdKick.Caption = "Kick"
            cmdKick.ToolTip = "Kick a player"
            cmdKick.Size = New Size(81, 17)
            layout_fralvl1.Add(cmdKick, 8, 16)


            fralvl3 = New LegacyFrame()
            fralvl3.Caption = "Developers"
            fralvl3.Visible = False
            fralvl3.Size = New Size(97, 154)
            rootLayout.Add(fralvl3, 949, 360)
            Dim layout_fralvl3 As New PixelLayout()
            fralvl3.Content = layout_fralvl3
            cmdNpcEditor = New LegacyButton()
            cmdNpcEditor.Caption = "Npc Editor"
            cmdNpcEditor.ToolTip = "Edit the Npcs"
            cmdNpcEditor.Size = New Size(81, 17)
            layout_fralvl3.Add(cmdNpcEditor, 8, 16)

            cmdItemEditor = New LegacyButton()
            cmdItemEditor.Caption = "Item Editor"
            cmdItemEditor.ToolTip = "Edit the Items"
            cmdItemEditor.Size = New Size(81, 17)
            layout_fralvl3.Add(cmdItemEditor, 8, 32)

            cmdShopEditor = New LegacyButton()
            cmdShopEditor.Caption = "ShopEditor"
            cmdShopEditor.ToolTip = "Edit the Shops"
            cmdShopEditor.Size = New Size(81, 17)
            layout_fralvl3.Add(cmdShopEditor, 8, 48)

            cmdSpellEditor = New LegacyButton()
            cmdSpellEditor.Caption = "SpellEditor"
            cmdSpellEditor.ToolTip = "Edit the Spells"
            cmdSpellEditor.Size = New Size(81, 17)
            layout_fralvl3.Add(cmdSpellEditor, 8, 64)

            cmdDelbanlist = New LegacyButton()
            cmdDelbanlist.Caption = "UnBan Player"
            cmdDelbanlist.ToolTip = "Unban Player."
            cmdDelbanlist.Size = New Size(81, 17)
            layout_fralvl3.Add(cmdDelbanlist, 8, 114)

            cmdKill = New LegacyButton()
            cmdKill.Caption = "Kill"
            cmdKill.ToolTip = "Kill a Player"
            cmdKill.Size = New Size(81, 17)
            layout_fralvl3.Add(cmdKill, 8, 129)

            cmbArrowEditor = New LegacyButton()
            cmbArrowEditor.Caption = "Arrow Editor"
            cmbArrowEditor.ToolTip = "Edit the Spells"
            cmbArrowEditor.Size = New Size(81, 17)
            layout_fralvl3.Add(cmbArrowEditor, 8, 98)

            cmbClassEditor = New LegacyButton()
            cmbClassEditor.Caption = "Class Editor"
            cmbClassEditor.ToolTip = "Edit the Spells"
            cmbClassEditor.Size = New Size(81, 17)
            layout_fralvl3.Add(cmbClassEditor, 8, 81)


            fralvl4 = New LegacyFrame()
            fralvl4.Caption = "Server Owner"
            fralvl4.Visible = False
            fralvl4.Size = New Size(97, 85)
            rootLayout.Add(fralvl4, 949, 511)
            Dim layout_fralvl4 As New PixelLayout()
            fralvl4.Content = layout_fralvl4
            AccessLevel = New LegacyLabel()
            AccessLevel.Caption = "Access Level"
            AccessLevel.Size = New Size(77, 18)
            layout_fralvl4.Add(AccessLevel, 8, 16)

            txtAccessLevel = New LegacyTextBox()
            txtAccessLevel.Text = ""
            txtAccessLevel.Size = New Size(81, 24)
            layout_fralvl4.Add(txtAccessLevel, 8, 32)

            cmdSetAccess = New LegacyButton()
            cmdSetAccess.Caption = "Set Access"
            cmdSetAccess.ToolTip = "Set a players' admin access"
            cmdSetAccess.Size = New Size(81, 19)
            layout_fralvl4.Add(cmdSetAccess, 8, 64)


            fraSpriteNum = New LegacyFrame()
            fraSpriteNum.Caption = "Sprite #"
            fraSpriteNum.Visible = False
            fraSpriteNum.Size = New Size(97, 48)
            rootLayout.Add(fraSpriteNum, 949, 96)
            Dim layout_fraSpriteNum As New PixelLayout()
            fraSpriteNum.Content = layout_fraSpriteNum
            txtSpriteNum = New LegacyTextBox()
            txtSpriteNum.Text = ""
            txtSpriteNum.Size = New Size(81, 24)
            layout_fraSpriteNum.Add(txtSpriteNum, 8, 16)


            fraPlayer = New LegacyFrame()
            fraPlayer.Caption = "Player Name"
            fraPlayer.Visible = False
            fraPlayer.Size = New Size(97, 48)
            rootLayout.Add(fraPlayer, 949, 0)
            Dim layout_fraPlayer As New PixelLayout()
            fraPlayer.Content = layout_fraPlayer
            txtPlayerName = New LegacyTextBox()
            txtPlayerName.Text = ""
            txtPlayerName.Size = New Size(81, 23)
            layout_fraPlayer.Add(txtPlayerName, 8, 16)


            fraMapNum = New LegacyFrame()
            fraMapNum.Caption = "Map Number"
            fraMapNum.Visible = False
            fraMapNum.Size = New Size(97, 48)
            rootLayout.Add(fraMapNum, 949, 48)
            Dim layout_fraMapNum As New PixelLayout()
            fraMapNum.Content = layout_fraMapNum
            txtMapNum = New LegacyTextBox()
            txtMapNum.Text = ""
            txtMapNum.Size = New Size(81, 24)
            layout_fraMapNum.Add(txtMapNum, 8, 16)


            imgSign = New ImageView()
            imgSign.Image = AssetLoader.LoadImage("frmMainGame/imgSign.jpg")
            imgSign.Visible = False
            imgSign.Size = New Size(185, 121)
            rootLayout.Add(imgSign, 245, 197)

            lblLine1Btm = New LegacyLabel()
            lblLine1Btm.Caption = "Label1"
            lblLine1Btm.Visible = False
            lblLine1Btm.Size = New Size(185, 25)
            rootLayout.Add(lblLine1Btm, 245, 235)

            lblLine2Btm = New LegacyLabel()
            lblLine2Btm.Caption = "Label1"
            lblLine2Btm.Visible = False
            lblLine2Btm.Size = New Size(185, 25)
            rootLayout.Add(lblLine2Btm, 245, 251)

            lblLine3Btm = New LegacyLabel()
            lblLine3Btm.Caption = "Label1"
            lblLine3Btm.Visible = False
            lblLine3Btm.Size = New Size(185, 25)
            rootLayout.Add(lblLine3Btm, 245, 267)

            lblNameBtm = New LegacyLabel()
            lblNameBtm.Caption = "Label1"
            lblNameBtm.Visible = False
            lblNameBtm.Size = New Size(185, 25)
            rootLayout.Add(lblNameBtm, 245, 208)

            lblexit = New LegacyLabel()
            lblexit.Caption = "Exit"
            lblexit.Visible = False
            lblexit.Size = New Size(57, 17)
            rootLayout.Add(lblexit, 309, 301)

            lblLine1Top = New LegacyLabel()
            lblLine1Top.Caption = "Label1"
            lblLine1Top.Visible = False
            lblLine1Top.Size = New Size(185, 25)
            rootLayout.Add(lblLine1Top, 248, 232)

            lblLine2Top = New LegacyLabel()
            lblLine2Top.Caption = "Label1"
            lblLine2Top.Visible = False
            lblLine2Top.Size = New Size(185, 25)
            rootLayout.Add(lblLine2Top, 248, 248)

            lblLine3Top = New LegacyLabel()
            lblLine3Top.Caption = "Label1"
            lblLine3Top.Visible = False
            lblLine3Top.Size = New Size(185, 25)
            rootLayout.Add(lblLine3Top, 248, 264)

            Line1 = New Drawable()
            Line1.Visible = False
            Line1.Size = New Size(10, 10)
            rootLayout.Add(Line1, 0, 0)

            lblNameTop = New LegacyLabel()
            lblNameTop.Caption = "Label1"
            lblNameTop.Visible = False
            lblNameTop.Size = New Size(185, 25)
            rootLayout.Add(lblNameTop, 248, 205)

            picGUI = New LegacyPictureBox()
            picGUI.Visible = False
            picGUI.Size = New Size(25, 25)
            rootLayout.Add(picGUI, 8, 616)

            cmdGUI = New LegacyButton()
            cmdGUI.Caption = ""
            cmdGUI.Visible = False
            cmdGUI.Size = New Size(25, 25)
            rootLayout.Add(cmdGUI, 40, 616)

            txtGUI = New LegacyTextBox()
            txtGUI.Text = ""
            txtGUI.Visible = False
            txtGUI.Size = New Size(25, 25)
            rootLayout.Add(txtGUI, 104, 616)

            chkGUI = New LegacyCheckBox()
            chkGUI.Caption = ""
            chkGUI.Checked = False
            chkGUI.Visible = False
            chkGUI.Size = New Size(25, 25)
            rootLayout.Add(chkGUI, 136, 616)

            picWebsite = New LegacyLabel()
            picWebsite.Caption = ""
            picWebsite.ToolTip = "Website"
            picWebsite.Size = New Size(121, 29)
            rootLayout.Add(picWebsite, 678, 665)

            picGuild = New LegacyLabel()
            picGuild.Caption = ""
            picGuild.ToolTip = "Guild information"
            picGuild.Size = New Size(42, 42)
            rootLayout.Add(picGuild, 781, 179)

            imgWho = New ImageView()
            imgWho.Image = AssetLoader.LoadImage("frmMainGame/imgWho.png")
            imgWho.Visible = False
            imgWho.Size = New Size(248, 266)
            rootLayout.Add(imgWho, 677, 280)

            lblWhoMessage = New LegacyLabel()
            lblWhoMessage.Caption = ""
            lblWhoMessage.ToolTip = "Continue"
            lblWhoMessage.Visible = False
            lblWhoMessage.Size = New Size(103, 24)
            rootLayout.Add(lblWhoMessage, 697, 510)

            lblWhoFriend = New LegacyLabel()
            lblWhoFriend.Caption = ""
            lblWhoFriend.ToolTip = "Continue"
            lblWhoFriend.Visible = False
            lblWhoFriend.Size = New Size(99, 24)
            rootLayout.Add(lblWhoFriend, 803, 510)

            imgInventory = New ImageView()
            imgInventory.Image = AssetLoader.LoadImage("frmMainGame/imgInventory.jpg")
            imgInventory.Visible = False
            imgInventory.Size = New Size(265, 382)
            rootLayout.Add(imgInventory, 673, 277)

            lstInv = New LegacyListBox()
            lstInv.Visible = False
            lstInv.Size = New Size(217, 132)
            rootLayout.Add(lstInv, 689, 357)

            picItem = New LegacyPictureBox()
            picItem.ToolTip = "This is an image of the selected item in your inventory."
            picItem.Visible = False
            picItem.Size = New Size(32, 32)
            rootLayout.Add(picItem, 748, 310)

            imgNotes = New ImageView()
            imgNotes.Image = AssetLoader.LoadImage("frmMainGame/imgNotes.png")
            imgNotes.Visible = False
            imgNotes.Size = New Size(248, 266)
            rootLayout.Add(imgNotes, 676, 280)

            lblNoteSave = New LegacyLabel()
            lblNoteSave.Caption = ""
            lblNoteSave.Visible = False
            lblNoteSave.Size = New Size(108, 25)
            rootLayout.Add(lblNoteSave, 808, 504)

            imgTraining = New ImageView()
            imgTraining.Image = AssetLoader.LoadImage("frmMainGame/imgTraining.png")
            imgTraining.Visible = False
            imgTraining.Size = New Size(248, 266)
            rootLayout.Add(imgTraining, 677, 280)

            lblPlayerPoints = New LegacyLabel()
            lblPlayerPoints.Caption = "Current Stat Points: 0"
            lblPlayerPoints.Visible = False
            lblPlayerPoints.Size = New Size(220, 20)
            rootLayout.Add(lblPlayerPoints, 691, 323)

            lblTrain = New LegacyLabel()
            lblTrain.Caption = ""
            lblTrain.Visible = False
            lblTrain.Size = New Size(65, 25)
            rootLayout.Add(lblTrain, 853, 504)

            cmbStat = New LegacyComboBox()
            cmbStat.Items.Add("Strength")
            cmbStat.Items.Add("Defense")
            cmbStat.Items.Add("Magic")
            cmbStat.Items.Add("Speed")
            cmbStat.Visible = False
            cmbStat.Size = New Size(185, 21)
            rootLayout.Add(cmbStat, 709, 408)

            imgCharacter = New ImageView()
            imgCharacter.Image = AssetLoader.LoadImage("frmMainGame/imgCharacter.jpg")
            imgCharacter.Visible = False
            imgCharacter.Size = New Size(265, 354)
            rootLayout.Add(imgCharacter, 679, 281)

            lblGearName = New LegacyLabel()
            lblGearName.Caption = ""
            lblGearName.Visible = False
            lblGearName.Size = New Size(129, 16)
            rootLayout.Add(lblGearName, 791, 409)

            lblGearDur = New LegacyLabel()
            lblGearDur.Caption = ""
            lblGearDur.Visible = False
            lblGearDur.Size = New Size(85, 17)
            rootLayout.Add(lblGearDur, 791, 436)

            lblGearStr = New LegacyLabel()
            lblGearStr.Caption = ""
            lblGearStr.Visible = False
            lblGearStr.Size = New Size(65, 17)
            rootLayout.Add(lblGearStr, 791, 465)

            imgEquipment = New ImageView()
            imgEquipment.Visible = False
            imgEquipment.Size = New Size(32, 32)
            rootLayout.Add(imgEquipment, 724, 579)

            imgEquipment_1 = New ImageView()
            imgEquipment_1.Visible = False
            imgEquipment_1.Size = New Size(32, 32)
            rootLayout.Add(imgEquipment_1, 769, 579)

            imgEquipment_2 = New ImageView()
            imgEquipment_2.Visible = False
            imgEquipment_2.Size = New Size(32, 32)
            rootLayout.Add(imgEquipment_2, 814, 579)

            imgEquipment_3 = New ImageView()
            imgEquipment_3.Visible = False
            imgEquipment_3.Size = New Size(32, 32)
            rootLayout.Add(imgEquipment_3, 859, 579)

            lblCharacterValue_0 = New LegacyLabel()
            lblCharacterValue_0.Caption = ""
            lblCharacterValue_0.Visible = False
            lblCharacterValue_0.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_0, 789, 310)

            lblCharacterValue_2 = New LegacyLabel()
            lblCharacterValue_2.Caption = ""
            lblCharacterValue_2.Visible = False
            lblCharacterValue_2.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_2, 789, 350)

            lblCharacterValue_3 = New LegacyLabel()
            lblCharacterValue_3.Caption = ""
            lblCharacterValue_3.Visible = False
            lblCharacterValue_3.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_3, 789, 370)

            lblCharacterValue_4 = New LegacyLabel()
            lblCharacterValue_4.Caption = ""
            lblCharacterValue_4.Visible = False
            lblCharacterValue_4.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_4, 789, 390)

            lblCharacterValue_5 = New LegacyLabel()
            lblCharacterValue_5.Caption = ""
            lblCharacterValue_5.Visible = False
            lblCharacterValue_5.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_5, 789, 410)

            lblCharacterValue_6 = New LegacyLabel()
            lblCharacterValue_6.Caption = ""
            lblCharacterValue_6.Visible = False
            lblCharacterValue_6.Size = New Size(28, 15)
            rootLayout.Add(lblCharacterValue_6, 773, 430)

            lblCharacterValue_7 = New LegacyLabel()
            lblCharacterValue_7.Caption = ""
            lblCharacterValue_7.Visible = False
            lblCharacterValue_7.Size = New Size(28, 15)
            rootLayout.Add(lblCharacterValue_7, 888, 430)

            lblCharacterValue_8 = New LegacyLabel()
            lblCharacterValue_8.Caption = ""
            lblCharacterValue_8.Visible = False
            lblCharacterValue_8.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_8, 789, 450)

            lblCharacterValue_9 = New LegacyLabel()
            lblCharacterValue_9.Caption = ""
            lblCharacterValue_9.Visible = False
            lblCharacterValue_9.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_9, 789, 470)

            lblCharacterValue_10 = New LegacyLabel()
            lblCharacterValue_10.Caption = ""
            lblCharacterValue_10.Visible = False
            lblCharacterValue_10.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_10, 789, 490)

            lblCharacterValue_11 = New LegacyLabel()
            lblCharacterValue_11.Caption = ""
            lblCharacterValue_11.Visible = False
            lblCharacterValue_11.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_11, 789, 510)

            lblCharacterValue_12 = New LegacyLabel()
            lblCharacterValue_12.Caption = ""
            lblCharacterValue_12.Visible = False
            lblCharacterValue_12.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_12, 789, 530)

            lblCharacterValue_13 = New LegacyLabel()
            lblCharacterValue_13.Caption = ""
            lblCharacterValue_13.Visible = False
            lblCharacterValue_13.Size = New Size(127, 15)
            rootLayout.Add(lblCharacterValue_13, 789, 550)

            lblForget = New LegacyLabel()
            lblForget.Caption = ""
            lblForget.Visible = False
            lblForget.Size = New Size(116, 29)
            rootLayout.Add(lblForget, 813, 498)

            lstSpells = New LegacyListBox()
            lstSpells.Visible = False
            lstSpells.Size = New Size(225, 132)
            rootLayout.Add(lstSpells, 689, 358)

            lblSkillsNext = New LegacyLabel()
            lblSkillsNext.Caption = ""
            lblSkillsNext.Visible = False
            lblSkillsNext.Size = New Size(116, 29)
            rootLayout.Add(lblSkillsNext, 813, 541)

            lblSkillsPrevious = New LegacyLabel()
            lblSkillsPrevious.Caption = ""
            lblSkillsPrevious.Visible = False
            lblSkillsPrevious.Size = New Size(116, 29)
            rootLayout.Add(lblSkillsPrevious, 813, 584)

            lblSkillsUpgrade = New LegacyLabel()
            lblSkillsUpgrade.Caption = ""
            lblSkillsUpgrade.ToolTip = "Spell upgrades are not supported by this game."
            lblSkillsUpgrade.Enabled = False
            lblSkillsUpgrade.Visible = False
            lblSkillsUpgrade.Size = New Size(116, 29)
            rootLayout.Add(lblSkillsUpgrade, 813, 459)

            lblSkillName = New LegacyLabel()
            lblSkillName.Caption = ""
            lblSkillName.Visible = False
            lblSkillName.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName, 736, 305)

            imgSkillIcon = New ImageView()
            imgSkillIcon.Visible = False
            imgSkillIcon.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon, 698, 305)

            lblSkillName_1 = New LegacyLabel()
            lblSkillName_1.Caption = ""
            lblSkillName_1.Visible = False
            lblSkillName_1.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_1, 736, 344)

            imgSkillIcon_1 = New ImageView()
            imgSkillIcon_1.Visible = False
            imgSkillIcon_1.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_1, 698, 344)

            lblSkillName_2 = New LegacyLabel()
            lblSkillName_2.Caption = ""
            lblSkillName_2.Visible = False
            lblSkillName_2.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_2, 736, 383)

            imgSkillIcon_2 = New ImageView()
            imgSkillIcon_2.Visible = False
            imgSkillIcon_2.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_2, 698, 383)

            lblSkillName_3 = New LegacyLabel()
            lblSkillName_3.Caption = ""
            lblSkillName_3.Visible = False
            lblSkillName_3.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_3, 736, 422)

            imgSkillIcon_3 = New ImageView()
            imgSkillIcon_3.Visible = False
            imgSkillIcon_3.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_3, 698, 422)

            lblSkillName_4 = New LegacyLabel()
            lblSkillName_4.Caption = ""
            lblSkillName_4.Visible = False
            lblSkillName_4.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_4, 736, 461)

            imgSkillIcon_4 = New ImageView()
            imgSkillIcon_4.Visible = False
            imgSkillIcon_4.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_4, 698, 461)

            lblSkillName_5 = New LegacyLabel()
            lblSkillName_5.Caption = ""
            lblSkillName_5.Visible = False
            lblSkillName_5.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_5, 736, 500)

            imgSkillIcon_5 = New ImageView()
            imgSkillIcon_5.Visible = False
            imgSkillIcon_5.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_5, 698, 500)

            lblSkillName_6 = New LegacyLabel()
            lblSkillName_6.Caption = ""
            lblSkillName_6.Visible = False
            lblSkillName_6.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_6, 736, 539)

            imgSkillIcon_6 = New ImageView()
            imgSkillIcon_6.Visible = False
            imgSkillIcon_6.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_6, 698, 539)

            lblSkillName_7 = New LegacyLabel()
            lblSkillName_7.Caption = ""
            lblSkillName_7.Visible = False
            lblSkillName_7.Size = New Size(67, 34)
            rootLayout.Add(lblSkillName_7, 736, 578)

            imgSkillIcon_7 = New ImageView()
            imgSkillIcon_7.Visible = False
            imgSkillIcon_7.Size = New Size(32, 32)
            rootLayout.Add(imgSkillIcon_7, 698, 578)

            lblPoints = New LegacyLabel()
            lblPoints.Caption = ""
            lblPoints.Visible = False
            lblPoints.Size = New Size(97, 17)
            rootLayout.Add(lblPoints, 757, 504)

            lblBlock = New LegacyLabel()
            lblBlock.Caption = ""
            lblBlock.Visible = False
            lblBlock.Size = New Size(97, 17)
            rootLayout.Add(lblBlock, 757, 488)

            lblCHit = New LegacyLabel()
            lblCHit.Caption = ""
            lblCHit.Visible = False
            lblCHit.Size = New Size(97, 17)
            rootLayout.Add(lblCHit, 757, 472)

            lblTNL = New LegacyLabel()
            lblTNL.Caption = ""
            lblTNL.Visible = False
            lblTNL.Size = New Size(97, 17)
            rootLayout.Add(lblTNL, 757, 448)

            lblEXP = New LegacyLabel()
            lblEXP.Caption = ""
            lblEXP.Visible = False
            lblEXP.Size = New Size(89, 17)
            rootLayout.Add(lblEXP, 765, 432)

            lblSPEED = New LegacyLabel()
            lblSPEED.Caption = ""
            lblSPEED.Visible = False
            lblSPEED.Size = New Size(97, 17)
            rootLayout.Add(lblSPEED, 757, 376)

            lblMAGI = New LegacyLabel()
            lblMAGI.Caption = ""
            lblMAGI.Visible = False
            lblMAGI.Size = New Size(97, 17)
            rootLayout.Add(lblMAGI, 757, 408)

            lblDEF = New LegacyLabel()
            lblDEF.Caption = ""
            lblDEF.Visible = False
            lblDEF.Size = New Size(97, 17)
            rootLayout.Add(lblDEF, 757, 392)

            lblSTR = New LegacyLabel()
            lblSTR.Caption = ""
            lblSTR.Visible = False
            lblSTR.Size = New Size(97, 17)
            rootLayout.Add(lblSTR, 757, 352)

            lblLevel = New LegacyLabel()
            lblLevel.Caption = ""
            lblLevel.Visible = False
            lblLevel.Size = New Size(97, 17)
            rootLayout.Add(lblLevel, 757, 336)

            Label8 = New LegacyLabel()
            Label8.Caption = ""
            Label8.Visible = False
            Label8.Size = New Size(65, 25)
            rootLayout.Add(Label8, 853, 504)

            imgMap = New ImageView()
            imgMap.Size = New Size(49, 14)
            rootLayout.Add(imgMap, 455, 509)

            Image1 = New ImageView()
            Image1.Size = New Size(200, 50)
            rootLayout.Add(Image1, 556, 522)

            imgGlobal = New ImageView()
            imgGlobal.Size = New Size(48, 14)
            rootLayout.Add(imgGlobal, 507, 509)

            imgGuild = New ImageView()
            imgGuild.Size = New Size(48, 14)
            rootLayout.Add(imgGuild, 558, 509)

            imgPM = New ImageView()
            imgPM.Size = New Size(48, 14)
            rootLayout.Add(imgPM, 608, 508)

            scrlPicture = New LegacyScrollBar()
            scrlPicture.MinValue = 0
            scrlPicture.MaxValue = 937
            scrlPicture.Value = 0
            scrlPicture.Orientation = Orientation.Vertical
            scrlPicture.SmallChange = 1
            scrlPicture.LargeChange = 7
            scrlPicture.Size = New Size(17, 225)
            rootLayout.Add(scrlPicture, 1350, 44)

            AddHandler Shown, AddressOf OnFormShown
            AddHandler Closed, AddressOf OnFormClosed
            WireGameClientLogic()
        End Sub

        Protected Overridable Sub OnFormShown(sender As Object, e As EventArgs)
            _client.MainGameAction("Form_Load")
            CloseSideMenu()
        End Sub

        Private Sub OnFormClosed(sender As Object, e As EventArgs)
            _client.GameDestroy()
        End Sub

        Private Sub WireGameClientLogic()
            ' Main game menu commands from frmMirage.frm.twin.
            AddMouseAction(picQuit, "GameDestroy")
            AddMouseAction(picOptions, "ShowOptions")
            AddMouseAction(picBugReport, "ShowBugReport")
            AddMouseAction(picTrade, "TradeRequest")
            AddMouseAction(picStats, "ToggleStats")
            AddMouseAction(picTrain, "ToggleTrain")
            AddMouseAction(picInventory, "ToggleInventory")
            AddMouseAction(picSpells, "ToggleSpells")
            AddMouseAction(lblKeepNotes, "ToggleNotes")
            AddMouseAction(lblPlayers, "SendWhosOnline")
            AddMouseAction(picWebsite, "OpenWebsite")
            AddMouseAction(picGuild, "ToggleGuild")
            AddMouseAction(picPM, "PrivateMessage")

            AddHandler cmdFill.Click, Sub(sender, e) _client.MainGameAction("EditorFillLayer", optLayers.Checked)
            AddHandler cmdClear.Click, Sub(sender, e) _client.MainGameAction("EditorClearLayer", optLayers.Checked)
            AddHandler cmdProperties.Click, Sub(sender, e) _client.MainGameAction("MapProperties")
            AddHandler cmdCancel.Click, Sub(sender, e) _client.MainGameAction("MapEditorCancel")
            AddHandler cmdSend.Click, Sub(sender, e) _client.MainGameAction("SendChat", txtMyTextBox.Text)

            AddHandler cmdBan.Click, Sub(sender, e) _client.MainGameAction("Ban", txtPlayerName.Text)
            AddHandler cmdDelbanlist.Click, Sub(sender, e) _client.MainGameAction("ClearBanList")
            AddHandler cmdItemEditor.Click, Sub(sender, e) _client.MainGameAction("ItemEditor")
            AddHandler cmdNpcEditor.Click, Sub(sender, e) _client.MainGameAction("NpcEditor")
            AddHandler cmdSetSprite.Click, Sub(sender, e) _client.MainGameAction("SetSprite", txtPlayerName.Text)
            AddHandler cmdPlayerSprite.Click, Sub(sender, e) _client.MainGameAction("PlayerSprite", txtPlayerName.Text)
            AddHandler cmdShopEditor.Click, Sub(sender, e) _client.MainGameAction("ShopEditor")
            AddHandler cmdSpellEditor.Click, Sub(sender, e) _client.MainGameAction("SpellEditor")
            AddHandler cmdKick.Click, Sub(sender, e) _client.MainGameAction("Kick", txtPlayerName.Text)
            AddHandler cmdLOC.Click, Sub(sender, e) _client.MainGameAction("Location", txtPlayerName.Text)
            AddHandler cmdMapeditor.Click, Sub(sender, e) _client.MainGameAction("MapEditor")
            AddHandler cmdMapreport.Click, Sub(sender, e) _client.MainGameAction("MapReport")
            AddHandler cmdRespawn.Click, Sub(sender, e) _client.MainGameAction("RespawnMap")
            AddHandler cmdSetAccess.Click, Sub(sender, e) _client.MainGameAction("SetAccess", txtPlayerName.Text, txtAccessLevel.Text)
            AddHandler cmdWarpto.Click, Sub(sender, e) _client.MainGameAction("WarpTo", txtPlayerName.Text)
            AddHandler cmdSignEdit.Click, Sub(sender, e) _client.MainGameAction("SignEditor")
            AddHandler cmbClassEditor.Click, Sub(sender, e) _client.MainGameAction("ClassEditor")
            AddHandler cmbArrowEditor.Click, Sub(sender, e) _client.MainGameAction("ArrowEditor")

            AddHandler optBlocked.CheckedChanged, Sub(sender, e)
                                                       If optBlocked.Checked Then _client.MainGameAction("MapBlock")
                                                   End Sub
            AddHandler optNpcSpawn.CheckedChanged, Sub(sender, e)
                                                        If optNpcSpawn.Checked Then _client.MainGameAction("MapSpawnNpc")
                                                    End Sub
            AddHandler optNudge.CheckedChanged, Sub(sender, e)
                                                    If optNudge.Checked Then _client.MainGameAction("MapNudge")
                                                End Sub
            AddHandler optSprite.CheckedChanged, Sub(sender, e)
                                                     If optSprite.Checked Then _client.MainGameAction("SetSpriteAttribute")
                                                 End Sub

            AddHandler lstInv.MouseDoubleClick, Sub(sender, e) _client.MainGameAction("UseInventoryItem", lstInv.SelectedIndex)
            AddHandler lstSpells.MouseDoubleClick, Sub(sender, e) _client.MainGameAction("CastSpell", lstSpells.SelectedIndex)
            AddHandler lstPlayers.MouseDoubleClick, Sub(sender, e) _client.MainGameAction("MessagePlayer", lstPlayers.SelectedIndex)

            AddHandler txtMyTextBox.KeyDown, AddressOf HandleChatKeyDown
            AddHandler KeyDown, AddressOf HandleGameKeyDown
            AddHandler KeyUp, AddressOf HandleGameKeyUp
            AddHandler picBack.Canvas.MouseDown, Sub(sender, e) _client.MainGameAction("EditorChooseTile", e.Buttons, e.Location.X, e.Location.Y)
            AddHandler picBack.Canvas.MouseMove, Sub(sender, e) _client.MainGameAction("EditorUpdateSelection", e.Buttons, e.Location.X, e.Location.Y)
            AddHandler picBack.Canvas.MouseUp, Sub(sender, e) _client.MainGameAction("EditorEndSelection", e.Buttons, e.Location.X, e.Location.Y)
            AddHandler scrlPicture.ValueChanged, Sub(sender, e) _client.MainGameAction("TilesetScroll", scrlPicture.Value)
        End Sub

        Private Sub AddMouseAction(control As Control, actionName As String)
            If control Is Nothing Then Return
            AddHandler control.MouseDown, Sub(sender, e)
                                              If e.Buttons = MouseButtons.Primary Then
                                                  If actionName = "GameDestroy" Then
                                                      _client.GameDestroy()
                                                  ElseIf actionName = "OpenWebsite" Then
                                                      _client.OpenWebsite()
                                                  Else
                                                      _client.MainGameAction(actionName)
                                                  End If
                                              End If
                                          End Sub
        End Sub

        Private Sub HandleChatKeyDown(sender As Object, e As KeyEventArgs)
            If e.Key <> Keys.Enter Then Return
            Dim text = If(txtMyTextBox.Text, String.Empty)
            _client.MainGameAction("HandleKeypresses", Keys.Enter, text)
            e.Handled = True
        End Sub

        Private Sub HandleGameKeyDown(sender As Object, e As KeyEventArgs)
            _client.MainGameAction("CheckInput", 1, e.KeyData)
        End Sub

        Private Sub HandleGameKeyUp(sender As Object, e As KeyEventArgs)
            _client.MainGameAction("CheckInput", 0, e.KeyData)
            _client.MainGameAction("UseSlotHotkey", e.Key)
        End Sub

        Public Sub CloseSideMenu()
            picPlayerList.Visible = False
            lstPlayers.Visible = False
            picPM.Visible = False
            imgWho.Visible = False
            imgInventory.Visible = False
            imgNotes.Visible = False
            imgTraining.Visible = False
            imgLiveStats.Visible = False
        End Sub
    End Class
End Namespace
