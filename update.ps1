# Neo Vcore V6 - Atualizador Completo (FORÇADO)
# Autor: Bruno Kupper

Write-Host "Forçando atualização completa do NeoVcore..." -ForegroundColor Cyan

$installPath = "$env:SystemDrive\NeoVcore"
$repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"

function Download-File($url, $dest) {
    Write-Host "Atualizando: $dest" -ForegroundColor Cyan
    Invoke-WebRequest $url -OutFile $dest -UseBasicParsing
}

# Atualizar arquivo principal
Download-File "$repo/NeoVcore.ps1" "$installPath\NeoVcore.ps1"

# Atualizar dados
$files = @("features.json","logs.txt","presets.json","Settings.json","version.txt")
foreach ($f in $files) {
    Download-File "$repo/data/$f" "$installPath/data/$f"
}

# Atualizar módulos
$modules = Get-ChildItem "$installPath\modules" | Select-Object -ExpandProperty Name
foreach ($m in $modules) {
    Download-File "$repo/modules/$m" "$installPath/modules/$m"
}

# Atualizar vivetool
$vt = @("ViVeTool.exe","Albacore.ViVe.dll","FeatureDictionary.pfs","Newtonsoft.Json.dll")
foreach ($v in $vt) {
    Download-File "$repo/vivetool/$v" "$installPath/vivetool/$v"
}

Write-Host "Atualização completa concluída!" -ForegroundColor Green
Write-Host "Abrindo NeoVcore..." -ForegroundColor Cyan

& "$installPath\NeoVcore.ps1"
