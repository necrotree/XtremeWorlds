Imports System.Text.Json.Nodes
Imports System.Threading.Tasks
Imports XtremeWorlds.Tools

Module Program
    Private checks As Integer
    Private Sub Check(condition As Boolean, message As String)
        If Not condition Then Throw New Exception(message)
        checks += 1
    End Sub
    Sub Main()
        Run().GetAwaiter().GetResult()
        Console.WriteLine("PASS " & checks & " tool protocol and map behavior checks")
    End Sub
    Private Async Function Run() As Task
        Dim store As New Dictionary(Of String, Dictionary(Of Integer, JsonObject))
        Dim limits As New Dictionary(Of String, Integer)
        For Each kind In {"item", "npc", "shop", "spell", "sign", "arrow", "class", "book", "quest", "emote", "map"}
            limits(kind) = 8
            store(kind) = New Dictionary(Of Integer, JsonObject)
        Next
        Dim actorAccess = 4, writes = 0
        Dim replies As New List(Of (Command As String, Fields As Object()))
        Dim service As New ToolService(Function(id) actorAccess,
            Function(kind) Task.FromResult(store(kind)),
            Function(kind, id, data)
                store(kind)(id) = DirectCast(data.DeepClone(), JsonObject)
                writes += 1
                Return Task.CompletedTask
            End Function,
            Sub(id, command, arguments) replies.Add((command, arguments)), limits)
        Await service.HandleAsync(1, {"requesttool", "book", "list1"})
        Check(replies.Count = 1 AndAlso replies.Last().Command = "toolindex", "Book index missing.")
        Dim slots = ToolWire.Decode(Of List(Of ContentSlot))(CStr(replies.Last().Fields(1)))
        Check(slots.Count = 8 AndAlso slots(0).Id = 1 AndAlso slots.Last().Id = 8, "Empty content slots omitted.")
        Await service.HandleAsync(1, {"requesttool", "class", "list0"})
        slots = ToolWire.Decode(Of List(Of ContentSlot))(CStr(replies.Last().Fields(1)))
        Check(slots(0).Id = 0, "Class slot zero omitted.")
        actorAccess = 0
        Await service.HandleAsync(1, {"edittool", "book", "1", "unauthorized"})
        Check(replies.Last().Command = "toolerror" AndAlso writes = 0, "Unauthorized editor access was allowed.")
        actorAccess = 2
        Await service.HandleAsync(1, {"edittool", "class", "0", "creator"})
        Check(replies.Last().Command = "toolerror", "Class editing did not require developer access.")
        actorAccess = 4
        For Each kind In limits.Keys
            Dim id = If(kind = "class", 0, 1)
            Await service.HandleAsync(1, {"edittool", kind, id.ToString(), "load-" & kind})
            Check(replies.Last().Command = "toolrecord", "Definition missing for " & kind)
            Dim record = ToolWire.Decode(Of ToolRecord)(CStr(replies.Last().Fields(2)))
            Check(record.Id = id AndAlso record.Kind = kind, "Record identity lost.")
            For Each field In ToolSchema.Fields(kind)
                If field.Kind = "text" Then record.Data(field.Key) = JsonValue.Create(If(field.Key = "Command", "/smile", "Some text"))
            Next
            Select Case kind
                Case "item"
                    record.Data("Type") = JsonValue.Create(15)
                    record.Data("Data1") = JsonValue.Create(2) : record.Data("Data2") = JsonValue.Create(0) : record.Data("Data3") = JsonValue.Create(0)
                Case "npc"
                    record.Data("Behavior") = JsonValue.Create(5) : record.Data("ShopCall") = JsonValue.Create(7)
                    record.Data("DropItemValue") = JsonValue.Create(Integer.MaxValue)
                Case "spell"
                    record.Data("Data1") = JsonValue.Create(0) : record.Data("Data2") = JsonValue.Create(0) : record.Data("Data3") = JsonValue.Create(0)
                    record.Data("DeliveryMode") = JsonValue.Create(1) : record.Data("Arrow") = JsonValue.Create(1) : record.Data("CastRange") = JsonValue.Create(32)
                Case "sign"
                    record.Data("Background") = JsonValue.Create(0)
                Case "book"
                    record.Data("NextBook") = JsonValue.Create(2)
                    record.Data("Quest") = JsonValue.Create(7)
                    record.Data("Page1") = JsonValue.Create("First page" & vbLf & "Unicode: Ω")
            End Select
            Dim before = writes, beforeReplies = replies.Count
            Await service.HandleAsync(1, {"savetool", kind, id.ToString(), ToolWire.Encode(record), "save-" & kind})
            Check(writes = before + 1 AndAlso replies.Last().Command = "toolsaved", "Save failed for " & kind & ": " & CStr(replies.Last().Fields(2)))
            Check(replies.Count = beforeReplies + 1, "Save produced a second spurious error.")
            Check(CStr(replies.Last().Fields.Last()) = "save-" & kind, "Request token lost.")
        Next
        Check(ToolSchema.Number(store("item")(1), "Data1") = 2, "Book item ID was lost.")
        Check(ToolSchema.Number(store("npc")(1), "ShopCall") = 7, "Quest NPC link was lost.")
        Check(ToolSchema.Number(store("npc")(1), "DropItemValue") = Integer.MaxValue, "NPC drop amount was truncated.")
        Check(DirectCast(store("book")(1)("Pages"), JsonArray)(0).ToString().Contains("Ω"), "Book pages lost unicode or multiline content.")
        Dim book As New ToolRecord With {.Kind = "book", .Id = 1, .Data = DirectCast(store("book")(1).DeepClone(), JsonObject)}
        book.Data("NextBook") = JsonValue.Create(1)
        Dim writeCount = writes
        Await service.HandleAsync(1, {"savetool", "book", "1", ToolWire.Encode(book), "self"})
        Check(writes = writeCount AndAlso replies.Last().Command = "toolerror", "Self-linked book was saved.")
        book.Id = 2
        Await service.HandleAsync(1, {"savetool", "book", "1", ToolWire.Encode(book), "wrongid"})
        Check(writes = writeCount AndAlso replies.Last().Command = "toolerror", "Mismatched content identity was saved.")
        Await service.HandleAsync(1, {"savetool", "book", "1", "bad-base64", "invalid"})
        Check(writes = writeCount AndAlso replies.Last().Command = "toolerror", "Malformed payload was accepted.")
        Await service.HandleAsync(1, {"edittool", "book", "999", "range"})
        Check(replies.Last().Command = "toolerror", "Out-of-range slot was loaded.")
        store("quest")(1)("Players") = New JsonArray(JsonValue.Create("Existing player"))
        Dim quest As New ToolRecord With {.Kind = "quest", .Id = 1, .Data = DirectCast(store("quest")(1).DeepClone(), JsonObject)}
        quest.Data("Players") = New JsonArray()
        Await service.HandleAsync(1, {"savetool", "quest", "1", ToolWire.Encode(quest), "preserve"})
        Check(DirectCast(store("quest")(1)("Players"), JsonArray).Count = 1, "Editor erased quest progress.")
        quest.Data("NpcSay") = JsonValue.Create("line1" & vbLf & "line2")
        writeCount = writes
        Await service.HandleAsync(1, {"savetool", "quest", "1", ToolWire.Encode(quest), "newline"})
        Check(writes = writeCount AndAlso replies.Last().Command = "toolerror", "Multiline quest text was accepted.")
        Dim map As New JsonObject From {{"Tileset", JsonValue.Create(2)}}
        MapEditing.PreserveTilesets(map)
        MapEditing.Paint(map, 14, 10, 3, 2, 3, 3, 3, 5, False)
        Dim tiles = MapEditing.EnsureTiles(map)
        Check(ToolSchema.Number(DirectCast(tiles(10 * 16 + 14), JsonObject), "Mask2") = 38, "Wrong palette tile painted.")
        Check(ToolSchema.Number(DirectCast(tiles(11 * 16 + 15), JsonObject), "Mask2") = 51, "Brush selection was not painted across rows.")
        Check(ToolSchema.Number(DirectCast(tiles(10 * 16 + 13), JsonObject), "Mask2") = 0, "Painting wrapped outside bounds.")
        Check(CInt(DirectCast(DirectCast(tiles(0), JsonObject)("LayerTileset"), JsonArray)(0).ToString()) = 2, "Inherited tileset was not preserved.")
        map("Tileset") = JsonValue.Create(8)
        MapEditing.Paint(map, 0, 0, 0, 0, 0, 1, 1, 8, False)
        Check(CInt(DirectCast(DirectCast(tiles(1), JsonObject)("LayerTileset"), JsonArray)(0).ToString()) = 2, "Changing palette retargeted existing tiles.")
        MapEditing.Paint(map, 14, 10, 3, 0, 0, 3, 3, 5, True)
        Check(ToolSchema.Number(DirectCast(tiles(11 * 16 + 15), JsonObject), "Mask2") = 0, "Erase did not use the selection footprint.")
        MapEditing.Attribute(map, 1, 1, 1, 2, 3, 4, 5)
        MapEditing.Attribute(map, 1, 1, 2, 8, 50, 0, 0)
        Dim tile = DirectCast(tiles(17), JsonObject)
        Check(ToolSchema.Number(tile, "Type") = 2 AndAlso ToolSchema.Number(tile, "Type2") = 8 AndAlso ToolSchema.Number(tile, "Data1") = 3 AndAlso ToolSchema.Number(tile, "Data21") = 50, "Second attributes overwrote first attributes.")
        Await RunAdmin()
    End Function
    Private Async Function RunAdmin() As Task
        Dim actor As New AdminPlayer With {.ConnectionId = 1, .Name = "Admin", .Access = 4, .Map = 8, .X = 1, .Y = 1}
        Dim target As New AdminPlayer With {.ConnectionId = 2, .Name = "Player", .Access = 0, .Map = 3, .X = 2, .Y = 4}
        Dim updates = 0, bans = 0, cleared = 0, disconnected = 0
        Dim messages As New List(Of String)
        Dim service As New AdminToolsService(Function() New AdminPlayer() {actor, target},
            Function(player)
                updates += 1
                Return Task.CompletedTask
            End Function,
            Function(admin, player)
                bans += 1
                Return Task.CompletedTask
            End Function,
            Function()
                cleared += 1
                Return Task.CompletedTask
            End Function,
            Sub(id) disconnected = id,
            Sub(id, message) messages.Add(message),
            Function(id) Task.CompletedTask)
        Await service.HandleAsync(1, {"moderation", "setjail", ""})
        Await service.HandleAsync(1, {"jailplayer", "Player"})
        Check(target.IsJailed AndAlso target.Map = 8 AndAlso target.X = 1, "Jail tool did not use the configured tile.")
        Await service.HandleAsync(1, {"unjailplayer", "Player"})
        Check(Not target.IsJailed AndAlso target.Map = 3 AndAlso target.X = 2 AndAlso target.Y = 4, "Unjail did not restore the previous location.")
        Await service.HandleAsync(1, {"muteplayer", "Player"})
        Check(target.IsMuted, "Mute tool failed.")
        Await service.HandleAsync(1, {"unmuteplayer", "Player"})
        Check(Not target.IsMuted, "Unmute tool failed.")
        Await service.HandleAsync(1, {"playersprite", "153", "Player"})
        Check(target.Sprite = 153, "Player sprite arguments were swapped.")
        Await service.HandleAsync(1, {"setaccess", "Player", "2"})
        Check(target.Access = 2, "Access tool failed.")
        Dim before = updates
        Await service.HandleAsync(1, {"setaccess", "Player", "999"})
        Check(updates = before AndAlso target.Access = 2, "Invalid access level was accepted.")
        actor.Access = 1
        Await service.HandleAsync(1, {"bandestroy"})
        Check(cleared = 0, "Monitor cleared the ban list.")
        Await service.HandleAsync(1, {"kickplayer", "Player"})
        Check(disconnected = 0, "Lower access actor kicked a higher access player.")
        actor.Access = 4
        Await service.HandleAsync(1, {"banplayer", "Player"})
        Check(bans = 1 AndAlso disconnected = 2, "Ban did not persist before disconnecting.")
        Await service.HandleAsync(1, {"bandestroy"})
        Check(cleared = 1, "Creator could not clear bans.")
        before = updates
        Await service.HandleAsync(1, {"muteplayer", "Admin"})
        Check(updates = before, "Admin moderated their own session.")
    End Function
End Module