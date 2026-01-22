[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#  
    ============================================================
    MÓDULO: AdvancedTools.psm1
    FUNÇÃO: Ferramentas avançadas do sistema
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

function Show-AdvancedToolsMenu {

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                     FERRAMENTAS AVANCADAS                  |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "1) Gerenciar Processos"
        Write-Host "2) Monitorar Sistema"
        Write-Host "3) Ferramentas Administrativas"
        Write-Host "4) Utilidades Avancadas"
		Write-Host ""
        Write-Host "0) Voltar"                      -ForegroundColor red
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {
            "1" { Manage-Processes }
            "2" { Monitor-System }
            "3" { Admin-Tools }
            "4" { Advanced-Utilities }
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
# GERENCIAR PROCESSOS
# =====================================================================

function Manage-Processes {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                       GERENCIAR PROCESSOS                  |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize

    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# MONITORAR SISTEMA (corrigido)
# =====================================================================

function Monitor-System {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                       MONITORAMENTO DO SISTEMA             |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Uso de CPU, Memoria e Disco:" -ForegroundColor DarkGray
    Write-Host ""

    # CPU
    $cpu = (Get-CimInstance Win32_Processor).LoadPercentage
    Write-Host "CPU: $cpu%"

    # Memória
    $mem = Get-CimInstance Win32_OperatingSystem
    $freeMB = [math]::Round($mem.FreePhysicalMemory / 1024, 2)
    $totalMB = [math]::Round($mem.TotalVisibleMemorySize / 1024, 2)
    $usedMB = $totalMB - $freeMB
    Write-Host "Memoria: $usedMB MB / $totalMB MB"

    # Disco
    $disk = Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk |
            Where-Object { $_.Name -eq "_Total" }

    Write-Host "Disco: $($disk.PercentDiskTime)%"

    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# FERRAMENTAS ADMINISTRATIVAS
# =====================================================================

function Admin-Tools {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    FERRAMENTAS ADMINISTRATIVAS             |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    control admintools

    Write-Host ""
    Read-Host "Pressione ENTER para continuar"
}

# =====================================================================
# UTILIDADES AVANÇADAS
# =====================================================================

function Advanced-Utilities {

    Clear-Host
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                       UTILIDADES AVANCADAS                 |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "1) Abrir Editor de Registro"
    Write-Host "2) Abrir Gerenciador de Dispositivos"
    Write-Host "3) Abrir Configuracoes Avancadas do Sistema"
	Write-Host ""
        Write-Host "0) Voltar"                      -ForegroundColor red
    Write-Host ""

    $choice = Read-Host "Escolha"

    switch ($choice) {
        "1" { regedit }
        "2" { devmgmt.msc }
        "3" { SystemPropertiesAdvanced.exe }
        "0" { return }
        default {
            Write-Host "Opcao invalida." -ForegroundColor Red
            Read-Host "Pressione ENTER para continuar"
        }
    }

}
