[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# NEO VCORE V6 - ATUALIZADOR AUTOMATICO DO NEOVCORE (INTELIGENTE)
# ============================================================

function Update-NeoVcore {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                ATUALIZADOR AUTOMATICO DO NEOVCORE          |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $installPath = "$env:SystemDrive\NeoVcore"
    $localVersionFile = "$installPath\data\version.txt"
    $remoteVersionUrl = "https://raw.githubusercontent.com/brunokupper/neovcore/main/data/version.txt"

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

    Write-Host "Atualizacao disponivel! Comparando arquivos..." -ForegroundColor White

    # ============================
    # FUNÇÃO DE COMPARAÇÃO
    # ============================
    function Compare-And-Update($remoteUrl, $localPath) {
        try {
            $remoteContent = (Invoke-WebRequest $remoteUrl -UseBasicParsing -ErrorAction Stop).Content
        }
        catch {
            Write-Host "Erro ao baixar: $remoteUrl" -ForegroundColor Red
            return
        }

        $localContent = ""
        if (Test-Path $localPath) {
            $localContent = Get-Content $localPath -Raw
        }

        if ($remoteContent -ne $localContent) {
            Write-Host "Atualizando: $localPath" -ForegroundColor Cyan
            $remoteContent | Out-File $localPath -Encoding UTF8
        }
        else {
            Write-Host "Sem mudanças: $localPath" -ForegroundColor DarkGray
        }
    }

    # ============================
    # ATUALIZAR ARQUIVO PRINCIPAL
    # ============================

    $mainLocal = "$installPath\NeoVcore.ps1"
    $mainRemote = "https://raw.githubusercontent.com/brunokupper/neovcore/main/NeoVcore.ps1"

    Write-Host "Criando backup da versao atual..." -ForegroundColor White
    if (Test-Path $mainLocal) {
        Copy-Item $mainLocal "$installPath\NeoVcore_backup.ps1" -Force
    }

    Compare-And-Update $mainRemote $mainLocal

    # ============================
    # ATUALIZAR PASTA DATA
    # ============================

    $dataFiles = @("features.json","logs.txt","presets.json","Settings.json","version.txt")

    foreach ($file in $dataFiles) {
        Compare-And-Update `
            "https://raw.githubusercontent.com/brunokupper/neovcore/main/data/$file" `
            "$installPath\data\$file"
    }

    # ============================
    # ATUALIZAR MÓDULOS
    # ============================

    $modules = Get-ChildItem "$installPath\modules" | Select-Object -ExpandProperty Name

    foreach ($m in $modules) {
        Compare-And-Update `
            "https://raw.githubusercontent.com/brunokupper/neovcore/main/modules/$m" `
            "$installPath\modules\$m"
    }

    # ============================
    # ATUALIZAR VIVETOOL
    # ============================

    $vtFiles = @("ViVeTool.exe","Albacore.ViVe.dll","FeatureDictionary.pfs","Newtonsoft.Json.dll")

    foreach ($v in $vtFiles) {
        Compare-And-Update `
            "https://raw.githubusercontent.com/brunokupper/neovcore/main/vivetool/$v" `
            "$installPath\vivetool\$v"
    }

    # ============================
    # FINALIZAÇÃO
    # ============================

    Write-Host ""
    Write-Host "NeoVcore atualizado com sucesso!" -ForegroundColor Green
    Write-Host "Backup salvo como NeoVcore_backup.ps1" -ForegroundColor DarkGray
    Write-Host ""

    Read-Host "Pressione ENTER para abrir o NeoVcore"
    & "$installPath\NeoVcore.ps1"
}