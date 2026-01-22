[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#
    ============================================================
    MÓDULO: Vivetool.psm1
    FUNÇÃO: Executar comandos do Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.2
    ============================================================
#>

# Caminho do executável Vivetool
$Global:VivetoolPath = "$($env:SystemDrive)\NeoVcore\vivetool\vivetool.exe"

# ============================================================
# EXECUTAR VIVETOOL - ATIVAR FEATURE (INTERATIVO)
# ============================================================

function Enable-Feature {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) {
        Write-Host "ID inválido." -ForegroundColor Red
        Write-Log "Tentativa de ativar ID inválido: $FeatureID"
        return
    }

    if (-not (Test-Path $Global:VivetoolPath)) {
        Write-Host "Vivetool não encontrado em $Global:VivetoolPath" -ForegroundColor Red
        Write-Log "Vivetool não encontrado"
        return
    }

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    ATIVANDO RECURSO...                    |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: vivetool /enable /id:$FeatureID" -ForegroundColor DarkGray
    Write-Host ""

    try {
        & $Global:VivetoolPath /enable /id:$FeatureID /product:$env:SystemDrive 2>$null
        Write-Log "Feature $FeatureID ativada"
    }
    catch {
        Write-Host "Erro ao ativar recurso." -ForegroundColor Red
        Write-Log "Erro ao ativar feature $FeatureID"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host ""
    Write-Host "Recurso ativado com sucesso!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# ============================================================
# EXECUTAR VIVETOOL - DESATIVAR FEATURE (INTERATIVO)
# ============================================================

function Disable-Feature {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) {
        Write-Host "ID inválido." -ForegroundColor Red
        Write-Log "Tentativa de desativar ID inválido: $FeatureID"
        return
    }

    if (-not (Test-Path $Global:VivetoolPath)) {
        Write-Host "Vivetool não encontrado em $Global:VivetoolPath" -ForegroundColor Red
        Write-Log "Vivetool não encontrado"
        return
    }

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                   DESATIVANDO RECURSO...                   |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: vivetool /disable /id:$FeatureID" -ForegroundColor DarkGray
    Write-Host ""

    try {
        & $Global:VivetoolPath /disable /id:$FeatureID /product:$env:SystemDrive 2>$null
        Write-Log "Feature $FeatureID desativada"
    }
    catch {
        Write-Host "Erro ao desativar recurso." -ForegroundColor Red
        Write-Log "Erro ao desativar feature $FeatureID"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host ""
    Write-Host "Recurso desativado com sucesso!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# ============================================================
# CONSULTAR STATUS DE UMA FEATURE
# ============================================================

function Check-FeatureStatus {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) { return "Inválido" }

    if (-not (Test-Path $Global:VivetoolPath)) {
        Write-Log "Vivetool não encontrado ao consultar status"
        return "Erro"
    }

    try {
        $output = & $Global:VivetoolPath /query /id:$FeatureID 2>$null
    }
    catch {
        Write-Log "Erro ao consultar status da feature $FeatureID"
        return "Erro"
    }

    $stateLine = $output | Where-Object { $_ -match "State" }

    if ($stateLine -match "Enabled") { return "Ativado" }
    if ($stateLine -match "Disabled") { return "Desativado" }

    return "Desconhecido"
}

# ============================================================
# MENU DE AÇÕES DO RECURSO (INTERATIVO)
# ============================================================

function Show-FeatureActions {
    param ($Feature)

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                     GERENCIAR RECURSO                      |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Recurso: $($Feature.name)"
        Write-Host "ID: $($Feature.id)"
        Write-Host ""

        $status = Check-FeatureStatus -FeatureID $Feature.id
        Write-Host "Status: $status"
        Write-Host ""

        Write-Host "1) Ativar Recurso"
        Write-Host "2) Desativar Recurso"
        Write-Host "0) Voltar" -ForegroundColor Red
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {
            "1" { Enable-Feature -FeatureID $Feature.id }
            "2" { Disable-Feature -FeatureID $Feature.id }
            "0" { return }
            default {
                Write-Host ""
                Write-Host "Opcao invalida." -ForegroundColor Red
                Read-Host "Pressione ENTER para tentar novamente"
            }
        }
    }
}

# ============================================================
# EXECUTAR VIVETOOL - ATIVAR FEATURE (SILENCIOSO, PARA PRESETS)
# ============================================================

function Enable-FeatureSilent {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) { return }
    if (-not (Test-Path $Global:VivetoolPath)) { return }

    try {
        & $Global:VivetoolPath /enable /id:$FeatureID /product:$env:SystemDrive 2>$null
        Write-Log "Feature $FeatureID ativada (silent)"
    }
    catch {
        Write-Log "Erro ao ativar feature $FeatureID (silent)"
    }
}

# ============================================================
# EXECUTAR VIVETOOL - DESATIVAR FEATURE (SILENCIOSO, PARA LOTES)
# ============================================================

function Disable-FeatureSilent {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) { return }
    if (-not (Test-Path $Global:VivetoolPath)) { return }

    try {
        & $Global:VivetoolPath /disable /id:$FeatureID /product:$env:SystemDrive 2>$null
        Write-Log "Feature $FeatureID desativada (silent)"
    }
    catch {
        Write-Log "Erro ao desativar feature $FeatureID (silent)"
    }
}

Export-ModuleMember -Function Enable-Feature, Disable-Feature, Enable-FeatureSilent, Disable-FeatureSilent, Check-FeatureStatus, Show-FeatureActions