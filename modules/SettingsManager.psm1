# ============================================================
# NEO VCORE V6 - GERENCIAMENTO DE CONFIGURACOES
# ============================================================

$Global:SettingsPath = Join-Path $PSScriptRoot "..\data\settings.json"

# ------------------------------------------------------------
# Criar arquivo de configuracoes se nao existir
# ------------------------------------------------------------
function Initialize-Settings {

    if (-not (Test-Path $Global:SettingsPath)) {

        $default = @{
            Theme  = "dark"
            Sounds = $true
            Turbo  = $false
        } | ConvertTo-Json -Depth 5

        $default | Out-File $Global:SettingsPath -Encoding UTF8
    }
}

# ------------------------------------------------------------
# Carregar configuracoes
# ------------------------------------------------------------
function Load-Settings {

    Initialize-Settings

    try {
        $json = Get-Content $Global:SettingsPath -Raw | ConvertFrom-Json

        $Global:NeoVcoreSettings.Theme  = $json.Theme
        $Global:NeoVcoreSettings.Sounds = $json.Sounds
        $Global:NeoVcoreSettings.Turbo  = $json.Turbo
    }
    catch {
        Write-Host "Erro ao carregar configuracoes. Usando padrao." -ForegroundColor Yellow

        $Global:NeoVcoreSettings.Theme  = "dark"
        $Global:NeoVcoreSettings.Sounds = $true
        $Global:NeoVcoreSettings.Turbo  = $false

        Save-Settings
    }
}

# ------------------------------------------------------------
# Salvar configuracoes
# ------------------------------------------------------------
function Save-Settings {

    $json = @{
        Theme  = $Global:NeoVcoreSettings.Theme
        Sounds = $Global:NeoVcoreSettings.Sounds
        Turbo  = $Global:NeoVcoreSettings.Turbo
    } | ConvertTo-Json -Depth 5

    $json | Out-File $Global:SettingsPath -Encoding UTF8
}