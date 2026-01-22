[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function Update-FeaturesJson {

    Clear-Host
    Write-Host "ATUALIZADOR DO FEATURES.JSON"
    Write-Host ""

    # Caminhos locais
    $local  = Join-Path $PSScriptRoot "..\data\features.json"
    $backup = Join-Path $PSScriptRoot "..\data\features_backup.json"

    # Caminho remoto atualizado
    $url = "https://raw.githubusercontent.com/brunokupper/neovcore/main/data/features.json"

    Write-Host "Baixando arquivo remoto..." -ForegroundColor White

    try {
        $remote = Invoke-WebRequest -Uri $url -UseBasicParsing
    }
    catch {
        Write-Host "Erro ao baixar arquivo remoto." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkGray
        Write-Log "Falha ao baixar features.json remoto"
        Read-Host "ENTER para continuar"
        return
    }

    if (-not $remote.Content) {
        Write-Host "Erro: Conteudo remoto vazio." -ForegroundColor Red
        Write-Log "features.json remoto vazio"
        Read-Host "ENTER para continuar"
        return
    }

    # Validar JSON
    try {
        $remote.Content | ConvertFrom-Json | Out-Null
    }
    catch {
        Write-Host "JSON remoto invalido." -ForegroundColor Red
        Write-Log "JSON remoto invalido em features.json"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host "Criando backup..." -ForegroundColor White

    try {
        Copy-Item $local $backup -Force
        Write-Log "Backup de features.json criado"
    }
    catch {
        Write-Host "Erro ao criar backup." -ForegroundColor Red
        Write-Log "Falha ao criar backup de features.json"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host "Aplicando nova versao..." -ForegroundColor White

    try {
        $remote.Content | Out-File $local -Encoding UTF8
        Write-Log "features.json atualizado com sucesso"
    }
    catch {
        Write-Host "Erro ao aplicar atualizacao." -ForegroundColor Red
        Write-Log "Falha ao atualizar features.json"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host ""
    Write-Host "Atualizado com sucesso." -ForegroundColor Green
    Write-Host ""
    Read-Host "ENTER para continuar"
}

