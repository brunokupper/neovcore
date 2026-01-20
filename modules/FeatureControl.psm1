# ============================================================
# NEO VCORE V6 - CONTROLE DE FEATURES VIA VIVETOOL
# ============================================================

$VivetoolPath = "$($env:SystemDrive)\NeoVcore\vivetool\vivetool.exe"

# ------------------------------------------------------------
# Obter drive do produto
# ------------------------------------------------------------
function Get-ProductDrive {
    return $env:SystemDrive
}

# ------------------------------------------------------------
# Obter lista de features ativas via Vivetool
# ------------------------------------------------------------
function Get-VivetoolStatus {

    $drive = Get-ProductDrive

    if (-not (Test-Path $VivetoolPath)) {
        Write-Host "Vivetool nao encontrado em $VivetoolPath" -ForegroundColor Red
        Write-Log "Vivetool nao encontrado"
        return @()
    }

    try {
        $output = & $VivetoolPath /query /product:$drive 2>$null
    }
    catch {
        Write-Host "Erro ao executar vivetool /query" -ForegroundColor Red
        Write-Log "Falha ao executar vivetool /query"
        return @()
    }

    $active = @()

    foreach ($line in $output) {

        # Formato novo
        if ($line -match "Feature\s+ID:\s+(\d+)\s+State:\s+Enabled") {
            $active += [int]$Matches[1]
        }

        # Formato antigo
        elseif ($line -match "ID\s+(\d+)\s+Enabled") {
            $active += [int]$Matches[1]
        }
    }

    return $active | Sort-Object -Unique
}

# ------------------------------------------------------------
# Obter status de uma feature específica
# ------------------------------------------------------------
function Get-FeatureStatus {
    param([int]$Id)

    if ($Id -le 0) { return "Invalid" }

    $active = Get-VivetoolStatus

    if ($active -contains $Id) {
        return "Enabled"
    }
    else {
        return "Disabled"
    }
}

# ------------------------------------------------------------
# Ativar feature
# ------------------------------------------------------------
function Enable-Feature {
    param([int]$Id)

    if ($Id -le 0) {
        Write-Log "ID invalido ao tentar habilitar feature: $Id"
        return
    }

    $drive = Get-ProductDrive

    try {
        & $VivetoolPath /enable /id:$Id /product:$drive | Out-Null
        Write-Log "Feature $Id habilitada"
    }
    catch {
        Write-Log "Erro ao habilitar feature $Id"
    }
}

# ------------------------------------------------------------
# Desativar feature
# ------------------------------------------------------------
function Disable-Feature {
    param([int]$Id)

    if ($Id -le 0) {
        Write-Log "ID invalido ao tentar desabilitar feature: $Id"
        return
    }

    $drive = Get-ProductDrive

    try {
        & $VivetoolPath /disable /id:$Id /product:$drive | Out-Null
        Write-Log "Feature $Id desabilitada"
    }
    catch {
        Write-Log "Erro ao desabilitar feature $Id"
    }
}

# ------------------------------------------------------------
# Ativar categoria inteira
# ------------------------------------------------------------
function Enable-Category {
    param([string]$Category, [object]$FeaturesJson)

    foreach ($f in $FeaturesJson.$Category) {
        if ($f.id) {
            Enable-Feature $f.id
        }
    }
}

# ------------------------------------------------------------
# Desativar categoria inteira
# ------------------------------------------------------------
function Disable-Category {
    param([string]$Category, [object]$FeaturesJson)

    foreach ($f in $FeaturesJson.$Category) {
        if ($f.id) {
            Disable-Feature $f.id
        }
    }
}

# ------------------------------------------------------------
# Ativar todas as features do JSON
# ------------------------------------------------------------
function Enable-AllFeatures {
    param([object]$FeaturesJson)

    foreach ($cat in $FeaturesJson.PSObject.Properties.Name) {
        foreach ($f in $FeaturesJson.$cat) {
            if ($f.id) {
                Enable-Feature $f.id
            }
        }
    }
}

# ------------------------------------------------------------
# Desativar todas as features do JSON
# ------------------------------------------------------------
function Disable-AllFeatures {
    param([object]$FeaturesJson)

    foreach ($cat in $FeaturesJson.PSObject.Properties.Name) {
        foreach ($f in $FeaturesJson.$cat) {
            if ($f.id) {
                Disable-Feature $f.id
            }
        }
    }
}

# ------------------------------------------------------------
# Status de um preset
# ------------------------------------------------------------
function Get-PresetStatus {
    param(
        [string]$PresetName,
        [hashtable]$Presets
    )

    $ids = $Presets[$PresetName]
    $active = Get-VivetoolStatus

    $countActive = ($ids | Where-Object { $active -contains $_ }).Count
    $countTotal  = $ids.Count

    return [PSCustomObject]@{
        Active = $countActive
        Total  = $countTotal
    }
}

# ------------------------------------------------------------
# Aplicar preset
# ------------------------------------------------------------
function Apply-Preset {
    param(
        [string]$PresetName,
        [hashtable]$Presets
    )

    $ids = $Presets[$PresetName]

    foreach ($id in $ids) {
        Enable-Feature $id
    }
}

# ------------------------------------------------------------
# Remover preset
# ------------------------------------------------------------
function Remove-Preset {
    param(
        [string]$PresetName,
        [hashtable]$Presets
    )

    $ids = $Presets[$PresetName]

    foreach ($id in $ids) {
        Disable-Feature $id
    }
}
