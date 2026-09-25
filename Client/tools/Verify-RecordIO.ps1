$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$src=Join-Path $root 'ServerMigration/Sources/Src'
$fixtures=Join-Path $root 'ServerMigration/RecordIOFixtures'
$constants=@{}
foreach($m in [regex]::Matches((Get-Content (Join-Path $src 'modConstants.bas') -Raw),'(?m)^Public Const (\w+) = (\d+)')){$constants[$m.Groups[1].Value]=[int]$m.Groups[2].Value}
$records=@{}
foreach($m in [regex]::Matches((Get-Content (Join-Path $src 'modTypes.bas') -Raw),'(?ms)^Type (\w+)\r?\n(.*?)^End Type')){$records[$m.Groups[1].Value]=$m.Groups[2].Value}
function Number($text){if($text -match '^\d+$'){return [int]$text}; return $constants[$text]}
function Write-EmptyRecord($writer,$name){
    foreach($field in [regex]::Matches($records[$name],'(?m)^\s*(\w+)(?:\(([^)]*)\))?\s+As\s+(\w+)(?:\s*\*\s*(\w+))?\s*$')){
        $count=1; $kind=$field.Groups[3].Value; $width=$field.Groups[4].Value
        if($field.Groups[2].Success){
            if($field.Groups[2].Value -eq ''){$writer.Write([int16]1);$writer.Write([int32]255);$writer.Write([int32]1);$count=255}
            else{foreach($bound in ($field.Groups[2].Value -split ',')){$parts=$bound.Trim() -split '\s+To\s+'; $count *= (Number $parts[1])-(Number $parts[0])+1}}
        }
        for($index=0;$index -lt $count;$index++){
            switch($kind){
                'String' {$writer.Write([Text.Encoding]::ASCII.GetBytes((' ' * (Number $width))))}
                'Byte' {$writer.Write([byte]0)}
                'Integer' {$writer.Write([int16]0)}
                'Long' {$writer.Write([int32]0)}
                default {Write-EmptyRecord $writer $kind}
            }
        }
    }
}
$checked=0
foreach($legacy in Get-ChildItem $fixtures -Filter '*.legacy'){
    $native=$legacy.FullName -replace '\.legacy$','.native'
    if((Get-FileHash $legacy.FullName).Hash -ne (Get-FileHash $native).Hash){throw "Compatibility mismatch: $($legacy.BaseName)"}
    $memory=[IO.MemoryStream]::new(); $writer=[IO.BinaryWriter]::new($memory)
    Write-EmptyRecord $writer $legacy.BaseName
    $writer.Flush()
    $expected=[Convert]::ToBase64String($memory.ToArray())
    $actual=[Convert]::ToBase64String([IO.File]::ReadAllBytes(($legacy.FullName -replace '\.legacy$','.cleared')))
    $writer.Dispose(); $memory.Dispose()
    if($actual -ne $expected){throw "Clear left stale fields in $($legacy.BaseName)"}
    $checked++
}
"PASS: $checked byte-exact legacy/native comparisons; all fields and array entries reset to empty/zero."
