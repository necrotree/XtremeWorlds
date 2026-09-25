$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$src = Join-Path $root 'ServerMigration/Sources/Src'
$types = Get-Content (Join-Path $src 'modTypes.bas') -Raw
$keep = @('PlayerInvRec','PlayerRec','TileRec','OldMapRec','MapRec','ClassRec','ItemRec','NpcRec','SignRec','QuestRec','TradeItemRec','ShopRec','SpellRec','GuildRec')
$lines = [Collections.Generic.List[string]]::new()
$lines.Add('Attribute VB_Name = "modRecordIO"')
$lines.Add('Option Explicit')
$lines.Add("' Generated from modTypes by tools/Generate-RecordCodecs.ps1. Disk fields are explicit; no raw UDT memory is serialized.")
foreach ($type in [regex]::Matches($types,'(?ms)^Type (\w+)\r?\n(.*?)^End Type')) {
    $name = $type.Groups[1].Value
    if ($name -notin $keep) { continue }
    foreach($mode in @('Read','Write','Reset')) {
        $parameter = if($mode -eq 'Reset'){''}else{'ByVal file As clsDataFile, '}
        $lines.Add("Public Sub $mode$name(${parameter}ByRef value As $name)")
        $lines.Add('    Dim i0 As Long, i1 As Long, count As Long, capacity As Long')
        foreach($field in [regex]::Matches($type.Groups[2].Value,'(?m)^\s*(\w+)(?:\(([^)]*)\))?\s+As\s+(\w+)(?:\s*\*\s*(\w+))?\s*$')) {
            $property=$field.Groups[1].Value; $kind=$field.Groups[3].Value; $width=$field.Groups[4].Value
            $target="value.$property"
            $loops=0
            if($field.Groups[2].Success) {
                $dims=$field.Groups[2].Value
                if(-not $dims) {
                    $maximum=if($name -eq 'GuildRec'){'MAX_GUILD_MEMBERS'}else{'MAX_QUEST_PLAYERS'}
                    if($mode -eq 'Read') {
                        $lines.Add("    count = file.ReadArrayCount($width)")
                        $lines.Add("    capacity = $maximum")
                        $lines.Add('    If count > capacity Then capacity = count')
                        $lines.Add("    ReDim $target(1 To capacity) As String * $width")
                        $lines.Add('    For i0 = 1 To capacity')
                        $lines.Add("        $target(i0) = vbNullString")
                        $lines.Add('    Next i0')
                    } elseif($mode -eq 'Write') {
                        $lines.Add("    count = UBound($target)")
                        $lines.Add("    If LBound($target) <> 1 Then Err.Raise 5, `"modRecordIO`", `"Invalid array lower bound`"")
                        $lines.Add('    file.WriteArrayCount count')
                    } else {
                        $lines.Add("    count = $maximum")
                        $lines.Add('    If count < 1 Then count = 1')
                        $lines.Add("    ReDim $target(1 To count) As String * $width")
                    }
                    $dims='1 To count'
                }
                $bounds=@($dims -split ',')
                for($d=$bounds.Count-1;$d -ge 0;$d--){$lines.Add("    For i$d = $($bounds[$d].Trim())")}
                $target += '('+((0..($bounds.Count-1) | ForEach-Object {"i$_"}) -join ', ')+')'
                $loops=$bounds.Count
            }
            if($kind -eq 'String') {
                if($mode -eq 'Read'){$statement="$target = file.ReadText($width)"}
                elseif($mode -eq 'Write'){$statement="file.WriteText $target, $width"}
                else{$statement="$target = vbNullString"}
            } elseif($kind -in @('Byte','Integer','Long')) {
                if($mode -eq 'Read'){$statement="$target = file.Read$kind()"}
                elseif($mode -eq 'Write'){$statement="file.Write$kind $target"}
                else{$statement="$target = 0"}
            } else {
                $arg=if($mode -eq 'Reset'){''}else{'file, '}
                $statement="$mode$kind $arg$target"
            }
            $lines.Add('    '+$statement)
            for($d=0;$d -lt $loops;$d++){$lines.Add("    Next i$d")}
        }
        $lines.Add('End Sub')
        $lines.Add('')
    }
}
$lines.Add(@'
Public Sub EnsureDataFolders(ByVal root As String)
    Dim folder As Variant, path As String, attributes As Long
    For Each folder In Array("data", "maps", "data\accounts", "data\guilds", "data\quests", "data\Shops", "data\Npcs", "data\Spells", "data\items", "data\Signs")
        path = root & "\" & CStr(folder)
        attributes = WinDevLib.GetFileAttributes(path)
        If attributes = -1 Then
            If WinDevLib.CreateDirectory(path, ByVal vbNullPtr) = 0 Then Err.Raise 75, "EnsureDataFolders", "Cannot create data directory: " & path
        ElseIf (attributes And WinDevLib.FILE_ATTRIBUTE_DIRECTORY) = 0 Then
            Err.Raise 75, "EnsureDataFolders", "Expected a directory: " & path
        End If
    Next folder
End Sub
'@)
[IO.File]::WriteAllText((Join-Path $src 'modRecordIO.bas'),($lines -join "`r`n"),(New-Object Text.UTF8Encoding($false)))
