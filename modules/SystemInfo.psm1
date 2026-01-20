[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#
    ============================================================
    MÓDULO: SystemInfo.psm1
    FUNÇÃO: Exibir informações detalhadas do sistema (versão completa)
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.5
    ============================================================
#>

function Show-SystemInfo {

    Clear-Host

    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|                    INFORMACOES DO SISTEMA                  |" -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    # ------------------------------------------------------------
    # Coleta segura de informações
    # ------------------------------------------------------------
    try { $os = Get-CimInstance Win32_OperatingSystem } catch { $os = $null }
    try { $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1 } catch { $cpu = $null }
    try { $gpus = Get-CimInstance Win32_VideoController } catch { $gpus = $null }
    try { $board = Get-CimInstance Win32_BaseBoard } catch { $board = $null }
    try { $bios = Get-CimInstance Win32_BIOS } catch { $bios = $null }
    try { $ram = Get-CimInstance Win32_PhysicalMemory } catch { $ram = $null }
    try { $disks = Get-CimInstance Win32_DiskDrive } catch { $disks = $null }
    try { $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } } catch { $net = $null }
    try { $battery = Get-CimInstance Win32_Battery } catch { $battery = $null }

    # ------------------------------------------------------------
    # Uptime seguro (corrigido)
    # ------------------------------------------------------------
    $uptime = "N/A"

    try {
        if ($os.LastBootUpTime) {
            $boot = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
            $ts = New-TimeSpan -Start $boot -End (Get-Date)
            $uptime = "{0}d {1}h {2}m" -f $ts.Days, $ts.Hours, $ts.Minutes
        }
    }
    catch {
        $uptime = "N/A"
    }

    # ------------------------------------------------------------
    # Processamento
    # ------------------------------------------------------------
    $ramTotalGB = if ($os) { [math]::Round($os.TotalVisibleMemorySize / 1MB, 2) } else { "N/A" }

    $gpuList = if ($gpus) { ($gpus | Select-Object -ExpandProperty Name) -join ", " } else { "N/A" }

    $ramModules = if ($ram) { $ram.Count } else { 0 }
    $ramSpeed = if ($ram) { ($ram | Select-Object -ExpandProperty Speed | Sort-Object -Descending | Select-Object -First 1) } else { "N/A" }

    $diskInfo = ""
    foreach ($d in $disks) {
        $sizeGB = [math]::Round($d.Size / 1GB, 2)
        $diskInfo += "$($d.Model) - $sizeGB GB ($($d.MediaType))`n"
    }

    $netInfo = ""
    foreach ($n in $net) {
        $ipv4 = $n.IPAddress | Where-Object { $_ -match '\.' }
        $netInfo += "$($n.Description) - IPv4: $ipv4`n"
    }

    # ------------------------------------------------------------
    # Exibição na tela
    # ------------------------------------------------------------
    Write-Host "Sistema Operacional : $($os.Caption)"
    Write-Host "Edição              : $($os.OperatingSystemSKU)"
    Write-Host "Versão              : $($os.Version)"
    Write-Host "Build               : $($os.BuildNumber)"
    Write-Host "Arquitetura         : $($os.OSArchitecture)"
    Write-Host "Idioma do Sistema   : $($os.MUILanguages)"
    Write-Host "Tempo de Atividade  : $uptime"
    Write-Host ""

    Write-Host "Processador         : $($cpu.Name)"
    Write-Host "Núcleos Físicos     : $($cpu.NumberOfCores)"
    Write-Host "Threads             : $($cpu.NumberOfLogicalProcessors)"
    Write-Host "Frequência Base     : $([math]::Round($cpu.MaxClockSpeed / 1000, 2)) GHz"
    Write-Host ""

    Write-Host "Memória RAM Total   : $ramTotalGB GB"
    Write-Host "Módulos Instalados  : $ramModules"
    Write-Host "Frequência Máxima   : $ramSpeed MHz"
    Write-Host ""

    Write-Host "Placas de Vídeo     : $gpuList"
    Write-Host ""

    Write-Host "Placa-mãe           : $($board.Manufacturer) $($board.Product)"
    Write-Host "BIOS                : $($bios.SMBIOSBIOSVersion) ($($bios.ReleaseDate))"
    Write-Host ""

    Write-Host "Armazenamento:"
    Write-Host $diskInfo
    Write-Host ""

    Write-Host "Rede:"
    Write-Host $netInfo
    Write-Host ""

    if ($battery) {
        Write-Host "Bateria:"
        Write-Host "Status: $($battery.BatteryStatus)"
        Write-Host "Capacidade: $($battery.EstimatedChargeRemaining)%"
        Write-Host ""
    }

    Write-Host "1) Exportar relatório para a Área de Trabalho"
    Write-Host "0) Voltar"
    Write-Host ""

    $choice = Read-Host "Escolha"

    if ($choice -eq "1") {
        Export-SystemInfoReport
    }
}

# ------------------------------------------------------------
# Exportar relatório completo para a Área de Trabalho
# ------------------------------------------------------------
function Export-SystemInfoReport {

    $desktop = [Environment]::GetFolderPath("Desktop")
    $file = Join-Path $desktop "NeoVcore_SystemInfo.txt"

    try {
        $report = @()

        $report += "==================== NEO VCORE SYSTEM REPORT ===================="
        $report += "Gerado em: $(Get-Date)"
        $report += ""

        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $gpus = Get-CimInstance Win32_VideoController
        $board = Get-CimInstance Win32_BaseBoard
        $bios = Get-CimInstance Win32_BIOS
        $ram = Get-CimInstance Win32_PhysicalMemory
        $disks = Get-CimInstance Win32_DiskDrive
        $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

        $report += "Sistema Operacional: $($os.Caption)"
        $report += "Versão: $($os.Version)"
        $report += "Build: $($os.BuildNumber)"
        $report += ""

        $report += "CPU: $($cpu.Name)"
        $report += "Cores: $($cpu.NumberOfCores)"
        $report += "Threads: $($cpu.NumberOfLogicalProcessors)"
        $report += ""

        $report += "GPU(s):"
        foreach ($g in $gpus) { $report += " - $($g.Name)" }
        $report += ""

        $report += "Placa-mãe: $($board.Manufacturer) $($board.Product)"
        $report += "BIOS: $($bios.SMBIOSBIOSVersion)"
        $report += ""

        $report += "Armazenamento:"
        foreach ($d in $disks) {
            $sizeGB = [math]::Round($d.Size / 1GB, 2)
            $report += " - $($d.Model) - $sizeGB GB ($($d.MediaType))"
        }
        $report += ""

        $report += "Rede:"
        foreach ($n in $net) {
            $ipv4 = $n.IPAddress | Where-Object { $_ -match '\.' }
            $report += " - $($n.Description) - IPv4: $ipv4"
        }

        $report | Out-File $file -Encoding UTF8

        Write-Host ""
        Write-Host "Relatório exportado para:" -ForegroundColor Green
        Write-Host $file -ForegroundColor Yellow
        Write-Host ""
        Read-Host "ENTER para continuar"
    }
    catch {
        Write-Host "Erro ao exportar relatório." -ForegroundColor Red
        Read-Host "ENTER para continuar"
    }
}
