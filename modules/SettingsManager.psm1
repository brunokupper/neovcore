[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# NEO VCORE V6 - GERENCIAMENTO DE CONFIGURACOES
# ============================================================

$Global:SettingsPath = Join-Path $PSScriptRoot "..\data\settings.json"

# Criar objeto global se não existir
if (-not $Global:NeoVcoreSettings) {
    $Global:NeoVcoreSettings = [ordered]@{
        Theme  = "dark"
        Sounds = $true
        Turbo  = $false
    }
}

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

        try {
            $default | Out-File $Global:SettingsPath -Encoding UTF8
            Write-Log "Arquivo settings.json criado com configuracoes padrao"
        }
        catch {
            Write-Host "Erro ao criar settings.json." -ForegroundColor Red
            Write-Log "Falha ao criar settings.json"
        }
    }
}

# ------------------------------------------------------------
# Carregar configuracoes
# ------------------------------------------------------------
function Load-Settings {

    Initialize-Settings

    try {
        $json = Get-Content $Global:SettingsPath -Raw | ConvertFrom-Json

        # Garantir que todas as chaves existam
        $Global:NeoVcoreSettings.Theme  = $json.Theme
        $Global:NeoVcoreSettings.Sounds = $json.Sounds
        $Global:NeoVcoreSettings.Turbo  = $json.Turbo

        Write-Log "Configuracoes carregadas com sucesso"
    }
    catch {
        Write-Host "Erro ao carregar configuracoes. Usando padrao." -ForegroundColor Yellow
        Write-Log "Falha ao carregar settings.json - usando configuracoes padrao"

        # Restaurar valores padrão
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

    try {
        $json | Out-File $Global:SettingsPath -Encoding UTF8
        Write-Log "Configuracoes salvas"
    }
    catch {
        Write-Host "Erro ao salvar configuracoes." -ForegroundColor Red
        Write-Log "Falha ao salvar settings.json"
    }
}

