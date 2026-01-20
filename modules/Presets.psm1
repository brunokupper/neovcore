[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
# ============================================================
# NEO VCORE V6 - SISTEMA DE PRESETS (AUTO + PERSISTENTE)
# Arquivo: modules\Presets.psm1
# - Lê features.json
# - Gera presets automáticos
# - Salva em data\presets.json (indentado)
# - Se já existir, pergunta se usa ou regenera
# - Expõe: Get-Presets
# ============================================================

function Get-FeaturesJsonPath {
    $dataDir = Join-Path $PSScriptRoot "..\data"
    return (Join-Path $dataDir "features.json")
}

function Get-PresetsJsonPath {
    $dataDir = Join-Path $PSScriptRoot "..\data"
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir | Out-Null
    }
    return (Join-Path $dataDir "presets.json")
}

function Get-FeaturesData {
    $featuresPath = Get-FeaturesJsonPath

    if (-not (Test-Path $featuresPath)) {
        throw "features.json nao encontrado em: $featuresPath"
    }

    $raw = Get-Content $featuresPath -Raw -Encoding UTF8
    $json = $raw | ConvertFrom-Json
    return $json
}

function New-DefaultPresets {

    $features = Get-FeaturesData
    $presets  = [ordered]@{}

    # --------------------------------------------------------
    # 1) Presets por categoria: "Categoria (Completo)"
    # --------------------------------------------------------
    $categories = $features.PSObject.Properties.Name

    foreach ($cat in $categories) {
        $items = $features.$cat
        if (-not $items) { continue }

        $ids = @()
        foreach ($f in $items) {
            if ($f.id) { $ids += [int]$f.id }
        }

        $presetName = "$cat (Completo)"
        $presets[$presetName] = $ids
    }

    # --------------------------------------------------------
    # 2) Sistema Completo / Sistema Maximo (tudo)
    # --------------------------------------------------------
    $allIds = @()
    foreach ($cat in $categories) {
        foreach ($f in $features.$cat) {
            if ($f.id) { $allIds += [int]$f.id }
        }
    }
    $allIds = $allIds | Sort-Object -Unique

    $presets["Sistema Completo"] = $allIds
    $presets["Sistema Maximo"]   = $allIds

    # --------------------------------------------------------
    # 3) Sistema Basico - recursos essenciais (por nome)
    # --------------------------------------------------------
    $basicKeywords = @(
        "Base",
        "Core",
        "Essencial",
        "Fundamental",
        "Padrao",
        "Padrão"
    )

    $basicIds = @()

    foreach ($cat in $categories) {
        foreach ($f in $features.$cat) {
            if (-not $f.id -or -not $f.name) { continue }

            $name = $f.name

            $isBasic = $false
            foreach ($kw in $basicKeywords) {
                if ($name -like "*$kw*") {
                    $isBasic = $true
                    break
                }
            }

            if ($isBasic) {
                $basicIds += [int]$f.id
            }
        }
    }

    $basicIds = $basicIds | Sort-Object -Unique
    $presets["Sistema Basico"] = $basicIds

    # --------------------------------------------------------
    # 4) Interface Moderna = tudo da categoria "Interface e Visual"
    # --------------------------------------------------------
    if ($features."Interface e Visual") {
        $ids = @()
        foreach ($f in $features."Interface e Visual") {
            if ($f.id) { $ids += [int]$f.id }
        }
        $ids = $ids | Sort-Object -Unique
        $presets["Interface Moderna"] = $ids
    }

    # --------------------------------------------------------
    # 5) IA Completa = tudo da categoria "Inteligencia Artificial"
    # --------------------------------------------------------
    if ($features."Inteligencia Artificial") {
        $ids = @()
        foreach ($f in $features."Inteligencia Artificial") {
            if ($f.id) { $ids += [int]$f.id }
        }
        $ids = $ids | Sort-Object -Unique
        $presets["IA Completa"] = $ids
    }

    return $presets
}

function Save-PresetsJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Presets
    )

    $path = Get-PresetsJsonPath

    # Converte hashtable em objeto para o JSON ficar bonitinho
    $obj = [PSCustomObject]@{}

    foreach ($key in $Presets.Keys) {
        # Garante que sao inteiros
        $ids = @()
        foreach ($id in $Presets[$key]) {
            $ids += [int]$id
        }
        $obj | Add-Member -NotePropertyName $key -NotePropertyValue $ids
    }

    $json = $obj | ConvertTo-Json -Depth 5
    $json | Out-File $path -Encoding UTF8
}

function Load-PresetsJson {

    $path = Get-PresetsJsonPath

    if (-not (Test-Path $path)) {
        return $null
    }

    $raw = Get-Content $path -Raw -Encoding UTF8
    $json = $raw | ConvertFrom-Json

    $presets = [ordered]@{}

    foreach ($prop in $json.PSObject.Properties) {
        $name = $prop.Name
        $ids  = @()

        foreach ($id in $prop.Value) {
            $ids += [int]$id
        }

        $presets[$name] = $ids
    }
# Normaliza todas as chaves para strings limpas
$clean = [ordered]@{}
foreach ($k in $presets.Keys) {
    $clean[$k.ToString().Trim()] = $presets[$k]
}
return $clean

    return $presets
}

function Initialize-Presets {

    $existing = Load-PresetsJson

    if ($existing -ne $null -and $existing.Keys.Count -gt 0) {

        Write-Host ""
        Write-Host "Um arquivo de presets ja existe em data\presets.json." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1) Usar o arquivo existente"
        Write-Host "2) Regenerar presets automaticamente a partir do features.json"
        Write-Host ""
        $choice = Read-Host "Escolha uma opcao (1 ou 2)"

        if ($choice -eq "1") {
            return $existing
        }
        elseif ($choice -eq "2") {
            $generated = New-DefaultPresets
            Save-PresetsJson -Presets $generated
            return $generated
        }
        else {
            Write-Host "Opcao invalida. Usando presets existentes." -ForegroundColor DarkYellow
            return $existing
        }
    }
    else {
        $generated = New-DefaultPresets
        Save-PresetsJson -Presets $generated
        return $generated
    }
}

function Get-Presets {
    # Funcao publica para o NeoVcore.ps1
    if (-not $script:PresetsCache) {
        $script:PresetsCache = Initialize-Presets
    }
    return $script:PresetsCache
}