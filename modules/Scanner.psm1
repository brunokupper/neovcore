<#  
    ============================================================
    MODULO: Scanner.psm1
    FUNCAO: Scanner automatico de features via Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSAO: 6.0
    ============================================================
#>

function Get-EnabledFeaturesRaw {

    $output = vivetool /query 2>$null
    $enabled = @()

    foreach ($line in $output) {
        if ($line -match "Enabled\s+(\d+)") {
            $enabled += [int]$Matches[1]
        }
        elseif ($line -match "Feature\s+ID:\s+(\d+)\s+State:\s+Enabled") {
            $enabled += [int]$Matches[1]
        }
    }

    $enabled = $enabled | Sort-Object -Unique
    return $enabled
}

function Get-AllQueriedFeaturesRaw {

    $output = vivetool /query 2>$null
    $all = @()

    foreach ($line in $output) {
        if ($line -match "Feature\s+ID:\s+(\d+)\s+State:\s+(\w+)") {
            $all += [PSCustomObject]@{
                Id    = [int]$Matches[1]
                State = $Matches[2]
            }
        }
        elseif ($line -match "ID\s+(\d+)\s+(\w+)") {
            $all += [PSCustomObject]@{
                Id    = [int]$Matches[1]
                State = $Matches[2]
            }
        }
    }

    $all = $all | Sort-Object Id -Unique
    return $all
}

function Show-FeatureScannerMenu {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    SCANNER DE FEATURES VIVETOOL            |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $allJson = Get-AllFeaturesFlat
    $allQuery = Get-AllQueriedFeaturesRaw

    if (-not $allQuery -or $allQuery.Count -eq 0) {
        Write-Host "Nenhum dado retornado pelo vivetool /query." -ForegroundColor Red
        Read-Host "Pressione ENTER para continuar"
        return
    }

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