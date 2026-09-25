VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "richtx32.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Begin VB.Form frmMainGame 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   Caption         =   "Playerworlds"
   ClientHeight    =   9120
   ClientLeft      =   3540
   ClientTop       =   1920
   ClientWidth     =   12000
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
   Picture         =   "frmMirage.frx":030A
   ScaleHeight     =   608
   ScaleMode       =   0  'User
   ScaleWidth      =   800
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
      Left            =   120
      ScaleHeight     =   593
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   255
      TabIndex        =   2
      Top             =   120
      Visible         =   0   'False
      Width           =   3855
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
      Left            =   255
      Picture         =   "frmMirage.frx":1BD7A
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   159
      Top             =   3900
      Visible         =   0   'False
      Width           =   3720
      Begin VB.PictureBox Equip 
         AutoRedraw      =   -1  'True
         BackColor       =   &H80000007&
         BorderStyle     =   0  'None
         Height          =   480
         Index           =   3
         Left            =   120
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   163
         Top             =   3180
         Width           =   480
      End
      Begin VB.PictureBox Equip 
         AutoRedraw      =   -1  'True
         BackColor       =   &H80000007&
         BorderStyle     =   0  'None
         Height          =   480
         Index           =   2
         Left            =   120
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   162
         Top             =   615
         Width           =   480
      End
      Begin VB.PictureBox Equip 
         AutoRedraw      =   -1  'True
         BackColor       =   &H80000007&
         BorderStyle     =   0  'None
         Height          =   480
         Index           =   1
         Left            =   120
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   161
         Top             =   2325
         Width           =   480
      End
      Begin VB.PictureBox Equip 
         AutoRedraw      =   -1  'True
         BackColor       =   &H80000007&
         BorderStyle     =   0  'None
         Height          =   480
         Index           =   0
         Left            =   120
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   160
         Top             =   1455
         Width           =   480
      End
      Begin VB.Label lblGearStr 
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1680
         TabIndex        =   167
         Top             =   2760
         Width           =   975
      End
      Begin VB.Label lblGearDur 
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1680
         TabIndex        =   166
         Top             =   2325
         Width           =   1275
      End
      Begin VB.Label lblGearName 
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   240
         Left            =   1680
         TabIndex        =   165
         Top             =   1920
         Width           =   1935
      End
   End
   Begin VB.CheckBox chkGUI 
      Height          =   375
      Index           =   0
      Left            =   2040
      TabIndex        =   157
      Top             =   9240
      Width           =   375
   End
   Begin VB.TextBox txtGUI 
      Height          =   375
      Index           =   0
      Left            =   1560
      TabIndex        =   156
      Top             =   9240
      Width           =   375
   End
   Begin VB.CommandButton cmdGUI 
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
      Visible         =   0   'False
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
      Left            =   255
      Picture         =   "frmMirage.frx":4C9E2
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   109
      Top             =   3900
      Visible         =   0   'False
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
         Left            =   120
         TabIndex        =   113
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblPlayerPoints 
         BackStyle       =   0  'Transparent
         Caption         =   "Points"
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
         Left            =   1920
         TabIndex        =   112
         Top             =   645
         Width           =   735
      End
      Begin VB.Label lblTrainClose 
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
         TabIndex        =   110
         Top             =   3360
         Width           =   975
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
      Left            =   255
      Picture         =   "frmMirage.frx":56977
      ScaleHeight     =   259.179
      ScaleMode       =   0  'User
      ScaleWidth      =   241.192
      TabIndex        =   27
      Top             =   3900
      Visible         =   0   'False
      Width           =   3720
      Begin RichTextLib.RichTextBox Notetext 
         Height          =   2895
         Left            =   285
         TabIndex        =   31
         Top             =   630
         Width           =   2295
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
      Begin VB.Label lblNoteClose 
         BackStyle       =   0  'Transparent
         Height          =   255
         Left            =   2640
         TabIndex        =   30
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblNoteSave 
         BackStyle       =   0  'Transparent
         Height          =   375
         Left            =   2640
         TabIndex        =   29
         Top             =   2760
         Width           =   975
      End
   End
   Begin VB.PictureBox picInv 
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
      Left            =   255
      Picture         =   "frmMirage.frx":5ACF1
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   11
      Top             =   3900
      Visible         =   0   'False
      Width           =   3720
      Begin VB.PictureBox picItem 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         ForeColor       =   &H80000008&
         Height          =   480
         Left            =   1125
         ScaleHeight     =   32
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   81
         ToolTipText     =   "This is an image of the selected item in your inventory."
         Top             =   495
         Width           =   480
      End
      Begin VB.ListBox lstInv 
         Appearance      =   0  'Flat
         BackColor       =   &H00800000&
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
         Height          =   2130
         ItemData        =   "frmMirage.frx":640A4
         Left            =   240
         List            =   "frmMirage.frx":640A6
         TabIndex        =   12
         Top             =   1200
         Width           =   3255
      End
      Begin VB.Label lblCancel 
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
         TabIndex        =   15
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblDropItem 
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
         Height          =   255
         Left            =   1680
         TabIndex        =   14
         Top             =   600
         Width           =   1095
      End
      Begin VB.Label lblUseItem 
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
         Height          =   255
         Left            =   120
         TabIndex        =   13
         Top             =   600
         Width           =   855
      End
   End
   Begin VB.PictureBox picPlayerSpells 
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
      Left            =   255
      Picture         =   "frmMirage.frx":640A8
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   16
      Top             =   3900
      Visible         =   0   'False
      Width           =   3720
      Begin VB.ListBox lstSpells 
         Appearance      =   0  'Flat
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
         Height          =   2130
         ItemData        =   "frmMirage.frx":6DB5B
         Left            =   180
         List            =   "frmMirage.frx":6DB5D
         TabIndex        =   17
         Top             =   1200
         Width           =   3375
      End
      Begin VB.Label lblForget 
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
         Left            =   1320
         TabIndex        =   94
         Top             =   3360
         Width           =   1095
      End
      Begin VB.Label lblCast 
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
         Left            =   120
         TabIndex        =   19
         Top             =   3360
         Width           =   975
      End
      Begin VB.Label lblSpellsCancel 
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
         TabIndex        =   18
         Top             =   3360
         Width           =   975
      End
   End
   Begin VB.PictureBox picLiveStats 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   3990
      Left            =   255
      Picture         =   "frmMirage.frx":6DB5F
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   82
      Top             =   3900
      Visible         =   0   'False
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
      Left            =   6360
      Picture         =   "frmMirage.frx":77871
      ScaleHeight     =   119
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   183
      TabIndex        =   42
      Top             =   3000
      Visible         =   0   'False
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
      Left            =   12000
      TabIndex        =   77
      Top             =   720
      Visible         =   0   'False
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
      Left            =   12000
      TabIndex        =   75
      Top             =   0
      Visible         =   0   'False
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
      Left            =   12000
      TabIndex        =   73
      Top             =   1440
      Visible         =   0   'False
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
      Left            =   12000
      TabIndex        =   69
      Top             =   7080
      Visible         =   0   'False
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
      Height          =   1707
      Left            =   12000
      TabIndex        =   62
      Top             =   5400
      Visible         =   0   'False
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
      Left            =   12000
      TabIndex        =   60
      Top             =   2160
      Visible         =   0   'False
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
      Left            =   12000
      TabIndex        =   52
      Top             =   2745
      Visible         =   0   'False
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
      Height          =   1455
      Left            =   4200
      TabIndex        =   1
      Top             =   7080
      Width           =   7575
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
      ForeColor       =   &H00000000&
      Height          =   5760
      Left            =   4140
      ScaleHeight     =   384
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   512
      TabIndex        =   0
      Top             =   1245
      Width           =   7680
   End
   Begin VB.PictureBox shpSP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   225
      Left            =   9015
      Picture         =   "frmMirage.frx":7A0EA
      ScaleHeight     =   225
      ScaleWidth      =   2295
      TabIndex        =   34
      Top             =   960
      Width           =   2295
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
      Height          =   75
      Left            =   5910
      Picture         =   "frmMirage.frx":7A1B3
      ScaleHeight     =   75
      ScaleWidth      =   5400
      TabIndex        =   38
      Top             =   795
      Width           =   5400
   End
   Begin VB.PictureBox shpMP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   225
      Left            =   6600
      Picture         =   "frmMirage.frx":7A588
      ScaleHeight     =   225
      ScaleWidth      =   2325
      TabIndex        =   37
      Top             =   960
      Width           =   2325
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
      Height          =   225
      Left            =   6600
      Picture         =   "frmMirage.frx":7A982
      ScaleHeight     =   225
      ScaleWidth      =   2325
      TabIndex        =   36
      Top             =   960
      Width           =   2325
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
      Height          =   75
      Left            =   5910
      Picture         =   "frmMirage.frx":7AA93
      ScaleHeight     =   75
      ScaleWidth      =   5400
      TabIndex        =   39
      Top             =   795
      Width           =   5400
   End
   Begin VB.PictureBox Picture2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   225
      Left            =   9015
      Picture         =   "frmMirage.frx":7AB49
      ScaleHeight     =   225
      ScaleWidth      =   2295
      TabIndex        =   35
      Top             =   960
      Width           =   2295
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
      Left            =   4170
      MousePointer    =   1  'Arrow
      TabIndex        =   108
      Top             =   8535
      Width           =   7620
   End
   Begin VB.PictureBox shpHP 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   225
      Left            =   4170
      Picture         =   "frmMirage.frx":7AC54
      ScaleHeight     =   225
      ScaleWidth      =   2340
      TabIndex        =   32
      Top             =   960
      Width           =   2340
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
      Height          =   225
      Left            =   4170
      Picture         =   "frmMirage.frx":7AD24
      ScaleHeight     =   225
      ScaleWidth      =   2340
      TabIndex        =   33
      Top             =   960
      Width           =   2340
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
      Left            =   255
      Picture         =   "frmMirage.frx":7AE36
      ScaleHeight     =   266
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   248
      TabIndex        =   114
      Top             =   3900
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
      Height          =   735
      Left            =   1335
      TabIndex        =   164
      ToolTipText     =   "View your current equipment."
      Top             =   1620
      Width           =   540
   End
   Begin VB.Label lblGUI 
      Height          =   375
      Index           =   0
      Left            =   1080
      TabIndex        =   155
      Top             =   9240
      Width           =   375
   End
   Begin VB.Label Label4 
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
      Height          =   255
      Left            =   8100
      TabIndex        =   125
      Top             =   240
      Width           =   2445
   End
   Begin VB.Label lblPlayers 
      BackStyle       =   0  'Transparent
      Height          =   705
      Left            =   1350
      TabIndex        =   119
      ToolTipText     =   "View the list of online players."
      Top             =   2490
      Width           =   525
   End
   Begin VB.Label cmdMinimize 
      BackStyle       =   0  'Transparent
      Height          =   270
      Left            =   11280
      TabIndex        =   107
      Top             =   120
      Width           =   270
   End
   Begin VB.Label picOptions 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   720
      TabIndex        =   106
      ToolTipText     =   "Change user settings."
      Top             =   8520
      Width           =   1335
   End
   Begin VB.Label lblGameName 
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
      Height          =   705
      Left            =   3120
      TabIndex        =   28
      ToolTipText     =   "Edit your player notes."
      Top             =   2490
      Width           =   585
   End
   Begin VB.Label picBugReport 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   2160
      TabIndex        =   26
      ToolTipText     =   "Report a Bug!"
      Top             =   8520
      Width           =   1335
   End
   Begin VB.Label picQuit 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   11610
      TabIndex        =   25
      ToolTipText     =   "Quit the Game"
      Top             =   120
      Width           =   255
   End
   Begin VB.Label picStats 
      BackStyle       =   0  'Transparent
      Height          =   735
      Left            =   495
      TabIndex        =   24
      ToolTipText     =   "View your current stats."
      Top             =   1620
      Width           =   525
   End
   Begin VB.Label picTrain 
      BackStyle       =   0  'Transparent
      Height          =   705
      Left            =   2250
      TabIndex        =   23
      ToolTipText     =   "Train your character."
      Top             =   2490
      Width           =   555
   End
   Begin VB.Label picInventory 
      BackStyle       =   0  'Transparent
      Height          =   735
      Left            =   3150
      TabIndex        =   22
      ToolTipText     =   "View your inventory."
      Top             =   1620
      Width           =   510
   End
   Begin VB.Label picSpells 
      BackStyle       =   0  'Transparent
      Height          =   735
      Left            =   2250
      TabIndex        =   21
      ToolTipText     =   "View your spells."
      Top             =   1620
      Width           =   510
   End
   Begin VB.Label picTrade 
      BackStyle       =   0  'Transparent
      Height          =   705
      Left            =   510
      TabIndex        =   20
      Top             =   2490
      Width           =   525
   End
End
Attribute VB_Name = "frmMainGame"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim KeyShift As Boolean
Private Ammount As Long
Dim SpellMemorized As Long
Public clsFormSkin As New clsFormSkin

Private Sub cmdFill_Click()
    Dim Y As Long
    Dim X As Long

    For Y = 0 To MAX_MAPY
        For X = 0 To MAX_MAPX
            If frmMainGame.optLayers.Value = True Then
                With Map.Tile(X, Y)
                    If frmMainGame.optGround.Value = True Then .Ground = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optMask.Value = True Then .Mask = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optAnim.Value = True Then .Anim = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optMask2.Value = True Then .Mask2 = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optM2Anim.Value = True Then .M2Anim = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optFringe.Value = True Then .Fringe = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optFAnim.Value = True Then .FAnim = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optFringe2.Value = True Then .Fringe2 = EditorTileY * 7 + EditorTileX
                    If frmMainGame.optF2Anim.Value = True Then .F2Anim = EditorTileY * 7 + EditorTileX
                End With
                BltMap
            ElseIf frmMainGame.optAttribs.Value = True Then
                With Map.Tile(X, Y)
                    If frmMainGame.optBlocked.Value = True Then .Type = TILE_TYPE_BLOCKED
                    If frmMainGame.optWarp.Value = True Then .Type = TILE_TYPE_WARP
                    If frmMainGame.optKill.Value = True Then .Type = TILE_TYPE_KILL
                    If frmMainGame.optItem.Value = True Then .Type = TILE_TYPE_ITEM
                    If frmMainGame.optHeal.Value = True Then .Type = TILE_TYPE_HEAL
                    If frmMainGame.optNpcAvoid.Value = True Then .Type = TILE_TYPE_NPCAVOID
                    If frmMainGame.optKey.Value = True Then .Type = TILE_TYPE_KEY
                    If frmMainGame.optKeyOpen.Value = True Then .Type = TILE_TYPE_KEYOPEN
                    If frmMainGame.optDoor.Value = True Then .Type = TILE_TYPE_DOOR
                    If frmMainGame.optSign.Value = True Then .Type = TILE_TYPE_SIGN
                    If frmMainGame.optSprite.Value = True Then .Type = TILE_TYPE_SPRITE
                End With
            End If
        Next X
    Next Y
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

    ' Dim result As Long
    ' result = SetWindowLong(txtChat.hWnd, GWL_EXSTYLE, WS_EX_TRANSPARENT)
    ' result = SetWindowLong(txtMyTextBox.hWnd, GWL_EXSTYLE, WS_EX_TRANSPARENT)
    
    Notetext.BackColor = RGB(174, 222, 245)
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
            If MsgBox("Are you sure you want to forget the spell " & vbQuote & Trim$(Spell(Player(MyIndex).Spell(lstSpells.ListIndex + 1)).name) & vbQuote & "?", vbYesNo) = vbNo Then Exit Sub

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
    Call SendData("usestatpoint" & SEP_CHAR & cmbStat.ListIndex & END_CHAR)
    If Val(lblPlayerPoints.Caption) > 0 Then
        lblPlayerPoints.Caption = STR$(Val(lblPlayerPoints.Caption) - 1)
    End If
End Sub

Private Sub lblTrainClose_Click()
    picMnuTrain.Visible = False
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
    Call EditorChooseTile(Button, Shift, X, Y)
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
    Call HandleKeypresses(KeyAscii)
End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    Call CheckInput(1, KeyCode, Shift)
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
    Call CheckInput(0, KeyCode, Shift)
    If KeyCode = vbKeyF1 Then
        If frmMainGame.Width = 13545 Then
            frmMainGame.fraPlayer.Visible = False
            frmMainGame.fraMapNum.Visible = False
            frmMainGame.fraSpriteNum.Visible = False
            frmMainGame.fralvl1.Visible = False
            frmMainGame.fralvl2.Visible = False
            frmMainGame.fralvl3.Visible = False
            frmMainGame.fralvl4.Visible = False
            frmMainGame.Width = 12120
        ' frmMainGame.ScaleWidth = 800
        Else
            Call AdminPanel
        End If
    ElseIf KeyCode = vbKeyInsert Then
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

Private Sub picInv_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    SOffsetX = X
    SOffsetY = Y
End Sub

Private Sub picInv_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
' Call MovePicture(frmMainGame.picInv, Button, Shift, X, Y)
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
    Call MovePicture(frmMainGame.picSign, Button, Shift, X, Y)
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

Private Sub txtMyTextBox_GotFocus()
    ' TxtHasFocus = True
    Call SetFocusOnGame
End Sub

Private Sub txtMyTextBox_LostFocus()
    TxtHasFocus = False
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
    picLiveStats.Visible = True
End Sub

Private Sub picGear_Click()
    Call CloseSideMenu
    picMnuGear.Visible = True
    BltPlayerGear
End Sub

Private Sub picTrain_Click()
    Call CloseSideMenu
    Call SendData("getlivestats" & END_CHAR)
    lblPlayerPoints.Caption = GetPlayerPOINTS(MyIndex)
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
    txtMyTextBox.SetFocus
End Sub

Private Sub Label8_Click()
    If picLiveStats.Visible = True Then picLiveStats.Visible = False
End Sub




Private Sub lstInv_Click()
    If Player(MyIndex).Inv(lstInv.ListIndex + 1).Num <> 0 Then
        Call BltPlayerInvItem
    Else
        picItem.Refresh
    End If
End Sub

Private Sub lblexit_Click()
    picSign.Visible = False
End Sub

Private Sub lblNoteClose_Click()
    picKeepNotes.Visible = False
End Sub

Private Sub lblNoteSave_Click()
    Dim iFileNum As Integer

    ' Get a free file handle
    iFileNum = FreeFile

    ' If the file is not there, one will be created
    ' If the file does exist, this one will
    ' overwrite it.
    Open App.Path & DATA_PATH & "notes.txt" For Output As iFileNum

    Print #iFileNum, Notetext.Text

    Close iFileNum
End Sub

Private Sub lstInv_DblClick()
    Call SendUseItem(frmMainGame.lstInv.ListIndex + 1)
End Sub

Private Sub lstSpells_DblClick()
    If Player(MyIndex).Spell(lstSpells.ListIndex + 1) > 0 Then
        SpellMemorized = lstSpells.ListIndex + 1
        Call AddText("Successfully memorized spell!", White)
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
        Call MsgBox("You must first enter a playername to ban.")
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
' Call MsgBox("You must first enter a playername to kill.")
' Else
' Call KillPlayer(Trim$(txtPlayerName.Text))
' End If
' End Sub

Private Sub cmdNpcEditor_Click()
    Call SendRequestEditNpc
End Sub

Private Sub cmdSetSprite_Click()
    If LenB(txtSpriteNum.Text) = 0 Then
        Call MsgBox("You must first enter a sprite number to set sprite.")
    Else
        Call SendSetSprite(Trim$(txtSpriteNum.Text))
    End If
End Sub

Private Sub cmdPlayerSprite_Click()
    If LenB(Trim$(txtSpriteNum.Text)) = 0 Or LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call MsgBox("You must first enter a sprite number and player name to set the player's sprite.")
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
        Call MsgBox("You must first enter a playername to kick.")
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
        Call MsgBox("You must first enter the playername and accesslevel to setaccess.")
    Else
        Call SendSetAccess(Trim$(txtPlayerName.Text), Val(txtAccessLevel.Text))
    End If
End Sub

Private Sub cmdWarpmeTo_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call MsgBox("You must first enter the playername to warp yourself to.")
    Else
        Call WarpMeTo(Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdWarpto_Click()
    If LenB(Trim$(txtMapNum.Text)) = 0 Then
        Call MsgBox("You must first enter the map number to warp to.")
    Else
        Call WarpTo(Trim$(txtMapNum.Text))
    End If
End Sub

Private Sub cmdWarptome_Click()
    If LenB(Trim$(txtPlayerName.Text)) = 0 Then
        Call MsgBox("You must first enter the playername to warp to yourself.")
    Else
        Call WarpToMe(Trim$(txtPlayerName.Text))
    End If
End Sub

Private Sub cmdSignEdit_Click()
    Call SendRequestEditSign
End Sub
