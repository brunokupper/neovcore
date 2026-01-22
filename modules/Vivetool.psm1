[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#
    ============================================================
    MÓDULO: Vivetool.psm1
    FUNÇÃO: Executar comandos do Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.2 (Revisado)
    ============================================================
#>

# Caminho do executável Vivetool
$Global:VivetoolPath = "$($env:SystemDrive)\NeoVcore\vivetool\vivetool.exe"

# ============================================================
# FUNÇÃO AUXILIAR — EXECUTAR COMANDO E TRATAR ERROS
# ============================================================

function Invoke-VivetoolCommand {
    param(
        [string[]]$Arguments,   # ← CORREÇÃO 1: virou array
        [string]$ActionDescription,
        [switch]$Silent
    )

    if (-not (Test-Path $Global:VivetoolPath)) {
        Write-Log "Vivetool não encontrado ao executar: $Arguments"
        if (-not $Silent) {
            Write-Host "Vivetool não encontrado em $Global:VivetoolPath" -ForegroundColor Red
            Read-Host "ENTER para continuar"
        }
        return $false
    }

    try {
        # ← CORREÇÃO 2: argumentos separados
        $output = & $Global:VivetoolPath @Arguments 2>&1

        Write-Log "$ActionDescription → $Arguments"
        Write-Log "Saída do Vivetool: $output"

        if ($output -match "error|failed|unrecognized|not found") {
            if (-not $Silent) {
                Write-Host "O Vivetool retornou uma mensagem de erro:" -ForegroundColor Red
                Write-Host $output -ForegroundColor Yellow
                Read-Host "ENTER para continuar"
            }
            return $false
        }

        return $true
    }
    catch {
        Write-Log "Exceção ao executar Vivetool: $Arguments"
        Write-Log $_.Exception.Message

        if (-not $Silent) {
            Write-Host "Erro inesperado ao executar o Vivetool." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Yellow
            Read-Host "ENTER para continuar"
        }

        return $false
    }
}

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

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    ATIVANDO RECURSO...                    |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: vivetool /enable /id:$FeatureID" -ForegroundColor DarkGray
    Write-Host ""

    $ok = Invoke-VivetoolCommand `
        -Arguments @("/enable", "/id:$FeatureID") `
        -ActionDescription "Ativar Feature $FeatureID"

    if ($ok) {
        Write-Host ""
        Write-Host "Recurso ativado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Falha ao ativar o recurso." -ForegroundColor Red
    }

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

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                   DESATIVANDO RECURSO...                   |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: vivetool /disable /id:$FeatureID" -ForegroundColor DarkGray
    Write-Host ""

    $ok = Invoke-VivetoolCommand `
        -Arguments @("/disable", "/id:$FeatureID") `
        -ActionDescription "Desativar Feature $FeatureID"

    if ($ok) {
        Write-Host ""
        Write-Host "Recurso desativado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Falha ao desativar o recurso." -ForegroundColor Red
    }

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
        $output = & $Global:VivetoolPath /query /id:$FeatureID 2>&1
        Write-Log "Consulta de status para $FeatureID → $output"
    }
    catch {
        Write-Log "Erro ao consultar status da feature $FeatureID"
        Write-Log $_.Exception.Message
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
                Write-Host "Opção inválida." -ForegroundColor Red
                Read-Host "Pressione ENTER para tentar novamente"
            }
        }
    }
}

# ============================================================
# EXECUTAR VIVETOOL - ATIVAR FEATURE (SILENCIOSO)
# ============================================================

function Enable-FeatureSilent {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) { return }

    Invoke-VivetoolCommand `
        -Arguments @("/enable", "/id:$FeatureID") `
        -ActionDescription "Ativar Feature $FeatureID (silent)" `
        -Silent
}

# ============================================================
# EXECUTAR VIVETOOL - DESATIVAR FEATURE (SILENCIOSO)
# ============================================================

function Disable-FeatureSilent {
    param ([int]$FeatureID)

    if ($FeatureID -le 0) { return }

    Invoke-VivetoolCommand `
        -Arguments @("/disable", "/id:$FeatureID") `
        -ActionDescription "Desativar Feature $FeatureID (silent)" `
        -Silent
}

Export-ModuleMember -Function Enable-Feature, Disable-Feature, Enable-FeatureSilent, Disable-FeatureSilent, Check-FeatureStatus, Show-FeatureActions