# Neo Vcore V6 - Instalador Inteligente
# Autor: Bruno Kupper

Write-Host "Verificando instalação do NeoVcore..." -ForegroundColor Cyan

$installPath = "$env:SystemDrive\NeoVcore"
$repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"

# Função para baixar arquivos
function Download-File($url, $dest) {
    Invoke-WebRequest $url -OutFile $dest -UseBasicParsing
}

# Criar diretórios
New-Item -ItemType Directory -Path $installPath -Force | Out-Null
New-Item -ItemType Directory -Path "$installPath\data" -Force | Out-Null
New-Item -ItemType Directory -Path "$installPath\modules" -Force | Out-Null
New-Item -ItemType Directory -Path "$installPath\vivetool" -Force | Out-Null

# Verificar versão local
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

# Se versões forem iguais → não baixa nada
if ($localVersion -eq $remoteVersion -and $localVersion -ne "") {
    Write-Host "NeoVcore já está atualizado (versão $localVersion)." -ForegroundColor Green
    Write-Host "Abrindo NeoVcore..." -ForegroundColor Cyan

    # Registrar comando NeoVcore automaticamente
    $profilePath = $PROFILE
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $aliasLine = 'Set-Alias NeoVcore "C:\NeoVcore\NeoVcore.ps1"'
    if (-not (Select-String -Path $profilePath -Pattern "NeoVcore.ps1" -Quiet)) {
        Add-Content -Path $profilePath -Value $aliasLine
    }

    & "$installPath\NeoVcore.ps1"
    exit
}

Write-Host "Instalando/Atualizando NeoVcore..." -ForegroundColor Cyan

# Arquivo principal
Download-File "$repo/NeoVcore.ps1" "$installPath\NeoVcore.ps1"

# Dados
$files = @("features.json","logs.txt","presets.json","Settings.json","version.txt")
foreach ($f in $files) {
    Download-File "$repo/data/$f" "$installPath/data/$f"
}

# Módulos
$modules = @(
    "AdvancedTools.psm1","CategoryLoader.psm1","CategoryMenu.psm1","DeveloperMenu.psm1",
    "FeatureControl.psm1","Header.psm1","Logger.psm1","MainMenu.psm1","Maintenance.psm1",
    "NeoVcoreUpdater.psm1","Optimization.psm1","PresetMenu.psm1","Presets.psm1",
    "Rollback.psm1","Scanner.psm1","SearchID.psm1","Settings.psm1","SettingsManager.psm1",
    "Submenus.psm1","SystemInfo.psm1","Updater.psm1","Validator.psm1","VersionManager.psm1",
    "Vivetool.psm1","VivetoolMenu.psm1"
)

foreach ($m in $modules) {
    Download-File "$repo/modules/$m" "$installPath/modules/$m"
}

# Vivetool
$vt = @("ViVeTool.exe","Albacore.ViVe.dll","FeatureDictionary.pfs","Newtonsoft.Json.dll")
foreach ($v in $vt) {
    Download-File "$repo/vivetool/$v" "$installPath/vivetool/$v"
}

# Registrar comando NeoVcore automaticamente
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$aliasLine = 'Set-Alias NeoVcore "C:\NeoVcore\NeoVcore.ps1"'
if (-not (Select-String -Path $profilePath -Pattern "NeoVcore.ps1" -Quiet)) {
    Add-Content -Path $profilePath -Value $aliasLine
}

Write-Host ""
Write-Host "Instalação concluída!" -ForegroundColor Green
Write-Host "Abrindo NeoVcore..." -ForegroundColor Cyan

# Abrir automaticamente
& "$installPath\NeoVcore.ps1"
