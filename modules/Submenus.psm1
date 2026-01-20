<#  
    ============================================================
    MÓDULO: Submenus.psm1
    FUNÇÃO: Exibir submenus de categorias do Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

Import-Module "$PSScriptRoot\CategoryLoader.psm1" -Force -Global
Import-Module "$PSScriptRoot\Vivetool.psm1" -Force -Global

function Show-Submenu {
    param (
        [string]$CategoryName
    )

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                  RECURSOS DA CATEGORIA                     |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Categoria: $CategoryName"
        Write-Host ""

        # Carregar features da categoria
        $features = Get-FeaturesByCategory -CategoryName $CategoryName

        if ($features.Count -eq 0) {
            Write-Host "Nenhum recurso encontrado nesta categoria." -ForegroundColor Red
            Write-Host ""
            Read-Host "Pressione ENTER para voltar"
            return
        }

        # Exibir lista numerada
        for ($i = 0; $i -lt $features.Count; $i++) {
            $num = $i + 1
            Write-Host "$num) $($features[$i].name) (ID: $($features[$i].id))"
        }

        # Opção Voltar
        $exitNum = $features.Count + 1
        Write-Host "$exitNum) Voltar"
        Write-Host ""

        # Entrada do usuário
        $choice = Read-Host "Escolha"

        # Validar número
        if ($choice -match '^\d+$') {
            $choice = [int]$choice

            # Voltar
            if ($choice -eq $exitNum) {
                return
            }

            # Selecionar recurso válido
            if ($choice -ge 1 -and $choice -le $features.Count) {
                $selectedFeature = $features[$choice - 1]
                Show-FeatureActions -Feature $selectedFeature
                continue
            }
        }

        Write-Host ""
        Write-Host "Opcao invalida. Pressione ENTER para tentar novamente..." -ForegroundColor Red
        Read-Host
    }
}