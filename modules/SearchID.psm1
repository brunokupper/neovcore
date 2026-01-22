[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#  
    ============================================================
    MODULO: SearchID.psm1
    FUNCAO: Buscar feature por ID e gerenciar estado
    AUTOR: Bruno Kupper (@brunokupper)
    VERSAO: 6.1
    ============================================================
#>

# ------------------------------------------------------------
# Obter estado de uma feature via Vivetool
# ------------------------------------------------------------
function Get-FeatureStateById {

    param([int]$Id)

    if ($Id -le 0) {
        Write-Log "ID inválido consultado: $Id"
        return "Inválido"
    }

    try {
        $output = vivetool /query /id:$Id 2>$null
    }
    catch {
        Write-Log "Erro ao executar vivetool /query para ID $Id"
        return "Erro"
    }

    foreach ($line in $output) {

        # Formato novo
        if ($line -match "Feature\s+ID:\s+$Id\s+State:\s+(\w+)") {
            return $Matches[1]
        }

        # Formato antigo
        elseif ($line -match "ID\s+$Id\s+(\w+)") {
            return $Matches[1]
        }
    }

    return "Desconhecido"
}

# ------------------------------------------------------------
# Menu de busca por ID
# ------------------------------------------------------------
function Show-SearchByIdMenu {

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                         BUSCAR POR ID                      |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        $input = Read-Host "Digite o ID (ou deixe vazio para voltar)"

        if ([string]::IsNullOrWhiteSpace($input)) { return }

        if (-not ($input -match '^\d+$')) {
            Write-Host "ID invalido. Digite apenas numeros." -ForegroundColor Red
            Read-Host "ENTER para continuar"
            continue
        }

        $id = [int]$input
        $all = Get-AllFeaturesFlat
        $match = $all | Where-Object { $_.Id -eq $id }

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                         RESULTADO DA BUSCA                 |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        if ($match) {
            Write-Host "ID:        $($match.Id)"
            Write-Host "Nome:      $($match.Name)"
            Write-Host "Categoria: $($match.Category)"
        }
        else {
            Write-Host "ID:        $id"
            Write-Host "Nome:      (nao encontrado no JSON)"
            Write-Host "Categoria: (desconhecida)"
        }

        $state = Get-FeatureStateById -Id $id
        Write-Host "Estado atual (via vivetool /query): $state"
        Write-Host ""

        Write-Host "1) Ativar"
        Write-Host "2) Desativar"
        Write-Host "3) Voltar"
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {

            "1" {
                try {
                    vivetool /enable /id:$id 2>$null
                    Write-Log "Feature $id ativada via SearchID"
                    Write-Host ""
                    Write-Host "Recurso ATIVADO." -ForegroundColor Green
                }
                catch {
                    Write-Host "Erro ao ativar recurso." -ForegroundColor Red
                    Write-Log "Erro ao ativar feature $id via SearchID"
                }
                Read-Host "ENTER para continuar"
            }

            "2" {
                try {
                    vivetool /disable /id:$id 2>$null
                    Write-Log "Feature $id desativada via SearchID"
                    Write-Host ""
                    Write-Host "Recurso DESATIVADO." -ForegroundColor Yellow
                }
                catch {
                    Write-Host "Erro ao desativar recurso." -ForegroundColor Red
                    Write-Log "Erro ao desativar feature $id via SearchID"
                }
                Read-Host "ENTER para continuar"
            }

            "3" { return }

            default {
                Write-Host "Opcao invalida." -ForegroundColor Red
                Read-Host "ENTER para continuar"
            }
        }
    }
}

