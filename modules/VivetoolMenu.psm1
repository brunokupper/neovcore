$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# NEO VCORE V6 - VIVETOOL MENU UNIFICADO (VISUAL PADRONIZADO)
# ============================================================

Import-Module "$PSScriptRoot\Vivetool.psm1" -Force

function Get-FeaturesJson {
    $path = "$($env:SystemDrive)\neovcore\data\features.json"
    if (Test-Path $path) {
        return Get-Content $path -Raw | ConvertFrom-Json
    }
    else {
        Write-Host "Arquivo features.json não encontrado em $path" -ForegroundColor Red
        return $null
    }
}

# ------------------------------------------------------------
# CABEÇALHO PADRONIZADO
# ------------------------------------------------------------
function Write-Header {
    param([string]$title)

    Clear-Host

    $width = 60
    $padding = [math]::Floor(($width - $title.Length) / 2)
    $line = "|" + (" " * $padding) + $title + (" " * ($width - $padding - $title.Length)) + "|"

    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Yellow
    Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}


# ------------------------------------------------------------
# IMPRESSÃO EM DUAS COLUNAS
# ------------------------------------------------------------
function Print-TwoColumnLines {
    param([array]$lines, [int]$leftWidth = 45)

    if ($lines.Count -eq 0) { return }

    $pairs = [math]::Ceiling($lines.Count / 2)

    for ($i = 0; $i -lt $pairs; $i++) {
        $left = $lines[$i]
        $rightIndex = $i + $pairs
        $right = if ($rightIndex -lt $lines.Count) { $lines[$rightIndex] } else { "" }

        $leftText = $left.PadRight($leftWidth)
        Write-Host "$leftText $right"
    }
}

# ------------------------------------------------------------
# LISTAGEM DE IDS EM DUAS COLUNAS
# ------------------------------------------------------------
function Show-IdsTwoColumns {
    param(
        [array]$Items,
        [string]$CategoryName
    )

    while ($true) {

        Write-Header $CategoryName

        $lines = @()
        $index = 1
        foreach ($it in $Items) {
            $lines += ("{0}) {1} - {2}" -f $index, $it.id, $it.name)
            $index++
        }

        Print-TwoColumnLines -lines $lines

        Write-Host ""
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "A) Ativar TODOS os recursos da categoria"
        Write-Host "D) Desativar TODOS os recursos da categoria"
        Write-Host "0) Voltar"                      -ForegroundColor red
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        $choice = Read-Host "Escolha"

        if ($choice -eq "0") { return }

        switch ($choice.ToUpper()) {

            "A" {
                foreach ($item in $Items) { Enable-Feature $item.id }
                Write-Host "Categoria ativada." -ForegroundColor Green
                Start-Sleep 1
            }

            "D" {
                foreach ($item in $Items) { Disable-Feature $item.id }
                Write-Host "Categoria desativada." -ForegroundColor Yellow
                Start-Sleep 1
            }

            default {
                if ($choice -match '^\d+$') {
                    $num = [int]$choice

                    if ($num -ge 1 -and $num -le $Items.Count) {
                        $selected = $Items[$num - 1]

                        # CHAMA O MENU INDIVIDUAL DO VIVETOOL
                        Show-FeatureActions -Feature $selected
                        continue
                    }
                }

                Write-Host "Opção inválida." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

# ------------------------------------------------------------
# MENU PRINCIPAL DO VIVETOOL
# ------------------------------------------------------------
function Show-VivetoolResourcesMenu {

    $json = Get-FeaturesJson
    if (-not $json) { return }

    while ($true) {

        Write-Header "GERENCIAMENTO DE RECURSOS (VIVETOOL)"

        Write-Host " 1) Interface e Visual              2) Inteligência Artificial"
        Write-Host " 3) Explorador e Barra de Tarefas   4) Sistema e Desempenho"
        Write-Host " 5) Configurações e Extras          6) Apps e Mídia"
        Write-Host " 7) Rede e Conectividade"
        Write-Host ""
        Write-Host " 8) ID Personalizada                9) Presets"
        Write-Host ""
        Write-Host "10) Verificar recursos             11) Atualizar recursos"
        Write-Host ""
        Write-Host "12) Ativar todas as categorias     13) Desativar todas as categorias"
        Write-Host ""
        Write-Host "0) Voltar"                      -ForegroundColor red
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {

            "1" { Show-IdsTwoColumns -Items $json."Interface e Visual" -CategoryName "INTERFACE E VISUAL" }
            "2" { Show-IdsTwoColumns -Items $json."Inteligencia Artificial" -CategoryName "INTELIGÊNCIA ARTIFICIAL" }
            "3" { Show-IdsTwoColumns -Items $json."Explorador e Barra de Tarefas" -CategoryName "EXPLORADOR E BARRA DE TAREFAS" }
            "4" { Show-IdsTwoColumns -Items $json."Sistema e Desempenho" -CategoryName "SISTEMA E DESEMPENHO" }
            "5" { Show-IdsTwoColumns -Items $json."Configuracoes e Extras" -CategoryName "CONFIGURAÇÕES E EXTRAS" }
            "6" { Show-IdsTwoColumns -Items $json."Apps e Midia" -CategoryName "APPS E MÍDIA" }
            "7" { Show-IdsTwoColumns -Items $json."Rede e Conectividade" -CategoryName "REDE E CONECTIVIDADE" }

            "8" {
                $id = Read-Host "Digite o ID"
                if ($id -match '^\d+$') {
                    $fakeFeature = [PSCustomObject]@{
                        id = [int]$id
                        name = "ID Personalizado"
                    }
                    Show-FeatureActions -Feature $fakeFeature
                }
                Start-Sleep 1
            }

            "9" { Show-PresetMenu }

            "10" { Validate-FeaturesJson }
            "11" { Update-FeaturesJson }

            "12" {
                $confirm = Read-Host "Tem certeza que deseja ATIVAR TODOS os recursos? (S/N)"
                if ($confirm.ToUpper() -eq "S") {
                    foreach ($cat in $json.PSObject.Properties) {
                        foreach ($item in $cat.Value) { Enable-Feature $item.id }
                    }
                    Write-Host "Todas as categorias foram ativadas." -ForegroundColor Green
                }
                else {
                    Write-Host "Operação cancelada." -ForegroundColor Yellow
                }
                Start-Sleep 1
            }

            "13" {
                $confirm = Read-Host "Tem certeza que deseja DESATIVAR TODOS os recursos? (S/N)"
                if ($confirm.ToUpper() -eq "S") {
                    foreach ($cat in $json.PSObject.Properties) {
                        foreach ($item in $cat.Value) { Disable-Feature $item.id }
                    }
                    Write-Host "Todas as categorias foram desativadas." -ForegroundColor Yellow
                }
                else {
                    Write-Host "Operação cancelada." -ForegroundColor Yellow
                }
                Start-Sleep 1
            }

            "0" { return }

            default {
                Write-Host "Opção inválida." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}

Export-ModuleMember -Function Show-VivetoolResourcesMenu

