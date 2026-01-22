[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# NEO VCORE V6 - ROLLBACK DO FEATURES.JSON
# ============================================================

function Rollback-FeaturesJson {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                 ROLLBACK DO FEATURES.JSON                  |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $path   = Join-Path $PSScriptRoot "..\data\features.json"
    $backup = Join-Path $PSScriptRoot "..\data\features_backup.json"

    if (-not (Test-Path $backup)) {
        Write-Host "Nenhum backup encontrado. Nao ha como restaurar." -ForegroundColor Red
        Write-Log "Falha no rollback: backup inexistente"
        Start-Sleep 1
        return
    }

    try {
        Copy-Item $backup $path -Force
        Write-Host "Rollback concluido com sucesso!" -ForegroundColor Green
        Write-Log "Rollback do features.json realizado com sucesso"
    }
    catch {
        Write-Host "Erro ao restaurar o arquivo." -ForegroundColor Red
        Write-Log "Erro ao tentar restaurar features.json"
    }

    Start-Sleep 1

}
