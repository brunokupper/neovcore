<#
    ============================================================
    MÓDULO: SystemInfo.psm1
    FUNÇÃO: Exibir informações detalhadas do sistema
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

function Show-SystemInfo {

    Clear-Host

    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    INFORMACOES DO SISTEMA                  |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1

    $ramGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)

    Write-Host "Sistema Operacional : $($os.Caption)"
    Write-Host "Versao              : $($os.Version)"
    Write-Host "Processador         : $($cpu.Name)"
    Write-Host "Memoria RAM         : $ramGB GB"
    Write-Host "Placa de Video      : $($gpu.Name)"
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar..." -ForegroundColor DarkGray

    [Console]::ReadKey($true)
}