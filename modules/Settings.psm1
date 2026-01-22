[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#  
    ============================================================
    MÓDULO: Settings.psm1
    FUNÇÃO: Configurações do NeoVcore
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

# ------------------------------------------------------------
# Carregar configuracoes do arquivo Settings.json
# (Agora integrado ao SettingsManager.psm1)
# ------------------------------------------------------------
function Load-Settings {

    $settingsPath = Join-Path $PSScriptRoot "..\data\Settings.json"

    if (-not (Test-Path $settingsPath)) {
        Write-Host "Arquivo Settings.json nao encontrado na pasta /data" -ForegroundColor Red
        return $null
    }

    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        return $settings
    }
    catch {
        Write-Host "Erro ao ler o arquivo Settings.json" -ForegroundColor Red
        return $null
    }
}

# ============================================================
# NEO VCORE V6 - MENU DE CONFIGURACOES
# ============================================================

function Show-SettingsMenu {

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                 CONFIGURACOES DO NEOVCORE                  |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""

        Write-Host " Tema atual: $($Global:NeoVcoreSettings.Theme)" -ForegroundColor White
        Write-Host " Sons:       $($Global:NeoVcoreSettings.Sounds)" -ForegroundColor White
        Write-Host " Modo Turbo: $($Global:NeoVcoreSettings.Turbo)" -ForegroundColor White

        Write-Host ""
        Write-Host " 1) Alternar tema (claro/escuro)" -ForegroundColor White
        Write-Host " 2) Ativar/Desativar sons" -ForegroundColor White
        Write-Host " 3) Ativar/Desativar modo turbo" -ForegroundColor White
        Write-Host " 4) Restaurar configuracoes padrao" -ForegroundColor Yellow

        Write-Host ""
        Write-Host " 0) Voltar" -ForegroundColor Red
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {

            # Alternar tema
            "1" {
                if ($Global:NeoVcoreSettings.Theme -eq "dark") {
                    $Global:NeoVcoreSettings.Theme = "light"
                    Write-Host "Tema alterado para CLARO." -ForegroundColor Green
                }
                else {
                    $Global:NeoVcoreSettings.Theme = "dark"
                    Write-Host "Tema alterado para ESCURO." -ForegroundColor Green
                }

                Save-Settings
                Start-Sleep -Milliseconds 700
                return
            }

            # Sons
            "2" {
                $Global:NeoVcoreSettings.Sounds = -not $Global:NeoVcoreSettings.Sounds
                Write-Host "Sons agora estao: $($Global:NeoVcoreSettings.Sounds)" -ForegroundColor Green

                Save-Settings
                Start-Sleep -Milliseconds 700
            }

            # Turbo
            "3" {
                $Global:NeoVcoreSettings.Turbo = -not $Global:NeoVcoreSettings.Turbo
                Write-Host "Modo Turbo agora esta: $($Global:NeoVcoreSettings.Turbo)" -ForegroundColor Green

                Save-Settings
                Start-Sleep -Milliseconds 700
            }

            # Reset
            "4" {
                $Global:NeoVcoreSettings.Theme  = "dark"
                $Global:NeoVcoreSettings.Sounds = $true
                $Global:NeoVcoreSettings.Turbo  = $false

                Save-Settings

                Write-Host "Configuracoes restauradas para o padrao." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 900
                return
            }

            # Voltar
            "0" { return }

            default {
                Write-Host "Opcao invalida." -ForegroundColor Red
                Start-Sleep -Milliseconds 700
            }
        }
    }
}

