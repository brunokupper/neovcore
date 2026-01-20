function Update-FeaturesJson {

    Clear-Host
    Write-Host "ATUALIZADOR DO FEATURES.JSON"
    Write-Host ""

    $local = Join-Path $PSScriptRoot "..\data\features.json"
    $backup = Join-Path $PSScriptRoot "..\data\features_backup.json"

    $url = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/features.json"

    try {
        $remote = Invoke-WebRequest -Uri $url -UseBasicParsing
    }
    catch {
    Write-Host "Erro ao baixar arquivo remoto." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkGray
    Read-Host "ENTER para continuar"
    return
}

    try {
        $remote.Content | ConvertFrom-Json | Out-Null
    }
    catch {
        Write-Host "JSON remoto invalido."
        return
    }

    Copy-Item $local $backup -Force
    $remote.Content | Out-File $local -Encoding UTF8

    Write-Host "Atualizado com sucesso."
    Read-Host "ENTER para continuar"
}