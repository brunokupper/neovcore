<#  
    ============================================================
    MODULO: SearchID.psm1
    FUNCAO: Buscar feature por ID e gerenciar estado
    AUTOR: Bruno Kupper (@brunokupper)
    VERSAO: 6.0
    ============================================================
#>

function Get-FeatureStateById {

    param([int]$Id)

    $output = vivetool /query 2>$null
    foreach ($line in $output) {
        if ($line -match "Feature\s+ID:\s+$Id\s+State:\s+(\w+)") {
            return $Matches[1]
        }
        elseif ($line -match "ID\s+$Id\s+(\w+)") {
            return $Matches[1]
        }
    }

    return "Desconhecido"
}

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
                vivetool /enable /id:$id
                Write-Host ""
                Write-Host "Recurso ATIVADO." -ForegroundColor Green
                Read-Host "ENTER para continuar"
            }
            "2" {
                vivetool /disable /id:$id
                Write-Host ""
                Write-Host "Recurso DESATIVADO." -ForegroundColor Yellow
                Read-Host "ENTER para continuar"
            }
            "3" {
                return
            }
            default {
                Write-Host "Opcao invalida." -ForegroundColor Red
                Read-Host "ENTER para continuar"
            }
        }
    }
}