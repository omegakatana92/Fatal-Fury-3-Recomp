# Package the Windows x64 Release build into
# dist/windows/Fatal Fury 3-Windows-x64.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\scripts\package-windows.ps1
param(
    [string]$BuildDir = "",
    [string]$OutDir = "",
    [string]$VCRedistDir = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not $BuildDir) { $BuildDir = Join-Path $root "build-windows" }
if (-not $OutDir) { $OutDir = Join-Path $root "dist\windows\Fatal Fury 3-Windows-x64" }

$exe = Join-Path $BuildDir "Release\Fatal Fury 3.exe"
if (-not (Test-Path $exe)) { throw "missing $exe; build the Release target first" }

New-Item -ItemType Directory -Force $OutDir | Out-Null
$lic = Join-Path $OutDir "LICENSES"
New-Item -ItemType Directory -Force $lic | Out-Null

Copy-Item $exe (Join-Path $OutDir "Fatal Fury 3.exe") -Force
Copy-Item (Join-Path $root "packaging\windows\README.txt") (Join-Path $OutDir "README.txt") -Force
Copy-Item (Join-Path $root "packaging\windows\Prepare-ROMs.ps1") (Join-Path $OutDir "Prepare-ROMs.ps1") -Force
Copy-Item (Join-Path $root "packaging\windows\Play Fatal Fury 3.cmd") (Join-Path $OutDir "Play Fatal Fury 3.cmd") -Force

$sdl = Join-Path $BuildDir "Release\SDL2.dll"
if (Test-Path $sdl) { Copy-Item $sdl (Join-Path $OutDir "SDL2.dll") -Force }
else { Write-Warning "SDL2.dll not found next to the executable" }

if (-not $VCRedistDir) {
    $candidates = Get-ChildItem "${env:ProgramFiles}\Microsoft Visual Studio" `
        -Recurse -Filter vcruntime140.dll -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DirectoryName -match '\\x64\\Microsoft\.VC[0-9]+\.CRT$' -and
            $_.DirectoryName -notmatch 'onecore|debug'
        }
    if ($candidates) { $VCRedistDir = $candidates[-1].DirectoryName }
}
if ($VCRedistDir -and (Test-Path $VCRedistDir)) {
    foreach ($dll in "vcruntime140.dll", "vcruntime140_1.dll") {
        $p = Join-Path $VCRedistDir $dll
        if (Test-Path $p) { Copy-Item $p (Join-Path $OutDir $dll) -Force }
    }
}

Copy-Item (Join-Path $root "LICENSE") (Join-Path $lic "LICENSE.txt") -Force
Copy-Item (Join-Path $root "LICENSE-STATUS.md") (Join-Path $lic "LICENSE-STATUS.txt") -Force
Copy-Item (Join-Path $root "THIRD_PARTY_NOTICES.md") (Join-Path $lic "THIRD_PARTY_NOTICES.txt") -Force
Copy-Item (Join-Path $root "packaging\windows\SDL2.txt") (Join-Path $lic "SDL2.txt") -Force
Copy-Item (Join-Path $root "neogeorecomp\LICENSE") (Join-Path $lic "neogeorecomp.txt") -Force
Copy-Item (Join-Path $root "neogeorecomp\NOTICE") (Join-Path $lic "neogeorecomp-NOTICE.txt") -Force
foreach ($f in "Musashi.txt", "ymfm.txt", "z80.txt") {
    Copy-Item (Join-Path $root "neogeorecomp\LICENSES\$f") (Join-Path $lic $f) -Force
}

# Recreate the zip used as a release asset.
$zip = Join-Path $root "dist\windows\Fatal Fury 3-Windows-x64.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $OutDir "*") -DestinationPath $zip -CompressionLevel Optimal

Write-Host "Wrote $OutDir"
Write-Host "Wrote $zip"
