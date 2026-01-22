[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#  
    ============================================================
    MÓDULO: Optimization.psm1
    FUNÇÃO: Otimizações gerais do sistema
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

function Show-OptimizationMenu {

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                        OTIMIZACAO DO SISTEMA               |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "1) Otimizar Servicos"
        Write-Host "2) Otimizar Rede"
        Write-Host "3) Otimizar Energia"
        Write-Host "4) Otimizar Sistema"
		Write-Host ""
        Write-Host "0) Voltar"                      -ForegroundColor red

        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {
            "1" { Optimize-Services }
            "2" { Optimize-Network }
            "3" { Optimize-Power }
            "4" { Optimize-System }
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
# OTIMIZAR SERVICOS
# =====================================================================

function Optimize-Services {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                        OTIMIZANDO SERVICOS                 |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $services = @(
        "DiagTrack"
        "SysMain"
        "WSearch"
    )

    foreach ($svc in $services) {
        Write-Host "Desativando: $svc" -ForegroundColor DarkGray
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Host "Servicos otimizados!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# OTIMIZAR REDE
# =====================================================================

function Optimize-Network {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                         OTIMIZANDO REDE                    |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Aplicando ajustes de rede..." -ForegroundColor DarkGray

    netsh int tcp set global autotuninglevel=normal | Out-Null
    netsh int tcp set global rss=enabled | Out-Null
    netsh int tcp set global chimney=enabled | Out-Null

    Write-Host ""
    Write-Host "Rede otimizada!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# OTIMIZAR ENERGIA
# =====================================================================

function Optimize-Power {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                        OTIMIZANDO ENERGIA                  |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Ativando plano de energia Alto Desempenho..." -ForegroundColor DarkGray

    powercfg -setactive SCHEME_MIN | Out-Null

    Write-Host ""
    Write-Host "Energia otimizada!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# OTIMIZAR SISTEMA
# =====================================================================

function Optimize-System {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                        OTIMIZANDO SISTEMA                  |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Aplicando ajustes gerais..." -ForegroundColor DarkGray

    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f | Out-Null

    Write-Host ""
    Write-Host "Sistema otimizado!" -ForegroundColor Green
    Read-Host "Pressione ENTER para continuar"

}
