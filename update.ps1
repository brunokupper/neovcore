# Neo Vcore V6 - Atualizador
# Autor: Bruno Kupper

Write-Host "Atualizando NeoVcore..." -ForegroundColor Cyan

$installPath = "$env:SystemDrive\NeoVcore"
$repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"

# Atualizar arquivo principal
Invoke-WebRequest "$repo/NeoVcore.ps1" -OutFile "$installPath\NeoVcore.ps1"

# Atualizar dados
$files = @("features.json","logs.txt","presets.json","Settings.json","version.txt")
foreach ($f in $files) {
    Invoke-WebRequest "$repo/data/$f" -OutFile "$installPath/data/$f"
}

# Atualizar módulos
$modules = Get-ChildItem "$installPath\modules" | Select-Object -ExpandProperty Name
foreach ($m in $modules) {
    Invoke-WebRequest "$repo/modules/$m" -OutFile "$installPath/modules/$m"
}

# Atualizar vivetool
$vt = @("ViVeTool.exe","Albacore.ViVe.dll","FeatureDictionary.pfs","Newtonsoft.Json.dll")
foreach ($v in $vt) {
    Invoke-WebRequest "$repo/vivetool/$v" -OutFile "$installPath/vivetool/$v"
}

Write-Host ""
Write-Host "Atualização concluída!" -ForegroundColor Green
