[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#  
    ============================================================
    MÓDULO: Maintenance.psm1
    FUNÇÃO: Manutenção geral do sistema
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

function Show-MaintenanceMenu {

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                        MANUTENCAO DO SISTEMA               |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "1) Limpar Arquivos Temporarios"
        Write-Host "2) Limpar Cache do Sistema"
        Write-Host "3) Reparar Componentes (DISM)"
        Write-Host "4) Verificar Integridade (SFC)"
		Write-Host ""
        Write-Host "0) Voltar"                      -ForegroundColor red
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {
            "1" { Clear-TempFiles }
            "2" { Clear-SystemCache }
            "3" { Repair-DISM }
            "4" { Repair-SFC }
            "0" { return }
            default {
                Write-Host ""
                Write-Host "Opcao invalida." -ForegroundColor Red
                Read-Host "Pressione ENTER para tentar novamente"
            }
        }
    }
}

# =====================================================================
# LIMPAR ARQUIVOS TEMPORÁRIOS
# =====================================================================

function Clear-TempFiles {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                   LIMPEZA DE ARQUIVOS TEMPORARIOS          |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Limpando arquivos temporarios..." -ForegroundColor DarkGray

    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Arquivos temporarios limpos!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# LIMPAR CACHE DO SISTEMA
# =====================================================================

function Clear-SystemCache {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                       LIMPEZA DE CACHE                     |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Limpando cache do sistema..." -ForegroundColor DarkGray

    # Flush DNS
    ipconfig /flushdns | Out-Null

    # Limpar thumbcache (PowerShell puro)
    $thumbcache = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Explorer\thumbcache_*.db"
    Remove-Item $thumbcache -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Cache limpo!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# REPARAR COMPONENTES (DISM)
# =====================================================================

function Repair-DISM {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                     REPARANDO COMPONENTES (DISM)           |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: DISM /Online /Cleanup-Image /RestoreHealth" -ForegroundColor DarkGray
    Write-Host ""

    DISM /Online /Cleanup-Image /RestoreHealth

    Write-Host ""
    Write-Host "DISM concluido!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# VERIFICAR INTEGRIDADE (SFC)
# =====================================================================

function Repair-SFC {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                     VERIFICANDO INTEGRIDADE (SFC)          |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Executando: sfc /scannow" -ForegroundColor DarkGray
    Write-Host ""

    sfc /scannow

    Write-Host ""
    Write-Host "Verificacao concluida!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"

}
