# Neo Vcore V6 - Instalador Online
# Autor: Bruno Kupper

Write-Host "Instalando Neo Vcore V6..." -ForegroundColor Cyan

$installPath = "$env:SystemDrive\NeoVcore"
$repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"

# Criar diretórios
New-Item -ItemType Directory -Path $installPath -Force | Out-Null
New-Item -ItemType Directory -Path "$installPath\data" -Force | Out-Null
New-Item -ItemType Directory -Path "$installPath\modules" -Force | Out-Null
New-Item -ItemType Directory -Path "$installPath\vivetool" -Force | Out-Null

# Arquivo principal
Invoke-WebRequest "$repo/NeoVcore.ps1" -OutFile "$installPath\NeoVcore.ps1"

# Dados
Invoke-WebRequest "$repo/data/features.json" -OutFile "$installPath\data\features.json"
Invoke-WebRequest "$repo/data/logs.txt" -OutFile "$installPath\data\logs.txt"
Invoke-WebRequest "$repo/data/presets.json" -OutFile "$installPath\data\presets.json"
Invoke-WebRequest "$repo/data/Settings.json" -OutFile "$installPath\data\Settings.json"
Invoke-WebRequest "$repo/data/version.txt" -OutFile "$installPath\data\version.txt"

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
    Invoke-WebRequest "$repo/modules/$m" -OutFile "$installPath/modules/$m"
}

# Vivetool
Invoke-WebRequest "$repo/vivetool/ViVeTool.exe" -OutFile "$installPath/vivetool/ViVeTool.exe"
Invoke-WebRequest "$repo/vivetool/Albacore.ViVe.dll" -OutFile "$installPath/vivetool/Albacore.ViVe.dll"
Invoke-WebRequest "$repo/vivetool/FeatureDictionary.pfs" -OutFile "$installPath/vivetool/FeatureDictionary.pfs"
Invoke-WebRequest "$repo/vivetool/Newtonsoft.Json.dll" -OutFile "$installPath/vivetool/Newtonsoft.Json.dll"

Write-Host ""
Write-Host "Instalação concluída!" -ForegroundColor Green
Write-Host "Execute:  NeoVcore" -ForegroundColor Yellow
