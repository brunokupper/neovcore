# ============================================================
# NEO VCORE V6 - SISTEMA DE VERSAO
# ============================================================

$Global:VersionPath = Join-Path $PSScriptRoot "..\data\version.txt"

# ------------------------------------------------------------
# Inicializar arquivo de versao se nao existir
# ------------------------------------------------------------
function Initialize-VersionFile {

    if (-not (Test-Path $Global:VersionPath)) {
        "6.0.0" | Out-File $Global:VersionPath -Encoding UTF8
    }
}

# ------------------------------------------------------------
# Obter versao atual do NeoVcore
# ------------------------------------------------------------
function Get-NeoVcoreVersion {

    Initialize-VersionFile

    try {
        return Get-Content $Global:VersionPath -Raw
    }
    catch {
        Write-Host "Erro ao ler versao. Usando 0.0.0." -ForegroundColor Yellow
        return "0.0.0"
    }
}

# ------------------------------------------------------------
# Definir nova versao do NeoVcore
# ------------------------------------------------------------
function Set-NeoVcoreVersion($version) {

    try {
        $version | Out-File $Global:VersionPath -Encoding UTF8
        Write-Log "Versao do NeoVcore atualizada para $version"
    }
    catch {
        Write-Host "Erro ao salvar nova versao." -ForegroundColor Red
    }
}