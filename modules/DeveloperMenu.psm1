[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# NEO VCORE V6 - MENU AVANCADO (F10)
# ============================================================

function Show-DeveloperMenu {

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                    MENU AVANCADO (F10)                     |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Este menu contem ferramentas internas para diagnostico." -ForegroundColor DarkGray
        Write-Host ""

        Write-Host " 1) Ver logs"
        Write-Host " 2) Limpar logs"
        Write-Host " 3) Recarregar configuracoes"
        Write-Host " 4) Salvar configuracoes"
        Write-Host ""
        Write-Host "0) Voltar"                      -ForegroundColor red

        Write-Host ""
        $choice = Read-Host "Escolha"

        switch ($choice) {

            "1" {
                Show-Logs
            }

            "2" {
                Clear-Logs
            }

            "3" {
                Load-Settings
                Write-Host "Configuracoes recarregadas." -ForegroundColor Green
                Start-Sleep 1
            }

            "4" {
                Save-Settings
                Write-Host "Configuracoes salvas." -ForegroundColor Green
                Start-Sleep 1
            }

            "0" {
                return
            }

            default {
                Write-Host "Opcao invalida." -ForegroundColor Red
                Start-Sleep 0.7
            }
        }
    }

}
