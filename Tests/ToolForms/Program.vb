Imports Eto.Forms
Imports System.Text.Json.Nodes
Imports XtremeWorlds.Tools
Imports XtremeWorlds.Client.Tools

Module Program
    <STAThread>
    Sub Main(args As String())
        Dim app As New Application(Eto.Platforms.Wpf)
        Dim kinds = {"item", "npc", "shop", "spell", "sign", "arrow", "class", "book", "quest", "emote", "map"}
        Dim factories As Func(Of ToolForm)() = {Function() New frmItemEditor(), Function() New frmNpcEditor(), Function() New frmShopEditor(), Function() New frmSpellEditor(), Function() New frmSignEditor(), Function() New frmArrowEditor(), Function() New frmClassEditor(), Function() New frmBookEditor(), Function() New frmQuestEditor(), Function() New frmEmoticonEditor(), Function() New frmMapEditor()}
        For i = 0 To kinds.Length - 1
            Using form = factories(i)()
                Dim data = ToolService.Defaults(kinds(i), New JsonObject())
                If kinds(i) = "emote" Then data("Command") = JsonValue.Create("/smile")
                Dim record As New ToolRecord With {.Kind = kinds(i), .Id = If(kinds(i) = "class", 0, 1), .Data = data}
                record.Catalogs("quest") = New List(Of ContentSlot) From {New ContentSlot With {.Id = 7, .Name = "Quest seven"}}
                record.Catalogs("book") = New List(Of ContentSlot) From {New ContentSlot With {.Id = 2, .Name = "Book two"}}
                record.Catalogs("arrow") = New List(Of ContentSlot) From {New ContentSlot With {.Id = 1, .Name = "Arrow one"}}
                form.LoadRecord(record)
                If args.Length > 0 Then Render(form, System.IO.Path.Combine(args(0), kinds(i) & ".png"))
                Dim snapshot = form.CollectRecord()
                If snapshot.Id <> record.Id OrElse ToolSchema.Validate(snapshot.Kind, snapshot.Id, snapshot.Data) IsNot Nothing Then Throw New Exception("Round trip failed: " & kinds(i))
                If kinds(i) = "npc" Then
                    Dim npc = DirectCast(form, frmNpcEditor)
                    npc.cmbBehavior.SelectedIndex = 5
                    npc.cmbQuestId.SelectedKey = "7"
                    If ToolSchema.Number(npc.CollectRecord().Data, "ShopCall") <> 7 Then Throw New Exception("NPC quest IDs were treated as indices.")
                    npc.scrlNum.Value = 0
                    If npc.lblItemName.Text <> "None" Then Throw New Exception("NPC drop label retained a stale name.")
                End If
                If kinds(i) = "item" Then
                    Dim item = DirectCast(form, frmItemEditor)
                    item.cmbType.SelectedIndex = 15 : item.scrlBook.Value = 2
                    If Not item.fraBook.Visible OrElse ToolSchema.Number(item.CollectRecord().Data, "Data1") <> 2 Then Throw New Exception("Book items were not linked.")
                End If
                If kinds(i) = "spell" Then
                    Dim spell = DirectCast(form, frmSpellEditor)
                    spell.cmbDelivery.SelectedIndex = 1 : spell.cmbArrow.SelectedKey = "1" : spell.txtCastRange.Text = "32"
                    If ToolSchema.Number(spell.CollectRecord().Data, "Arrow") <> 1 Then Throw New Exception("Spell delivery was lost.")
                End If
                Dim saved As ToolRecord = Nothing
                AddHandler form.SaveRequested, Sub(value) saved = value
                form.Save()
                If saved Is Nothing OrElse Not form.Saving Then Throw New Exception("Save was not submitted.")
                form.SaveComplete(999)
                If Not form.Saving Then Throw New Exception("Wrong save acknowledgement released the editor.")
                form.Disconnect()
            End Using
            Console.WriteLine("PASS native Eto " & kinds(i) & " editor")
        Next
        Using admin As New frmAdminPanel()
            admin.ApplyAccess(4)
            If args.Length > 0 Then Render(admin, System.IO.Path.Combine(args(0), "admin.png"))
            admin.ApplyAccess(1)
            If Not admin.fralvl1.Visible OrElse admin.fralvl3.Visible Then Throw New Exception("Admin controls ignored access.")
        End Using
        Using index As New frmIndex()
            If index.lstIndex Is Nothing Then Throw New Exception("Missing index control.")
        End Using
        Console.WriteLine("PASS all 13 Eto form constructors, bindings, and save lifecycle checks")
    End Sub
    Private Sub PrepareLayout(control As Control)
        Dim dynamic = TryCast(control, DynamicLayout)
        If dynamic IsNot Nothing Then dynamic.Create()
        Dim container = TryCast(control, Container)
        If container IsNot Nothing Then
            For Each child In container.Children.ToArray()
                PrepareLayout(child)
            Next
        End If
    End Sub
    Private Sub Render(form As ToolForm, imagePath As String)
        PrepareLayout(form.Content)
        Dim window = DirectCast(form.ControlObject, System.Windows.Window)
        Dim content = DirectCast(window.Content, System.Windows.FrameworkElement)
        Dim size As New System.Windows.Size(form.ClientSize.Width, form.ClientSize.Height)
        content.Measure(size)
        content.Arrange(New System.Windows.Rect(size))
        content.UpdateLayout()
        Dim bitmap As New System.Windows.Media.Imaging.RenderTargetBitmap(CInt(size.Width), CInt(size.Height), 96, 96, System.Windows.Media.PixelFormats.Pbgra32)
        Dim background As New System.Windows.Media.DrawingVisual()
        Using drawing = background.RenderOpen()
            drawing.DrawRectangle(System.Windows.Media.Brushes.WhiteSmoke, Nothing, New System.Windows.Rect(size))
        End Using
        bitmap.Render(background)
        bitmap.Render(content)
        Dim encoder As New System.Windows.Media.Imaging.PngBitmapEncoder()
        encoder.Frames.Add(System.Windows.Media.Imaging.BitmapFrame.Create(bitmap))
        System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(imagePath))
        Using stream = System.IO.File.Create(imagePath)
            encoder.Save(stream)
        End Using
    End Sub
End Module