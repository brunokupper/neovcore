# ============================================================
# NEO VCORE V6 - ATUALIZADOR AUTOMATICO DO NEOVCORE
# ============================================================

function Update-NeoVcore {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                ATUALIZADOR AUTOMATICO DO NEOVCORE          |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    # Caminhos principais
    $installPath = "$env:SystemDrive\NeoVcore"
    $localVersionFile = "$installPath\data\version.txt"
    $remoteVersionUrl = "https://raw.githubusercontent.com/brunokupper/neovcore/main/data/version.txt"
    $remoteMainScript = "https://raw.githubusercontent.com/brunokupper/neovcore/main/NeoVcore.ps1"

    Write-Host "Verificando versao remota..." -ForegroundColor White

    # Ler versão local
    $localVersion = ""
    if (Test-Path $localVersionFile) {
        $localVersion = Get-Content $localVersionFile -Raw
    }

    # Ler versão remota
    try {
        $remoteVersion = (Invoke-WebRequest $remoteVersionUrl -UseBasicParsing -ErrorAction Stop).Content.Trim()
    }
    catch {
        Write-Host "Erro: Nao foi possivel verificar a versao remota." -ForegroundColor Red
        Write-Log "Falha ao verificar versao remota"
        return
    }

    if (-not $remoteVersion) {
        Write-Host "Erro: Versao remota vazia." -ForegroundColor Red
        Write-Log "Versao remota vazia"
        return
    }

    Write-Host ""
    Write-Host "Versao instalada: $localVersion" -ForegroundColor DarkGray
    Write-Host "Versao disponivel: $remoteVersion" -ForegroundColor DarkGray
    Write-Host ""

    # Se já estiver atualizado
    if ($localVersion -eq $remoteVersion -and $localVersion -ne "") {
        Write-Host "NeoVcore ja esta atualizado!" -ForegroundColor Green
        Write-Host ""
        Read-Host "Pressione ENTER para abrir o NeoVcore"
        & "$installPath\NeoVcore.ps1"
        return
    }

    Write-Host "Atualizacao disponivel! Baixando nova versao..." -ForegroundColor White

    # Baixar script principal
    try {
        $remote = Invoke-WebRequest -Uri $remoteMainScript -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Host "Erro: Nao foi possivel baixar a nova versao." -ForegroundColor Red
        Write-Log "Falha ao baixar NeoVcore.ps1 remoto"
        return
    }

    if (-not $remote.Content) {
        Write-Host "Erro: Conteudo remoto vazio." -ForegroundColor Red
        Write-Log "Conteudo remoto vazio ao atualizar NeoVcore"
        return
    }

    # Caminhos
    $localPath  = "$installPath\NeoVcore.ps1"
    $backupPath = "$installPath\NeoVcore_backup.ps1"

    Write-Host "Criando backup da versao atual..." -ForegroundColor White

    try {
        if (Test-Path $localPath) {
            Copy-Item $localPath $backupPath -Force
            Write-Log "Backup do NeoVcore criado"
        }
        else {
            Write-Log "Nenhum arquivo local encontrado para backup (instalacao nova)"
        }
    }
    catch {
        Write-Host "Erro ao criar backup." -ForegroundColor Red
        Write-Log "Falha ao criar backup"
        return
    }

    Write-Host "Aplicando nova versao..." -ForegroundColor White

    try {
        $remote.Content | Out-File $localPath -Encoding UTF8
        Write-Log "NeoVcore atualizado com sucesso"
    }
    catch {
        Write-Host "Erro ao aplicar atualizacao." -ForegroundColor Red
        Write-Log "Falha ao aplicar atualizacao"
        return
    }

    # Atualizar version.txt
    try {
        $remoteVersion | Out-File $localVersionFile -Encoding UTF8
    }
    catch {
        Write-Host "Aviso: Nao foi possivel atualizar version.txt" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "NeoVcore atualizado com sucesso!" -ForegroundColor Green
    Write-Host "Backup salvo como NeoVcore_backup.ps1" -ForegroundColor DarkGray
    Write-Host ""

    Read-Host "Pressione ENTER para abrir o NeoVcore"
    & "$installPath\NeoVcore.ps1"
}
