param([switch]$Force)
$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'monitor\handler.py'
$directory = Join-Path $PSScriptRoot '.local-backups'
$destination = Join-Path $directory 'website-monitor.zip'
if (-not (Test-Path -LiteralPath $source)) { throw 'monitor/handler.py is missing.' }
if ((Test-Path -LiteralPath $destination) -and -not $Force) {
    Write-Host 'Existing monitor ZIP retained. Use -Force only for an intentional rebuild.'
    return
}
New-Item -ItemType Directory -Path $directory -Force | Out-Null
Compress-Archive -LiteralPath $source -DestinationPath $destination -Force
Get-Item -LiteralPath $destination | Select-Object Name,Length
Write-Host 'Inspect the next Terraform plan: ZIP byte changes can propose a Lambda update.'
