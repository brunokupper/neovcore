[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# NEO VCORE V6 - ATUALIZADOR INTELIGENTE (SHA256 + ROLLBACK)
# ============================================================

function Update-NeoVcore {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                ATUALIZADOR INTELIGENTE DO NEOVCORE         |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $installPath = "$env:SystemDrive\NeoVcore"
    $repo = "https://raw.githubusercontent.com/brunokupper/neovcore/main"
    $backupRoot = "$installPath\backup"
    $timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $backupPath = "$backupRoot\$timestamp"

    # Criar pasta de backup
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

    # Arquivos a atualizar
    $fileList = @(
        @{ Remote="$repo/NeoVcore.ps1"; Local="$installPath\NeoVcore.ps1" },
        @{ Remote="$repo/data/features.json"; Local="$installPath\data\features.json" },
        @{ Remote="$repo/data/logs.txt"; Local="$installPath\data\logs.txt" },
        @{ Remote="$repo/data/presets.json"; Local="$installPath\data\presets.json" },
        @{ Remote="$repo/data/Settings.json"; Local="$installPath\data\Settings.json" },
        @{ Remote="$repo/data/version.txt"; Local="$installPath\data\version.txt" }
    )

    # Módulos
    $modules = Get-ChildItem "$installPath\modules" | Select-Object -ExpandProperty Name
    foreach ($m in $modules) {
        $fileList += @{ Remote="$repo/modules/$m"; Local="$installPath\modules\$m" }
    }

    # Vivetool
    $vtFiles = @("ViVeTool.exe","Albacore.ViVe.dll","FeatureDictionary.pfs","Newtonsoft.Json.dll")
    foreach ($v in $vtFiles) {
        $fileList += @{ Remote="$repo/vivetool/$v"; Local="$installPath\vivetool\$v" }
    }

    # ============================================================
    # FUNÇÃO: SHA256
    # ============================================================

    function Get-HashSHA256($path) {
        if (-not (Test-Path $path)) { return "" }
        return (Get-FileHash -Path $path -Algorithm SHA256).Hash
    }

    # ============================================================
    # FUNÇÃO: DOWNLOAD RÁPIDO
    # ============================================================

    function Fast-Download($url, $dest) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
            return $true
        }
        catch {
            return $false
        }
    }

    # ============================================================
    # PROCESSO DE ATUALIZAÇÃO
    # ============================================================

    $total = $fileList.Count
    $index = 0

    Write-Host "Iniciando atualização inteligente..." -ForegroundColor White
    Write-Host ""

    foreach ($file in $fileList) {

        $index++
        $remote = $file.Remote
        $local = $file.Local
        $backup = "$backupPath\" + (Split-Path $local -Leaf)

        Write-Progress -Activity "Atualizando NeoVcore..." `
                       -Status "Processando $index de $total" `
                       -PercentComplete (($index / $total) * 100)

        # Baixar arquivo remoto temporário
        $temp = "$env:TEMP\neo_temp_$index"
        $downloadOK = Fast-Download $remote $temp

        if (-not $downloadOK) {
            Write-Host "[ERRO] Falha ao baixar: $remote" -ForegroundColor Red
            continue
        }

        # Comparar SHA256
        $localHash = Get-HashSHA256 $local
        $remoteHash = Get-HashSHA256 $temp

        if ($localHash -eq $remoteHash -and $localHash -ne "") {
            Write-Host "[SKIP] Sem mudanças: $local" -ForegroundColor DarkGray
            Remove-Item $temp -Force
            continue
        }

        # Backup
        if (Test-Path $local) {
            Copy-Item $local $backup -Force
        }

        # Atualizar
        try {
            Move-Item $temp $local -Force
            Write-Host "[OK] Atualizado: $local" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERRO] Falha ao atualizar: $local" -ForegroundColor Red
        }
    }

    Write-Progress -Activity "Atualização concluída" -Completed

    Write-Host ""
    Write-Host "Atualização concluída com sucesso!" -ForegroundColor Green
    Write-Host "Backup salvo em: $backupPath" -ForegroundColor DarkGray
    Write-Host ""

    Read-Host "Pressione ENTER para abrir o NeoVcore"
    & "$installPath\NeoVcore.ps1"
}