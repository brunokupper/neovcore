$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# CARREGAR MÓDULOS
# ============================================================

$modulesPath = Join-Path $PSScriptRoot "modules"

$modules = @(
    "Header.psm1",
    "CategoryLoader.psm1",
    "Vivetool.psm1",
    "VivetoolMenu.psm1",
    "Presets.psm1",
    "Scanner.psm1",
    "SearchID.psm1",
    "Optimization.psm1",
    "Maintenance.psm1",
    "AdvancedTools.psm1",
    "Settings.psm1",
    "SystemInfo.psm1",
    "SettingsManager.psm1",
    "DeveloperMenu.psm1",
    "Logger.psm1",
    "VersionManager.psm1",
    "NeoVcoreUpdater.psm1",
    "Rollback.psm1",
    "Validator.psm1",
    "Updater.psm1",
    "FeatureControl.psm1",
    "CategoryMenu.psm1",
    "PresetMenu.psm1"
)

foreach ($m in $modules) {
    $full = Join-Path $modulesPath $m
    if (Test-Path $full) {
        Import-Module $full -Force -Scope Global
    }
    else {
        Write-Host "Modulo nao encontrado: $m" -ForegroundColor Red
    }
}

# ============================================================
# CONFIGURAÇÕES GLOBAIS
# ============================================================

if (-not $Global:NeoVcoreSettings) {
    $Global:NeoVcoreSettings = @{
        Theme  = "dark"
        Turbo  = $false
        Sounds = $true
    }
}

if (Get-Command Load-Settings -ErrorAction SilentlyContinue) {
    Load-Settings
}

# ============================================================
# AUXÍLIO DE CORES (CORRIGE TEMA CLARO)
# ============================================================

function Get-Color {
    param($color)

    if ($Global:NeoVcoreSettings.Theme -eq "light") {
        switch ($color) {
            "White" { return "Black" }
            default { return $color }
        }
    }

    return $color
}

# ============================================================
# FUNÇÕES DE SONS E ANIMAÇÃO
# ============================================================

function Play-Beep {
    if ($Global:NeoVcoreSettings.Sounds) {
        [console]::beep(900, 60)
    }
}

function Animate-Text($text, $color = "White", $delay = 25) {
    if ($Global:NeoVcoreSettings.Turbo) {
        Write-Host $text -ForegroundColor (Get-Color $color)
        return
    }
    foreach ($c in $text.ToCharArray()) {
        Write-Host -NoNewline $c -ForegroundColor (Get-Color $color)
        Start-Sleep -Milliseconds $delay
    }
    Write-Host ""
}

function Apply-Theme {
    if ($Global:NeoVcoreSettings.Theme -eq "light") {
        $Host.UI.RawUI.BackgroundColor = "White"
        $Host.UI.RawUI.ForegroundColor = "Black"
    }
    else {
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Gray"
    }
    Clear-Host
}

# ============================================================
# TELA DE ABERTURA
# ============================================================

function Show-SplashScreen {
    Apply-Theme
    Clear-Host

    Start-Sleep -Milliseconds 2
    Animate-Text "+------------------------------------------------------------+" "Cyan" 2
    Animate-Text "|                        NEO VCORE V6                        |" "Yellow" 2
    Animate-Text "+------------------------------------------------------------+" "Cyan" 2
    Animate-Text "" "Gray"
    Animate-Text "Carregando modulos..." "Gray" 15
    Start-Sleep -Milliseconds 250
    Animate-Text "Inicializando componentes..." "Gray" 15
    Start-Sleep -Milliseconds 250
    Animate-Text "Pronto." "Green" 10
    Start-Sleep 0.7
}

# ============================================================
# MENU PRINCIPAL (SEM DUPLICAÇÕES DE FUNÇÕES DE RECURSOS)
# ============================================================

function Show-MainMenu {

    Apply-Theme

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor (Get-Color "Cyan")
        Write-Host "|                        NEO VCORE V6                        |" -ForegroundColor (Get-Color "Yellow")
        Write-Host "+------------------------------------------------------------+" -ForegroundColor (Get-Color "Cyan")
        Write-Host ""

        Write-Host " 1) Gerenciar Recursos (Vivetool, categorias, presets, scanner)" -ForegroundColor (Get-Color "White")

        Write-Host ""
        Write-Host " 2) Otimizacoes do Sistema"    -ForegroundColor (Get-Color "White")
        Write-Host " 3) Manutencao do Sistema"     -ForegroundColor (Get-Color "White")
        Write-Host " 4) Ferramentas Avancadas"     -ForegroundColor (Get-Color "White")

        Write-Host ""
        Write-Host " 5) Configuracoes do NeoVcore" -ForegroundColor (Get-Color "White")
        Write-Host " 6) Informacoes do Sistema"    -ForegroundColor (Get-Color "White")

        Write-Host ""
        Write-Host " 7) Atualizar NeoVcore"        -ForegroundColor (Get-Color "Yellow")

        Write-Host ""
        Write-Host " 8) Sair"                      -ForegroundColor (Get-Color "Red")
        Write-Host ""

        $choice = $null

        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true).KeyChar
            if ($key -match '^\d+$') {
                Play-Beep
                $choice = $key
            }
        }

        if (-not $choice) {
            $choice = Read-Host "Escolha"
        }

        Play-Beep

        switch ($choice) {

            "1" { Show-VivetoolResourcesMenu }

            "2" { Show-OptimizationMenu }
            "3" { Show-MaintenanceMenu }
            "4" { Show-AdvancedToolsMenu }

            "5" { Show-SettingsMenu }
            "6" { Show-SystemInfo }

            "7" { Update-NeoVcore }

            "8" { return }

            default {
                Write-Host "Opcao invalida." -ForegroundColor (Get-Color "Red")
                Start-Sleep -Milliseconds 700
            }
        }

        Apply-Theme
    }
}

# ============================================================
# INICIAR NEO VCORE
# ============================================================

Show-SplashScreen

Show-MainMenu
