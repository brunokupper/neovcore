# ============================================================
# NEO VCORE V6 - ATUALIZADOR AUTOMATICO DO NEOVCORE
# ============================================================

function Update-NeoVcore {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                ATUALIZADOR AUTOMATICO DO NEOVCORE          |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    # URL do repositório remoto (AJUSTE AQUI)
    $remoteUrl = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/NeoVcore.ps1"

    Write-Host "Baixando versao remota..." -ForegroundColor White

    try {
        $remote = Invoke-WebRequest -Uri $remoteUrl -UseBasicParsing
    }
    catch {
        Write-Host "Erro: Nao foi possivel baixar a versao remota." -ForegroundColor Red
        Write-Log "Falha ao baixar versao remota do NeoVcore"
        Start-Sleep 1
        return
    }

    if (-not $remote.Content) {
        Write-Host "Erro: Conteudo remoto vazio." -ForegroundColor Red
        Write-Log "Conteudo remoto vazio ao atualizar NeoVcore"
        return
    }

    # Caminhos
    $localPath  = Join-Path $PSScriptRoot "..\NeoVcore.ps1"
    $backupPath = Join-Path $PSScriptRoot "..\NeoVcore_backup.ps1"

    Write-Host "Criando backup da versao atual..." -ForegroundColor White

    try {
        Copy-Item $localPath $backupPath -Force
        Write-Log "Backup do NeoVcore criado"
    }
    catch {
        Write-Host "Erro ao criar backup." -ForegroundColor Red
        Write-Log "Falha ao criar backup do NeoVcore"
        return
    }

    Write-Host "Aplicando nova versao..." -ForegroundColor White

    try {
        $remote.Content | Out-File $localPath -Encoding UTF8
        Write-Log "NeoVcore atualizado com sucesso"
    }
    catch {
        Write-Host "Erro ao aplicar atualizacao." -ForegroundColor Red
        Write-Log "Falha ao aplicar atualizacao do NeoVcore"
        return
    }

    Write-Host ""
    Write-Host "NeoVcore atualizado com sucesso!" -ForegroundColor Green
    Write-Host "Backup salvo como NeoVcore_backup.ps1" -ForegroundColor DarkGray
    Write-Host ""

    Read-Host "Pressione ENTER para continuar"
}