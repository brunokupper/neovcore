<#  
    ============================================================
    MÓDULO: Vivetool.psm1
    FUNÇÃO: Executar comandos do Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

# Caminho do executável Vivetool
$Global:VivetoolPath = "$($env:SystemDrive)\neovcore\vivetool\vivetool.exe"

# ============================================================
# EXECUTAR VIVETOOL
# ============================================================

function Enable-Feature {
    param ([int]$FeatureID)

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    ATIVANDO RECURSO...                    |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: vivetool /enable /id:$FeatureID" -ForegroundColor DarkGray
    Write-Host ""

    & $Global:VivetoolPath /enable /id:$FeatureID

    Write-Host ""
    Write-Host "Recurso ativado com sucesso!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

function Disable-Feature {
    param ([int]$FeatureID)

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                   DESATIVANDO RECURSO...                   |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: vivetool /disable /id:$FeatureID" -ForegroundColor DarkGray
    Write-Host ""

    & $Global:VivetoolPath /disable /id:$FeatureID

    Write-Host ""
    Write-Host "Recurso desativado com sucesso!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

function Check-FeatureStatus {
    param ([int]$FeatureID)

    # Executa o vivetool e captura a saída
    $output = & $Global:VivetoolPath /query /id:$FeatureID 2>$null

    # Procura pela linha que contém "State"
    $stateLine = $output | Where-Object { $_ -match "State" }

    if ($stateLine -match "Enabled") {
        return "Ativado"
    }
    elseif ($stateLine -match "Disabled") {
        return "Desativado"
    }
    else {
        return "Desconhecido"
    }
}

# ============================================================
# MENU DE AÇÕES DO RECURSO (NUMÉRICO)
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
        Write-Host "0) Voltar"                      -ForegroundColor red
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