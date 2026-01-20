# ============================================================
# NEO VCORE V6 - SISTEMA DE VERSAO
# ============================================================

$Global:VersionPath = Join-Path $PSScriptRoot "..\data\version.txt"
$Global:RemoteVersionUrl = "https://raw.githubusercontent.com/brunokupper/neovcore/main/data/version.txt"

# ------------------------------------------------------------
# Inicializar arquivo de versao se nao existir
# ------------------------------------------------------------
function Initialize-VersionFile {

    if (-not (Test-Path $Global:VersionPath)) {
        "6.0.0" | Out-File $Global:VersionPath -Encoding UTF8
        Write-Log "Arquivo version.txt criado com versao inicial 6.0.0"
    }
}

# ------------------------------------------------------------
# Obter versao atual do NeoVcore
# ------------------------------------------------------------
function Get-NeoVcoreVersion {

    Initialize-VersionFile

    try {
        return (Get-Content $Global:VersionPath -Raw).Trim()
    }
    catch {
        Write-Host "Erro ao ler versao. Usando 0.0.0." -ForegroundColor Yellow
        Write-Log "Falha ao ler version.txt - usando 0.0.0"
        return "0.0.0"
    }
}

# ------------------------------------------------------------
# Obter versao remota do NeoVcore
# ------------------------------------------------------------
function Get-RemoteNeoVcoreVersion {

    try {
        $remote = Invoke-WebRequest -Uri $Global:RemoteVersionUrl -UseBasicParsing
        return $remote.Content.Trim()
    }
    catch {
        Write-Host "Erro ao verificar versao remota." -ForegroundColor Red
        Write-Log "Falha ao obter versao remota"
        return $null
    }
}

# ------------------------------------------------------------
# Comparar versoes (retorna True se houver nova versao)
# ------------------------------------------------------------
function Test-NeoVcoreUpdateAvailable {

    $local  = Get-NeoVcoreVersion
    $remote = Get-RemoteNeoVcoreVersion

    if (-not $remote) {
        return $false
    }

    if ($local -ne $remote) {
        return $true
    }

    return $false
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
        Write-Log "Falha ao salvar nova versao no version.txt"
    }
}
