<#
    ============================================================
    MÓDULO: Submenus.psm1
    FUNÇÃO: Exibir submenus de categorias do Vivetool
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.1
    ============================================================
#>

Import-Module "$PSScriptRoot\CategoryLoader.psm1" -Force -Global
Import-Module "$PSScriptRoot\Vivetool.psm1" -Force -Global

function Show-Submenu {
    param (
        [string]$CategoryName
    )

    # Verificar se a categoria existe no JSON
    $allCategories = Get-AllCategories
    if ($allCategories -notcontains $CategoryName) {
        Write-Host "Categoria '$CategoryName' não encontrada no JSON." -ForegroundColor Red
        Write-Log "Tentativa de abrir categoria inexistente: $CategoryName"
        Start-Sleep 1
        return
    }

    while ($true) {

        Clear-Host
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host "|                  RECURSOS DA CATEGORIA                     |" -ForegroundColor Yellow
        Write-Host "+------------------------------------------------------------+" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Categoria: $CategoryName"
        Write-Host ""

        # Carregar features da categoria
        try {
            $features = Get-FeaturesByCategory -CategoryName $CategoryName
        }
        catch {
            Write-Host "Erro ao carregar recursos da categoria." -ForegroundColor Red
            Write-Log "Erro ao carregar categoria $CategoryName"
            Read-Host "ENTER para voltar"
            return
        }

        if (-not $features -or $features.Count -eq 0) {
            Write-Host "Nenhum recurso encontrado nesta categoria." -ForegroundColor Red
            Write-Log "Categoria vazia: $CategoryName"
            Write-Host ""
            Read-Host "Pressione ENTER para voltar"
            return
        }

        # Exibir lista numerada
        for ($i = 0; $i -lt $features.Count; $i++) {
            $num = $i + 1
            $f = $features[$i]

            # Proteção contra JSON mal formatado
            if (-not $f.id -or -not $f.name) {
                Write-Host "$num) [ERRO NO JSON] (ID inválido)" -ForegroundColor Red
                continue
            }

            Write-Host "$num) $($f.name) (ID: $($f.id))"
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

                # Proteção contra feature inválida
                if (-not $selectedFeature.id) {
                    Write-Host "Recurso inválido no JSON." -ForegroundColor Red
                    Write-Log "Feature inválida detectada na categoria $CategoryName"
                    Start-Sleep 1
                    continue
                }

                Show-FeatureActions -Feature $selectedFeature
                continue
            }
        }

        Write-Host ""
        Write-Host "Opcao invalida. Pressione ENTER para tentar novamente..." -ForegroundColor Red
        Read-Host
    }
}
