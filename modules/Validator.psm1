function Validate-FeaturesJson {

    Clear-Host
    Write-Host "VALIDADOR DO FEATURES.JSON"
    Write-Host ""

    $path = Join-Path $PSScriptRoot "..\data\features.json"

    if (-not (Test-Path $path)) {
        Write-Host "ERRO: features.json nao encontrado."
        return
    }

    try {
        $json = Get-Content $path -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "ERRO: JSON invalido."
        return
    }

    Write-Host "JSON valido."

    $categories = $json.PSObject.Properties.Name
    Write-Host "Categorias: $($categories.Count)"

    $ids = @()

    foreach ($cat in $categories) {
        foreach ($f in $json.$cat) {
            if ($f.id) { $ids += $f.id }
        }
    }

    $dupes = $ids | Group-Object | Where-Object { $_.Count -gt 1 }

    if ($dupes.Count -gt 0) {
        Write-Host "IDs duplicados:"
        foreach ($d in $dupes) {
            Write-Host " - $($d.Name)"
        }
    }
    else {
        Write-Host "Nenhum ID duplicado."
    }

    Read-Host "ENTER para continuar"
}