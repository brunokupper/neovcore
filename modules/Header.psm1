[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

<#  
    ============================================================
    MÓDULO: Header.psm1
    FUNÇÃO: Exibir o cabeçalho premium do NeoVcore
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.1
    ============================================================
#>

function Show-NeoVcoreHeader {

    Clear-Host

    # Carregar versão real do sistema
    $version = "6.x"
    try {
        $version = Get-NeoVcoreVersion
    }
    catch {
        # fallback silencioso
    }

    # Linha decorativa
    $line = "=" * 60

    # Tema
    $theme = $Global:NeoVcoreSettings.Theme
    $colorTitle = "Yellow"
    $colorAuthor = "DarkCyan"
    $colorLine = "Cyan"

    if ($theme -eq "light") {
        $colorTitle = "DarkYellow"
        $colorAuthor = "Blue"
        $colorLine = "White"
    }

    Write-Host $line -ForegroundColor $colorLine
    Write-Host ("==                 NEO VCORE V$version                 ==") -ForegroundColor $colorTitle
    Write-Host "==                    By Bruno Kupper                    ==" -ForegroundColor $colorAuthor
    Write-Host $line -ForegroundColor $colorLine
    Write-Host ""
}

