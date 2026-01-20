# Neo Vcore V6 - Atualizador Inteligente
# Autor: Bruno Kupper

Write-Host "Verificando atualizações do NeoVcore..." -ForegroundColor Cyan

$installPath = "$env:SystemDrive\NeoVcore"
$repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"

function Download-File($url, $dest) {
    Invoke-WebRequest $url -OutFile $dest -UseBasicParsing
}

# Verificar versão local e remota
$localVersionFile = "$installPath\data\version.txt"
$remoteVersionUrl = "$repo/data/version.txt"

$localVersion = ""
$remoteVersion = ""

if (Test-Path $localVersionFile) {
    $localVersion = Get-Content $localVersionFile
}

try {
    $remoteVersion = (Invoke-WebRequest $remoteVersionUrl -UseBasicParsing).Content
} catch {
    Write-Host "Não foi possível verificar a versão online." -ForegroundColor Yellow
}

if ($localVersion -eq $remoteVersion -and $localVersion -ne "") {
    Write-Host "NeoVcore já está atualizado (versão $localVersion)." -ForegroundColor Green
    Write-Host "Abrindo NeoVcore..." -ForegroundColor Cyan
    & "$installPath\NeoVcore.ps1"
    exit
}

Write-Host "Atualizando NeoVcore para a versão $remoteVersion..." -ForegroundColor Cyan

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

Write-Host "Atualização concluída!" -ForegroundColor Green
Write-Host "Abrindo NeoVcore..." -ForegroundColor Cyan

& "$installPath\NeoVcore.ps1"
