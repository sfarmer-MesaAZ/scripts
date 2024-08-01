param(
    [string]$path,
    [switch]$recursive
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$date = Get-Date -Format yyyyMMdd
$outputFile = Join-Path -Path $scriptPath -ChildPath ("directory_list_$date.txt")

function Get-Directories {
    param(
        [string]$path,
        [switch]$recursive
    )

    if ($recursive) {
        Get-ChildItem $path -Directory -Recurse | Select-Object -ExpandProperty Name
    } else {
        Get-ChildItem $path -Directory | Select-Object -ExpandProperty Name
    }
}

$directories = Get-Directories -path $path -recursive:$recursive

$directories | Out-File -FilePath $outputFile

Write-Host "Directory list saved to: $outputFile"
