<#  
    ============================================================
    MODULO: Scanner.psm1
    FUNCAO: Scanner automatico de features via Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSAO: 6.1
    ============================================================
#>

# ------------------------------------------------------------
# Obter lista de features ativas diretamente do Vivetool
# ------------------------------------------------------------
function Get-EnabledFeaturesRaw {

    try {
        $output = vivetool /query 2>$null
    }
    catch {
        Write-Host "Erro ao executar vivetool /query" -ForegroundColor Red
        Write-Log "Falha ao executar vivetool /query"
        return @()
    }

    $enabled = @()

    foreach ($line in $output) {

        # Formato antigo do ViVeTool
        if ($line -match "Enabled\s+(\d+)") {
            $enabled += [int]$Matches[1]
        }

        # Formato novo do ViVeTool
        elseif ($line -match "Feature\s+ID:\s+(\d+)\s+State:\s+Enabled") {
            $enabled += [int]$Matches[1]
        }
    }

    return $enabled | Sort-Object -Unique
}

# ------------------------------------------------------------
# Obter todas as features detectadas pelo Vivetool
# ------------------------------------------------------------
function Get-AllQueriedFeaturesRaw {

    try {
        $output = vivetool /query 2>$null
    }
    catch {
        Write-Host "Erro ao executar vivetool /query" -ForegroundColor Red
        Write-Log "Falha ao executar vivetool /query"
        return @()
    }

    $all = @()

    foreach ($line in $output) {

        # Formato novo
        if ($line -match "Feature\s+ID:\s+(\d+)\s+State:\s+(\w+)") {
            $all += [PSCustomObject]@{
                Id    = [int]$Matches[1]
                State = $Matches[2]
            }
        }

        # Formato antigo
        elseif ($line -match "ID\s+(\d+)\s+(\w+)") {
            $all += [PSCustomObject]@{
                Id    = [int]$Matches[1]
                State = $Matches[2]
            }
        }
    }

    return $all | Sort-Object Id -Unique
}

# ------------------------------------------------------------
# Menu visual do scanner
# ------------------------------------------------------------
function Show-FeatureScannerMenu {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    SCANNER DE FEATURES VIVETOOL            |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    # Carregar JSON de features
    $allJson = Get-AllFeaturesFlat
    if (-not $allJson) {
        Write-Host "Erro: features.json nao carregado." -ForegroundColor Red
        Write-Log "Falha ao carregar features.json no scanner"
        Read-Host "Pressione ENTER para continuar"
        return
    }

    # Executar scanner
    $allQuery = Get-AllQueriedFeaturesRaw

    if (-not $allQuery -or $allQuery.Count -eq 0) {
        Write-Host "Nenhum dado retornado pelo vivetool /query." -ForegroundColor Red
        Write-Log "vivetool /query retornou vazio"
        Read-Host "Pressione ENTER para continuar"
        return
    }

    # ------------------------------
    # FEATURES ATIVAS
    # ------------------------------
    Write-Host "=== FEATURES ATIVOS DETECTADOS ===" -ForegroundColor Green

    foreach ($item in $allQuery | Where-Object { $_.State -match 'Enabled' }) {

        $match = $allJson | Where-Object { $_.Id -eq $item.Id }

        if ($match) {
            Write-Host "* $($item.Id) - $($match.Name) [$($match.Category)]"
        }
        else {
            Write-Host "* $($item.Id) - (nao encontrado no JSON)"
        }
    }

    Write-Host ""

    # ------------------------------
    # FEATURES DESATIVADAS
    # ------------------------------
    Write-Host "=== FEATURES DESATIVADOS DETECTADOS ===" -ForegroundColor Yellow

    foreach ($item in $allQuery | Where-Object { $_.State -match 'Disabled' }) {

        $match = $allJson | Where-Object { $_.Id -eq $item.Id }

        if ($match) {
            Write-Host "  $($item.Id) - $($match.Name) [$($match.Category)]"
        }
        else {
            Write-Host "  $($item.Id) - (nao encontrado no JSON)"
        }
    }

    Write-Host ""

    # ------------------------------
    # FEATURES DESCONHECIDAS
    # ------------------------------
    Write-Host "=== FEATURES DESCONHECIDOS (nao estao no JSON) ===" -ForegroundColor Cyan

    foreach ($item in $allQuery) {

        $match = $allJson | Where-Object { $_.Id -eq $item.Id }

        if (-not $match) {
            Write-Host "  $($item.Id) - Estado: $($item.State)"
        }
    }

    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}
