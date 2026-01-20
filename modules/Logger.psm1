# ============================================================
# NEO VCORE V6 - SISTEMA DE LOGS
# ============================================================

$Global:LogPath = Join-Path $PSScriptRoot "..\data\logs.txt"

# ------------------------------------------------------------
# Registrar mensagem no log
# ------------------------------------------------------------
function Write-Log($msg) {

    try {
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        "$timestamp - $msg" | Out-File $Global:LogPath -Append -Encoding UTF8
    }
    catch {
        Write-Host "Erro ao escrever no log." -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# Exibir logs
# ------------------------------------------------------------
function Show-Logs {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                        LOGS DO SISTEMA                     |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    if (Test-Path $Global:LogPath) {
        Get-Content $Global:LogPath
    }
    else {
        Write-Host "Nenhum log encontrado." -ForegroundColor DarkGray
    }

    Write-Host ""
    Read-Host "Pressione ENTER para voltar"
}

# ------------------------------------------------------------
# Limpar logs
# ------------------------------------------------------------
function Clear-Logs {

    if (Test-Path $Global:LogPath) {
        try {
            Remove-Item $Global:LogPath -Force
            Write-Host "Logs apagados com sucesso." -ForegroundColor Yellow
            Write-Log "Logs apagados manualmente"
        }
        catch {
            Write-Host "Erro ao apagar logs." -ForegroundColor Red
        }
    }
    else {
        Write-Host "Nenhum log para apagar." -ForegroundColor DarkGray
    }

    Start-Sleep 1
}