param([switch]$Fixed)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'TwinContainer.ps1')
$root = Split-Path $PSScriptRoot -Parent
$tree = Join-Path $root 'ServerMigration'
$project = [TwinNode]::Load((Join-Path $tree 'Server.twinproj'))
$settings = [Text.Encoding]::UTF8.GetString($project.Find('Settings').Data) | ConvertFrom-Json
$settings.'project.name' = 'IniSmoke'
$settings.'project.startupObject' = 'Sub Main'
$settings.'project.iconForm' = ''
$settings.'project.buildPath' = '${SourcePath}\IniSmoke.exe'
$project.Replace('Settings', [Text.Encoding]::UTF8.GetBytes(($settings | ConvertTo-Json -Depth 40)))
$project.Find('Sources/Src').Children.Clear()
$test = [IO.File]::ReadAllText((Join-Path $root 'tools/IniSmoke.twin'))
if ($Fixed) {
    foreach ($name in @('modDatabase.bas','clsCommands.cls')) {
        $text = [IO.File]::ReadAllText((Join-Path $tree "Sources/Src/$name"))
        $methods = [regex]::Match($text, '(?s)Public Function GetVar\(.*?Public Sub PutVar\(.*?End Sub').Value
        if (-not $methods) { throw "INI methods missing in $name" }
        if ($name -eq 'modDatabase.bas') { $text = "Attribute VB_Name = `"modDatabase`"`r`nOption Explicit`r`n" + $methods }
        else { $text = $text.Substring(0,$text.IndexOf('Option Explicit')) + "Option Explicit`r`n" + $methods }
        $project.AddSource($name, [Text.Encoding]::UTF8.GetBytes(($text -replace '\r?\n', "`r`n")))
    }
}
$database = [IO.File]::ReadAllText((Join-Path $tree 'Sources/Src/modDatabase.bas'))
$methods = [regex]::Match($database, '(?s)Public Function GetVar\(.*?Public Sub PutVar\(.*?End Sub').Value
$methods += "`r`n" + [regex]::Match($database, '(?s)Public Function FileExist\(.*?End Function').Value
foreach ($method in @('LoadClasses','SaveClasses','CheckClasses')) {
    $methods += "`r`n" + [regex]::Match($database, ('(?s)Sub ' + $method + '\(\).*?End Sub')).Value
}
$types = [IO.File]::ReadAllText((Join-Path $tree 'Sources/Src/modTypes.bas'))
$globals = "Public Max_Classes As Byte`r`nPublic Class() As ClassRec`r`nPublic Const NAME_LENGTH = 50`r`n" + [regex]::Match($types, '(?s)Type ClassRec\r?\n.*?End Type').Value
$logic = [IO.File]::ReadAllText((Join-Path $tree 'Sources/Src/modGameLogic.bas'))
$methods += "`r`n" + [regex]::Match($logic, '(?s)Sub ClearClasses\(\).*?End Sub').Value
$declares = [IO.File]::ReadAllText((Join-Path $tree 'Sources/Src/modDeclares.bas'))
$api = ([regex]::Matches($declares, '(?m)^Declare Function (Write|Get)PrivateProfileString.*$') | ForEach-Object Value) -join "`r`n"
$text = "Attribute VB_Name = `"modDatabase`"`r`nOption Explicit`r`n$globals`r`n$api`r`n$methods"
$project.AddSource('modDatabase.bas', [Text.Encoding]::UTF8.GetBytes(($text -replace '\r?\n', "`r`n")))
$project.AddSource('IniSmoke.twin', [Text.Encoding]::UTF8.GetBytes($test))
$project.Save((Join-Path $tree 'IniSmoke.twinproj'))
