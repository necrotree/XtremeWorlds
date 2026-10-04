VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "richtx32.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmMainGame
   Tag = "ArtworkAligned" 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "Playerworlds"
   ClientHeight    =   10500
   ClientLeft      =   3540
   ClientTop       =   1920
   ClientWidth     =   19890
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   9.75
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00FFFFFF&
   Icon            =   "frmMirage.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture = "frmMirage.frx":84382
   ScaleHeight     =   700
   ScaleMode       =   3
   ScaleWidth      =   1326
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.PictureBox picMapEditor 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   8925
      Left            =   14340
      ScaleHeight     =   593
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   255
      TabIndex        =   2
      Top             =   585
      Visible         =   0
      Width           =   3855
      Begin VB.HScrollBar scrlTileset
         Height          =   255
         Left            =   120
         Min             =   1
         Max             =   6
         Value           =   1
         Top             =   6840
         Width           =   1695
      End
      Begin VB.CommandButton cmdEditorAttribs2
         Caption         =   "Attributes 2"
         Height          =   375
         Left            =   120
         Top             =   7200
         Width           =   1695
      End
      Begin VB.CommandButton cmdSend 
         Caption         =   "Send"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   120
         TabIndex        =   7
         Top             =   8280
         Width           =   1695
      End
      Begin VB.Frame fraMapSettings 
         Caption         =   "-- Map Settings --"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   2055
         Left            =   2160
         TabIndex        =   98
         Top             =   4440
         Width           =   1455
         Begin VB.Label Label2 
            BackStyle       =   0  'Transparent
            Caption         =   "Map Name:"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   120
            TabIndex        =   105
            Top             =   360
            Width           =   1215
         End
         Begin VB.Label lblMapName 
            BackStyle       =   0  'Transparent
            Caption         =   "Map Name"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   360
            TabIndex        =   104
            Top             =   600
            Width           =   1695
         End
         Begin VB.Label Label9 
            BackStyle       =   0  'Transparent
            Caption         =   "Map Number:"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   120
            TabIndex        =   103
            Top             =   1560
            Width           =   1215
         End
         Begin VB.Label lblMapNumber 
            Alignment       =   2  'Center
            BackStyle       =   0  'Transparent
            Caption         =   "10"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   0
            TabIndex        =   102
            Top             =   1800
            Width           =   1455
         End
         Begin VB.Label Label16 
            BackStyle       =   0  'Transparent
            Caption         =   "MapX:       MapY:"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   120
            TabIndex        =   101
            Top             =   960
            Width           =   1695
         End
         Begin VB.Label lblMapX 
            Alignment       =   2  'Center
            BackStyle       =   0  'Transparent
            Caption         =   "10"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   120
            TabIndex        =   100
            Top             =   1200
            Width           =   615
         End
         Begin VB.Label lblMapY 
            Alignment       =   2  'Center
            BackStyle       =   0  'Transparent
            Caption         =   "10"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   720
            TabIndex        =   99
            Top             =   1200
            Width           =   735
         End
      End
      Begin VB.CommandButton cmdClear 
         Caption         =   "Clear"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   2280
         TabIndex        =   96
         Top             =   7560
         Width           =   1335
      End
      Begin VB.CommandButton cmdFill 
         Caption         =   "Fill"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   2280
         TabIndex        =   95
         Top             =   7080
         Width           =   1335
      End
      Begin TabDlg.SSTab SSTab1 
         Height          =   4575
         Left            =   120
         TabIndex        =   41
         Top             =   3600
         Width           =   1965
         _ExtentX        =   3466
         _ExtentY        =   8070
         _Version        =   393216
         Tabs            =   2
         TabsPerRow      =   2
         TabHeight       =   529
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         TabCaption(0)   =   "Layers"
         TabPicture(0)   =   "frmMirage.frx":1BD42
         Tab(0).ControlEnabled=   -1  'True
         Tab(0).Control(0)=   "Picture6"
         Tab(0).Control(0).Enabled=   0   'False
         Tab(0).ControlCount=   1
         TabCaption(1)   =   "Attribs"
         TabPicture(1)   =   "frmMirage.frx":1BD5E
         Tab(1).ControlEnabled=   0   'False
         Tab(1).Control(0)=   "Picture5"
         Tab(1).ControlCount=   1
         Begin VB.PictureBox Picture6 
            BorderStyle     =   0  'None
            Height          =   3855
            Left            =   120
            ScaleHeight     =   3855
            ScaleWidth      =   1695
            TabIndex        =   143
            Top             =   480
            Width           =   1695
            Begin VB.OptionButton optFringe 
               Caption         =   "Fringe"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   152
               Top             =   1800
               Width           =   1215
            End
            Begin VB.OptionButton optAnim 
               Caption         =   "Animation"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   151
               Top             =   1080
               Width           =   1215
            End
            Begin VB.OptionButton optMask 
               Caption         =   "Mask"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   150
               Top             =   840
               Width           =   1215
            End
            Begin VB.OptionButton optGround 
               Caption         =   "Ground"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   149
               Top             =   600
               Value           =   -1  'True
               Width           =   1215
            End
            Begin VB.OptionButton optMask2 
               Caption         =   "Mask2"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   148
               Top             =   1320
               Width           =   1215
            End
            Begin VB.OptionButton optM2Anim 
               Caption         =   "Animation"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   147
               Top             =   1560
               Width           =   1215
            End
            Begin VB.OptionButton optFAnim 
               Caption         =   "Animation"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   146
               Top             =   2040
               Width           =   1215
            End
            Begin VB.OptionButton optFringe2 
               Caption         =   "Fringe2"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   145
               Top             =   2280
               Width           =   1215
            End
            Begin VB.OptionButton optF2Anim 
               Caption         =   "Animation"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   240
               TabIndex        =   144
               Top             =   2520
               Width           =   1215
            End
         End
         Begin VB.PictureBox Picture5 
            BorderStyle     =   0  'None
            Height          =   3735
            Left            =   -74640
            ScaleHeight     =   3735
            ScaleWidth      =   1335
            TabIndex        =   128
            Top             =   480
            Width           =   1335
            Begin VB.OptionButton optNudge 
               Caption         =   "Nudge"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               ForeColor       =   &H00808080&
               Height          =   255
               Left            =   0
               TabIndex        =   158
               Top             =   3360
               Width           =   1335
            End
            Begin VB.OptionButton optFlight 
               Caption         =   "Flight"
               Enabled         =   0   'False
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               ForeColor       =   &H00808080&
               Height          =   255
               Left            =   0
               TabIndex        =   142
               Top             =   3120
               Width           =   1335
            End
            Begin VB.OptionButton optNpcSpawn 
               Caption         =   "NPC Spawn"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               ForeColor       =   &H80000008&
               Height          =   255
               Left            =   0
               TabIndex        =   141
               Top             =   2880
               Width           =   1335
            End
            Begin VB.OptionButton optSprite 
               Caption         =   "Sprite Change"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               ForeColor       =   &H80000008&
               Height          =   255
               Left            =   0
               TabIndex        =   140
               Top             =   2640
               Width           =   1335
            End
            Begin VB.OptionButton optMsg 
               Caption         =   "Map Message"
               Enabled         =   0   'False
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               ForeColor       =   &H00808080&
               Height          =   255
               Left            =   0
               TabIndex        =   139
               Top             =   2400
               Width           =   1335
            End
            Begin VB.OptionButton optSign 
               Caption         =   "Sign"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   0
               TabIndex        =   138
               Top             =   2160
               Width           =   1215
            End
            Begin VB.OptionButton optKey 
               Caption         =   "Key"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   270
               Left            =   0
               TabIndex        =   137
               Top             =   960
               Width           =   1215
            End
            Begin VB.OptionButton optNpcAvoid 
               Caption         =   "Npc Avoid"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   270
               Left            =   0
               TabIndex        =   136
               Top             =   720
               Width           =   1215
            End
            Begin VB.OptionButton optItem 
               Caption         =   "Item"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   270
               Left            =   0
               TabIndex        =   135
               Top             =   480
               Width           =   1215
            End
            Begin VB.OptionButton optBlocked 
               Caption         =   "Blocked"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   0
               TabIndex        =   134
               Top             =   0
               Value           =   -1  'True
               Width           =   1215
            End
            Begin VB.OptionButton optKeyOpen 
               Caption         =   "Key Open"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   240
               Left            =   0
               TabIndex        =   133
               Top             =   1200
               Width           =   1215
            End
            Begin VB.OptionButton optHeal 
               Caption         =   "Heal"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   0
               TabIndex        =   132
               Top             =   1440
               Width           =   1215
            End
            Begin VB.OptionButton optKill 
               Caption         =   "Damage"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   0
               TabIndex        =   131
               Top             =   1680
               Width           =   1215
            End
            Begin VB.OptionButton optDoor 
               Caption         =   "Door"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   0
               TabIndex        =   130
               Top             =   1920
               Width           =   1215
            End
            Begin VB.OptionButton optWarp 
               Caption         =   "Warp"
               BeginProperty Font 
                  Name            =   "Tahoma"
                  Size            =   8.25
                  Charset         =   0
                  Weight          =   400
                  Underline       =   0   'False
                  Italic          =   0   'False
                  Strikethrough   =   0   'False
               EndProperty
               Height          =   255
               Left            =   0
               TabIndex        =   129
               Top             =   240
               Width           =   1215
            End
         End
      End
      Begin VB.OptionButton optLayers 
         Caption         =   "Layers"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   10
         Top             =   6840
         Value           =   -1  'True
         Visible         =   0   'False
         Width           =   1575
      End
      Begin VB.OptionButton optAttribs 
         Caption         =   "Attributes"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   7080
         Visible         =   0   'False
         Width           =   1575
      End
      Begin VB.CommandButton cmdCancel 
         Caption         =   "Cancel"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   2040
         TabIndex        =   8
         Top             =   8280
         Width           =   1695
      End
      Begin VB.CommandButton cmdProperties 
         Caption         =   "Properties"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   390
         Left            =   2280
         TabIndex        =   6
         Top             =   6585
         Width           =   1335
      End
      Begin VB.VScrollBar scrlPicture 
         Height          =   3375
         LargeChange     =   7
         Left            =   3480
         Max             =   937
         TabIndex        =   5
         Top             =   120
         Width           =   255
      End
      Begin VB.PictureBox picBack 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   3360
         Left            =   120
         ScaleHeight     =   224
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   224
         TabIndex        =   4
         Top             =   120
         Width           =   3360
      End
      Begin VB.PictureBox picSelect 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H80000008&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   480
         Left            =   2640
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   3
         Top             =   3600
         Width           =   480
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Caption         =   "Selected Tile"
         Height          =   255
         Left            =   2280
         TabIndex        =   40
         Top             =   4080
         Width           =   1215
      End
   End
   Begin VB.PictureBox picMnuGear
      Left = 10155
      Top = 4200
      Width = 3975
      Height = 5310
      ScaleMode = 3
      ScaleWidth = 265
      ScaleHeight = 354
      BorderStyle = 0
      Visible = 0
      Picture = "frmMirage.frx":C6073
      Begin VB.Label lblGearName
         Left = 1680
         Top = 1920
         Width = 1935
         Height = 240
         Visible = 0
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblGearDur
         Left = 1680
         Top = 2325
         Width = 1275
         Height = 255
         Visible = 0
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblGearStr
         Left = 1680
         Top = 2760
         Width = 975
         Height = 255
         Visible = 0
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox Equip
         Left = 675
         Top = 4470
         Width = 480
         Height = 480
         Index = 0
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.PictureBox Equip
         Left = 1350
         Top = 4470
         Width = 480
         Height = 480
         Index = 1
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.PictureBox Equip
         Left = 2025
         Top = 4470
         Width = 480
         Height = 480
         Index = 2
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.PictureBox Equip
         Left = 2700
         Top = 4470
         Width = 480
         Height = 480
         Index = 3
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 435
         Width = 1905
         Height = 225
         Index = 0
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 735
         Width = 1905
         Height = 225
         Index = 1
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 1035
         Width = 1905
         Height = 225
         Index = 2
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 1335
         Width = 1905
         Height = 225
         Index = 3
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 1635
         Width = 1905
         Height = 225
         Index = 4
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 1935
         Width = 1905
         Height = 225
         Index = 5
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1410
         Top = 2235
         Width = 420
         Height = 225
         Index = 6
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 3135
         Top = 2235
         Width = 420
         Height = 225
         Index = 7
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterTrain
         Left = 3675
         Top = 2535
         Width = 210
         Height = 225
         Index = 0
         Caption = "+"
         Alignment = 2
         BackStyle = 0
         ForeColor = 16777215
         Tag = "game-menu:picMnuGear:show"
      End
      Begin VB.Label lblCharacterTrain
         Left = 3675
         Top = 2835
         Width = 210
         Height = 225
         Index = 1
         Caption = "+"
         Alignment = 2
         BackStyle = 0
         ForeColor = 16777215
         Tag = "game-menu:picMnuGear:show"
      End
      Begin VB.Label lblCharacterTrain
         Left = 3675
         Top = 3435
         Width = 210
         Height = 225
         Index = 2
         Caption = "+"
         Alignment = 2
         BackStyle = 0
         ForeColor = 16777215
         Tag = "game-menu:picMnuGear:show"
      End
      Begin VB.Label lblCharacterTrain
         Left = 3675
         Top = 3735
         Width = 210
         Height = 225
         Index = 3
         Caption = "+"
         Alignment = 2
         BackStyle = 0
         ForeColor = 16777215
         Tag = "game-menu:picMnuGear:show"
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 2535
         Width = 1905
         Height = 225
         Index = 8
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 2835
         Width = 1905
         Height = 225
         Index = 9
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 3135
         Width = 1905
         Height = 225
         Index = 10
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 3435
         Width = 1905
         Height = 225
         Index = 11
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 3735
         Width = 1905
         Height = 225
         Index = 12
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCharacterValue
         Left = 1650
         Top = 4035
         Width = 1905
         Height = 225
         Index = 13
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
   End
   Begin VB.CheckBox chkGUI 
      Visible = 0
      Height          =   375
      Index           =   0
      Left            =   2040
      TabIndex        =   157
      Top             =   9240
      Width           =   375
   End
   Begin VB.TextBox txtGUI 
      Visible = 0
      Height          =   375
      Index           =   0
      Left            =   1560
      TabIndex        =   156
      Top             =   9240
      Width           =   375
   End
   Begin VB.CommandButton cmdGUI 
      Visible = 0
      Height          =   375
      Index           =   0
      Left            =   600
      TabIndex        =   154
      Top             =   9240
      Width           =   375
   End
   Begin VB.PictureBox picGUI 
      Height          =   375
      Index           =   0
      Left            =   120
      ScaleHeight     =   315
      ScaleWidth      =   315
      TabIndex        =   153
      Top             =   9240
      Visible         =   0
      Width           =   375
   End
   Begin VB.PictureBox picMnuTrain 
      Appearance      =   0  'Flat
      BackColor       =   &H00400000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   3990
      Left            =   10155
      Picture         =   "frmMirage.frx":4C9E2
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   109
      Top             =   4200
      Visible         =   0
      Width           =   3720
      Begin VB.ComboBox cmbStat 
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   330
         ItemData        =   "frmMirage.frx":56942
         Left            =   480
         List            =   "frmMirage.frx":56952
         Style           =   2  'Dropdown List
         TabIndex        =   111
         Top             =   1920
         Width           =   2775
      End
      Begin VB.Label lblTrain 
         BackStyle       =   0  'Transparent
         Height          =   375
         Left            =   2640
         TabIndex        =   113
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblPlayerPoints 
         BackStyle       =   0  'Transparent
         Caption         =   "Current Stat Points: 0"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   300
         Left            =   210
         TabIndex        =   112
         Top             =   645
         Width           =   3300
         Alignment       =   2  'Center
      End
   End
   Begin VB.PictureBox picKeepNotes 
      Appearance      =   0  'Flat
      BackColor       =   &H00400000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   3990
      Left            =   10155
      Picture         =   "frmMirage.frx":56977
      ScaleHeight     =   259.179
      ScaleMode       =   0  'User
      ScaleWidth      =   241.192
      TabIndex        =   27
      Top             =   4200
      Visible         =   0
      Width           =   3720
      Begin RichTextLib.RichTextBox Notetext 
         Height          =   1800
         Left            =   285
         TabIndex        =   31
         Top             =   630
         Width           =   3270
         _ExtentX        =   4048
         _ExtentY        =   5106
         _Version        =   393217
         BackColor       =   16777215
         BorderStyle     =   0
         ScrollBars      =   1
         Appearance      =   0
         TextRTF         =   $"frmMirage.frx":5AC67
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin VB.Label lblNoteSave 
         BackStyle       =   0  'Transparent
         Height          =   375
         Left            =   1965
         TabIndex        =   29
         Top             =   3360
         Width           =   1530
      End
   End
   Begin VB.PictureBox picInv
      Left = 10155
      Top = 4200
      Width = 3975
      Height = 5730
      ScaleMode = 3
      ScaleWidth = 265
      ScaleHeight = 382
      AutoRedraw = -1
      BorderStyle = 0
      BackColor = 2631720
      Visible = 0
      Picture = "frmMirage.frx":B21EA
      Begin VB.Label lblUseItem
         Left = 90
         Top = 5370
         Width = 630
         Height = 300
         Caption = "Use"
         BackStyle = 0
         ForeColor = 14809087
      End
      Begin VB.Label lblDropItem
         Left = 750
         Top = 5370
         Width = 630
         Height = 300
         Caption = "Drop"
         BackStyle = 0
         ForeColor = 14809087
      End
      Begin VB.Label lblCancel
         Left = 3195
         Top = 5370
         Width = 630
         Height = 300
         Caption = "Close"
         BackStyle = 0
         ForeColor = 14809087
      End
      Begin VB.ListBox lstInv
         Left = 240
         Top = 1200
         Width = 3255
         Height = 2130
         Visible = 0
      End
      Begin VB.PictureBox picItem
         Left = 1125
         Top = 495
         Width = 480
         Height = 480
         Visible = 0
      End
      Begin VB.Label lblInventoryPrevious
         Left = 1500
         Top = 5370
         Width = 300
         Height = 300
         Caption = "<"
         BackStyle = 0
         ForeColor = 14809087
      End
      Begin VB.Label lblInventoryPage
         Left = 1905
         Top = 5370
         Width = 540
         Height = 300
         Caption = "1/3"
         BackStyle = 0
         ForeColor = 14809087
      End
      Begin VB.Label lblInventoryNext
         Left = 2655
         Top = 5370
         Width = 300
         Height = 300
         Caption = ">"
         BackStyle = 0
         ForeColor = 14809087
      End
   End
   Begin VB.PictureBox picPlayerSpells
      Left = 10155
      Top = 4200
      Width = 3975
      Height = 5730
      ScaleMode = 3
      ScaleWidth = 265
      ScaleHeight = 382
      BorderStyle = 0
      Visible = 0
      Picture = "frmMirage.frx":E11E4
      Begin VB.Label lblSpellsCancel
         Left = 3045
         Top = 5370
         Width = 750
         Height = 300
         Caption = "Close"
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblCast
         Left = 2100
         Top = 5370
         Width = 750
         Height = 300
         Caption = "Cast"
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblForget
         Left = 2040
         Top = 3300
         Width = 1740
         Height = 435
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.ListBox lstSpells
         Left = 180
         Top = 1200
         Width = 3375
         Height = 2130
         Visible = 0
      End
      Begin VB.Label lblSkillsNext
         Left = 2040
         Top = 3945
         Width = 1740
         Height = 435
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblSkillsPrevious
         Left = 2040
         Top = 4590
         Width = 1740
         Height = 435
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblSkillsUpgrade
         Left = 2040
         Top = 2715
         Width = 1740
         Height = 435
         Enabled = 0
         ToolTipText = "Spell upgrades are not supported by this game."
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblSkillsDetails
         Left = 2145
         Top = 390
         Width = 1515
         Height = 2145
         Caption = "Select a spell."
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblSkillsPage
         Left = 240
         Top = 5370
         Width = 1500
         Height = 300
         Caption = "Page 1"
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 405
         Width = 1005
         Height = 510
         Index = 0
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 405
         Width = 480
         Height = 480
         Index = 0
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 990
         Width = 1005
         Height = 510
         Index = 1
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 990
         Width = 480
         Height = 480
         Index = 1
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 1575
         Width = 1005
         Height = 510
         Index = 2
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 1575
         Width = 480
         Height = 480
         Index = 2
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 2160
         Width = 1005
         Height = 510
         Index = 3
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 2160
         Width = 480
         Height = 480
         Index = 3
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 2745
         Width = 1005
         Height = 510
         Index = 4
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 2745
         Width = 480
         Height = 480
         Index = 4
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 3330
         Width = 1005
         Height = 510
         Index = 5
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 3330
         Width = 480
         Height = 480
         Index = 5
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 3915
         Width = 1005
         Height = 510
         Index = 6
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 3915
         Width = 480
         Height = 480
         Index = 6
         AutoRedraw = -1
         BorderStyle = 0
      End
      Begin VB.Label lblSkillName
         Left = 885
         Top = 4500
         Width = 1005
         Height = 510
         Index = 7
         Caption = ""
         BackStyle = 0
         ForeColor = 16777215
      End
      Begin VB.PictureBox picSkillIcon
         Left = 315
         Top = 4500
         Width = 480
         Height = 480
         Index = 7
         AutoRedraw = -1
         BorderStyle = 0
      End
   End
   Begin VB.PictureBox picLiveStats 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   3990
      Left            =   10155
      Picture         =   "frmMirage.frx":6DB5F
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   82
      Top             =   4200
      Visible         =   0
      Width           =   3720
      Begin VB.Label Label8 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   2640
         TabIndex        =   93
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblLevel 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   92
         Top             =   840
         Width           =   1455
      End
      Begin VB.Label lblSTR 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   91
         Top             =   1080
         Width           =   1455
      End
      Begin VB.Label lblDEF 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   90
         Top             =   1680
         Width           =   1455
      End
      Begin VB.Label lblMAGI 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   89
         Top             =   1920
         Width           =   1455
      End
      Begin VB.Label lblSPEED 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   88
         Top             =   1440
         Width           =   1455
      End
      Begin VB.Label lblEXP 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1320
         TabIndex        =   87
         Top             =   2280
         Width           =   1335
      End
      Begin VB.Label lblTNL 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   86
         Top             =   2520
         Width           =   1455
      End
      Begin VB.Label lblCHit 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   85
         Top             =   2880
         Width           =   1455
      End
      Begin VB.Label lblBlock 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   84
         Top             =   3120
         Width           =   1455
      End
      Begin VB.Label lblPoints 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1200
         TabIndex        =   83
         Top             =   3360
         Width           =   1455
      End
   End
   Begin VB.PictureBox picSign 
      Appearance      =   0  'Flat
      BackColor       =   &H0080FFFF&
      ForeColor       =   &H80000008&
      Height          =   1815
      Left            =   3682
      Picture         =   "frmMirage.frx":77871
      ScaleHeight     =   119
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   183
      TabIndex        =   42
      Top             =   2962
      Visible         =   0
      Width           =   2775
      Begin VB.Label lblNameTop 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   50
         Top             =   120
         Width           =   2775
      End
      Begin VB.Line Line1 
         BorderColor     =   &H00000080&
         X1              =   0
         X2              =   184
         Y1              =   35
         Y2              =   35
      End
      Begin VB.Label lblLine3Top 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   46
         Top             =   1005
         Width           =   2775
      End
      Begin VB.Label lblLine2Top 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   45
         Top             =   765
         Width           =   2775
      End
      Begin VB.Label lblLine1Top 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   375
         Left            =   45
         TabIndex        =   44
         Top             =   525
         Width           =   2775
      End
      Begin VB.Label lblexit 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Exit"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080C0FF&
         Height          =   255
         Left            =   960
         TabIndex        =   43
         Top             =   1560
         Width           =   855
      End
      Begin VB.Label lblNameBtm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00404040&
         Height          =   375
         Left            =   0
         TabIndex        =   51
         Top             =   165
         Width           =   2775
      End
      Begin VB.Label lblLine3Btm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   375
         Left            =   0
         TabIndex        =   49
         Top             =   1050
         Width           =   2775
      End
      Begin VB.Label lblLine2Btm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   375
         Left            =   0
         TabIndex        =   48
         Top             =   810
         Width           =   2775
      End
      Begin VB.Label lblLine1Btm 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label1"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   375
         Left            =   0
         TabIndex        =   47
         Top             =   570
         Width           =   2775
      End
   End
   Begin VB.Frame fraMapNum 
      BackColor       =   &H00800000&
      Caption         =   "Map Number"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   720
      Left            =   18315
      TabIndex        =   77
      Top             =   1230
      Visible         =   0
      Width           =   1455
      Begin VB.TextBox txtMapNum 
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   360
         Left            =   120
         TabIndex        =   78
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.Frame fraPlayer 
      BackColor       =   &H00800000&
      Caption         =   "Player Name"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   720
      Left            =   18315
      TabIndex        =   75
      Top             =   510
      Visible         =   0
      Width           =   1455
      Begin VB.TextBox txtPlayerName 
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   345
         Left            =   120
         TabIndex        =   76
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.Frame fraSpriteNum 
      BackColor       =   &H00800000&
      Caption         =   "Sprite #"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   720
      Left            =   18315
      TabIndex        =   73
      Top             =   1950
      Visible         =   0
      Width           =   1455
      Begin VB.TextBox txtSpriteNum 
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   360
         Left            =   120
         TabIndex        =   74
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.Frame fralvl4 
      BackColor       =   &H00800000&
      Caption         =   "Server Owner"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   1275
      Left            =   18315
      TabIndex        =   69
      Top             =   7590
      Visible         =   0
      Width           =   1455
      Begin VB.CommandButton cmdSetAccess 
         BackColor       =   &H00FF8080&
         Caption         =   "Set Access"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   71
         TabStop         =   0   'False
         ToolTipText     =   "Set a players' admin access"
         Top             =   960
         Width           =   1215
      End
      Begin VB.TextBox txtAccessLevel 
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   360
         Left            =   120
         TabIndex        =   70
         Top             =   480
         Width           =   1215
      End
      Begin VB.Label AccessLevel 
         AutoSize        =   -1  'True
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "Access Level"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H008080FF&
         Height          =   270
         Left            =   120
         TabIndex        =   72
         Top             =   240
         Width           =   1155
      End
   End
   Begin VB.Frame fralvl3 
      BackColor       =   &H00800000&
      Caption         =   "Developers"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   1710
      Left            =   18315
      TabIndex        =   62
      Top             =   5910
      Visible         =   0
      Width           =   1455
      Begin VB.CommandButton cmdKill 
         BackColor       =   &H00FF8080&
         Caption         =   "Kill"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   68
         TabStop         =   0   'False
         ToolTipText     =   "Kill a Player"
         Top             =   1440
         Width           =   1215
      End
      Begin VB.CommandButton cmdDelbanlist 
         BackColor       =   &H00FF8080&
         Caption         =   "UnBan Player"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   67
         TabStop         =   0   'False
         ToolTipText     =   "Unban Player."
         Top             =   1200
         Width           =   1215
      End
      Begin VB.CommandButton cmdSpellEditor 
         BackColor       =   &H00FF8080&
         Caption         =   "SpellEditor"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   66
         TabStop         =   0   'False
         ToolTipText     =   "Edit the Spells"
         Top             =   960
         Width           =   1215
      End
      Begin VB.CommandButton cmdShopEditor 
         BackColor       =   &H00FF8080&
         Caption         =   "ShopEditor"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   65
         TabStop         =   0   'False
         ToolTipText     =   "Edit the Shops"
         Top             =   720
         Width           =   1215
      End
      Begin VB.CommandButton cmdItemEditor 
         BackColor       =   &H00FF8080&
         Caption         =   "Item Editor"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   64
         TabStop         =   0   'False
         ToolTipText     =   "Edit the Items"
         Top             =   480
         Width           =   1215
      End
      Begin VB.CommandButton cmdNpcEditor 
         BackColor       =   &H00FF8080&
         Caption         =   "Npc Editor"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   63
         TabStop         =   0   'False
         ToolTipText     =   "Edit the Npcs"
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.Frame fralvl1 
      BackColor       =   &H00800000&
      Caption         =   "Monitors"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   555
      Left            =   18315
      TabIndex        =   60
      Top             =   2670
      Visible         =   0
      Width           =   1455
      Begin VB.CommandButton cmdKick 
         BackColor       =   &H00FF8080&
         Caption         =   "Kick"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   61
         TabStop         =   0   'False
         ToolTipText     =   "Kick a player"
         Top             =   240
         Width           =   1215
      End
   End
   Begin VB.Frame fralvl2 
      BackColor       =   &H00800000&
      Caption         =   "Mappers"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   2670
      Left            =   18315
      TabIndex        =   52
      Top             =   3255
      Visible         =   0
      Width           =   1455
      Begin VB.CommandButton cmdSetSprite 
         BackColor       =   &H00FF8080&
         Caption         =   "Set Sprite"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   55
         ToolTipText     =   "Change your sprite"
         Top             =   720
         Width           =   1215
      End
      Begin VB.CommandButton cmdWarpto 
         BackColor       =   &H00FF8080&
         Caption         =   "Warpto"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   54
         TabStop         =   0   'False
         ToolTipText     =   "Warp yourself to"
         Top             =   480
         Width           =   1215
      End
      Begin VB.CommandButton cmdMapeditor 
         BackColor       =   &H00FF8080&
         Caption         =   "MapEditor"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   53
         TabStop         =   0   'False
         ToolTipText     =   "Edit the map"
         Top             =   240
         Width           =   1215
      End
      Begin VB.CommandButton cmdPlayerSprite 
         BackColor       =   &H00FF8080&
         Caption         =   "Player Sprite"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   79
         ToolTipText     =   "Change your sprite"
         Top             =   960
         Width           =   1215
      End
      Begin VB.CommandButton cmdRespawn 
         BackColor       =   &H00FF8080&
         Caption         =   "Respawn"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   56
         TabStop         =   0   'False
         ToolTipText     =   "Respawn the map"
         Top             =   1200
         Width           =   1215
      End
      Begin VB.CommandButton cmdMapreport 
         BackColor       =   &H00FF8080&
         Caption         =   "Map Report"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   57
         TabStop         =   0   'False
         ToolTipText     =   "View all free maps"
         Top             =   1440
         Width           =   1215
      End
      Begin VB.CommandButton cmdBan 
         BackColor       =   &H00FF8080&
         Caption         =   "Ban"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   58
         ToolTipText     =   "Ban a player"
         Top             =   1680
         UseMaskColor    =   -1  'True
         Width           =   1215
      End
      Begin VB.CommandButton cmdLOC 
         BackColor       =   &H00FF8080&
         Caption         =   "Location"
         CausesValidation=   0   'False
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   59
         TabStop         =   0   'False
         ToolTipText     =   "Find your location"
         Top             =   1920
         Width           =   1215
      End
      Begin VB.CommandButton cmdSignEdit 
         BackColor       =   &H00FF8080&
         Caption         =   "Sign Editor"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   80
         ToolTipText     =   "Ban a player"
         Top             =   2160
         UseMaskColor    =   -1  'True
         Width           =   1215
      End
   End
   Begin MSWinsockLib.Winsock Socket 
      Left            =   0
      Top             =   0
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin RichTextLib.RichTextBox txtChat 
      Height          =   1920
      Left            =   270
      TabIndex        =   1
      Top             =   7890
      Width           =   9600
      _ExtentX        =   13361
      _ExtentY        =   2566
      _Version        =   393217
      BackColor       =   0
      BorderStyle     =   0
      ReadOnly        =   -1  'True
      ScrollBars      =   2
      MousePointer    =   1
      Appearance      =   0
      TextRTF         =   $"frmMirage.frx":7A069
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Trebuchet MS"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin VB.PictureBox picScreen 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   7200
      Left            =   270
      ScaleHeight     =   384
      ScaleMode       =   0
      ScaleWidth      =   512
      TabIndex        =   0
      Top             =   270
      Width           =   9600
   End
   Begin VB.PictureBox shpSP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7A0EA
      ScaleHeight     =   225
      ScaleWidth      =   2295
      TabIndex        =   34
      Top             =   1380
      Width           =   3090
      Begin VB.Label lblSP 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "0%"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   0
         Left            =   0
         TabIndex        =   122
         Top             =   0
         Width           =   2295
      End
   End
   Begin VB.PictureBox shpEXP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7A1B3
      ScaleHeight     =   75
      ScaleWidth      =   5400
      TabIndex        =   38
      Top             =   1125
      Width           =   3090
   End
   Begin VB.PictureBox shpMP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7A588
      ScaleHeight     =   225
      ScaleWidth      =   2325
      TabIndex        =   37
      Top             =   855
      Width           =   3090
      Begin VB.Label lblMP 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "0%"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   225
         Index           =   0
         Left            =   0
         TabIndex        =   124
         Top             =   0
         Width           =   2325
      End
   End
   Begin VB.PictureBox Picture3 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7A982
      ScaleHeight     =   225
      ScaleWidth      =   2325
      TabIndex        =   36
      Top             =   855
      Width           =   3090
      Begin VB.Label lblMP 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "0%"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   225
         Index           =   1
         Left            =   0
         TabIndex        =   127
         Top             =   0
         Width           =   2325
      End
   End
   Begin VB.PictureBox Picture4 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7AA93
      ScaleHeight     =   75
      ScaleWidth      =   5400
      TabIndex        =   39
      Top             =   1125
      Width           =   3090
   End
   Begin VB.PictureBox Picture2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7AB49
      ScaleHeight     =   225
      ScaleWidth      =   2295
      TabIndex        =   35
      Top             =   1380
      Width           =   3090
      Begin VB.Label lblSP 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "0%"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   1
         Left            =   0
         TabIndex        =   123
         Top             =   0
         Width           =   2295
      End
   End
   Begin VB.TextBox txtMyTextBox 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Trebuchet MS"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   360
      Left            =   270
      MousePointer    =   1  'Arrow
      TabIndex        =   108
      Top             =   9870
      Width           =   9600
   End
   Begin VB.PictureBox shpHP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7AC54
      ScaleHeight     =   225
      ScaleWidth      =   2340
      TabIndex        =   32
      Top             =   585
      Width           =   3090
      Begin VB.Label lblHP 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "0%"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   0
         Left            =   0
         TabIndex        =   120
         Top             =   0
         Width           =   2340
      End
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   165
      Left            =   10485
      Picture         =   "frmMirage.frx":7AD24
      ScaleHeight     =   225
      ScaleWidth      =   2340
      TabIndex        =   33
      Top             =   585
      Width           =   3090
      Begin VB.Label lblHP 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "0%"
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   1
         Left            =   0
         TabIndex        =   121
         Top             =   0
         Width           =   2340
      End
   End
   Begin VB.PictureBox picPlayerList 
      Appearance      =   0  'Flat
      BackColor       =   &H00400000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   3990
      Left            =   10155
      Picture         =   "frmMirage.frx":7AE36
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   114
      Top             =   4200
      Width           =   3720
      Begin VB.ListBox lstPlayers 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   1920
         Left            =   600
         TabIndex        =   116
         Top             =   1200
         Width           =   2415
      End
      Begin VB.Label picPM 
         BackStyle       =   0  'Transparent
         Height          =   375
         Left            =   120
         TabIndex        =   118
         ToolTipText     =   "Send a personal message!"
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblWeb 
         BackStyle       =   0  'Transparent
         Height          =   375
         Left            =   1440
         TabIndex        =   117
         ToolTipText     =   "Web Browser"
         Top             =   3360
         Width           =   855
      End
      Begin VB.Label Label5 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF00FF&
         Height          =   375
         Left            =   2640
         TabIndex        =   115
         Top             =   3360
         Width           =   975
      End
   End
   Begin VB.Label picGear 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   10080
      TabIndex        =   164
      ToolTipText     =   "View your current equipment."
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label lblGUI 
      Visible = 0
      Height          =   375
      Index           =   0
      Left            =   1080
      TabIndex        =   155
      Top             =   9240
      Width           =   375
   End
   Begin VB.Label Label4 
      Visible = 0
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "POWERED BY PLAYERWORLDS"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   5.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   135
      Left            =   600
      TabIndex        =   126
      Top             =   8925
      Width           =   2895
   End
   Begin VB.Label lblMapInfo 
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "Map Name"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   240
      Left            =   300
      TabIndex        =   125
      Top             =   7620
      Width           =   6300
   End
   Begin VB.Label lblPlayers 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   11190
      TabIndex        =   119
      ToolTipText     =   "View the list of online players."
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label cmdMinimize 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   13410
      TabIndex        =   107
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label picOptions 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H80000008&
      Height          =   630
      Left            =   13125
      TabIndex        =   106
      ToolTipText     =   "Change user settings."
      Top             =   2685
      Width           =   630
   End
   Begin VB.Label lblGameName 
      Visible = 0
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Game Name"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   255
      Left            =   1440
      TabIndex        =   97
      Top             =   780
      Width           =   2415
   End
   Begin VB.Label lblKeepNotes 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   12300
      TabIndex        =   28
      ToolTipText     =   "Edit your player notes."
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label picBugReport 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   12855
      TabIndex        =   26
      ToolTipText     =   "Report a Bug!"
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label picQuit 
      BackStyle       =   0  'Transparent
      Height          =   435
      Left            =   11985
      TabIndex        =   25
      ToolTipText     =   "Quit the Game"
      Top             =   9975
      Width           =   1815
   End
   Begin VB.Label picStats 
      BackStyle       =   0  'Transparent
      Height          =   630
      Left            =   10305
      TabIndex        =   24
      ToolTipText     =   "View your current stats."
      Top             =   2685
      Width           =   630
   End
   Begin VB.Label picTrain 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   11745
      TabIndex        =   23
      ToolTipText     =   "Train your character."
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label picInventory 
      BackStyle       =   0  'Transparent
      Height          =   630
      Left            =   11025
      TabIndex        =   22
      ToolTipText     =   "View your inventory."
      Top             =   2685
      Width           =   630
   End
   Begin VB.Label picSpells 
      BackStyle       =   0  'Transparent
      Height          =   630
      Left            =   12405
      TabIndex        =   21
      ToolTipText     =   "View your spells."
      Top             =   2685
      Width           =   630
   End
   Begin VB.Label picTrade 
      BackStyle       =   0  'Transparent
      Height          =   540
      Left            =   10635
      TabIndex        =   20
      Top             =   1770
      Width           =   525
   End
   Begin VB.Label picWebsite
      BackStyle = 0
      Caption = ""
      Left = 10170
      Top = 9975
      Width = 1815
      Height = 435
   End
   Begin VB.Label picGuild
      BackStyle = 0
      Caption = ""
      Left = 11715
      Top = 2685
      Width = 630
      Height = 630
   End
End
Attribute VB_Name = "frmMainGame"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
    Private InventoryPage As Long
    Private InventoryClickedSlot As Long
    Private InventoryCanvas As clsDX11Surface



Dim KeyShift As Boolean
Private ChatInputHasFocus As Boolean
Public ChatUnlocked As Boolean
Private ChatEnterDown As Boolean
Private Ammount As Long
Dim SpellMemorized As Long
Public clsFormSkin As New clsFormSkin

Private Sub cmdFill_Click()
    Call EditorFillSelection
End Sub

Private Sub cmdClear_Click()
    If frmMainGame.optLayers.Value = True Then
        Call EditorClearLayer
    ElseIf frmMainGame.optAttribs.Value = True Then
        Call EditorClearAttribs
    End If
End Sub

Private Sub cmdMinimize_Click()
    Me.WindowState = 1
End Sub

Private Sub Equip_Click(index As Integer)
    Select Case index
        Case 0
            If GetPlayerShieldSlot(MyIndex) <> 0 Then
                lblGearName.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerShieldSlot(MyIndex))).name
                lblGearDur.Caption = GetPlayerInvItemDur(MyIndex, GetPlayerShieldSlot(MyIndex)) & " / " & Item(GetPlayerInvItemNum(MyIndex, GetPlayerShieldSlot(MyIndex))).Data1
                lblGearStr.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerShieldSlot(MyIndex))).Data2
            Else
                Call EmptyGearSlot(0)
            End If
        Case 1
            If GetPlayerArmorSlot(MyIndex) <> 0 Then
                lblGearName.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerArmorSlot(MyIndex))).name
                lblGearDur.Caption = GetPlayerInvItemDur(MyIndex, GetPlayerArmorSlot(MyIndex)) & " / " & Item(GetPlayerInvItemNum(MyIndex, GetPlayerArmorSlot(MyIndex))).Data2
                lblGearStr.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerArmorSlot(MyIndex))).Data2
            Else
                Call EmptyGearSlot(1)
            End If
        Case 2
            If GetPlayerWeaponSlot(MyIndex) <> 0 Then
                lblGearName.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerWeaponSlot(MyIndex))).name
                lblGearDur.Caption = GetPlayerInvItemDur(MyIndex, GetPlayerWeaponSlot(MyIndex)) & " / " & Item(GetPlayerInvItemNum(MyIndex, GetPlayerWeaponSlot(MyIndex))).Data1
                lblGearStr.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerWeaponSlot(MyIndex))).Data2
            Else
                Call EmptyGearSlot(2)
            End If
        Case 3
            If GetPlayerHelmetSlot(MyIndex) <> 0 Then
                lblGearName.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerHelmetSlot(MyIndex))).name
                lblGearDur.Caption = GetPlayerInvItemDur(MyIndex, GetPlayerHelmetSlot(MyIndex)) & " / " & Item(GetPlayerInvItemNum(MyIndex, GetPlayerHelmetSlot(MyIndex))).Data1
                lblGearStr.Caption = Item(GetPlayerInvItemNum(MyIndex, GetPlayerHelmetSlot(MyIndex))).Data2
            Else
                Call EmptyGearSlot(3)
            End If
    End Select
End Sub

Private Sub Form_Load()
        LayoutGamePanels
    Call ApplyMovementControls

    ' Dim result As Long
    ' result = SetWindowLong(txtChat.hWnd, GWL_EXSTYLE, WS_EX_TRANSPARENT)
    ' result = SetWindowLong(txtMyTextBox.hWnd, GWL_EXSTYLE, WS_EX_TRANSPARENT)
    
   Notetext.BackColor = RGB(214, 188, 154)
    lstInv.BackColor = RGB(174, 222, 245)
    lstSpells.BackColor = RGB(174, 222, 245)
    
    ' Dim AppPath As String
    ' AppPath = App.Path
    ' Call clsFormSkin.fn_CreateSkin(Me, 741, 481, AppPath & "\GUI\InGame.bmp", RGB(255, 0, 200))
    
    If IsDebug = False Then
        EnableURLDetect txtChat.hwnd, Me.hwnd
    End If
    
    If EditorscrlPicture >= 0 Then
        scrlPicture.Value = EditorscrlPicture
    End If
    
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveForm(Me)
End Sub

Private Sub Form_Terminate()
    Call GameDestroy
End Sub

Private Sub Form_Unload(Cancel As Integer)
    
    If IsDebug = False Then
        DisableURLDetect
    End If
    
    Call GameDestroy

End Sub

Private Sub lblForget_Click()
    If Player(MyIndex).Spell(lstSpells.ListIndex + 1) > 0 Then
        If GetTickCount > Player(MyIndex).AttackTimer + 1000 Then
            If GameMsgBox("Are you sure you want to forget the spell " & vbQuote & Trim$(Spell(Player(MyIndex).Spell(lstSpells.ListIndex + 1)).name) & vbQuote & "?", vbYesNo) = vbNo Then Exit Sub

            SendData "forgetspell" & SEP_CHAR & lstSpells.ListIndex + 1 & END_CHAR
            picPlayerSpells.Visible = False
        End If
    Else
        AddText "No spell here.", BrightRed
    End If
End Sub

Private Sub lblPlayers_Click()
    Call CloseSideMenu
End Sub

Private Sub lblTrain_Click()
   Dim currentPoints As Long
   currentPoints = GetPlayerPOINTS(MyIndex)
   lblPlayerPoints.Caption = "Current Stat Points: " & CStr(currentPoints)
   If currentPoints <= 0 Then Exit Sub
   Call SendData("usestatpoint" & SEP_CHAR & cmbStat.ListIndex & END_CHAR)
   Call SetPlayerPOINTS(MyIndex, currentPoints - 1)
   lblPlayerPoints.Caption = "Current Stat Points: " & CStr(GetPlayerPOINTS(MyIndex))
End Sub

Private Sub TrainCharacterStat(ByVal PointType As Long)
    If MyIndex < 1 Then Exit Sub
    If GetPlayerPOINTS(MyIndex) <= 0 Then Exit Sub
    Call SendData("usestatpoint" & SEP_CHAR & PointType & END_CHAR)
End Sub

Private Sub lblCharacterTrain_Click(Index As Integer)
    Select Case Index
        Case 0: TrainCharacterStat 0
        Case 1: TrainCharacterStat 1
        Case 2: TrainCharacterStat 3
        Case 3: TrainCharacterStat 2
    End Select
End Sub

Private Sub optBlocked_Click()
    frmMapBlock.Show vbModal
End Sub

Private Sub optNpcSpawn_Click()
    frmMapSpawnNPC.Show vbModal
End Sub

Private Sub optNudge_Click()
    frmMapNudge.Show vbModal
End Sub

Private Sub optSprite_Click()
    frmSetSprite.Show vbModal
End Sub

Private Sub picBack_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call EditorChooseTile(Button, Shift, X, Y)
End Sub

Private Sub picBack_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call EditorUpdateSelection(Button, X, Y)
End Sub

Private Sub picBack_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call EditorEndSelection(Button, X, Y)
End Sub





Private Sub picOptions_Click()
    frmOptions.Show vbModal
End Sub


Private Sub picScreen_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyShift Then
        KeyShift = True
    End If
End Sub

Private Sub picScreen_KeyUp(KeyCode As Integer, Shift As Integer)
    KeyShift = False
End Sub

Private Sub Socket_DataArrival(ByVal bytesTotal As Long)
    If IsConnected Then
        Call IncomingData(bytesTotal)
    End If
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    ' Enter is handled on key-down so changing focus cannot submit it twice.
    If KeyAscii = vbKeyReturn Then
        KeyAscii = 0
    ElseIf Not KeyChatEnabled And TxtHasFocus And Not ChatInputHasFocus Then
        Call HandleKeypresses(KeyAscii)
        KeyAscii = 0
    ElseIf KeyChatEnabled And Not ChatUnlocked And TxtHasFocus Then
        KeyAscii = 0
    End If
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyReturn And (ChatUnlocked Or TxtHasFocus) Then
        If Not ChatEnterDown Then
            ChatEnterDown = True
            If Not KeyChatEnabled Then
                ' Classic chat is always available; Enter sends without locking it.
                MyText = txtMyTextBox.Text
                If Len(Trim$(MyText)) = 0 And GameKeyMatches(HK_PICKUP, vbKeyReturn) Then Call CheckMapGetItem
                Call HandleKeypresses(vbKeyReturn)
                txtMyTextBox.Text = MyText
            ElseIf ChatUnlocked Then
                MyText = txtMyTextBox.Text
                ChatUnlocked = False
                txtMyTextBox.Locked = True
                Call HandleKeypresses(vbKeyReturn)
                txtMyTextBox.Text = MyText
                Call SetFocusOnGame
            Else
                If GameKeyMatches(HK_PICKUP, vbKeyReturn) Then Call CheckMapGetItem
                Call UnlockChat
            End If
        End If
        KeyCode = 0
        Exit Sub
    End If
    If EditingHotkeys Or ChatUnlocked Or ChatInputHasFocus Or Not TxtHasFocus Then Exit Sub
    Call CheckInput(1, KeyCode, Shift)
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyReturn Then ChatEnterDown = False
    If EditingHotkeys Or ChatUnlocked Or ChatInputHasFocus Or Not TxtHasFocus Then Exit Sub
    Call CheckInput(0, KeyCode, Shift)
        Call UseSlotHotkey(KeyCode)
    If GameKeyMatches(HK_ADMIN, KeyCode) Then
        If frmMainGame.fraPlayer.Visible Then
            frmMainGame.fraPlayer.Visible = False
            frmMainGame.fraMapNum.Visible = False
            frmMainGame.fraSpriteNum.Visible = False
            frmMainGame.fralvl1.Visible = False
            frmMainGame.fralvl2.Visible = False
            frmMainGame.fralvl3.Visible = False
            frmMainGame.fralvl4.Visible = False
            frmMainGame.LayoutGamePanels
        ' frmMainGame.ScaleWidth = 800
        Else
            Call AdminPanel
        End If
    ElseIf GameKeyMatches(HK_CAST, KeyCode) Then
        If SpellMemorized > 0 Then
            If GetTickCount > Player(MyIndex).AttackTimer + 1000 Then
                If Player(MyIndex).Moving = 0 Then
                    Call SendData("cast" & SEP_CHAR & SpellMemorized & END_CHAR)
                    Player(MyIndex).Attacking = 1
                    Player(MyIndex).AttackTimer = GetTickCount
                    Player(MyIndex).CastedSpell = YES
                Else
                    Call AddText("Cannot cast while walking!", BrightRed)
                End If
            End If
        Else
            Call AddText("No spell here memorized.", BrightRed)
        End If
    End If
End Sub

Private Sub picKeepNotes_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
' Call MovePicture(frmMainGame.picKeepNotes, Button, Shift, X, Y)
End Sub

Private Sub picLiveStats_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    SOffsetX = X
    SOffsetY = Y
End Sub

Private Sub picLiveStats_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
' Call MovePicture(frmMainGame.picLiveStats, Button, Shift, X, Y)
End Sub

Private Sub picMapEditor_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    SOffsetX = X
    SOffsetY = Y
End Sub
Private Sub picMapEditor_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
' Call MovePicture(frmMainGame.picMapEditor, Button, Shift, X, Y)
End Sub

Private Sub picPlayerSpells_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    SOffsetX = X
    SOffsetY = Y
End Sub

Private Sub picPlayerSpells_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
' Call MovePicture(frmMainGame.picPlayerSpells, Button, Shift, X, Y)
End Sub


Private Sub picScreen_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call EditorMouseDown(Button, Shift, X, Y)
    If KeyShift = True Then
        If GetPlayerAccess(MyIndex) > 1 Then
            Call WarpSearch(Button, Shift, X, Y)
        End If
    Else
        Call PlayerSearch(Button, Shift, X, Y)
    End If
End Sub

Private Sub picScreen_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call EditorMouseDown(Button, Shift, X, Y)

    CurX = Int(X / PIC_X)
    CurY = Int(Y / PIC_Y)

    lblMapX.Caption = CurX
    lblMapY.Caption = CurY

End Sub

Private Sub picSign_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    SOffsetX = X
    SOffsetY = Y
End Sub

Private Sub picSign_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    CenterSign
End Sub

Private Sub txtChat_GotFocus()
    Call SetFocusOnGame
End Sub

' Focus Stuff

Private Sub txtMapNum_Change()
On Error Resume Next
    txtMapNum.SetFocus
End Sub

Private Sub txtMapNum_Click()
On Error Resume Next
    txtMapNum.SetFocus
End Sub

Public Sub ApplyMovementControls()
    ChatUnlocked = False
    ChatEnterDown = False
    DirUp = False
    DirDown = False
    DirLeft = False
    DirRight = False
    ControlDown = False
    ShiftDown = False
    txtMyTextBox.Locked = KeyChatEnabled
    If KeyChatEnabled Then
        txtMyTextBox.ToolTipText = "Enter: open/send chat | Options > Keyboard Shortcuts: change game keys"
    Else
        txtMyTextBox.ToolTipText = "Type to chat | Enter: send | Arrow keys: move"
    End If
End Sub

Public Sub UnlockChat()
    ChatUnlocked = KeyChatEnabled
    DirUp = False
    DirDown = False
    DirLeft = False
    DirRight = False
    ControlDown = False
    ShiftDown = False
    txtMyTextBox.Locked = False
    txtMyTextBox.Text = MyText
    txtMyTextBox.SetFocus
    txtMyTextBox.SelStart = Len(MyText)
End Sub

Private Sub txtMyTextBox_GotFocus()
    If KeyChatEnabled And Not ChatUnlocked Then
        Call SetFocusOnGame
        Exit Sub
    End If
    ChatInputHasFocus = True
    TxtHasFocus = True
End Sub

Private Sub txtMyTextBox_LostFocus()
    ChatInputHasFocus = False
    TxtHasFocus = False
End Sub

Private Sub txtMyTextBox_Change()
    Dim CleanText As String, I As Long, Code As Long
    ' Match the server's printable-ASCII chat protocol, including pasted text.
    For I = 1 To Len(txtMyTextBox.Text)
        Code = AscW(Mid$(txtMyTextBox.Text, I, 1))
        If Code >= 32 And Code <= 126 Then CleanText = CleanText & Chr$(Code)
    Next I
    MyText = CleanText
    If txtMyTextBox.Text <> CleanText Then
        txtMyTextBox.Text = CleanText
        txtMyTextBox.SelStart = Len(CleanText)
    End If
End Sub

Private Sub txtMyTextBox_KeyPress(KeyAscii As Integer)
    If KeyAscii = vbKeyReturn Or (KeyChatEnabled And Not ChatUnlocked) Then KeyAscii = 0
End Sub

Private Sub txtPlayerName_Change()
On Error Resume Next
    txtPlayerName.SetFocus
End Sub

Private Sub txtPlayerName_Click()
On Error Resume Next
    txtPlayerName.SetFocus
End Sub

Private Sub Notetext_GotFocus()
    TxtHasFocus = False
End Sub

Private Sub picScreen_GotFocus()
    TxtHasFocus = True
End Sub

Private Sub picScreen_LostFocus()
    TxtHasFocus = False
End Sub


' Button Click Codes

Private Sub picSpells_Click()
    Call CloseSideMenu
    If picPlayerSpells.Visible = True Then
        picPlayerSpells.Visible = False
    Else
        Call SendData("spells" & END_CHAR)
    End If
End Sub

Private Sub picStats_Click()
    Call CloseSideMenu
    Call SendData("getlivestats" & END_CHAR)
    picMnuGear.Visible = True
        RefreshCharacterDetails
        BltPlayerGear
End Sub

Private Sub picGear_Click()
    Call CloseSideMenu
    picMnuGear.Visible = True
        RefreshCharacterDetails
        BltPlayerGear
End Sub

Private Sub picTrain_Click()
    Call CloseSideMenu
    Call SendData("getlivestats" & END_CHAR)
   lblPlayerPoints.Caption = "Current Stat Points: " & CStr(GetPlayerPOINTS(MyIndex))
    picMnuTrain.Visible = True
    frmMainGame.cmbStat.ListIndex = 0
' frmTrade.mnuTrain.Visible = True
' frmTrade.Caption = "Crystalion II :: Training"
End Sub

Private Sub picTrade_Click()
    Call SendData("trade" & END_CHAR)
End Sub

Private Sub picQuit_Click()
    Call GameDestroy
End Sub

Private Sub picInventory_Click()
    Call CloseSideMenu
    If picInv.Visible = True Then
        picInv.Visible = False
    Else
        Call UpdateInventory
        picInv.Visible = True
    End If
End Sub

Private Sub lblKeepNotes_Click()
    Call CloseSideMenu
    ' Dim result As Long
    ' result = SetWindowLong(Notetext.hWnd, GWL_EXSTYLE, WS_EX_TRANSPARENT)
    If picKeepNotes.Visible = True Then
        picKeepNotes.Visible = False
    Else
        Notetext.LoadFile (App.Path & DATA_PATH & "notes.txt")
        picKeepNotes.Visible = True
    End If
End Sub

Private Sub picBugReport_Click()
    frmBugReport.Show vbModal
End Sub

Private Sub picPM_Click()
    MyText = "!" & lstPlayers.List(lstPlayers.ListIndex) & " "
On Error Resume Next
    Call UnlockChat
End Sub

Private Sub Label8_Click()
    If picLiveStats.Visible = True Then picLiveStats.Visible = False
End Sub


Private Sub lblexit_Click()
    picSign.Visible = False
End Sub

Private Sub lblNoteSave_Click()
    Dim iFileNum As Integer
   Dim saveError As String
   On Error GoTo SaveFailed

    ' Get a free file handle
    iFileNum = FreeFile

    ' If the file is not there, one will be created
    ' If the file does exist, this one will
    ' overwrite it.
    Open App.Path & DATA_PATH & "notes.txt" For Output As iFileNum

    Print #iFileNum, Notetext.Text

   Close #iFileNum
   picKeepNotes.Visible = False
   Exit Sub

SaveFailed:
   saveError = Err.Description
   On Error Resume Next
   Close #iFileNum
   On Error GoTo 0
   Call GameMsgBox("Could not save notes: " & saveError, vbOKOnly, GAME_NAME)
End Sub

Private Sub lstInv_DblClick()
    Call SendUseItem(frmMainGame.lstInv.ListIndex + 1)
End Sub

Private Sub lstSpells_DblClick()
    If Player(MyIndex).Spell(lstSpells.ListIndex + 1) > 0 Then
        SpellMemorized = lstSpells.ListIndex + 1
        Call AddText("Successfully memorized spell!", BrightGreen)
    Else
        Call AddText("No spell here to memorize.", BrightRed)
    End If
End Sub

Private Sub lstPlayers_DblClick()
    MyText = "!" & lstPlayers.List(lstPlayers.ListIndex) & " "
End Sub

Private Sub lblUseItem_Click()
    Call SendUseItem(frmMainGame.lstInv.ListIndex + 1)
End Sub

Private Sub lblDropItem_Click()
    Dim Value As Long
    Dim InvNum As Long

    InvNum = frmMainGame.lstInv.ListIndex + 1

    If GetPlayerInvItemNum(MyIndex, InvNum) > 0 And GetPlayerInvItemNum(MyIndex, InvNum) <= MAX_ITEMS Then
        If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Type = ITEM_TYPE_CURRENCY Then
            ' Show them the drop dialog
            frmDrop.Show vbModal
        Else
            Call SendDropItem(frmMainGame.lstInv.ListIndex + 1, 0)
        End If
    End If
End Sub

Private Sub lblCast_Click()
    If Player(MyIndex).Spell(lstSpells.ListIndex + 1) > 0 Then
        If GetTickCount > Player(MyIndex).AttackTimer + 1000 Then
            If Player(MyIndex).Moving = 0 Then
                Call SendData("cast" & SEP_CHAR & lstSpells.ListIndex + 1 & END_CHAR)
                Player(MyIndex).Attacking = 1
                Player(MyIndex).AttackTimer = GetTickCount
                Player(MyIndex).CastedSpell = YES
            Else
                Call AddText("Cannot cast while walking!", BrightRed)
            End If
        End If
    Else
        Call AddText("No spell here.", BrightRed)
    End If
End Sub

Private Sub lblCancel_Click()
    picInv.Visible = False
End Sub

Private Sub lblSpellsCancel_Click()
    picPlayerSpells.Visible = False
End Sub

Private Sub EmptyGearSlot(ByVal Slot As Byte)
Dim strSlot As String

    Select Case Slot
        Case 0
            strSlot = "Shield"
        Case 1
            strSlot = "Armor"
        Case 2
            strSlot = "Weapon"
        Case 3
            strSlot = "Helmet"
    End Select
    
    lblGearName.Caption = "No " & strSlot & " equipped."
    lblGearDur.Caption = vbNullString
    lblGearStr.Caption = vbNullString
    
End Sub

' // MAP EDITOR STUFF //

Private Sub optLayers_Click()
    If optLayers.Value = True Then

    End If
End Sub

Private Sub optAttribs_Click()
    If optAttribs.Value = True Then

    End If
End Sub

' Private Sub picBack_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
' Call EditorChooseTile(Button, Shift, X, Y)
' End Sub

' Private Sub picBack_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
' Call EditorChooseTile(Button, Shift, x, y)
' End Sub

Private Sub cmdSend_Click()
    Call EditorSend
    
    Call SetFocusOnGame
    
    EditorscrlPicture = scrlPicture.Value
End Sub

Private Sub cmdCancel_Click()
    Call EditorCancel
    
    EditorscrlPicture = scrlPicture.Value
End Sub

Private Sub cmdProperties_Click()
    frmMapProperties.Show vbModal
End Sub

Private Sub optWarp_Click()
    frmMapWarp.Show vbModal
End Sub

Private Sub optItem_Click()
    frmMapItem.Show vbModal
End Sub

Private Sub optKey_Click()
    frmMapKey.Show vbModal
End Sub

Private Sub optKeyOpen_Click()
    frmKeyOpen.Show vbModal
End Sub

Private Sub optSign_Click()
    Call SendData("signnames" & END_CHAR)
    frmSignChoose.Show vbModal
End Sub

Private Sub optKill_Click()
    frmMapDmg.Show vbModal
End Sub

Private Sub optMsg_Click()
    frmMsgEditor.Show vbModal
End Sub

Private Sub scrlPicture_Change()
    Call EditorTileScroll
End Sub

Private Sub SSTab1_Click(PreviousTab As Integer)
    If SSTab1.Caption = "Layers" Then
        optLayers.Value = True
        optAttribs.Value = False
    ElseIf SSTab1.Caption = "Attribs" Then
        EditorAttributeLayer = 1
        optLayers.Value = False
        optAttribs.Value = True
    End If
End Sub

Private Sub picBack_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyShift Then
        KeyShift = True
    End If
End Sub

' /// Admin Pannel Crapz0rz ///

Private Sub cmdBan_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call GameMsgBox("You must first enter a playername to ban.")
    Else
        Call SendBan(Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdBanlist_Click()
    Call SendBanList
End Sub

' Private Sub cmdCreate_Click()
' frmCreateGuild.Visible = True
' End Sub

Private Sub cmdDelbanlist_Click()
    Call SendBanDestroy
End Sub

Private Sub cmdItemEditor_Click()
    Call SendRequestEditItem
End Sub

' Private Sub cmdKill_Click()
' If txtPlayerName.Text = vbNullString Then
' Call GameMsgBox("You must first enter a playername to kill.")
' Else
' Call KillPlayer(Trim$(txtPlayerName.Text))
' End If
' End Sub

Private Sub cmdNpcEditor_Click()
    Call SendRequestEditNpc
End Sub

Private Sub cmdSetSprite_Click()
    If LenB(txtSpriteNum.Text) = 0 Then
        Call GameMsgBox("You must first enter a sprite number to set sprite.")
    Else
        Call SendSetSprite(Trim$(txtSpriteNum.Text))
    End If
End Sub

Private Sub cmdPlayerSprite_Click()
    If LenB(Trim$(txtSpriteNum.Text)) = 0 Or LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call GameMsgBox("You must first enter a sprite number and player name to set the player's sprite.")
    Else
        Call SendPlayerSprite(Trim$(txtSpriteNum.Text), Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdShopEditor_Click()
    Call SendRequestEditShop
End Sub

Private Sub cmdSpellEditor_Click()
    Call SendRequestEditSpell
End Sub

Private Sub cmdKick_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call GameMsgBox("You must first enter a playername to kick.")
    Else
        Call SendKick(Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdLOC_Click()
    Call SendRequestLocation
End Sub

Private Sub cmdMapeditor_Click()
    Call SendRequestEditMap
End Sub

Private Sub cmdMapreport_Click()
    Call SendData("mapreport" & END_CHAR)
End Sub

Private Sub cmdRespawn_Click()
    Call SendMapRespawn
End Sub

Private Sub cmdSetAccess_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Or LenB(Trim$(txtAccessLevel.Text)) = 0 Then
        Call GameMsgBox("You must first enter the playername and accesslevel to setaccess.")
    Else
        Call SendSetAccess(Trim$(txtPlayerName.Text), Val(txtAccessLevel.Text))
    End If
End Sub

Private Sub cmdWarpmeTo_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call GameMsgBox("You must first enter the playername to warp yourself to.")
    Else
        Call WarpMeTo(Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdWarpto_Click()
    If LenB(Trim$(txtMapNum.Text)) = 0 Then
        Call GameMsgBox("You must first enter the map number to warp to.")
    Else
        Call WarpTo(Trim$(txtMapNum.Text))
    End If
End Sub

Private Sub cmdWarptome_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call GameMsgBox("You must first enter the playername to warp to yourself.")
    Else
        Call WarpToMe(Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdSignEdit_Click()
    Call SendRequestEditSign
End Sub

    Public Sub LayoutGamePanels()
        Dim sidebar As Single, adminLeft As Single, requiredWidth As Single
        sidebar = 956
        picMapEditor.Left = Me.ScaleX(sidebar, vbPixels, Me.ScaleMode)
        picMapEditor.Top = Me.ScaleY(39, vbPixels, Me.ScaleMode)
        adminLeft = sidebar
        requiredWidth = 948
        If picMapEditor.Visible Then
            requiredWidth = sidebar + Me.ScaleX(picMapEditor.Width, Me.ScaleMode, vbPixels) + 8
            adminLeft = requiredWidth
        End If
        fraPlayer.Left = Me.ScaleX(adminLeft, vbPixels, Me.ScaleMode)
        fraMapNum.Left = fraPlayer.Left
        fraSpriteNum.Left = fraPlayer.Left
        fralvl1.Left = fraPlayer.Left
        fralvl2.Left = fraPlayer.Left
        fralvl3.Left = fraPlayer.Left
        fralvl4.Left = fraPlayer.Left
        If fraPlayer.Visible Then requiredWidth = adminLeft + Me.ScaleX(fraPlayer.Width, Me.ScaleMode, vbPixels) + 8
        Me.Width = Me.Width + Me.ScaleX(requiredWidth - Me.ScaleX(Me.ScaleWidth, Me.ScaleMode, vbPixels), vbPixels, vbTwips)
        CenterSign
    End Sub

    Public Sub CenterSign()
        picSign.Left = picScreen.Left + (picScreen.Width - picSign.Width) / 2
        picSign.Top = picScreen.Top + (picScreen.Height - picSign.Height) / 2
        If picSign.Visible Then picSign.ZOrder 0
    End Sub

    Private Sub picWebsite_Click()
        Dim address As String
        address = Trim$(WEBSITE)
        If Len(address) = 0 Then Exit Sub
        If LCase$(Left$(address, 7)) <> "http://" And LCase$(Left$(address, 8)) <> "https://" Then address = "https://" & address
        ShellExecute Me.hWnd, "open", address, vbNullString, vbNullString, 1
    End Sub

    Private Sub picGuild_Click()
        AddText "Your guild is " & GetPlayerGuild(MyIndex) & ".", HelpColor
    End Sub

    Private Sub picInv_DblClick()
        If InventoryClickedSlot > 0 Then SendUseItem InventoryClickedSlot
    End Sub

    Public Sub DrawInventoryGrid()
        Dim Bounds As RECT, Source As RECT
        Dim InventoryBackground As clsDX11Surface
        Dim Cell As Long, Slot As Long, ItemNum As Long, X As Long, Y As Long
        Dim SlotX As Long, SlotY As Long
        If DD_ItemSurf Is Nothing Then Exit Sub
        Set InventoryBackground = InventoryBackgroundPicture()
        If InventoryBackground Is Nothing Then Exit Sub
        If InventoryCanvas Is Nothing Then
            Set InventoryCanvas = New clsDX11Surface
            InventoryCanvas.Create 265, 354
        End If
        Bounds.Right = 265
        Bounds.Bottom = 354
        InventoryCanvas.Blt Bounds, InventoryBackground, Bounds
        For Cell = 0 To 34
            Slot = InventoryPage * 35 + Cell + 1
            If Slot <= MAX_INV Then
                ItemNum = GetPlayerInvItemNum(MyIndex, Slot)
                If ItemNum > 0 And ItemNum <= MAX_ITEMS Then
                    GetItemPictureRect Item(ItemNum).Pic, Source
                    InventoryCanvas.BltFast 26 + (Cell Mod 5) * 45, 30 + (Cell \ 5) * 45, DD_ItemSurf, Source, True
                End If
            End If
        Next Cell

        picInv.Cls
        InventoryCanvas.BltToDC picInv.hDC, Bounds, Bounds

        ' Draw a gray outline around every occupied inventory slot.
        For Cell = 0 To 34
            Slot = InventoryPage * 35 + Cell + 1
            If Slot <= MAX_INV Then
                ItemNum = GetPlayerInvItemNum(MyIndex, Slot)
                If ItemNum > 0 And ItemNum <= MAX_ITEMS Then
                    SlotX = 23 + (Cell Mod 5) * 45
                    SlotY = 27 + (Cell \ 5) * 45
                    picInv.Line (SlotX, SlotY)-(SlotX + 37, SlotY + 37), RGB(128, 128, 128), B
                End If
            End If
        Next Cell

        ' Replace the gray outline with yellow for the selected occupied slot.
        Cell = lstInv.ListIndex - InventoryPage * 35
        If Cell >= 0 And Cell < 35 Then
            Slot = InventoryPage * 35 + Cell + 1
            If Slot <= MAX_INV Then
                ItemNum = GetPlayerInvItemNum(MyIndex, Slot)
                If ItemNum > 0 And ItemNum <= MAX_ITEMS Then
                    X = 23 + (Cell Mod 5) * 45
                    Y = 27 + (Cell \ 5) * 45
                    picInv.Line (X, Y)-(X + 37, Y + 37), RGB(255, 230, 120), B
                End If
            End If
        End If

        lblInventoryPage.Caption = CStr(InventoryPage + 1) & "/" & CStr((MAX_INV + 34) \ 35)
        picInv.Refresh
    End Sub

    Private Function InventorySlotAt(ByVal X As Single, ByVal Y As Single) As Long
        Dim Column As Long, Row As Long, Slot As Long
        X = X - 23
        Y = Y - 27
        If X < 0 Or Y < 0 Or X >= 225 Or Y >= 315 Then Exit Function
        Column = Int(X / 45)
        Row = Int(Y / 45)
        If X - Column * 45 >= 38 Or Y - Row * 45 >= 38 Then Exit Function
        Slot = InventoryPage * 35 + Row * 5 + Column + 1
        If Slot <= MAX_INV Then InventorySlotAt = Slot
    End Function

    Private Sub picInv_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
        Dim Slot As Long
        Slot = InventorySlotAt(X, Y)
        InventoryClickedSlot = Slot
        If Button = vbLeftButton And Slot > 0 Then
            lstInv.ListIndex = Slot - 1
            DrawInventoryGrid
        End If
    End Sub

    Private Sub picInv_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
        Dim Slot As Long
        Slot = InventorySlotAt(X, Y)
        picInv.ToolTipText = vbNullString
        If Slot > 0 And Slot <= lstInv.ListCount Then picInv.ToolTipText = lstInv.List(Slot - 1)
    End Sub

    Private Sub lblInventoryPrevious_Click()
        If InventoryPage > 0 Then
            InventoryPage = InventoryPage - 1
            lstInv.ListIndex = InventoryPage * 35
        End If
    End Sub

    Private Sub lblInventoryNext_Click()
        If (InventoryPage + 1) * 35 < MAX_INV Then
            InventoryPage = InventoryPage + 1
            lstInv.ListIndex = InventoryPage * 35
        End If
    End Sub

    Private Sub lstInv_Click()
        If lstInv.ListIndex < 0 Then Exit Sub
        InventoryPage = lstInv.ListIndex \ 35
        DrawInventoryGrid
    End Sub
    Public Sub RefreshCharacterDetails()
        If MyIndex < 1 Then Exit Sub
        lblCharacterValue(0).Caption = Trim$(Class(GetPlayerClass(MyIndex)).name)
        lblCharacterValue(1).Caption = CStr(GetPlayerLevel(MyIndex))
        lblCharacterValue(2).Caption = "None"
        If GetPlayerGuild(MyIndex) > 0 Then lblCharacterValue(2).Caption = CStr(GetPlayerGuild(MyIndex))
        lblCharacterValue(3).Caption = GetPlayerHP(MyIndex) & " / " & GetPlayerMaxHP(MyIndex)
        lblCharacterValue(4).Caption = GetPlayerMP(MyIndex) & " / " & GetPlayerMaxMP(MyIndex)
        lblCharacterValue(5).Caption = GetPlayerExp(MyIndex) & " / " & GetPlayerNextLevel(MyIndex)
        lblCharacterValue(6).Caption = ChrW$(&H2014)
        lblCharacterValue(7).Caption = CStr(GetPlayerPOINTS(MyIndex))
        lblCharacterValue(8).Caption = CStr(GetPlayerSTR(MyIndex))
        lblCharacterValue(9).Caption = CStr(GetPlayerDEF(MyIndex))
        lblCharacterValue(9).ToolTipText = "Defense"
        lblCharacterValue(10).Caption = GetPlayerSP(MyIndex) & " / " & GetPlayerMaxSP(MyIndex)
        lblCharacterValue(11).Caption = CStr(GetPlayerSPEED(MyIndex))
        lblCharacterValue(11).ToolTipText = "Speed"
        lblCharacterValue(12).Caption = CStr(GetPlayerMAGI(MyIndex))
        lblCharacterValue(12).ToolTipText = "Magic"
        lblCharacterValue(13).Caption = ChrW$(&H2014)
        lblCharacterValue(6).ToolTipText = "Not tracked by this game"
        lblCharacterValue(13).ToolTipText = "Not tracked by this game"
        Dim TrainColor As Long
        If GetPlayerPOINTS(MyIndex) > 0 Then
            TrainColor = RGB(255, 255, 255)
        Else
            TrainColor = RGB(255, 0, 0)
        End If
        lblCharacterTrain(0).Caption = "+"
        lblCharacterTrain(1).Caption = "+"
        lblCharacterTrain(2).Caption = "+"
        lblCharacterTrain(3).Caption = "+"
        lblCharacterTrain(0).ForeColor = TrainColor
        lblCharacterTrain(1).ForeColor = TrainColor
        lblCharacterTrain(2).ForeColor = TrainColor
        lblCharacterTrain(3).ForeColor = TrainColor
    End Sub

    Public Sub RefreshSkills()
        Dim Page As Long, i As Long, Slot As Long, Num As Long
        Dim Canvas As New clsDX11Surface, Bounds As RECT, Source As RECT
        If lstSpells.ListIndex < 0 Then Exit Sub
        Page = lstSpells.ListIndex \ 8
        lblSkillsPage.Caption = "Page " & (Page + 1) & " / " & ((MAX_PLAYER_SPELLS + 7) \ 8)
        Canvas.Create 32, 32
        Bounds.Right = 32
        Bounds.Bottom = 32
        For i = 0 To 7
            Slot = Page * 8 + i + 1
            Num = 0
            If Slot <= MAX_PLAYER_SPELLS Then Num = Player(MyIndex).Spell(Slot)
            lblSkillName(i).Caption = "Empty"
            lblSkillName(i).ForeColor = RGB(220, 205, 180)
            Canvas.BltColorFill Bounds, RGB(102, 51, 51)
            If Num > 0 And Num <= MAX_SPELLS Then
                lblSkillName(i).Caption = Trim$(Spell(Num).name)
                If Not DD_SpellSurf Is Nothing Then
                    Source.Left = PIC_X
                    Source.Top = Spell(Num).Graphic * PIC_Y
                    Source.Right = Source.Left + PIC_X
                    Source.Bottom = Source.Top + PIC_Y
                    If Source.Top >= 0 And Source.Bottom <= DD_SpellSurf.Height Then Canvas.BltFast 0, 0, DD_SpellSurf, Source, True
                End If
            End If
            If Slot = lstSpells.ListIndex + 1 Then lblSkillName(i).ForeColor = RGB(255, 230, 120)
            picSkillIcon(i).ToolTipText = Slot & ": " & lblSkillName(i).Caption
            Canvas.BltToDC picSkillIcon(i).hDC, Bounds, Bounds
            picSkillIcon(i).Refresh
        Next i
        Num = Player(MyIndex).Spell(lstSpells.ListIndex + 1)
        lblSkillsDetails.Caption = "Empty spell slot."
        If Num > 0 And Num <= MAX_SPELLS Then
            lblSkillsDetails.Caption = Trim$(Spell(Num).name) & vbCrLf & vbCrLf & "Level: " & Spell(Num).LevelReq & vbCrLf & "Mana: " & Spell(Num).MPReq & vbCrLf & vbCrLf & "Double-click to memorize."
        End If
    End Sub

    Private Sub lstSpells_Click()
        RefreshSkills
    End Sub

    Private Sub lblSkillName_Click(index As Integer)
        Dim Slot As Long
        If lstSpells.ListIndex < 0 Then Exit Sub
        Slot = (lstSpells.ListIndex \ 8) * 8 + index
        If Slot < lstSpells.ListCount Then lstSpells.ListIndex = Slot
    End Sub

    Private Sub picSkillIcon_Click(index As Integer)
        lblSkillName_Click index
    End Sub

    Private Sub lblSkillName_DblClick(index As Integer)
        lblSkillName_Click index
        lstSpells_DblClick
    End Sub

    Private Sub picSkillIcon_DblClick(index As Integer)
        lblSkillName_DblClick index
    End Sub

    Private Sub lblSkillsNext_Click()
        Dim Slot As Long
        Slot = (lstSpells.ListIndex \ 8 + 1) * 8
        If Slot < lstSpells.ListCount Then lstSpells.ListIndex = Slot
    End Sub

    Private Sub lblSkillsPrevious_Click()
        Dim Slot As Long
        Slot = (lstSpells.ListIndex \ 8 - 1) * 8
        If Slot >= 0 Then lstSpells.ListIndex = Slot
    End Sub

    Private Sub cmdEditorAttribs2_Click()
        SSTab1.Tab = 1
        Picture6.Visible = False
        Picture5.Visible = True
        optLayers.Value = False
        optAttribs.Value = True
        EditorAttributeLayer = 2
    End Sub

Private Sub scrlTileset_Change()
    Call EditorChangeTileset(scrlTileset.Value)
End Sub
