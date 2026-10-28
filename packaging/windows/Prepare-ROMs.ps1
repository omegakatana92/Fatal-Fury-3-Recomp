# Prepare-ROMs.ps1 - build a runtime-ready Fatal Fury 3 ROM folder from
# your own dumps. This script downloads nothing and contains no ROM data.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1
#   powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1 `
#       -GameZip C:\path\fatfury3.zip -NeoGeoZip C:\path\neogeo.zip

param(
    [string]$GameZip = "",
    [string]$NeoGeoZip = "",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $OutDir) { $OutDir = Join-Path $here "roms" }

function Ask-Zip($label, $current) {
    if ($current -and (Test-Path $current)) { return (Resolve-Path $current).Path }
    while ($true) {
        $p = Read-Host "Path to $label"
        $p = $p.Trim('"').Trim()
        if (Test-Path $p) { return (Resolve-Path $p).Path }
        Write-Host "Not found: $p" -ForegroundColor Yellow
    }
}

$GameZip = Ask-Zip "fatfury3.zip" $GameZip
$NeoGeoZip = Ask-Zip "neogeo.zip" $NeoGeoZip

New-Item -ItemType Directory -Force $OutDir | Out-Null

Write-Host "Extracting $GameZip"
tar -xf $GameZip -C $OutDir
if ($LASTEXITCODE -ne 0) { throw "Could not extract fatfury3.zip" }

Write-Host "Extracting $NeoGeoZip"
tar -xf $NeoGeoZip -C $OutDir
if ($LASTEXITCODE -ne 0) { throw "Could not extract neogeo.zip" }

# The archives may contain a top-level folder; flatten the files we need.
$files = @(
    "069-p1.p1","069-sp2.sp2","069-s1.s1","069-m1.m1",
    "069-c1.c1","069-c2.c2","069-c3.c3","069-c4.c4",
    "069-c5.c5","069-c6.c6","069-v1.v1","069-v2.v2","069-v3.v3",
    "sp-s2.sp1","sfix.sfix","sm1.sm1","000-lo.lo"
)
foreach ($f in $files) {
    if (Test-Path (Join-Path $OutDir $f)) { continue }
    $found = Get-ChildItem $OutDir -Recurse -File -Filter $f |
             Select-Object -First 1
    if ($found) { Copy-Item $found.FullName (Join-Path $OutDir $f) -Force }
}
$missing = $files | Where-Object { -not (Test-Path (Join-Path $OutDir $_)) }
if ($missing) {
    Write-Warning ("Missing: " + ($missing -join ", "))
} else {
    Write-Host ""
    Write-Host "Done. Run:" -ForegroundColor Green
    Write-Host "  `"Fatal Fury 3.exe`" --rom-path `"$OutDir`""
}
