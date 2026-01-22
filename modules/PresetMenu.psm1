[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# MENU DE PRESETS (BETA)
# ============================================================

Import-Module "$PSScriptRoot\Presets.psm1" -Force
Import-Module "$PSScriptRoot\Vivetool.psm1" -Force

# ============================================================
# APLICAR PRESET  (BETA)
# ============================================================

function Apply-Preset {
    param([string]$PresetName)

    try {
        $PresetName = [string]$PresetName
        $presets = Get-Presets

        if (-not $presets.Contains($PresetName)) {
            Write-Host "Preset não encontrado." -ForegroundColor Red
            Start-Sleep 1
            return
        }

        $ids = $presets[$PresetName]

        # Carrega o features.json para obter nomes
        $features = Get-FeaturesData

        # Monta lista de ID + nome
        $itemsToApply = @()

        foreach ($id in $ids) {
            $found = $null

            foreach ($cat in $features.PSObject.Properties.Name) {
                foreach ($f in $features.$cat) {
                    if ($f.id -eq $id) {
                        $found = $f
                        break
                    }
                }
                if ($found) { break }
            }

            if ($found) {
                $itemsToApply += ("{0} - {1}" -f $found.id, $found.name)
            }
            else {
                $itemsToApply += ("{0} - (Nome não encontrado no features.json)" -f $id)
            }
        }

        # Tela de confirmação
        Clear-Host
        Write-Host "============================================================"
        Write-Host " CONFIRMAÇÃO DE PRESET (BETA): $PresetName"
        Write-Host "============================================================"
        Write-Host ""
        Write-Host "Os seguintes recursos serão ATIVADOS:"
        Write-Host ""

        # Exibe em duas colunas
        $half = [math]::Ceiling($itemsToApply.Count / 2)

        for ($i = 0; $i -lt $half; $i++) {
            $left  = $itemsToApply[$i]
            $right = if ($i + $half -lt $itemsToApply.Count) { $itemsToApply[$i + $half] } else { "" }
            Write-Host ("{0,-55} {1}" -f $left, $right)
        }

        Write-Host ""
        $confirm = Read-Host "Deseja aplicar este preset? (S/N)"

        if ($confirm.ToUpper() -ne "S") {
            Write-Host "Operação cancelada." -ForegroundColor Yellow
            Start-Sleep 1
            return
        }

        # Aplicação real do preset
        Clear-Host
        Write-Host "Aplicando preset: $PresetName" -ForegroundColor Cyan
        Write-Host ""

        foreach ($id in $ids) {

            # Buscar nome da feature
            $featureName = "(Nome não encontrado)"
            foreach ($cat in $features.PSObject.Properties.Name) {
                foreach ($f in $features.$cat) {
                    if ($f.id -eq $id) {
                        $featureName = $f.name
                        break
                    }
                }
            }

            # Executar ativação silenciosa
            $result = Enable-FeatureSilent -FeatureID $id

            # Exibir resultado formatado
            if ($result -eq $true) {
                Write-Host "Ativado  →  ID $id  |  $featureName" -ForegroundColor Green
            }
            else {
                Write-Host "ERRO ao ativar  →  ID $id  |  $featureName" -ForegroundColor Red
            }
        }

        Write-Host ""
        Write-Host "Preset aplicado com sucesso!" -ForegroundColor Green
        Read-Host "ENTER para continuar"
    }
    catch {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Red
        Write-Host " ERRO DURANTE A APLICAÇÃO DO PRESET (BETA)" -ForegroundColor Red
        Write-Host "============================================================" -ForegroundColor Red
        Write-Host ""
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host ""
        Read-Host "PRESSIONE ENTER PARA CONTINUAR"
    }
}

# ============================================================
# MENU PRINCIPAL DE PRESETS (RESTAURADO)
# ============================================================

function Show-PresetMenu {

    while ($true) {

        try {
            $presets = Get-Presets
            $names = @($presets.Keys)
        }
        catch {
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host " ERRO AO CARREGAR PRESETS (BETA)" -ForegroundColor Red
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host ""
            Write-Host $_.Exception.Message -ForegroundColor Yellow
            Write-Host ""
            Read-Host "PRESSIONE ENTER PARA CONTINUAR"
            return
        }

        Clear-Host
        Write-Host "============================================================"
        Write-Host "                     PRESETS DE RECURSOS (BETA)"
        Write-Host "============================================================"
        Write-Host ""

        $index = 1
        foreach ($name in $names) {
            Write-Host "$index) $name"
            $index++
        }

        Write-Host ""
        Write-Host "$index) Voltar"
        Write-Host ""

        $choice = Read-Host "Escolha"

        try {
            if ($choice -match '^\d+$') {
                $num = [int]$choice

                if ($num -eq $index) {
                    return
                }

                if ($num -ge 1 -and $num -lt $index) {
                    $selected = $names[$num - 1]
                    Apply-Preset -PresetName $selected
                    continue
                }
            }

            Write-Host "Opção inválida." -ForegroundColor Red
            Start-Sleep 1
        }
        catch {
            Write-Host ""
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host " ERRO AO PROCESSAR SELEÇÃO DO MENU (BETA)" -ForegroundColor Red
            Write-Host "============================================================" -ForegroundColor Red
            Write-Host ""
            Write-Host $_.Exception.Message -ForegroundColor Yellow
            Write-Host ""
            Read-Host "PRESSIONE ENTER PARA CONTINUAR"
        }
    }
}

Export-ModuleMember -Function Show-PresetMenu