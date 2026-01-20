# ============================================================
# NEO VCORE V6 - CONTROLE DE FEATURES VIA VIVETOOL
# ============================================================

$VivetoolPath = "$($env:SystemDrive)\neovcore\vivetool\vivetool.exe"

function Get-ProductDrive {
    return $env:SystemDrive
}

function Get-VivetoolStatus {
    $drive = Get-ProductDrive
    $output = & $VivetoolPath /query /product:$drive 2>$null
    $active = @()

    foreach ($line in $output) {
        if ($line -match "ID\s+(\d+)") {
            $active += [int]$Matches[1]
        }
    }

    return $active | Sort-Object -Unique
}

function Get-FeatureStatus {
    param([int]$Id)

    $active = Get-VivetoolStatus

    if ($active -contains $Id) {
        return "Enabled"
    }
    else {
        return "Disabled"
    }
}

function Enable-Feature {
    param([int]$Id)
    $drive = Get-ProductDrive
    & $VivetoolPath /enable /id:$Id /product:$drive | Out-Null
}

function Disable-Feature {
    param([int]$Id)
    $drive = Get-ProductDrive
    & $VivetoolPath /disable /id:$Id /product:$drive | Out-Null
}

function Enable-Category {
    param([string]$Category, [object]$FeaturesJson)

    foreach ($f in $FeaturesJson.$Category) {
        if ($f.id) {
            Enable-Feature $f.id
        }
    }
}

function Disable-Category {
    param([string]$Category, [object]$FeaturesJson)

    foreach ($f in $FeaturesJson.$Category) {
        if ($f.id) {
            Disable-Feature $f.id
        }
    }
}

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