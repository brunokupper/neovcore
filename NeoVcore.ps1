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
# AUXÍLIO DE CORES
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
# SONS E ANIMAÇÃO
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
# SPLASH SCREEN
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
# SUBMENU: SOBRE O NEO VCORE
# ============================================================

function Show-NeoVcoreInfoMenu {

    while ($true) {

        Clear-Host
        Write-Host "============================================================" -ForegroundColor (Get-Color "Cyan")
        Write-Host "                     SOBRE O NEO VCORE" -ForegroundColor (Get-Color "Yellow")
        Write-Host "============================================================" -ForegroundColor (Get-Color "Cyan")
        Write-Host ""
        Write-Host " 1) Atualizar NeoVcore" -ForegroundColor (Get-Color "White")
        Write-Host " 2) Restaurar Backup"   -ForegroundColor (Get-Color "White")
        Write-Host " 3) Verificador de Integridade" -ForegroundColor (Get-Color "White")
        Write-Host " 4) Informações do Programa" -ForegroundColor (Get-Color "White")
        Write-Host " 5) Diagnóstico" -ForegroundColor (Get-Color "White")
        Write-Host ""
        Write-Host " 0) Voltar" -ForegroundColor (Get-Color "Red")
        Write-Host ""

        $choice = Read-Host "Escolha"
        Play-Beep

        switch ($choice) {

            "1" { Update-NeoVcore }
            "2" { Show-RestoreBackupMenu }
            "3" { Show-IntegrityCheck }
            "4" { Show-ProgramInfo }
            "5" { Show-DiagnosticMenu }
            "0" { return }

            default {
                Write-Host "Opção inválida." -ForegroundColor (Get-Color "Red")
                Start-Sleep -Milliseconds 700
            }
        }
    }
}

# ============================================================
# RESTAURAR BACKUP
# ============================================================

function Show-RestoreBackupMenu {

    $backupRoot = "$env:SystemDrive\NeoVcore\backup"

    if (-not (Test-Path $backupRoot)) {
        Write-Host "Nenhum backup encontrado." -ForegroundColor Yellow
        Read-Host "ENTER para voltar"
        return
    }

    $backups = Get-ChildItem $backupRoot | Sort-Object Name

    if ($backups.Count -eq 0) {
        Write-Host "Nenhum backup disponível." -ForegroundColor Yellow
        Read-Host "ENTER para voltar"
        return
    }

    Clear-Host
    Write-Host "============================================================"
    Write-Host "                 RESTAURAR BACKUP DO NEO VCORE"
    Write-Host "============================================================"
    Write-Host ""

    $i = 1
    foreach ($b in $backups) {
        Write-Host "$i) $($b.Name)"
        $i++
    }

    Write-Host ""
    Write-Host "0) Voltar"
    Write-Host ""

    $choice = Read-Host "Escolha"

    if ($choice -eq "0") { return }

    if ($choice -notmatch '^\d+$' -or $choice -lt 1 -or $choice -gt $backups.Count) {
        Write-Host "Opção inválida." -ForegroundColor Red
        Start-Sleep 1
        return
    }

    $selected = $backups[$choice - 1].FullName

    Write-Host ""
    Write-Host "Restaurando backup: $selected" -ForegroundColor Cyan

    $files = Get-ChildItem $selected

    foreach ($f in $files) {
        Copy-Item $f.FullName "$env:SystemDrive\NeoVcore\$($f.Name)" -Force
    }

    Write-Host "Backup restaurado com sucesso!" -ForegroundColor Green
    Read-Host "ENTER para continuar"
}

# ============================================================
# VERIFICADOR DE INTEGRIDADE (COMPLETO)
# ============================================================

function Show-IntegrityCheck {

    Clear-Host
    Write-Host "============================================================"
    Write-Host "                 VERIFICADOR DE INTEGRIDADE"
    Write-Host "============================================================"
    Write-Host ""

    $installPath = "$env:SystemDrive\NeoVcore"
    $repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"

    function Get-HashSHA256($path) {
        if (-not (Test-Path $path)) { return "" }
        return (Get-FileHash -Path $path -Algorithm SHA256).Hash
    }

    function Get-RemoteHash($url) {
        try {
            $temp = "$env:TEMP\neo_hash"
            Invoke-WebRequest $url -OutFile $temp -UseBasicParsing -ErrorAction Stop
            $hash = Get-HashSHA256 $temp
            Remove-Item $temp -Force
            return $hash
        }
        catch {
            return ""
        }
    }

    # ============================
    # LISTA COMPLETA DE ARQUIVOS
    # ============================

    $files = @()

    # Arquivo principal
    $files += @{ Remote="$repo/NeoVcore.ps1"; Local="$installPath\NeoVcore.ps1" }

    # Data (exceto .txt)
    $dataFiles = Get-ChildItem "$installPath\data" | Where-Object { $_.Extension -ne ".txt" }
    foreach ($f in $dataFiles) {
        $files += @{
            Remote="$repo/data/$($f.Name)"
            Local="$installPath\data\$($f.Name)"
        }
    }

    # Módulos
    $modules = Get-ChildItem "$installPath\modules"
    foreach ($m in $modules) {
        if ($m.Extension -ne ".txt") {
            $files += @{
                Remote="$repo/modules/$($m.Name)"
                Local="$installPath\modules\$($m.Name)"
            }
        }
    }

    # Vivetool
    $vtFiles = Get-ChildItem "$installPath\vivetool"
    foreach ($v in $vtFiles) {
        if ($v.Extension -ne ".txt") {
            $files += @{
                Remote="$repo/vivetool/$($v.Name)"
                Local="$installPath\vivetool\$($v.Name)"
            }
        }
    }

    # ============================
    # VERIFICAÇÃO
    # ============================

    $modified = @()

    foreach ($f in $files) {

        $localHash = Get-HashSHA256 $f.Local
        $remoteHash = Get-RemoteHash $f.Remote

        if ($localHash -eq "" -or $remoteHash -eq "") {
            Write-Host "[ERRO] Falha ao verificar: $($f.Local)" -ForegroundColor Red
            continue
        }

        if ($localHash -eq $remoteHash) {
            Write-Host "[OK] Integridade confirmada: $($f.Local)" -ForegroundColor Green
        }
        else {
            Write-Host "[ALERTA] Arquivo modificado: $($f.Local)" -ForegroundColor Yellow
            $modified += $f.Local
        }
    }

    Write-Host ""

    # ============================
    # AÇÃO EM CASO DE ARQUIVOS MODIFICADOS
    # ============================

    if ($modified.Count -gt 0) {

        Write-Host "============================================================" -ForegroundColor Red
        Write-Host "   ARQUIVOS MODIFICADOS DETECTADOS — ATUALIZAÇÃO URGENTE" -ForegroundColor Red
        Write-Host "============================================================" -ForegroundColor Red
        Write-Host ""

        Write-Host "Pode haver uma versão nova disponível ou arquivos corrompidos." -ForegroundColor Yellow
        Write-Host ""

        Write-Host "1) Atualizar agora (forçado)"
        Write-Host "2) Entrar em SafeMode"
        Write-Host "3) Excluir todos backups comprometidos"
        Write-Host "0) Voltar"
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {

            "1" {
                Write-Host "Executando atualização forçada..." -ForegroundColor Cyan
                irm https://raw.githubusercontent.com/brunokupper/neovcore/main/update.ps1 | iex
                return
            }

            "2" {
                Show-SafeMode
                return
            }

            "3" {
                $backupRoot = "$env:SystemDrive\NeoVcore\backup"
                if (Test-Path $backupRoot) {
                    Remove-Item $backupRoot -Recurse -Force
                    Write-Host "Backups excluídos." -ForegroundColor Green
                }
                else {
                    Write-Host "Nenhum backup encontrado." -ForegroundColor Yellow
                }
                Read-Host "ENTER para continuar"
            }

            default { return }
        }
    }
    else {
        Write-Host "Nenhuma alteração detectada. Sistema íntegro." -ForegroundColor Green
        Read-Host "ENTER para continuar"
    }
}

# ============================================================
# DIAGNÓSTICO COMPLETO
# ============================================================

function Show-DiagnosticMenu {

    Clear-Host
    Write-Host "============================================================"
    Write-Host "                 DIAGNÓSTICO DO NEO VCORE"
    Write-Host "============================================================"
    Write-Host ""

    Write-Host "1) Verificar integridade completa"
    Write-Host "2) Verificar permissões"
    Write-Host "3) Verificar vivetool"
    Write-Host "4) Verificar módulos"
    Write-Host "5) Verificar arquivos essenciais"
    Write-Host ""
    Write-Host "0) Voltar"
    Write-Host ""

    $choice = Read-Host "Escolha"

    switch ($choice) {

        "1" { Show-IntegrityCheck }

        "2" {
            Write-Host "Verificando permissões..." -ForegroundColor Cyan
            if (-not (Test-Path "$env:SystemDrive\NeoVcore")) {
                Write-Host "[ERRO] Pasta NeoVcore inacessível." -ForegroundColor Red
            }
            else {
                Write-Host "[OK] Permissões adequadas." -ForegroundColor Green
            }
            Read-Host "ENTER para continuar"
        }

        "3" {
            $vt = "$env:SystemDrive\NeoVcore\vivetool\ViVeTool.exe"
            if (Test-Path $vt) {
                Write-Host "[OK] Vivetool encontrado." -ForegroundColor Green
            }
            else {
                Write-Host "[ERRO] Vivetool ausente!" -ForegroundColor Red
            }
            Read-Host "ENTER para continuar"
        }

        "4" {
            Write-Host "Verificando módulos..." -ForegroundColor Cyan
            $modules = Get-ChildItem "$env:SystemDrive\NeoVcore\modules"
            foreach ($m in $modules) {
                Write-Host "[OK] $($m.Name)" -ForegroundColor Green
            }
            Read-Host "ENTER para continuar"
        }

        "5" {
            Write-Host "Verificando arquivos essenciais..." -ForegroundColor Cyan
            $essential = @(
                "NeoVcore.ps1",
                "data\features.json",
                "modules\Vivetool.psm1"
            )
            foreach ($e in $essential) {
                $path = "$env:SystemDrive\NeoVcore\$e"
                if (Test-Path $path) {
                    Write-Host "[OK] $e" -ForegroundColor Green
                }
                else {
                    Write-Host "[ERRO] $e ausente!" -ForegroundColor Red
                }
            }
            Read-Host "ENTER para continuar"
        }

        default { return }
    }
}

# ============================================================
# SAFE MODE
# ============================================================

function Show-SafeMode {

    Clear-Host
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "                     NEO VCORE SAFE MODE"
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alguns arquivos estão corrompidos ou modificados." -ForegroundColor Yellow
    Write-Host "Recomendações:" -ForegroundColor Yellow
    Write-Host "1) Rodar Diagnóstico"
    Write-Host "2) Restaurar Backup"
    Write-Host "3) Atualização Forçada"
    Write-Host ""
    Write-Host "0) Voltar"
    Write-Host ""

    $choice = Read-Host "Escolha"

    switch ($choice) {
        "1" { Show-DiagnosticMenu }
        "2" { Show-RestoreBackupMenu }
        "3" { irm https://raw.githubusercontent.com/brunokupper/neovcore/main/update.ps1 | iex }
        default { return }
    }
}

# ============================================================
# INFORMAÇÕES DO PROGRAMA
# ============================================================

function Show-ProgramInfo {

    Clear-Host
    Write-Host "============================================================"
    Write-Host "                 INFORMAÇÕES DO NEO VCORE"
    Write-Host "============================================================"
    Write-Host ""

    $versionFile = "$env:SystemDrive\NeoVcore\data\version.txt"
    $version = "(desconhecida)"

    if (Test-Path $versionFile) {
        $version = Get-Content $versionFile -Raw
    }

    $vtPath = "$env:SystemDrive\NeoVcore\vivetool\ViVeTool.exe"
    $vtVersion = "(não encontrado)"

    if (Test-Path $vtPath) {
        $vtVersion = (Get-Item $vtPath).VersionInfo.FileVersion
    }

    Write-Host "NeoVcore Versão: $version" -ForegroundColor Cyan
    Write-Host "ViVeTool Versão: $vtVersion" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Desenvolvedor: Bruno Kupper"
    Write-Host "Ano de criação: 2026 — Licença MIT"
    Write-Host "Projeto: NeoVcore V6"
    Write-Host ""

    Read-Host "ENTER para voltar"
}

# ============================================================
# MENU PRINCIPAL
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
        Write-Host " 7) Sobre o NeoVcore"          -ForegroundColor (Get-Color "Yellow")

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

            "7" { Show-NeoVcoreInfoMenu }

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