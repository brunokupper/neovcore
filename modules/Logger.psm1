# ============================================================
# NEO VCORE V6 - SISTEMA DE LOGS
# ============================================================

$Global:LogPath = Join-Path $PSScriptRoot "..\data\logs.txt"
$Global:MaxLogSizeKB = 512   # Limite de ~0.5 MB para evitar arquivo gigante

# ------------------------------------------------------------
# Garantir que o arquivo de log exista
# ------------------------------------------------------------
function Initialize-LogFile {

    try {
        if (-not (Test-Path $Global:LogPath)) {
            New-Item -ItemType File -Path $Global:LogPath -Force | Out-Null
        }
    }
    catch {
        Write-Host "Erro ao inicializar arquivo de log." -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# Verificar tamanho do log e rotacionar se necessário
# ------------------------------------------------------------
function Rotate-Logs {

    if (-not (Test-Path $Global:LogPath)) { return }

    try {
        $sizeKB = (Get-Item $Global:LogPath).Length / 1KB

        if ($sizeKB -ge $Global:MaxLogSizeKB) {

            $backup = $Global:LogPath + ".old"

            # Apagar backup antigo se existir
            if (Test-Path $backup) {
                Remove-Item $backup -Force
            }

            # Criar backup
            Rename-Item -Path $Global:LogPath -NewName "logs.txt.old"

            # Criar novo arquivo vazio
            New-Item -ItemType File -Path $Global:LogPath -Force | Out-Null

            Write-Host "Log rotacionado (arquivo estava muito grande)." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Erro ao rotacionar logs." -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# Registrar mensagem no log
# ------------------------------------------------------------
function Write-Log($msg) {

    Initialize-LogFile
    Rotate-Logs

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

    Initialize-LogFile

    try {
        if (Test-Path $Global:LogPath) {
            Get-Content $Global:LogPath
        }
        else {
            Write-Host "Nenhum log encontrado." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "Erro ao ler logs." -ForegroundColor Red
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
            Initialize-LogFile
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
