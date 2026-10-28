# Build the Windows x64 Release player.
#
# Usage (from the project root):
#   powershell -ExecutionPolicy Bypass -File scripts\build-windows.ps1
#   powershell ... -RomDir C:\path\to\roms -SdlDir C:\path\to\SDL2\cmake
param(
    [string]$RomDir = '',
    [string]$SdlDir = '',
    [string]$BuildDir = 'build-windows'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $RomDir) { $RomDir = Join-Path $root 'roms' }
$RomDir = (Resolve-Path $RomDir).Path
$build = Join-Path $root $BuildDir

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vsVer = & $vswhere -latest -products * -property installationVersion
if (-not $vsVer) { throw 'Visual Studio with the C++ workload was not found' }
$major = ([regex]::Match("$vsVer", '^(\d+)')).Groups[1].Value
$gen = if ($major -eq '18') { 'Visual Studio 18 2026' } else { 'Visual Studio 17 2022' }

$cfg = @('-S', $root, '-B', $build, '-G', $gen, '-A', 'x64', "-DFATFURY3_ROM_DIR=$RomDir")
if ($SdlDir) { $cfg += "-DSDL2_DIR=$SdlDir" }
& cmake @cfg
if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed' }
& cmake --build $build --config Release --target fatfury3 --parallel
if ($LASTEXITCODE -ne 0) { throw 'build failed' }
Write-Host "built $build\Release\Fatal Fury 3.exe" -ForegroundColor Green
