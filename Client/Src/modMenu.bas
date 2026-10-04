Attribute VB_Name = "modMenu"
Option Explicit

Public Sub MoveForm(F As Form)
    ReleaseCapture
    SendMessage F.hWnd, WM_NCLBUTTONDOWN, 2, 0
End Sub

Public Sub NewAccountConnect()
    Dim Msg As String
    Dim i As Long

    If LenB(Trim$(frmMainMenu.txtNewAcctName.Text)) > 0 And LenB(Trim$(frmMainMenu.txtNewAcctPassword.Text)) > 0 Then
        Msg = Trim$(frmMainMenu.txtNewAcctName.Text)

        ' Prevent high ascii chars
        For i = 1 To Len(Msg)
            If Asc(Mid$(Msg, i, 1)) < 32 Or Asc(Mid$(Msg, i, 1)) > 126 Then
                Call GameMsgBox("You cannot use high ascii chars in your name, please re-enter.", vbOKOnly, GAME_NAME)
                frmMainMenu.txtNewAcctName.Text = vbNullString
                Exit Sub
            End If
        Next i

        Call MenuState(MENU_STATE_NEWACCOUNT)
    End If
End Sub

Public Sub LoginConnect()
    If LenB(Trim$(frmMainMenu.txtLoginName.Text)) > 0 And LenB(Trim$(frmMainMenu.txtLoginPassword.Text)) > 0 Then
        Call MenuState(MENU_STATE_LOGIN)
    ElseIf LenB(Trim$(frmMainMenu.txtLoginName.Text)) = 0 And LenB(Trim$(frmMainMenu.txtLoginPassword.Text)) = 0 Then
        Call GameMsgBox("Please enter your login name and password!", vbOKOnly)
    ElseIf LenB(Trim$(frmMainMenu.txtLoginName.Text)) = 0 Then
        Call GameMsgBox("Please enter your login name!", vbOKOnly)
    ElseIf LenB(Trim$(frmMainMenu.txtLoginPassword.Text)) = 0 Then
        Call GameMsgBox("Please enter your password!", vbOKOnly)
    End If
End Sub

Public Sub AddCharClick()
    Dim Msg As String
    Dim i As Long

    If LenB(Trim$(frmMainMenu.txtNewCharName.Text)) > 0 Then
        Msg = Trim$(frmMainMenu.txtNewCharName.Text)

        ' Prevent high ascii chars
        For i = 1 To Len(Msg)
            If Asc(Mid$(Msg, i, 1)) < 32 Or Asc(Mid$(Msg, i, 1)) > 126 Then
                Call GameMsgBox("You cannot use high ascii chars in your name, please reenter.", vbOKOnly, GAME_NAME)
                frmMainMenu.txtNewCharName.Text = vbNullString
                Exit Sub
            End If
        Next i

        Call MenuState(MENU_STATE_ADDCHAR)
    End If
End Sub

Public Sub CloseSideMenu()
    ' Close Mirage Menus
    With frmMainGame
        .picGuildPanel.Visible = False
        .picWho.Visible = False
        .picPlayerList.Visible = False
        .lstPlayers.Visible = False
        .picPM.Visible = False
        .picMnuGear.Visible = False
        .picPlayerSpells.Visible = False
        .picInv.Visible = False
        .picKeepNotes.Visible = False
        .picMnuTrain.Visible = False
        .picLiveStats.Visible = False
    End With
End Sub


Public Sub MenuState(ByVal State As Long)
' ****************************************************************
' * WHEN    WHO    WHAT
' * ----    ---    ----
' * 07/12/2005  Shannara   Added website constant.
' ****************************************************************

    frmSendGetData.Visible = True
    Call SetStatus("Connecting to server...")
    Select Case State
        Case MENU_STATE_NEWACCOUNT
            frmMainMenu.SetMenuVisible "mnuNewAccount", False
            If ConnectToServer = True Then
                Call SetStatus("Connected, sending new account information...")
                Call SendNewAccount(frmMainMenu.txtNewAcctName.Text, frmMainMenu.txtNewAcctPassword.Text, ENC_KEY)
            End If

        Case MENU_STATE_LOGIN
            frmMainMenu.SetMenuVisible "mnuLogin", False
            If ConnectToServer = True Then
                Call SetStatus("Connected, sending login information...")
                Call SendLogin(frmMainMenu.txtLoginName.Text, frmMainMenu.txtLoginPassword.Text, ENC_KEY)
            End If

        Case MENU_STATE_NEWCHAR
            frmMainMenu.SetMenuVisible "mnuChars", False
            Call SetStatus("Connected, getting available classes...")
            Call SendGetClasses

        Case MENU_STATE_ADDCHAR
            frmMainMenu.SetMenuVisible "mnuNewCharacter", False
            If ConnectToServer = True Then
                Call SetStatus("Connected, sending character addition data...")
                If CurrentSex = 1 Then
                    Call SendAddChar(frmMainMenu.txtNewCharName, 0, CurrentClass, frmMainMenu.lstChars.ListIndex + 1)
                Else
                    Call SendAddChar(frmMainMenu.txtNewCharName, 1, CurrentClass, frmMainMenu.lstChars.ListIndex + 1)
                End If
            End If

        Case MENU_STATE_DELCHAR
            frmMainMenu.SetMenuVisible "mnuChars", False
            If ConnectToServer = True Then
                Call SetStatus("Connected, sending character deletion request...")
                Call SendDelChar(frmMainMenu.lstChars.ListIndex + 1)
            End If

        Case MENU_STATE_USECHAR
            frmMainMenu.SetMenuVisible "mnuChars", False
            frmMainMenu.Visible = False
            If ConnectToServer = True Then
                Call EnsureGameGraphics
                Call GetGameName
                Call GetGameSite
                Call GetGameMaxes

                Call SetStatus("Connected, sending char data...")
                Call SendUseChar(frmMainMenu.lstChars.ListIndex + 1)
                Call Unload(frmMainMenu)
                frmMainGame.lblGameName.Caption = Trim$(GAME_NAME)
            End If
    End Select

    If Not IsConnected Then
        ReturnToLoginMenu
    End If
End Sub


Public Sub ReturnToLoginMenu()
    Dim openForm As Form
    If InGame Then Exit Sub
    frmSendGetData.Visible = False
    For Each openForm In VB.Forms
        If StrComp(openForm.Name, "frmAlert", vbTextCompare) = 0 Then openForm.Hide
    Next
    PlayerBuffer = vbNullString
    frmMainMenu.ShowMenuHome
    frmMainMenu.Visible = True
End Sub