$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = Join-Path $root 'DX11Project/Sources/Src'
$encoding = New-Object Text.UTF8Encoding($false)
function Set-Property($node, $name, $value) { $node | Add-Member -NotePropertyName $name -NotePropertyValue $value -Force }
foreach ($file in Get-ChildItem $source -Filter '*.tbform') {
    $script:declarations = ''
    $script:initializers = ''
    $script:changed = $false
    function Convert-Controls($nodes) {
        foreach ($node in $nodes) {
            if ($node._className -eq 'MSWinsockLib.Winsock') {
                $script:declarations += "`r`n    Public WithEvents Socket As clsNativeSocket"
                $script:initializers += "`r`n        Set Socket = New clsNativeSocket`r`n        Socket.Attach Me.hWnd"
                $script:changed = $true
                continue
            }
            if ($node._className -eq 'RichTextLib.RichTextBox') {
                $name = $node.Name
                $readOnly = if ($node.ReadOnly) { 'True' } else { 'False' }
                $background = $node.BackColor
                $size = ([single]$(if ($node.FontSize) { $node.FontSize } else { 9.75 })).ToString([Globalization.CultureInfo]::InvariantCulture)
                $script:declarations += "`r`n    Public WithEvents $name As clsNativeRichText"
                $script:initializers += "`r`n        Set $name = New clsNativeRichText`r`n        $name.Attach host$name, $readOnly, $background, $size"
                $node.Name = "host$name"
                $node._className = 'PictureBox'
                Set-Property $node '_clsid' '{33AD4ED0-6699-11CF-B70C-00AA0060D393}'
                Set-Property $node 'BorderStyle' 0
                Set-Property $node 'TabStop' $false
                foreach ($property in @('_isImportedActiveXControl','_Version','_ExtentX','_ExtentY','TextRTF','ScrollBars','ReadOnly','Font')) { $node.PSObject.Properties.Remove($property) }
                $script:changed = $true
            }
            if ($node._className -eq 'TabDlg.SSTab') {
                $tabCount = $node.Tabs
                Set-Property $node 'Caption' $node.'TabCaption(0)'
                $node._className = 'Frame'
                Set-Property $node '_clsid' '{33AD4EE8-6699-11CF-B70C-00AA0060D393}'
                foreach ($property in @($node.PSObject.Properties.Name)) {
                    if ($property -match '^(Tab\(|TabCaption|TabPicture|TabHeight|Tabs|_isImported|_Version|_Extent)') { $node.PSObject.Properties.Remove($property) }
                }
                if ($tabCount -eq 2) {
                    $node.Caption = ''
                    foreach ($child in $node._children) {
                        if ($child.Name -eq 'Picture5') { $child.Left += 5000; Set-Property $child 'Visible' $false }
                    }
                    foreach ($i in 0..1) {
                        $caption = @('Layers','Attribs')[$i]
                        $node._children += [pscustomobject]@{Name="cmdEditor$caption"; _className='CommandButton'; _clsid='{33AD4EF0-6699-11CF-B70C-00AA0060D393}'; Caption=$caption; Left=(4+62*$i); Top=4; Width=61; Height=25; TabIndex=(200+$i); FontName='MS Sans Serif'; FontSize=8.25}
                    }
                }
                $script:changed = $true
            }
            if ($null -ne $node._children) { $node._children = @(Convert-Controls $node._children) }
            $node
        }
    }
    $form = @(Convert-Controls (Get-Content $file.FullName -Raw | ConvertFrom-Json))
    if (-not $script:changed) { continue }
    [IO.File]::WriteAllText($file.FullName, (ConvertTo-Json -InputObject $form -Depth 100), $encoding)
    $codePath = $file.FullName -replace '\.tbform$', '.twin'
    $code = [IO.File]::ReadAllText($codePath)
    if ($script:declarations) {
        if ($code -match 'Option Explicit') {
            $code = $code -replace 'Option Explicit', ('Option Explicit' + $script:declarations)
        } else {
            $code = $code.Replace('Attribute VB_Exposed = False', 'Attribute VB_Exposed = False' + $script:declarations)
        }
        $code = $code -replace 'Private Sub Form_Load\(\)', ('Private Sub Form_Load()' + $script:initializers)
    }
    if ($file.Name -eq 'frmMirage.frm.tbform') {
        $code = $code.Replace('EnableURLDetect txtChat.hwnd, Me.hWnd', 'EnableURLDetect txtChat.hwnd, hosttxtChat.hWnd')
        $code = [regex]::Replace($code, '(?s)    Private Sub SSTab1_Click\(PreviousTab As Integer\).*?    End Sub', @'
    Private Sub cmdEditorLayers_Click()
        Picture6.Visible = True
        Picture5.Visible = False
        optLayers.Value = True
        optAttribs.Value = False
    End Sub

    Private Sub cmdEditorAttribs_Click()
        Picture6.Visible = False
        Picture5.Visible = True
        optLayers.Value = False
        optAttribs.Value = True
    End Sub
'@)
    }
    [IO.File]::WriteAllText($codePath, ($code -replace '\r?\n', "`r`n"), $encoding)
    Write-Output "Replaced OCX controls in $($file.Name)"
}
$settingsPath = Join-Path $root 'DX11Project/Settings'
$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
$settings.'project.references' = @($settings.'project.references' | Where-Object { $_.symbolId -notin @('RichTextLib','MSWinsockLib','TabDlg') })
[IO.File]::WriteAllText($settingsPath, ($settings | ConvertTo-Json -Depth 30), $encoding)

