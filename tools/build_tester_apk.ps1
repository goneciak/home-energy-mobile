<#
.SYNOPSIS
  Builds the beta flavor release APK for a tester and verifies it.
  Output: dist/tester/GI-Home-beta-<version>+<build>.apk and BUILD-INFO.txt.
  Details: docs/tester-build.md.
#>
[CmdletBinding()]
param(
    [string] $BuildName,
    [int] $BuildNumber,
    [switch] $SplitAbi,
    [switch] $AllowDirty
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

if (-not $AllowDirty -and (git status --porcelain)) {
    throw 'Working tree is dirty. Commit or stash, or pass -AllowDirty.'
}

if (-not $BuildName) {
    $BuildName = (Select-String -Path app/pubspec.yaml -Pattern '^version:\s*([\d.]+)').Matches[0].Groups[1].Value
}
if (-not $BuildNumber) {
    # Minutes since 2025-01-01 UTC: always rises, fits the 2.1e9 versionCode limit.
    $BuildNumber = [int][math]::Floor(([datetime]::UtcNow - [datetime]'2025-01-01').TotalMinutes)
}

# FVM Flutter: sdk path from local.properties, else .fvmrc version.
$flutterBat = $null
$lp = 'app/android/local.properties'
if (Test-Path $lp) {
    $m = Select-String -Path $lp -Pattern '^flutter\.sdk=(.+)$' | Select-Object -First 1
    if ($m) {
        $sdk = $m.Matches[0].Groups[1].Value -replace '\\\\', '\' -replace '\\:', ':'
        $c = Join-Path $sdk 'bin\flutter.bat'
        if (Test-Path $c) { $flutterBat = $c }
    }
}
if (-not $flutterBat -and (Test-Path .fvmrc)) {
    $ver = (Get-Content .fvmrc -Raw | ConvertFrom-Json).flutter
    $c = Join-Path $env:USERPROFILE "fvm\versions\$ver\bin\flutter.bat"
    if (Test-Path $c) { $flutterBat = $c }
}
if (-not $flutterBat) { throw 'FVM Flutter not found (local.properties flutter.sdk or .fvmrc).' }
Write-Host "Flutter: $flutterBat"

# Gradle needs JDK 17+; ignore an old JAVA_HOME and use Android Studio's JBR.
$jbr = 'C:\Program Files\Android\Android Studio\jbr'
$jh = $env:JAVA_HOME
$needJbr = $true
if ($jh -and (Test-Path (Join-Path $jh 'release'))) {
    $rel = Get-Content (Join-Path $jh 'release') -Raw
    if ($rel -match 'JAVA_VERSION="(\d+)') { $needJbr = ([int]$Matches[1] -lt 17) }
}
if ($needJbr) {
    if (-not (Test-Path $jbr)) { throw "JDK 17+ not found; set JAVA_HOME (tried $jbr)." }
    $env:JAVA_HOME = $jbr
    Write-Host "JAVA_HOME: $jbr"
}

$hasKey = (Test-Path app/android/key.properties) -or [bool]$env:GI_UPLOAD_KEYSTORE_PATH -or [bool]$env:GI_UPLOAD_STORE_FILE
if (-not $hasKey) {
    Write-Warning 'No release signing config: the APK is signed with this PC debug key (~/.android/debug.keystore). Updating a tester install needs the same key; otherwise uninstall first. See docs/tester-build.md.'
}

$buildArgs = @('build', 'apk', '--release', '--flavor', 'beta', '-t', 'lib/main_beta.dart',
    '--dart-define-from-file=config/beta.json', '--build-name', $BuildName, '--build-number', $BuildNumber)
if ($SplitAbi) { $buildArgs += @('--split-per-abi', '--target-platform', 'android-arm64') }

Push-Location app
try {
    & $flutterBat @buildArgs
    if ($LASTEXITCODE -ne 0) { throw "flutter build failed ($LASTEXITCODE)" }
} finally { Pop-Location }

$outDir = 'app/build/app/outputs/flutter-apk'
$srcName = if ($SplitAbi) { 'app-arm64-v8a-beta-release.apk' } else { 'app-beta-release.apk' }
$src = Join-Path $outDir $srcName
if (-not (Test-Path $src)) { throw "Expected output missing: $src" }

New-Item -ItemType Directory -Force dist/tester | Out-Null
$dest = "dist/tester/GI-Home-beta-$BuildName+$BuildNumber.apk"
Copy-Item $src $dest -Force
$destFull = (Resolve-Path $dest).Path
$sha = (Get-FileHash $destFull -Algorithm SHA256).Hash.ToLower()
$size = (Get-Item $destFull).Length
$gitSha = (git rev-parse --short HEAD)
$dirty = if (git status --porcelain) { ' (dirty tree)' } else { '' }

& "$PSScriptRoot/verify_tester_apk.ps1" -ApkPath $destFull -BuildName $BuildName -BuildNumber $BuildNumber -SplitAbi:$SplitAbi
$verifyCode = $LASTEXITCODE

$info = @(
    "File:      $(Split-Path -Leaf $destFull)"
    "Flavor:    beta (release, $(if ($hasKey) { 'release key' } else { 'debug key' }))"
    "Version:   $BuildName+$BuildNumber"
    "Git:       $gitSha$dirty"
    "SHA-256:   $sha"
    "Size:      $size bytes ($([math]::Round($size / 1MB, 1)) MB)"
    "ABI:       $(if ($SplitAbi) { 'arm64-v8a' } else { 'universal' })"
    "Built:     $([datetime]::UtcNow.ToString('s'))Z"
    "Verified:  $(if ($verifyCode -eq 0) { 'yes' } else { 'NO' })"
)
$info | Set-Content dist/tester/BUILD-INFO.txt -Encoding utf8

Write-Host "APK:    $destFull"
Write-Host "SHA256: $sha"
Write-Host "Size:   $size bytes"
if ($verifyCode -ne 0) { exit $verifyCode }
