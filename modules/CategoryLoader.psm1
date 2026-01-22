[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ============================================================
# NEO VCORE V6 - MENU DE CATEGORIAS (OTIMIZADO)
# ============================================================

function Show-CategoryMenu {
    param([object]$FeaturesJson)

    while ($true) {

        Clear-Host
        Write-Host "============================================================"
        Write-Host "                 MENU DE CATEGORIAS DO NEO VCORE"
        Write-Host "============================================================"
        Write-Host ""

        # Carrega status APENAS UMA VEZ (muito mais rápido)
        $active = @()
        if (Get-Command Get-VivetoolStatus -ErrorAction SilentlyContinue) {
            $active = Get-VivetoolStatus
        }

        $categories = $FeaturesJson.PSObject.Properties.Name
        $colWidth = 40

        # Exibir categorias com números
        for ($i = 0; $i -lt $categories.Count; $i += 2) {

            $leftIndex  = $i + 1
            $left       = $categories[$i]
            $leftItems  = $FeaturesJson.$left
            $leftActive = ($leftItems | Where-Object { $active -contains $_.id }).Count
            $leftTotal  = $leftItems.Count

            if ($leftActive -eq 0) { $leftStatus = "[ ]" }
            elseif ($leftActive -eq $leftTotal) { $leftStatus = "[X]" }
            else { $leftStatus = "[~]" }

            $leftText = "$leftIndex) $leftStatus $left"

            if ($i + 1 -lt $categories.Count) {
                $rightIndex  = $i + 2
                $right       = $categories[$i + 1]
                $rightItems  = $FeaturesJson.$right
                $rightActive = ($rightItems | Where-Object { $active -contains $_.id }).Count
                $rightTotal  = $rightItems.Count

                if ($rightActive -eq 0) { $rightStatus = "[ ]" }
                elseif ($rightActive -eq $rightTotal) { $rightStatus = "[X]" }
                else { $rightStatus = "[~]" }

                $rightText = "$rightIndex) $rightStatus $right"
            }
            else {
                $rightText = ""
            }

            "{0,-40}{1,-40}" -f $leftText, $rightText
        }

        Write-Host ""
        Write-Host "------------------------------------------------------------"
        Write-Host "[X] = Todos ativos   [ ] = Nenhum ativo   [~] = Parcial"
        Write-Host "------------------------------------------------------------"
        Write-Host ""
        Write-Host "A) Ativar todas as categorias"
        Write-Host "B) Desativar todas as categorias"
        Write-Host "0) Voltar"                      -ForegroundColor red
        Write-Host ""

        $choice = Read-Host "Escolha uma opcao ou numero da categoria"

        # Seleção por número
        if ($choice -match '^\d+$') {
            $index = [int]$choice - 1
            if ($index -ge 0 -and $index -lt $categories.Count) {
                $selectedCategory = $categories[$index]
                Show-CategoryDetails -Category $selectedCategory -FeaturesJson $FeaturesJson
                continue
            }
            else {
                Write-Host "Categoria invalida." -ForegroundColor Yellow
                Start-Sleep 1
                continue
            }
        }

        switch ($choice.ToUpper()) {

            "A" {
                foreach ($cat in $categories) {
                    Enable-Category -Category $cat -FeaturesJson $FeaturesJson
                }
            }

            "B" {
                foreach ($cat in $categories) {
                    Disable-Category -Category $cat -FeaturesJson $FeaturesJson
                }
            }

            "C" {
                return
            }

            default {
                Write-Host "Opcao invalida." -ForegroundColor Yellow
                Start-Sleep 1
            }
        }
    }
}

# ------------------------------------------------------------
# DETALHES DA CATEGORIA (TAMBÉM OTIMIZADO)
# ------------------------------------------------------------

function Show-CategoryDetails {
    param(
        [string]$Category,
        [object]$FeaturesJson
    )

    while ($true) {

        Clear-Host
        Write-Host "============================================================"
        Write-Host "              CATEGORIA: $Category"
        Write-Host "============================================================"
        Write-Host ""

        $items = $FeaturesJson.$Category

        # Carrega status uma única vez
        $active = Get-VivetoolStatus

        for ($i = 0; $i -lt $items.Count; $i += 2) {

            $left  = $items[$i]
            $leftStatus = if ($active -contains $left.id) { "[X]" } else { "[ ]" }
            $leftText   = "$leftStatus $($left.id) $($left.name)"

            if ($i + 1 -lt $items.Count) {
                $right = $items[$i + 1]
                $rightStatus = if ($active -contains $right.id) { "[X]" } else { "[ ]" }
                $rightText   = "$rightStatus $($right.id) $($right.name)"
            }
            else {
                $rightText = ""
            }

            "{0,-40}{1,-40}" -f $leftText, $rightText
        }

        Write-Host ""
        Write-Host "------------------------------------------------------------"
        Write-Host "1) Ativar categoria"
        Write-Host "2) Desativar categoria"
        Write-Host "0) Voltar"                      -ForegroundColor red
        Write-Host "------------------------------------------------------------"
        Write-Host ""

        $choice = Read-Host "Escolha"

        switch ($choice) {

            "1" { Enable-Category  -Category $Category -FeaturesJson $FeaturesJson }
            "2" { Disable-Category -Category $Category -FeaturesJson $FeaturesJson }
            "0" { return }

            default {
                Write-Host "Opcao invalida." -ForegroundColor Yellow
                Start-Sleep 1
            }
        }
    }

}
