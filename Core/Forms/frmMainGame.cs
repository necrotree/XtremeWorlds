using System;
using Eto.Drawing;
using Eto.Forms;
using XtremeWorlds.Client.Logic;
using XtremeWorlds.Client.UI;

namespace XtremeWorlds.Client.Forms
{
    public class frmMainGame : Form
    {

        private readonly IGameClientRuntime _client;

        public readonly LegacyLabel lblCharacterValue;
        public readonly LegacyLabel lblSkillsDetails;
        public readonly ImageView imgLiveStats;
        public readonly LegacyPictureBox picPlayerList;
        public readonly LegacyLabel lblFriend;
        public readonly LegacyLabel lblWeb;
        public readonly LegacyLabel picPM;
        public readonly LegacyListBox lstPlayers;
        public readonly LegacyListBox lstWho;
        public readonly LegacyPictureBox hostNotetext;
        public readonly ImageView imgSkills;
        public readonly LegacyLabel lblExperience;
        public readonly LegacyPictureBox picMapEditor;
        public readonly LegacyPictureBox picBack;
        public readonly LegacyButton cmdProperties;
        public readonly LegacyButton cmdCancel;
        public readonly LegacyRadioButton optAttribs;
        public readonly LegacyRadioButton optLayers;
        public readonly LegacyFrame SSTab1;
        public readonly LegacyPictureBox Picture5;
        public readonly LegacyRadioButton optWarp;
        public readonly LegacyRadioButton optDoor;
        public readonly LegacyRadioButton optKill;
        public readonly LegacyRadioButton optHeal;
        public readonly LegacyRadioButton optKeyOpen;
        public readonly LegacyRadioButton optBlocked;
        public readonly LegacyRadioButton optItem;
        public readonly LegacyRadioButton optNpcAvoid;
        public readonly LegacyRadioButton optKey;
        public readonly LegacyRadioButton optSign;
        public readonly LegacyRadioButton optMsg;
        public readonly LegacyRadioButton optSprite;
        public readonly LegacyRadioButton optNpcSpawn;
        public readonly LegacyRadioButton optFlight;
        public readonly LegacyRadioButton optNudge;
        public readonly LegacyPictureBox Picture6;
        public readonly LegacyRadioButton optF2Anim;
        public readonly LegacyRadioButton optFringe2;
        public readonly LegacyRadioButton optFAnim;
        public readonly LegacyRadioButton optM2Anim;
        public readonly LegacyRadioButton optMask2;
        public readonly LegacyRadioButton optGround;
        public readonly LegacyRadioButton optMask;
        public readonly LegacyRadioButton optAnim;
        public readonly LegacyRadioButton optFringe;
        public readonly LegacyButton cmdEditorLayers;
        public readonly LegacyButton cmdEditorAttribs;
        public readonly LegacyButton cmdFill;
        public readonly LegacyButton cmdClear;
        public readonly LegacyFrame fraMapSettings;
        public readonly LegacyLabel lblMapY;
        public readonly LegacyLabel lblMapX;
        public readonly LegacyLabel Label16;
        public readonly LegacyLabel lblMapNumber;
        public readonly LegacyLabel Label9;
        public readonly LegacyLabel lblMapName;
        public readonly LegacyLabel Label2;
        public readonly LegacyButton cmdSend;
        public readonly LegacyScrollBar scrlTileset;
        public readonly LegacyLabel picTrade;
        public readonly LegacyLabel picSpells;
        public readonly LegacyLabel picInventory;
        public readonly LegacyLabel picTrain;
        public readonly LegacyLabel picStats;
        public readonly LegacyLabel picQuit;
        public readonly LegacyLabel picBugReport;
        public readonly LegacyLabel lblKeepNotes;
        public readonly LegacyLabel lblGameName;
        public readonly LegacyLabel picOptions;
        public readonly LegacyLabel cmdMinimize;
        public readonly LegacyLabel lblPlayers;
        public readonly LegacyLabel lblMapInfo;
        public readonly LegacyLabel Label4;
        public readonly LegacyLabel lblGUI;
        public readonly LegacyPictureBox Picture1;
        public readonly LegacyLabel lblHP;
        public readonly LegacyPictureBox shpHP;
        public readonly LegacyLabel lblHP_0;
        public readonly LegacyTextBox txtMyTextBox;
        public readonly LegacyPictureBox Picture2;
        public readonly LegacyLabel lblSP;
        public readonly LegacyPictureBox Picture3;
        public readonly LegacyLabel lblMP;
        public readonly LegacyPictureBox shpMP;
        public readonly LegacyLabel lblMP_0;
        public readonly LegacyPictureBox shpEXP;
        public readonly LegacyPictureBox shpSP;
        public readonly LegacyLabel lblSP_0;
        public readonly LegacyPictureBox picScreen;
        public readonly LegacyPictureBox hosttxtChat;
        public readonly LegacyFrame fralvl2;
        public readonly LegacyButton cmdSignEdit;
        public readonly LegacyButton cmdLOC;
        public readonly LegacyButton cmdBan;
        public readonly LegacyButton cmdMapreport;
        public readonly LegacyButton cmdRespawn;
        public readonly LegacyButton cmdPlayerSprite;
        public readonly LegacyButton cmdMapeditor;
        public readonly LegacyButton cmdWarpto;
        public readonly LegacyButton cmdSetSprite;
        public readonly LegacyFrame fralvl1;
        public readonly LegacyButton cmdKick;
        public readonly LegacyFrame fralvl3;
        public readonly LegacyButton cmdNpcEditor;
        public readonly LegacyButton cmdItemEditor;
        public readonly LegacyButton cmdShopEditor;
        public readonly LegacyButton cmdSpellEditor;
        public readonly LegacyButton cmdDelbanlist;
        public readonly LegacyButton cmdKill;
        public readonly LegacyButton cmbArrowEditor;
        public readonly LegacyButton cmbClassEditor;
        public readonly LegacyFrame fralvl4;
        public readonly LegacyLabel AccessLevel;
        public readonly LegacyTextBox txtAccessLevel;
        public readonly LegacyButton cmdSetAccess;
        public readonly LegacyFrame fraSpriteNum;
        public readonly LegacyTextBox txtSpriteNum;
        public readonly LegacyFrame fraPlayer;
        public readonly LegacyTextBox txtPlayerName;
        public readonly LegacyFrame fraMapNum;
        public readonly LegacyTextBox txtMapNum;
        public readonly ImageView imgSign;
        public readonly LegacyLabel lblLine1Btm;
        public readonly LegacyLabel lblLine2Btm;
        public readonly LegacyLabel lblLine3Btm;
        public readonly LegacyLabel lblNameBtm;
        public readonly LegacyLabel lblexit;
        public readonly LegacyLabel lblLine1Top;
        public readonly LegacyLabel lblLine2Top;
        public readonly LegacyLabel lblLine3Top;
        public readonly Drawable Line1;
        public readonly LegacyLabel lblNameTop;
        public readonly LegacyPictureBox picGUI;
        public readonly LegacyButton cmdGUI;
        public readonly LegacyTextBox txtGUI;
        public readonly LegacyCheckBox chkGUI;
        public readonly LegacyLabel picWebsite;
        public readonly LegacyLabel picGuild;
        public readonly ImageView imgWho;
        public readonly LegacyLabel lblWhoMessage;
        public readonly LegacyLabel lblWhoFriend;
        public readonly ImageView imgInventory;
        public readonly LegacyListBox lstInv;
        public readonly LegacyPictureBox picItem;
        public readonly ImageView imgNotes;
        public readonly LegacyLabel lblNoteSave;
        public readonly ImageView imgTraining;
        public readonly LegacyLabel lblPlayerPoints;
        public readonly LegacyLabel lblTrain;
        public readonly LegacyComboBox cmbStat;
        public readonly ImageView imgCharacter;
        public readonly LegacyLabel lblGearName;
        public readonly LegacyLabel lblGearDur;
        public readonly LegacyLabel lblGearStr;
        public readonly ImageView imgEquipment;
        public readonly ImageView imgEquipment_1;
        public readonly ImageView imgEquipment_2;
        public readonly ImageView imgEquipment_3;
        public readonly LegacyLabel lblCharacterValue_0;
        public readonly LegacyLabel lblCharacterValue_2;
        public readonly LegacyLabel lblCharacterValue_3;
        public readonly LegacyLabel lblCharacterValue_4;
        public readonly LegacyLabel lblCharacterValue_5;
        public readonly LegacyLabel lblCharacterValue_6;
        public readonly LegacyLabel lblCharacterValue_7;
        public readonly LegacyLabel lblCharacterValue_8;
        public readonly LegacyLabel lblCharacterValue_9;
        public readonly LegacyLabel lblCharacterValue_10;
        public readonly LegacyLabel lblCharacterValue_11;
        public readonly LegacyLabel lblCharacterValue_12;
        public readonly LegacyLabel lblCharacterValue_13;
        public readonly LegacyLabel lblForget;
        public readonly LegacyListBox lstSpells;
        public readonly LegacyLabel lblSkillsNext;
        public readonly LegacyLabel lblSkillsPrevious;
        public readonly LegacyLabel lblSkillsUpgrade;
        public readonly LegacyLabel lblSkillName;
        public readonly ImageView imgSkillIcon;
        public readonly LegacyLabel lblSkillName_1;
        public readonly ImageView imgSkillIcon_1;
        public readonly LegacyLabel lblSkillName_2;
        public readonly ImageView imgSkillIcon_2;
        public readonly LegacyLabel lblSkillName_3;
        public readonly ImageView imgSkillIcon_3;
        public readonly LegacyLabel lblSkillName_4;
        public readonly ImageView imgSkillIcon_4;
        public readonly LegacyLabel lblSkillName_5;
        public readonly ImageView imgSkillIcon_5;
        public readonly LegacyLabel lblSkillName_6;
        public readonly ImageView imgSkillIcon_6;
        public readonly LegacyLabel lblSkillName_7;
        public readonly ImageView imgSkillIcon_7;
        public readonly LegacyLabel lblPoints;
        public readonly LegacyLabel lblBlock;
        public readonly LegacyLabel lblCHit;
        public readonly LegacyLabel lblTNL;
        public readonly LegacyLabel lblEXP;
        public readonly LegacyLabel lblSPEED;
        public readonly LegacyLabel lblMAGI;
        public readonly LegacyLabel lblDEF;
        public readonly LegacyLabel lblSTR;
        public readonly LegacyLabel lblLevel;
        public readonly LegacyLabel Label8;
        public readonly ImageView imgMap;
        public readonly ImageView Image1;
        public readonly ImageView imgGlobal;
        public readonly ImageView imgGuild;
        public readonly ImageView imgPM;
        public readonly LegacyScrollBar scrlPicture;

        public frmMainGame(IGameClientRuntime client = null)
        {
            _client = client ?? GameClientRuntime.Current;
            Title = "XtremeWorlds";
            Icon = AssetLoader.LoadIcon("Icon.ico");
            ClientSize = new Size(1396, 698);
            var rootLayout = new PixelLayout();
            Content = rootLayout;

            lblCharacterValue = new LegacyLabel();
            lblCharacterValue.Caption = "";
            lblCharacterValue.Visible = false;
            lblCharacterValue.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue, 789, 330);

            lblSkillsDetails = new LegacyLabel();
            lblSkillsDetails.Caption = "Select a spell.";
            lblSkillsDetails.Visible = false;
            lblSkillsDetails.Size = new Size(101, 143);
            rootLayout.Add(lblSkillsDetails, 820, 304);

            imgLiveStats = new ImageView();
            imgLiveStats.Visible = false;
            imgLiveStats.Size = new Size(248, 266);
            rootLayout.Add(imgLiveStats, 677, 280);

            picPlayerList = new LegacyPictureBox();
            picPlayerList.Visible = false;
            picPlayerList.Size = new Size(248, 266);
            rootLayout.Add(picPlayerList, 680, 281);
            var layout_picPlayerList = new PixelLayout();
            picPlayerList.Content = layout_picPlayerList;
            lblFriend = new LegacyLabel();
            lblFriend.Caption = "";
            lblFriend.Size = new Size(106, 25);
            layout_picPlayerList.Add(lblFriend, 125, 227);

            lblWeb = new LegacyLabel();
            lblWeb.Caption = "";
            lblWeb.ToolTip = "Web Browser";
            lblWeb.Size = new Size(57, 25);
            layout_picPlayerList.Add(lblWeb, 96, 224);

            picPM = new LegacyLabel();
            picPM.Caption = "";
            picPM.ToolTip = "Send a personal message!";
            picPM.Visible = false;
            picPM.Size = new Size(104, 25);
            layout_picPlayerList.Add(picPM, 15, 229);

            lstPlayers = new LegacyListBox();
            lstPlayers.Visible = false;
            lstPlayers.Size = new Size(205, 128);
            layout_picPlayerList.Add(lstPlayers, 22, 80);


            lstWho = new LegacyListBox();
            lstWho.Visible = false;
            lstWho.Size = new Size(216, 184);
            rootLayout.Add(lstWho, 692, 306);

            hostNotetext = new LegacyPictureBox();
            hostNotetext.Visible = false;
            hostNotetext.Size = new Size(218, 127);
            rootLayout.Add(hostNotetext, 697, 306);

            imgSkills = new ImageView();
            imgSkills.Image = AssetLoader.LoadImage("frmMainGame/imgSkills.jpg");
            imgSkills.Visible = false;
            imgSkills.Size = new Size(265, 382);
            rootLayout.Add(imgSkills, 677, 278);

            lblExperience = new LegacyLabel();
            lblExperience.Caption = "XP: 0 | TNL: --";
            lblExperience.ToolTip = "TNL: experience points remaining until the next level.";
            lblExperience.Size = new Size(257, 12);
            rootLayout.Add(lblExperience, 670, 74);

            picMapEditor = new LegacyPictureBox();
            picMapEditor.Visible = false;
            picMapEditor.Size = new Size(444, 595);
            rootLayout.Add(picMapEditor, 956, 5);
            var layout_picMapEditor = new PixelLayout();
            picMapEditor.Content = layout_picMapEditor;
            picBack = new LegacyPictureBox();
            picBack.Size = new Size(384, 224);
            layout_picMapEditor.Add(picBack, 8, 7);

            cmdProperties = new LegacyButton();
            cmdProperties.Caption = "Properties";
            cmdProperties.Size = new Size(89, 26);
            layout_picMapEditor.Add(cmdProperties, 152, 439);

            cmdCancel = new LegacyButton();
            cmdCancel.Caption = "Cancel";
            cmdCancel.Size = new Size(113, 33);
            layout_picMapEditor.Add(cmdCancel, 136, 552);

            optAttribs = new LegacyRadioButton();
            optAttribs.Caption = "Attributes";
            optAttribs.Visible = false;
            optAttribs.Size = new Size(105, 17);
            layout_picMapEditor.Add(optAttribs, 8, 472);

            optLayers = new LegacyRadioButton(optAttribs);
            optLayers.Caption = "Layers";
            optLayers.Value = true;
            optLayers.Visible = false;
            optLayers.Size = new Size(105, 17);
            layout_picMapEditor.Add(optLayers, 8, 456);

            SSTab1 = new LegacyFrame();
            SSTab1.Caption = "";
            SSTab1.Size = new Size(131, 281);
            layout_picMapEditor.Add(SSTab1, 8, 260);
            var layout_SSTab1 = new PixelLayout();
            SSTab1.Content = layout_SSTab1;
            Picture5 = new LegacyPictureBox();
            Picture5.Visible = false;
            Picture5.Size = new Size(89, 249);
            layout_SSTab1.Add(Picture5, 24, 32);
            var layout_Picture5 = new PixelLayout();
            Picture5.Content = layout_Picture5;
            optWarp = new LegacyRadioButton();
            optWarp.Caption = "Warp";
            optWarp.Size = new Size(81, 17);
            layout_Picture5.Add(optWarp, 0, 16);

            optDoor = new LegacyRadioButton(optWarp);
            optDoor.Caption = "Door";
            optDoor.Size = new Size(81, 17);
            layout_Picture5.Add(optDoor, 0, 128);

            optKill = new LegacyRadioButton(optWarp);
            optKill.Caption = "Damage";
            optKill.Size = new Size(81, 17);
            layout_Picture5.Add(optKill, 0, 112);

            optHeal = new LegacyRadioButton(optWarp);
            optHeal.Caption = "Heal";
            optHeal.Size = new Size(81, 17);
            layout_Picture5.Add(optHeal, 0, 96);

            optKeyOpen = new LegacyRadioButton(optWarp);
            optKeyOpen.Caption = "Key Open";
            optKeyOpen.Size = new Size(81, 16);
            layout_Picture5.Add(optKeyOpen, 0, 80);

            optBlocked = new LegacyRadioButton(optWarp);
            optBlocked.Caption = "Blocked";
            optBlocked.Value = true;
            optBlocked.Size = new Size(81, 17);
            layout_Picture5.Add(optBlocked, 0, 0);

            optItem = new LegacyRadioButton(optWarp);
            optItem.Caption = "Item";
            optItem.Size = new Size(81, 18);
            layout_Picture5.Add(optItem, 0, 32);

            optNpcAvoid = new LegacyRadioButton(optWarp);
            optNpcAvoid.Caption = "Npc Avoid";
            optNpcAvoid.Size = new Size(81, 18);
            layout_Picture5.Add(optNpcAvoid, 0, 48);

            optKey = new LegacyRadioButton(optWarp);
            optKey.Caption = "Key";
            optKey.Size = new Size(81, 18);
            layout_Picture5.Add(optKey, 0, 64);

            optSign = new LegacyRadioButton(optWarp);
            optSign.Caption = "Sign";
            optSign.Size = new Size(81, 17);
            layout_Picture5.Add(optSign, 0, 144);

            optMsg = new LegacyRadioButton(optWarp);
            optMsg.Caption = "Map Message";
            optMsg.Enabled = false;
            optMsg.Size = new Size(89, 17);
            layout_Picture5.Add(optMsg, 0, 160);

            optSprite = new LegacyRadioButton(optWarp);
            optSprite.Caption = "Sprite Change";
            optSprite.Size = new Size(89, 17);
            layout_Picture5.Add(optSprite, 0, 176);

            optNpcSpawn = new LegacyRadioButton(optWarp);
            optNpcSpawn.Caption = "NPC Spawn";
            optNpcSpawn.Size = new Size(89, 17);
            layout_Picture5.Add(optNpcSpawn, 0, 192);

            optFlight = new LegacyRadioButton(optWarp);
            optFlight.Caption = "Flight";
            optFlight.Enabled = false;
            optFlight.Size = new Size(89, 17);
            layout_Picture5.Add(optFlight, 0, 208);

            optNudge = new LegacyRadioButton(optWarp);
            optNudge.Caption = "Nudge";
            optNudge.Size = new Size(89, 17);
            layout_Picture5.Add(optNudge, 0, 224);


            Picture6 = new LegacyPictureBox();
            Picture6.Size = new Size(113, 257);
            layout_SSTab1.Add(Picture6, 8, 32);
            var layout_Picture6 = new PixelLayout();
            Picture6.Content = layout_Picture6;
            optF2Anim = new LegacyRadioButton();
            optF2Anim.Caption = "Animation";
            optF2Anim.Size = new Size(81, 17);
            layout_Picture6.Add(optF2Anim, 16, 168);

            optFringe2 = new LegacyRadioButton(optF2Anim);
            optFringe2.Caption = "Fringe2";
            optFringe2.Size = new Size(81, 17);
            layout_Picture6.Add(optFringe2, 16, 152);

            optFAnim = new LegacyRadioButton(optF2Anim);
            optFAnim.Caption = "Animation";
            optFAnim.Size = new Size(81, 17);
            layout_Picture6.Add(optFAnim, 16, 136);

            optM2Anim = new LegacyRadioButton(optF2Anim);
            optM2Anim.Caption = "Animation";
            optM2Anim.Size = new Size(81, 17);
            layout_Picture6.Add(optM2Anim, 16, 104);

            optMask2 = new LegacyRadioButton(optF2Anim);
            optMask2.Caption = "Mask2";
            optMask2.Size = new Size(81, 17);
            layout_Picture6.Add(optMask2, 16, 88);

            optGround = new LegacyRadioButton(optF2Anim);
            optGround.Caption = "Ground";
            optGround.Value = true;
            optGround.Size = new Size(81, 17);
            layout_Picture6.Add(optGround, 16, 40);

            optMask = new LegacyRadioButton(optF2Anim);
            optMask.Caption = "Mask";
            optMask.Size = new Size(81, 17);
            layout_Picture6.Add(optMask, 16, 56);

            optAnim = new LegacyRadioButton(optF2Anim);
            optAnim.Caption = "Animation";
            optAnim.Size = new Size(81, 17);
            layout_Picture6.Add(optAnim, 16, 72);

            optFringe = new LegacyRadioButton(optF2Anim);
            optFringe.Caption = "Fringe";
            optFringe.Size = new Size(81, 17);
            layout_Picture6.Add(optFringe, 16, 120);


            cmdEditorLayers = new LegacyButton();
            cmdEditorLayers.Caption = "Layers";
            cmdEditorLayers.Size = new Size(61, 25);
            layout_SSTab1.Add(cmdEditorLayers, 5, 9);

            cmdEditorAttribs = new LegacyButton();
            cmdEditorAttribs.Caption = "Attribs";
            cmdEditorAttribs.Size = new Size(61, 25);
            layout_SSTab1.Add(cmdEditorAttribs, 67, 9);


            cmdFill = new LegacyButton();
            cmdFill.Caption = "Fill";
            cmdFill.Size = new Size(89, 25);
            layout_picMapEditor.Add(cmdFill, 152, 472);

            cmdClear = new LegacyButton();
            cmdClear.Caption = "Clear";
            cmdClear.Size = new Size(89, 25);
            layout_picMapEditor.Add(cmdClear, 152, 504);

            fraMapSettings = new LegacyFrame();
            fraMapSettings.Caption = "-- Map Settings --";
            fraMapSettings.Size = new Size(97, 162);
            layout_picMapEditor.Add(fraMapSettings, 142, 272);
            var layout_fraMapSettings = new PixelLayout();
            fraMapSettings.Content = layout_fraMapSettings;
            lblMapY = new LegacyLabel();
            lblMapY.Caption = "10";
            lblMapY.Size = new Size(49, 17);
            layout_fraMapSettings.Add(lblMapY, 48, 80);

            lblMapX = new LegacyLabel();
            lblMapX.Caption = "10";
            lblMapX.Size = new Size(41, 17);
            layout_fraMapSettings.Add(lblMapX, 8, 80);

            Label16 = new LegacyLabel();
            Label16.Caption = "MapX:       MapY:";
            Label16.Size = new Size(113, 17);
            layout_fraMapSettings.Add(Label16, 8, 64);

            lblMapNumber = new LegacyLabel();
            lblMapNumber.Caption = "10";
            lblMapNumber.Size = new Size(97, 17);
            layout_fraMapSettings.Add(lblMapNumber, 0, 120);

            Label9 = new LegacyLabel();
            Label9.Caption = "Map Number:";
            Label9.Size = new Size(81, 17);
            layout_fraMapSettings.Add(Label9, 8, 104);

            lblMapName = new LegacyLabel();
            lblMapName.Caption = "Map Name";
            lblMapName.Size = new Size(113, 17);
            layout_fraMapSettings.Add(lblMapName, 24, 40);

            Label2 = new LegacyLabel();
            Label2.Caption = "Map Name:";
            Label2.Size = new Size(81, 17);
            layout_fraMapSettings.Add(Label2, 8, 24);


            cmdSend = new LegacyButton();
            cmdSend.Caption = "Send";
            cmdSend.Size = new Size(113, 33);
            layout_picMapEditor.Add(cmdSend, 8, 552);

            scrlTileset = new LegacyScrollBar();
            scrlTileset.MinValue = 0;
            scrlTileset.MaxValue = 6;
            scrlTileset.Value = 1;
            scrlTileset.Orientation = Orientation.Horizontal;
            scrlTileset.SmallChange = 1;
            scrlTileset.LargeChange = 1;
            scrlTileset.Size = new Size(383, 19);
            layout_picMapEditor.Add(scrlTileset, 7, 230);


            picTrade = new LegacyLabel();
            picTrade.Caption = "Trade";
            picTrade.Size = new Size(35, 36);
            rootLayout.Add(picTrade, 671, 119);

            picSpells = new LegacyLabel();
            picSpells.Caption = "";
            picSpells.ToolTip = "View your spells.";
            picSpells.Size = new Size(42, 42);
            rootLayout.Add(picSpells, 827, 179);

            picInventory = new LegacyLabel();
            picInventory.Caption = "";
            picInventory.ToolTip = "View your inventory.";
            picInventory.Size = new Size(42, 42);
            rootLayout.Add(picInventory, 735, 179);

            picTrain = new LegacyLabel();
            picTrain.Caption = "Train";
            picTrain.ToolTip = "Train your character.";
            picTrain.Size = new Size(35, 36);
            rootLayout.Add(picTrain, 745, 118);

            picStats = new LegacyLabel();
            picStats.Caption = "";
            picStats.ToolTip = "View your current stats.";
            picStats.Size = new Size(42, 42);
            rootLayout.Add(picStats, 687, 179);

            picQuit = new LegacyLabel();
            picQuit.Caption = "";
            picQuit.ToolTip = "Quit the Game";
            picQuit.Size = new Size(121, 29);
            rootLayout.Add(picQuit, 799, 665);

            picBugReport = new LegacyLabel();
            picBugReport.Caption = "Bug";
            picBugReport.ToolTip = "Report a Bug!";
            picBugReport.Size = new Size(35, 36);
            rootLayout.Add(picBugReport, 819, 119);

            lblKeepNotes = new LegacyLabel();
            lblKeepNotes.Caption = "Notes";
            lblKeepNotes.ToolTip = "Edit your player notes.";
            lblKeepNotes.Size = new Size(35, 36);
            rootLayout.Add(lblKeepNotes, 782, 119);

            lblGameName = new LegacyLabel();
            lblGameName.Caption = "Game Name";
            lblGameName.Visible = false;
            lblGameName.Size = new Size(161, 17);
            rootLayout.Add(lblGameName, 96, 52);

            picOptions = new LegacyLabel();
            picOptions.Caption = "";
            picOptions.ToolTip = "Change user settings.";
            picOptions.Size = new Size(42, 42);
            rootLayout.Add(picOptions, 875, 179);

            cmdMinimize = new LegacyLabel();
            cmdMinimize.Caption = "_";
            cmdMinimize.Size = new Size(35, 36);
            rootLayout.Add(cmdMinimize, 894, 118);

            lblPlayers = new LegacyLabel();
            lblPlayers.Caption = "Who";
            lblPlayers.ToolTip = "View the list of online players.";
            lblPlayers.Size = new Size(35, 36);
            rootLayout.Add(lblPlayers, 708, 119);

            lblMapInfo = new LegacyLabel();
            lblMapInfo.Caption = "Map Name";
            lblMapInfo.Size = new Size(420, 16);
            rootLayout.Add(lblMapInfo, 20, 508);

            Label4 = new LegacyLabel();
            Label4.Caption = "POWERED BY PLAYERWORLDS";
            Label4.Visible = false;
            Label4.Size = new Size(193, 9);
            rootLayout.Add(Label4, 40, 595);

            lblGUI = new LegacyLabel();
            lblGUI.Caption = "";
            lblGUI.Visible = false;
            lblGUI.Size = new Size(25, 25);
            rootLayout.Add(lblGUI, 72, 616);

            Picture1 = new LegacyPictureBox();
            Picture1.Size = new Size(206, 11);
            rootLayout.Add(Picture1, 699, 39);
            var layout_Picture1 = new PixelLayout();
            Picture1.Content = layout_Picture1;
            lblHP = new LegacyLabel();
            lblHP.Caption = "0%";
            lblHP.Size = new Size(211, 12);
            layout_Picture1.Add(lblHP, 0, 0);


            shpHP = new LegacyPictureBox();
            shpHP.Size = new Size(211, 12);
            rootLayout.Add(shpHP, 696, 39);
            var layout_shpHP = new PixelLayout();
            shpHP.Content = layout_shpHP;
            lblHP_0 = new LegacyLabel();
            lblHP_0.Caption = "0%";
            lblHP_0.Size = new Size(211, 12);
            layout_shpHP.Add(lblHP_0, 1, 0);


            txtMyTextBox = new LegacyTextBox();
            txtMyTextBox.Text = "";
            txtMyTextBox.Size = new Size(640, 24);
            rootLayout.Add(txtMyTextBox, 18, 658);

            Picture2 = new LegacyPictureBox();
            Picture2.Size = new Size(206, 11);
            rootLayout.Add(Picture2, 699, 92);
            var layout_Picture2 = new PixelLayout();
            Picture2.Content = layout_Picture2;
            lblSP = new LegacyLabel();
            lblSP.Caption = "0%";
            lblSP.Size = new Size(211, 12);
            layout_Picture2.Add(lblSP, 0, 0);


            Picture3 = new LegacyPictureBox();
            Picture3.Size = new Size(206, 11);
            rootLayout.Add(Picture3, 699, 57);
            var layout_Picture3 = new PixelLayout();
            Picture3.Content = layout_Picture3;
            lblMP = new LegacyLabel();
            lblMP.Caption = "0%";
            lblMP.Size = new Size(211, 12);
            layout_Picture3.Add(lblMP, 0, 0);


            shpMP = new LegacyPictureBox();
            shpMP.Size = new Size(211, 12);
            rootLayout.Add(shpMP, 696, 56);
            var layout_shpMP = new PixelLayout();
            shpMP.Content = layout_shpMP;
            lblMP_0 = new LegacyLabel();
            lblMP_0.Caption = "0%";
            lblMP_0.Size = new Size(211, 12);
            layout_shpMP.Add(lblMP_0, 1, 0);


            shpEXP = new LegacyPictureBox();
            shpEXP.Size = new Size(211, 12);
            rootLayout.Add(shpEXP, 696, 73);

            shpSP = new LegacyPictureBox();
            shpSP.Size = new Size(211, 12);
            rootLayout.Add(shpSP, 696, 90);
            var layout_shpSP = new PixelLayout();
            shpSP.Content = layout_shpSP;
            lblSP_0 = new LegacyLabel();
            lblSP_0.Caption = "0%";
            lblSP_0.Size = new Size(211, 12);
            layout_shpSP.Add(lblSP_0, 0, 0);


            picScreen = new LegacyPictureBox();
            picScreen.Size = new Size(640, 480);
            rootLayout.Add(picScreen, 18, 18);

            hosttxtChat = new LegacyPictureBox();
            hosttxtChat.Size = new Size(640, 128);
            rootLayout.Add(hosttxtChat, 20, 524);

            fralvl2 = new LegacyFrame();
            fralvl2.Caption = "Mappers";
            fralvl2.Visible = false;
            fralvl2.Size = new Size(97, 178);
            rootLayout.Add(fralvl2, 949, 183);
            var layout_fralvl2 = new PixelLayout();
            fralvl2.Content = layout_fralvl2;
            cmdSignEdit = new LegacyButton();
            cmdSignEdit.Caption = "Sign Editor";
            cmdSignEdit.ToolTip = "Ban a player";
            cmdSignEdit.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdSignEdit, 8, 144);

            cmdLOC = new LegacyButton();
            cmdLOC.Caption = "Location";
            cmdLOC.ToolTip = "Find your location";
            cmdLOC.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdLOC, 8, 128);

            cmdBan = new LegacyButton();
            cmdBan.Caption = "Ban";
            cmdBan.ToolTip = "Ban a player";
            cmdBan.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdBan, 8, 112);

            cmdMapreport = new LegacyButton();
            cmdMapreport.Caption = "Map Report";
            cmdMapreport.ToolTip = "View all free maps";
            cmdMapreport.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdMapreport, 8, 96);

            cmdRespawn = new LegacyButton();
            cmdRespawn.Caption = "Respawn";
            cmdRespawn.ToolTip = "Respawn the map";
            cmdRespawn.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdRespawn, 8, 80);

            cmdPlayerSprite = new LegacyButton();
            cmdPlayerSprite.Caption = "Player Sprite";
            cmdPlayerSprite.ToolTip = "Change your sprite";
            cmdPlayerSprite.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdPlayerSprite, 8, 64);

            cmdMapeditor = new LegacyButton();
            cmdMapeditor.Caption = "MapEditor";
            cmdMapeditor.ToolTip = "Edit the map";
            cmdMapeditor.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdMapeditor, 8, 16);

            cmdWarpto = new LegacyButton();
            cmdWarpto.Caption = "Warpto";
            cmdWarpto.ToolTip = "Warp yourself to";
            cmdWarpto.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdWarpto, 8, 32);

            cmdSetSprite = new LegacyButton();
            cmdSetSprite.Caption = "Set Sprite";
            cmdSetSprite.ToolTip = "Change your sprite";
            cmdSetSprite.Size = new Size(81, 17);
            layout_fralvl2.Add(cmdSetSprite, 8, 48);


            fralvl1 = new LegacyFrame();
            fralvl1.Caption = "Monitors";
            fralvl1.Visible = false;
            fralvl1.Size = new Size(97, 37);
            rootLayout.Add(fralvl1, 949, 144);
            var layout_fralvl1 = new PixelLayout();
            fralvl1.Content = layout_fralvl1;
            cmdKick = new LegacyButton();
            cmdKick.Caption = "Kick";
            cmdKick.ToolTip = "Kick a player";
            cmdKick.Size = new Size(81, 17);
            layout_fralvl1.Add(cmdKick, 8, 16);


            fralvl3 = new LegacyFrame();
            fralvl3.Caption = "Developers";
            fralvl3.Visible = false;
            fralvl3.Size = new Size(97, 154);
            rootLayout.Add(fralvl3, 949, 360);
            var layout_fralvl3 = new PixelLayout();
            fralvl3.Content = layout_fralvl3;
            cmdNpcEditor = new LegacyButton();
            cmdNpcEditor.Caption = "Npc Editor";
            cmdNpcEditor.ToolTip = "Edit the Npcs";
            cmdNpcEditor.Size = new Size(81, 17);
            layout_fralvl3.Add(cmdNpcEditor, 8, 16);

            cmdItemEditor = new LegacyButton();
            cmdItemEditor.Caption = "Item Editor";
            cmdItemEditor.ToolTip = "Edit the Items";
            cmdItemEditor.Size = new Size(81, 17);
            layout_fralvl3.Add(cmdItemEditor, 8, 32);

            cmdShopEditor = new LegacyButton();
            cmdShopEditor.Caption = "ShopEditor";
            cmdShopEditor.ToolTip = "Edit the Shops";
            cmdShopEditor.Size = new Size(81, 17);
            layout_fralvl3.Add(cmdShopEditor, 8, 48);

            cmdSpellEditor = new LegacyButton();
            cmdSpellEditor.Caption = "SpellEditor";
            cmdSpellEditor.ToolTip = "Edit the Spells";
            cmdSpellEditor.Size = new Size(81, 17);
            layout_fralvl3.Add(cmdSpellEditor, 8, 64);

            cmdDelbanlist = new LegacyButton();
            cmdDelbanlist.Caption = "UnBan Player";
            cmdDelbanlist.ToolTip = "Unban Player.";
            cmdDelbanlist.Size = new Size(81, 17);
            layout_fralvl3.Add(cmdDelbanlist, 8, 114);

            cmdKill = new LegacyButton();
            cmdKill.Caption = "Kill";
            cmdKill.ToolTip = "Kill a Player";
            cmdKill.Size = new Size(81, 17);
            layout_fralvl3.Add(cmdKill, 8, 129);

            cmbArrowEditor = new LegacyButton();
            cmbArrowEditor.Caption = "Arrow Editor";
            cmbArrowEditor.ToolTip = "Edit the Spells";
            cmbArrowEditor.Size = new Size(81, 17);
            layout_fralvl3.Add(cmbArrowEditor, 8, 98);

            cmbClassEditor = new LegacyButton();
            cmbClassEditor.Caption = "Class Editor";
            cmbClassEditor.ToolTip = "Edit the Spells";
            cmbClassEditor.Size = new Size(81, 17);
            layout_fralvl3.Add(cmbClassEditor, 8, 81);


            fralvl4 = new LegacyFrame();
            fralvl4.Caption = "Server Owner";
            fralvl4.Visible = false;
            fralvl4.Size = new Size(97, 85);
            rootLayout.Add(fralvl4, 949, 511);
            var layout_fralvl4 = new PixelLayout();
            fralvl4.Content = layout_fralvl4;
            AccessLevel = new LegacyLabel();
            AccessLevel.Caption = "Access Level";
            AccessLevel.Size = new Size(77, 18);
            layout_fralvl4.Add(AccessLevel, 8, 16);

            txtAccessLevel = new LegacyTextBox();
            txtAccessLevel.Text = "";
            txtAccessLevel.Size = new Size(81, 24);
            layout_fralvl4.Add(txtAccessLevel, 8, 32);

            cmdSetAccess = new LegacyButton();
            cmdSetAccess.Caption = "Set Access";
            cmdSetAccess.ToolTip = "Set a players' admin access";
            cmdSetAccess.Size = new Size(81, 19);
            layout_fralvl4.Add(cmdSetAccess, 8, 64);


            fraSpriteNum = new LegacyFrame();
            fraSpriteNum.Caption = "Sprite #";
            fraSpriteNum.Visible = false;
            fraSpriteNum.Size = new Size(97, 48);
            rootLayout.Add(fraSpriteNum, 949, 96);
            var layout_fraSpriteNum = new PixelLayout();
            fraSpriteNum.Content = layout_fraSpriteNum;
            txtSpriteNum = new LegacyTextBox();
            txtSpriteNum.Text = "";
            txtSpriteNum.Size = new Size(81, 24);
            layout_fraSpriteNum.Add(txtSpriteNum, 8, 16);


            fraPlayer = new LegacyFrame();
            fraPlayer.Caption = "Player Name";
            fraPlayer.Visible = false;
            fraPlayer.Size = new Size(97, 48);
            rootLayout.Add(fraPlayer, 949, 0);
            var layout_fraPlayer = new PixelLayout();
            fraPlayer.Content = layout_fraPlayer;
            txtPlayerName = new LegacyTextBox();
            txtPlayerName.Text = "";
            txtPlayerName.Size = new Size(81, 23);
            layout_fraPlayer.Add(txtPlayerName, 8, 16);


            fraMapNum = new LegacyFrame();
            fraMapNum.Caption = "Map Number";
            fraMapNum.Visible = false;
            fraMapNum.Size = new Size(97, 48);
            rootLayout.Add(fraMapNum, 949, 48);
            var layout_fraMapNum = new PixelLayout();
            fraMapNum.Content = layout_fraMapNum;
            txtMapNum = new LegacyTextBox();
            txtMapNum.Text = "";
            txtMapNum.Size = new Size(81, 24);
            layout_fraMapNum.Add(txtMapNum, 8, 16);


            imgSign = new ImageView();
            imgSign.Image = AssetLoader.LoadImage("frmMainGame/imgSign.jpg");
            imgSign.Visible = false;
            imgSign.Size = new Size(185, 121);
            rootLayout.Add(imgSign, 245, 197);

            lblLine1Btm = new LegacyLabel();
            lblLine1Btm.Caption = "Label1";
            lblLine1Btm.Visible = false;
            lblLine1Btm.Size = new Size(185, 25);
            rootLayout.Add(lblLine1Btm, 245, 235);

            lblLine2Btm = new LegacyLabel();
            lblLine2Btm.Caption = "Label1";
            lblLine2Btm.Visible = false;
            lblLine2Btm.Size = new Size(185, 25);
            rootLayout.Add(lblLine2Btm, 245, 251);

            lblLine3Btm = new LegacyLabel();
            lblLine3Btm.Caption = "Label1";
            lblLine3Btm.Visible = false;
            lblLine3Btm.Size = new Size(185, 25);
            rootLayout.Add(lblLine3Btm, 245, 267);

            lblNameBtm = new LegacyLabel();
            lblNameBtm.Caption = "Label1";
            lblNameBtm.Visible = false;
            lblNameBtm.Size = new Size(185, 25);
            rootLayout.Add(lblNameBtm, 245, 208);

            lblexit = new LegacyLabel();
            lblexit.Caption = "Exit";
            lblexit.Visible = false;
            lblexit.Size = new Size(57, 17);
            rootLayout.Add(lblexit, 309, 301);

            lblLine1Top = new LegacyLabel();
            lblLine1Top.Caption = "Label1";
            lblLine1Top.Visible = false;
            lblLine1Top.Size = new Size(185, 25);
            rootLayout.Add(lblLine1Top, 248, 232);

            lblLine2Top = new LegacyLabel();
            lblLine2Top.Caption = "Label1";
            lblLine2Top.Visible = false;
            lblLine2Top.Size = new Size(185, 25);
            rootLayout.Add(lblLine2Top, 248, 248);

            lblLine3Top = new LegacyLabel();
            lblLine3Top.Caption = "Label1";
            lblLine3Top.Visible = false;
            lblLine3Top.Size = new Size(185, 25);
            rootLayout.Add(lblLine3Top, 248, 264);

            Line1 = new Drawable();
            Line1.Visible = false;
            Line1.Size = new Size(10, 10);
            rootLayout.Add(Line1, 0, 0);

            lblNameTop = new LegacyLabel();
            lblNameTop.Caption = "Label1";
            lblNameTop.Visible = false;
            lblNameTop.Size = new Size(185, 25);
            rootLayout.Add(lblNameTop, 248, 205);

            picGUI = new LegacyPictureBox();
            picGUI.Visible = false;
            picGUI.Size = new Size(25, 25);
            rootLayout.Add(picGUI, 8, 616);

            cmdGUI = new LegacyButton();
            cmdGUI.Caption = "";
            cmdGUI.Visible = false;
            cmdGUI.Size = new Size(25, 25);
            rootLayout.Add(cmdGUI, 40, 616);

            txtGUI = new LegacyTextBox();
            txtGUI.Text = "";
            txtGUI.Visible = false;
            txtGUI.Size = new Size(25, 25);
            rootLayout.Add(txtGUI, 104, 616);

            chkGUI = new LegacyCheckBox();
            chkGUI.Caption = "";
            chkGUI.Checked = false;
            chkGUI.Visible = false;
            chkGUI.Size = new Size(25, 25);
            rootLayout.Add(chkGUI, 136, 616);

            picWebsite = new LegacyLabel();
            picWebsite.Caption = "";
            picWebsite.ToolTip = "Website";
            picWebsite.Size = new Size(121, 29);
            rootLayout.Add(picWebsite, 678, 665);

            picGuild = new LegacyLabel();
            picGuild.Caption = "";
            picGuild.ToolTip = "Guild information";
            picGuild.Size = new Size(42, 42);
            rootLayout.Add(picGuild, 781, 179);

            imgWho = new ImageView();
            imgWho.Image = AssetLoader.LoadImage("frmMainGame/imgWho.png");
            imgWho.Visible = false;
            imgWho.Size = new Size(248, 266);
            rootLayout.Add(imgWho, 677, 280);

            lblWhoMessage = new LegacyLabel();
            lblWhoMessage.Caption = "";
            lblWhoMessage.ToolTip = "Continue";
            lblWhoMessage.Visible = false;
            lblWhoMessage.Size = new Size(103, 24);
            rootLayout.Add(lblWhoMessage, 697, 510);

            lblWhoFriend = new LegacyLabel();
            lblWhoFriend.Caption = "";
            lblWhoFriend.ToolTip = "Continue";
            lblWhoFriend.Visible = false;
            lblWhoFriend.Size = new Size(99, 24);
            rootLayout.Add(lblWhoFriend, 803, 510);

            imgInventory = new ImageView();
            imgInventory.Image = AssetLoader.LoadImage("frmMainGame/imgInventory.jpg");
            imgInventory.Visible = false;
            imgInventory.Size = new Size(265, 382);
            rootLayout.Add(imgInventory, 673, 277);

            lstInv = new LegacyListBox();
            lstInv.Visible = false;
            lstInv.Size = new Size(217, 132);
            rootLayout.Add(lstInv, 689, 357);

            picItem = new LegacyPictureBox();
            picItem.ToolTip = "This is an image of the selected item in your inventory.";
            picItem.Visible = false;
            picItem.Size = new Size(32, 32);
            rootLayout.Add(picItem, 748, 310);

            imgNotes = new ImageView();
            imgNotes.Image = AssetLoader.LoadImage("frmMainGame/imgNotes.png");
            imgNotes.Visible = false;
            imgNotes.Size = new Size(248, 266);
            rootLayout.Add(imgNotes, 676, 280);

            lblNoteSave = new LegacyLabel();
            lblNoteSave.Caption = "";
            lblNoteSave.Visible = false;
            lblNoteSave.Size = new Size(108, 25);
            rootLayout.Add(lblNoteSave, 808, 504);

            imgTraining = new ImageView();
            imgTraining.Image = AssetLoader.LoadImage("frmMainGame/imgTraining.png");
            imgTraining.Visible = false;
            imgTraining.Size = new Size(248, 266);
            rootLayout.Add(imgTraining, 677, 280);

            lblPlayerPoints = new LegacyLabel();
            lblPlayerPoints.Caption = "Current Stat Points: 0";
            lblPlayerPoints.Visible = false;
            lblPlayerPoints.Size = new Size(220, 20);
            rootLayout.Add(lblPlayerPoints, 691, 323);

            lblTrain = new LegacyLabel();
            lblTrain.Caption = "";
            lblTrain.Visible = false;
            lblTrain.Size = new Size(65, 25);
            rootLayout.Add(lblTrain, 853, 504);

            cmbStat = new LegacyComboBox();
            cmbStat.Items.Add("Strength");
            cmbStat.Items.Add("Defense");
            cmbStat.Items.Add("Magic");
            cmbStat.Items.Add("Speed");
            cmbStat.Visible = false;
            cmbStat.Size = new Size(185, 21);
            rootLayout.Add(cmbStat, 709, 408);

            imgCharacter = new ImageView();
            imgCharacter.Image = AssetLoader.LoadImage("frmMainGame/imgCharacter.jpg");
            imgCharacter.Visible = false;
            imgCharacter.Size = new Size(265, 354);
            rootLayout.Add(imgCharacter, 679, 281);

            lblGearName = new LegacyLabel();
            lblGearName.Caption = "";
            lblGearName.Visible = false;
            lblGearName.Size = new Size(129, 16);
            rootLayout.Add(lblGearName, 791, 409);

            lblGearDur = new LegacyLabel();
            lblGearDur.Caption = "";
            lblGearDur.Visible = false;
            lblGearDur.Size = new Size(85, 17);
            rootLayout.Add(lblGearDur, 791, 436);

            lblGearStr = new LegacyLabel();
            lblGearStr.Caption = "";
            lblGearStr.Visible = false;
            lblGearStr.Size = new Size(65, 17);
            rootLayout.Add(lblGearStr, 791, 465);

            imgEquipment = new ImageView();
            imgEquipment.Visible = false;
            imgEquipment.Size = new Size(32, 32);
            rootLayout.Add(imgEquipment, 724, 579);

            imgEquipment_1 = new ImageView();
            imgEquipment_1.Visible = false;
            imgEquipment_1.Size = new Size(32, 32);
            rootLayout.Add(imgEquipment_1, 769, 579);

            imgEquipment_2 = new ImageView();
            imgEquipment_2.Visible = false;
            imgEquipment_2.Size = new Size(32, 32);
            rootLayout.Add(imgEquipment_2, 814, 579);

            imgEquipment_3 = new ImageView();
            imgEquipment_3.Visible = false;
            imgEquipment_3.Size = new Size(32, 32);
            rootLayout.Add(imgEquipment_3, 859, 579);

            lblCharacterValue_0 = new LegacyLabel();
            lblCharacterValue_0.Caption = "";
            lblCharacterValue_0.Visible = false;
            lblCharacterValue_0.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_0, 789, 310);

            lblCharacterValue_2 = new LegacyLabel();
            lblCharacterValue_2.Caption = "";
            lblCharacterValue_2.Visible = false;
            lblCharacterValue_2.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_2, 789, 350);

            lblCharacterValue_3 = new LegacyLabel();
            lblCharacterValue_3.Caption = "";
            lblCharacterValue_3.Visible = false;
            lblCharacterValue_3.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_3, 789, 370);

            lblCharacterValue_4 = new LegacyLabel();
            lblCharacterValue_4.Caption = "";
            lblCharacterValue_4.Visible = false;
            lblCharacterValue_4.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_4, 789, 390);

            lblCharacterValue_5 = new LegacyLabel();
            lblCharacterValue_5.Caption = "";
            lblCharacterValue_5.Visible = false;
            lblCharacterValue_5.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_5, 789, 410);

            lblCharacterValue_6 = new LegacyLabel();
            lblCharacterValue_6.Caption = "";
            lblCharacterValue_6.Visible = false;
            lblCharacterValue_6.Size = new Size(28, 15);
            rootLayout.Add(lblCharacterValue_6, 773, 430);

            lblCharacterValue_7 = new LegacyLabel();
            lblCharacterValue_7.Caption = "";
            lblCharacterValue_7.Visible = false;
            lblCharacterValue_7.Size = new Size(28, 15);
            rootLayout.Add(lblCharacterValue_7, 888, 430);

            lblCharacterValue_8 = new LegacyLabel();
            lblCharacterValue_8.Caption = "";
            lblCharacterValue_8.Visible = false;
            lblCharacterValue_8.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_8, 789, 450);

            lblCharacterValue_9 = new LegacyLabel();
            lblCharacterValue_9.Caption = "";
            lblCharacterValue_9.Visible = false;
            lblCharacterValue_9.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_9, 789, 470);

            lblCharacterValue_10 = new LegacyLabel();
            lblCharacterValue_10.Caption = "";
            lblCharacterValue_10.Visible = false;
            lblCharacterValue_10.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_10, 789, 490);

            lblCharacterValue_11 = new LegacyLabel();
            lblCharacterValue_11.Caption = "";
            lblCharacterValue_11.Visible = false;
            lblCharacterValue_11.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_11, 789, 510);

            lblCharacterValue_12 = new LegacyLabel();
            lblCharacterValue_12.Caption = "";
            lblCharacterValue_12.Visible = false;
            lblCharacterValue_12.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_12, 789, 530);

            lblCharacterValue_13 = new LegacyLabel();
            lblCharacterValue_13.Caption = "";
            lblCharacterValue_13.Visible = false;
            lblCharacterValue_13.Size = new Size(127, 15);
            rootLayout.Add(lblCharacterValue_13, 789, 550);

            lblForget = new LegacyLabel();
            lblForget.Caption = "";
            lblForget.Visible = false;
            lblForget.Size = new Size(116, 29);
            rootLayout.Add(lblForget, 813, 498);

            lstSpells = new LegacyListBox();
            lstSpells.Visible = false;
            lstSpells.Size = new Size(225, 132);
            rootLayout.Add(lstSpells, 689, 358);

            lblSkillsNext = new LegacyLabel();
            lblSkillsNext.Caption = "";
            lblSkillsNext.Visible = false;
            lblSkillsNext.Size = new Size(116, 29);
            rootLayout.Add(lblSkillsNext, 813, 541);

            lblSkillsPrevious = new LegacyLabel();
            lblSkillsPrevious.Caption = "";
            lblSkillsPrevious.Visible = false;
            lblSkillsPrevious.Size = new Size(116, 29);
            rootLayout.Add(lblSkillsPrevious, 813, 584);

            lblSkillsUpgrade = new LegacyLabel();
            lblSkillsUpgrade.Caption = "";
            lblSkillsUpgrade.ToolTip = "Spell upgrades are not supported by this game.";
            lblSkillsUpgrade.Enabled = false;
            lblSkillsUpgrade.Visible = false;
            lblSkillsUpgrade.Size = new Size(116, 29);
            rootLayout.Add(lblSkillsUpgrade, 813, 459);

            lblSkillName = new LegacyLabel();
            lblSkillName.Caption = "";
            lblSkillName.Visible = false;
            lblSkillName.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName, 736, 305);

            imgSkillIcon = new ImageView();
            imgSkillIcon.Visible = false;
            imgSkillIcon.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon, 698, 305);

            lblSkillName_1 = new LegacyLabel();
            lblSkillName_1.Caption = "";
            lblSkillName_1.Visible = false;
            lblSkillName_1.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_1, 736, 344);

            imgSkillIcon_1 = new ImageView();
            imgSkillIcon_1.Visible = false;
            imgSkillIcon_1.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_1, 698, 344);

            lblSkillName_2 = new LegacyLabel();
            lblSkillName_2.Caption = "";
            lblSkillName_2.Visible = false;
            lblSkillName_2.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_2, 736, 383);

            imgSkillIcon_2 = new ImageView();
            imgSkillIcon_2.Visible = false;
            imgSkillIcon_2.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_2, 698, 383);

            lblSkillName_3 = new LegacyLabel();
            lblSkillName_3.Caption = "";
            lblSkillName_3.Visible = false;
            lblSkillName_3.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_3, 736, 422);

            imgSkillIcon_3 = new ImageView();
            imgSkillIcon_3.Visible = false;
            imgSkillIcon_3.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_3, 698, 422);

            lblSkillName_4 = new LegacyLabel();
            lblSkillName_4.Caption = "";
            lblSkillName_4.Visible = false;
            lblSkillName_4.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_4, 736, 461);

            imgSkillIcon_4 = new ImageView();
            imgSkillIcon_4.Visible = false;
            imgSkillIcon_4.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_4, 698, 461);

            lblSkillName_5 = new LegacyLabel();
            lblSkillName_5.Caption = "";
            lblSkillName_5.Visible = false;
            lblSkillName_5.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_5, 736, 500);

            imgSkillIcon_5 = new ImageView();
            imgSkillIcon_5.Visible = false;
            imgSkillIcon_5.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_5, 698, 500);

            lblSkillName_6 = new LegacyLabel();
            lblSkillName_6.Caption = "";
            lblSkillName_6.Visible = false;
            lblSkillName_6.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_6, 736, 539);

            imgSkillIcon_6 = new ImageView();
            imgSkillIcon_6.Visible = false;
            imgSkillIcon_6.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_6, 698, 539);

            lblSkillName_7 = new LegacyLabel();
            lblSkillName_7.Caption = "";
            lblSkillName_7.Visible = false;
            lblSkillName_7.Size = new Size(67, 34);
            rootLayout.Add(lblSkillName_7, 736, 578);

            imgSkillIcon_7 = new ImageView();
            imgSkillIcon_7.Visible = false;
            imgSkillIcon_7.Size = new Size(32, 32);
            rootLayout.Add(imgSkillIcon_7, 698, 578);

            lblPoints = new LegacyLabel();
            lblPoints.Caption = "";
            lblPoints.Visible = false;
            lblPoints.Size = new Size(97, 17);
            rootLayout.Add(lblPoints, 757, 504);

            lblBlock = new LegacyLabel();
            lblBlock.Caption = "";
            lblBlock.Visible = false;
            lblBlock.Size = new Size(97, 17);
            rootLayout.Add(lblBlock, 757, 488);

            lblCHit = new LegacyLabel();
            lblCHit.Caption = "";
            lblCHit.Visible = false;
            lblCHit.Size = new Size(97, 17);
            rootLayout.Add(lblCHit, 757, 472);

            lblTNL = new LegacyLabel();
            lblTNL.Caption = "";
            lblTNL.Visible = false;
            lblTNL.Size = new Size(97, 17);
            rootLayout.Add(lblTNL, 757, 448);

            lblEXP = new LegacyLabel();
            lblEXP.Caption = "";
            lblEXP.Visible = false;
            lblEXP.Size = new Size(89, 17);
            rootLayout.Add(lblEXP, 765, 432);

            lblSPEED = new LegacyLabel();
            lblSPEED.Caption = "";
            lblSPEED.Visible = false;
            lblSPEED.Size = new Size(97, 17);
            rootLayout.Add(lblSPEED, 757, 376);

            lblMAGI = new LegacyLabel();
            lblMAGI.Caption = "";
            lblMAGI.Visible = false;
            lblMAGI.Size = new Size(97, 17);
            rootLayout.Add(lblMAGI, 757, 408);

            lblDEF = new LegacyLabel();
            lblDEF.Caption = "";
            lblDEF.Visible = false;
            lblDEF.Size = new Size(97, 17);
            rootLayout.Add(lblDEF, 757, 392);

            lblSTR = new LegacyLabel();
            lblSTR.Caption = "";
            lblSTR.Visible = false;
            lblSTR.Size = new Size(97, 17);
            rootLayout.Add(lblSTR, 757, 352);

            lblLevel = new LegacyLabel();
            lblLevel.Caption = "";
            lblLevel.Visible = false;
            lblLevel.Size = new Size(97, 17);
            rootLayout.Add(lblLevel, 757, 336);

            Label8 = new LegacyLabel();
            Label8.Caption = "";
            Label8.Visible = false;
            Label8.Size = new Size(65, 25);
            rootLayout.Add(Label8, 853, 504);

            imgMap = new ImageView();
            imgMap.Size = new Size(49, 14);
            rootLayout.Add(imgMap, 455, 509);

            Image1 = new ImageView();
            Image1.Size = new Size(200, 50);
            rootLayout.Add(Image1, 556, 522);

            imgGlobal = new ImageView();
            imgGlobal.Size = new Size(48, 14);
            rootLayout.Add(imgGlobal, 507, 509);

            imgGuild = new ImageView();
            imgGuild.Size = new Size(48, 14);
            rootLayout.Add(imgGuild, 558, 509);

            imgPM = new ImageView();
            imgPM.Size = new Size(48, 14);
            rootLayout.Add(imgPM, 608, 508);

            scrlPicture = new LegacyScrollBar();
            scrlPicture.MinValue = 0;
            scrlPicture.MaxValue = 937;
            scrlPicture.Value = 0;
            scrlPicture.Orientation = Orientation.Vertical;
            scrlPicture.SmallChange = 1;
            scrlPicture.LargeChange = 7;
            scrlPicture.Size = new Size(17, 225);
            rootLayout.Add(scrlPicture, 1350, 44);

            Shown += OnFormShown;
            Closed += OnFormClosed;
            WireGameClientLogic();
        }

        protected virtual void OnFormShown(object sender, EventArgs e)
        {
            _client.MainGameAction("Form_Load");
            CloseSideMenu();
        }

        private void OnFormClosed(object sender, EventArgs e)
        {
            _client.GameDestroy();
        }

        private void WireGameClientLogic()
        {
            // Main game menu commands from frmMirage.frm.twin.
            AddMouseAction(picQuit, "GameDestroy");
            AddMouseAction(picOptions, "ShowOptions");
            AddMouseAction(picBugReport, "ShowBugReport");
            AddMouseAction(picTrade, "TradeRequest");
            AddMouseAction(picStats, "ToggleStats");
            AddMouseAction(picTrain, "ToggleTrain");
            AddMouseAction(picInventory, "ToggleInventory");
            AddMouseAction(picSpells, "ToggleSpells");
            AddMouseAction(lblKeepNotes, "ToggleNotes");
            AddMouseAction(lblPlayers, "SendWhosOnline");
            AddMouseAction(picWebsite, "OpenWebsite");
            AddMouseAction(picGuild, "ToggleGuild");
            AddMouseAction(picPM, "PrivateMessage");

            cmdFill.Click += (sender, e) => _client.MainGameAction("EditorFillLayer", optLayers.Checked);
            cmdClear.Click += (sender, e) => _client.MainGameAction("EditorClearLayer", optLayers.Checked);
            cmdProperties.Click += (sender, e) => _client.MainGameAction("MapProperties");
            cmdCancel.Click += (sender, e) => _client.MainGameAction("MapEditorCancel");
            cmdSend.Click += (sender, e) => _client.MainGameAction("SendChat", txtMyTextBox.Text);

            cmdBan.Click += (sender, e) => _client.MainGameAction("Ban", txtPlayerName.Text);
            cmdDelbanlist.Click += (sender, e) => _client.MainGameAction("ClearBanList");
            cmdItemEditor.Click += (sender, e) => _client.MainGameAction("ItemEditor");
            cmdNpcEditor.Click += (sender, e) => _client.MainGameAction("NpcEditor");
            cmdSetSprite.Click += (sender, e) => _client.MainGameAction("SetSprite", txtPlayerName.Text);
            cmdPlayerSprite.Click += (sender, e) => _client.MainGameAction("PlayerSprite", txtPlayerName.Text);
            cmdShopEditor.Click += (sender, e) => _client.MainGameAction("ShopEditor");
            cmdSpellEditor.Click += (sender, e) => _client.MainGameAction("SpellEditor");
            cmdKick.Click += (sender, e) => _client.MainGameAction("Kick", txtPlayerName.Text);
            cmdLOC.Click += (sender, e) => _client.MainGameAction("Location", txtPlayerName.Text);
            cmdMapeditor.Click += (sender, e) => _client.MainGameAction("MapEditor");
            cmdMapreport.Click += (sender, e) => _client.MainGameAction("MapReport");
            cmdRespawn.Click += (sender, e) => _client.MainGameAction("RespawnMap");
            cmdSetAccess.Click += (sender, e) => _client.MainGameAction("SetAccess", txtPlayerName.Text, txtAccessLevel.Text);
            cmdWarpto.Click += (sender, e) => _client.MainGameAction("WarpTo", txtPlayerName.Text);
            cmdSignEdit.Click += (sender, e) => _client.MainGameAction("SignEditor");
            cmbClassEditor.Click += (sender, e) => _client.MainGameAction("ClassEditor");
            cmbArrowEditor.Click += (sender, e) => _client.MainGameAction("ArrowEditor");

            optBlocked.CheckedChanged += (sender, e) => { if (optBlocked.Checked) _client.MainGameAction("MapBlock"); };
            optNpcSpawn.CheckedChanged += (sender, e) => { if (optNpcSpawn.Checked) _client.MainGameAction("MapSpawnNpc"); };
            optNudge.CheckedChanged += (sender, e) => { if (optNudge.Checked) _client.MainGameAction("MapNudge"); };
            optSprite.CheckedChanged += (sender, e) => { if (optSprite.Checked) _client.MainGameAction("SetSpriteAttribute"); };

            lstInv.MouseDoubleClick += (sender, e) => _client.MainGameAction("UseInventoryItem", lstInv.SelectedIndex);
            lstSpells.MouseDoubleClick += (sender, e) => _client.MainGameAction("CastSpell", lstSpells.SelectedIndex);
            lstPlayers.MouseDoubleClick += (sender, e) => _client.MainGameAction("MessagePlayer", lstPlayers.SelectedIndex);

            txtMyTextBox.KeyDown += HandleChatKeyDown;
            KeyDown += HandleGameKeyDown;
            KeyUp += HandleGameKeyUp;
            picBack.Canvas.MouseDown += (sender, e) => _client.MainGameAction("EditorChooseTile", e.Buttons, e.Location.X, e.Location.Y);
            picBack.Canvas.MouseMove += (sender, e) => _client.MainGameAction("EditorUpdateSelection", e.Buttons, e.Location.X, e.Location.Y);
            picBack.Canvas.MouseUp += (sender, e) => _client.MainGameAction("EditorEndSelection", e.Buttons, e.Location.X, e.Location.Y);
            scrlPicture.ValueChanged += (sender, e) => _client.MainGameAction("TilesetScroll", scrlPicture.Value);
        }

        private void AddMouseAction(Control control, string actionName)
        {
            if (control is null)
                return;
            control.MouseDown += (sender, e) => { if (e.Buttons == MouseButtons.Primary) { if (actionName == "GameDestroy") { _client.GameDestroy(); } else if (actionName == "OpenWebsite") { _client.OpenWebsite(); } else { _client.MainGameAction(actionName); } } };
        }

        private void HandleChatKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key != Keys.Enter)
                return;
            string text = txtMyTextBox.Text ?? string.Empty;
            _client.MainGameAction("HandleKeypresses", Keys.Enter, text);
            e.Handled = true;
        }

        private void HandleGameKeyDown(object sender, KeyEventArgs e)
        {
            _client.MainGameAction("CheckInput", 1, e.KeyData);
        }

        private void HandleGameKeyUp(object sender, KeyEventArgs e)
        {
            _client.MainGameAction("CheckInput", 0, e.KeyData);
            _client.MainGameAction("UseSlotHotkey", e.Key);
        }

        public void CloseSideMenu()
        {
            picPlayerList.Visible = false;
            lstPlayers.Visible = false;
            picPM.Visible = false;
            imgWho.Visible = false;
            imgInventory.Visible = false;
            imgNotes.Visible = false;
            imgTraining.Visible = false;
            imgLiveStats.Visible = false;
        }
    }
}