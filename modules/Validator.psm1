[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function Validate-FeaturesJson {

    Clear-Host
    Write-Host "VALIDADOR DO FEATURES.JSON"
    Write-Host ""

    $path = Join-Path $PSScriptRoot "..\data\features.json"

    if (-not (Test-Path $path)) {
        Write-Host "ERRO: features.json nao encontrado." -ForegroundColor Red
        Write-Log "features.json nao encontrado"
        Read-Host "ENTER para continuar"
        return
    }

    # ------------------------------------------------------------
    # Validar JSON
    # ------------------------------------------------------------
    try {
        $json = Get-Content $path -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "ERRO: JSON invalido." -ForegroundColor Red
        Write-Log "features.json invalido"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host "JSON valido." -ForegroundColor Green
    Write-Host ""

    # ------------------------------------------------------------
    # Validar categorias
    # ------------------------------------------------------------
    $categories = $json.PSObject.Properties.Name
    Write-Host "Categorias encontradas: $($categories.Count)"

    if ($categories.Count -eq 0) {
        Write-Host "ERRO: Nenhuma categoria encontrada." -ForegroundColor Red
        Write-Log "Nenhuma categoria encontrada no features.json"
        Read-Host "ENTER para continuar"
        return
    }

    Write-Host ""

    # ------------------------------------------------------------
    # Validar IDs
    # ------------------------------------------------------------
    $ids = @()
    $invalidIds = @()
    $missingNames = @()
    $emptyCategories = @()

    foreach ($cat in $categories) {

        if (-not $json.$cat -or $json.$cat.Count -eq 0) {
            $emptyCategories += $cat
            continue
        }

        foreach ($f in $json.$cat) {

            # Feature sem ID
            if (-not $f.id) {
                $invalidIds += "Categoria: $cat → Feature sem ID"
                continue
            }

            # ID não numérico
            if ($f.id -notmatch '^\d+$') {
                $invalidIds += "Categoria: $cat → ID inválido: $($f.id)"
            }

            # Feature sem nome
            if (-not $f.name -or $f.name.Trim() -eq "") {
                $missingNames += "Categoria: $cat → ID $($f.id) sem nome"
            }

            $ids += [int]$f.id
        }
    }

    # ------------------------------------------------------------
    # Exibir categorias vazias
    # ------------------------------------------------------------
    if ($emptyCategories.Count -gt 0) {
        Write-Host "Categorias vazias:" -ForegroundColor Yellow
        foreach ($c in $emptyCategories) {
            Write-Host " - $c"
        }
        Write-Host ""
    }

    # ------------------------------------------------------------
    # Exibir IDs inválidos
    # ------------------------------------------------------------
    if ($invalidIds.Count -gt 0) {
        Write-Host "IDs invalidos encontrados:" -ForegroundColor Red
        foreach ($i in $invalidIds) {
            Write-Host " - $i"
        }
        Write-Host ""
    }

    # ------------------------------------------------------------
    # Exibir features sem nome
    # ------------------------------------------------------------
    if ($missingNames.Count -gt 0) {
        Write-Host "Features sem nome:" -ForegroundColor Yellow
        foreach ($m in $missingNames) {
            Write-Host " - $m"
        }
        Write-Host ""
    }

    # ------------------------------------------------------------
    # Detectar IDs duplicados
    # ------------------------------------------------------------
    $dupes = $ids | Group-Object | Where-Object { $_.Count -gt 1 }

    if ($dupes.Count -gt 0) {
        Write-Host "IDs duplicados:" -ForegroundColor Red
        foreach ($d in $dupes) {
            Write-Host " - $($d.Name) (duplicado $($d.Count)x)"
        }
    }
    else {
        Write-Host "Nenhum ID duplicado." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Validacao concluida." -ForegroundColor Cyan
    Write-Log "Validacao do features.json concluida"

    Read-Host "ENTER para continuar"
}

