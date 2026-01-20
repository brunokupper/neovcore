<#
    ============================================================
    MÓDULO: Header.psm1
    FUNÇÃO: Exibir o cabeçalho premium do NeoVcore
    AUTOR: Bruno Kupper (@brunokupper)
    VERSÃO: 6.0
    ============================================================
#>

function Show-NeoVcoreHeader {

    Clear-Host

    $line = "=" * 60

    Write-Host $line -ForegroundColor Cyan
    Write-Host "==                     NEO VCORE V6                      ==" -ForegroundColor Yellow
    Write-Host "==                    By Bruno Kupper                    ==" -ForegroundColor DarkCyan
    Write-Host $line -ForegroundColor Cyan
    Write-Host ""
}