# ============================================================
# NEO VCORE V6 - MENU PRINCIPAL
# ============================================================

function Show-MainMenu {
    param(
        [object]$FeaturesJson,
        [hashtable]$Presets
    )

    while ($true) {

        Clear-Host
        Write-Host "============================================================"
        Write-Host "                     NEO VCORE V6"
        Write-Host "============================================================"
        Write-Host ""
        Write-Host "Sistema detectado em: $($env:SystemDrive)"
        Write-Host ""
        Write-Host "1) Menu de Categorias"
        Write-Host "2) Menu de Presets"
        Write-Host "3) Ativar todas as features"
        Write-Host "4) Desativar todas as features"
        Write-Host "5) Informacoes do Sistema"
		Write-Host "0) " -NoNewline
		Write-Host "Voltar" -ForegroundColor Red
        Write-Host ""
        
        $choice = Read-Host "Escolha uma opcao"

        switch ($choice) {

            "1" {
                Show-CategoryMenu -FeaturesJson $FeaturesJson
            }

            "2" {
                Show-PresetMenu -Presets $Presets
            }

            "3" {
                Enable-AllFeatures -FeaturesJson $FeaturesJson
                Write-Host "Todas as features foram ativadas." -ForegroundColor Green
                Start-Sleep 1.5
            }

            "4" {
                Disable-AllFeatures -FeaturesJson $FeaturesJson
                Write-Host "Todas as features foram desativadas." -ForegroundColor Yellow
                Start-Sleep 1.5
            }

            "5" {
                Show-SystemInfo
            }

            "6" {
                Clear-Host
                Write-Host "Saindo do Neo Vcore..." -ForegroundColor Cyan
                Start-Sleep 1
                exit
            }

            default {
                Write-Host "Opcao invalida." -ForegroundColor Yellow
                Start-Sleep 1
            }
        }
    }
}

function Show-SystemInfo {

    Clear-Host
    Write-Host "============================================================"
    Write-Host "                 INFORMACOES DO SISTEMA"
    Write-Host "============================================================"
    Write-Host ""

    Write-Host "Unidade do Windows: $($env:SystemDrive)"
    Write-Host "Diretorio atual:    $PWD"
    Write-Host "Usuario:            $env:USERNAME"
    Write-Host "Computador:         $env:COMPUTERNAME"
    Write-Host "Versao PowerShell:  $($PSVersionTable.PSVersion)"
    Write-Host ""

    Write-Host "Pressione ENTER para voltar..."
    Read-Host
}