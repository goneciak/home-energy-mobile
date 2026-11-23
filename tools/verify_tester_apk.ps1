<#
.SYNOPSIS
  Verifies a beta tester APK (see docs/tester-build.md). Exits non-zero on failure.
.EXAMPLE
  pwsh tools/verify_tester_apk.ps1 -ApkPath dist/tester/x.apk -BuildName 0.1.0 -BuildNumber 123
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $ApkPath,
    [Parameter(Mandatory)] [string] $BuildName,
    [Parameter(Mandatory)] [int] $BuildNumber,
    [switch] $SplitAbi,
    [string] $SdkRoot
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
if (-not $SdkRoot) {
    $SdkRoot = $env:ANDROID_HOME
    if (-not $SdkRoot) { $SdkRoot = $env:ANDROID_SDK_ROOT }
    $lp = Join-Path $repo 'app/android/local.properties'
    if (-not $SdkRoot -and (Test-Path $lp)) {
        $m = Select-String -Path $lp -Pattern '^sdk\.dir=(.+)$' | Select-Object -First 1
        if ($m) { $SdkRoot = ($m.Matches[0].Groups[1].Value -replace '\\\\', '\' -replace '\\:', ':') }
    }
    if (-not $SdkRoot) { $SdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
}
$bt = Get-ChildItem (Join-Path $SdkRoot 'build-tools') -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'aapt2.exe') } |
    Sort-Object { [version]($_.Name -replace '[^\d.].*$', '') } -Descending | Select-Object -First 1
if (-not $bt) { throw "No build-tools with aapt2 under $SdkRoot" }
$aapt2 = Join-Path $bt.FullName 'aapt2.exe'
$apksigner = Join-Path $bt.FullName 'apksigner.bat'
$apk = (Resolve-Path $ApkPath).Path

$results = New-Object System.Collections.Generic.List[object]
function Check([string] $name, [bool] $ok, [string] $detail) {
    $results.Add([pscustomobject]@{ Check = $name; Result = $(if ($ok) { 'PASS' } else { 'FAIL' }); Detail = $detail })
}

$badging = (& $aapt2 dump badging $apk) -join "`n"
$pkg = [regex]::Match($badging, "package: name='([^']+)' versionCode='(\d+)' versionName='([^']*)'")
Check 'package' ($pkg.Groups[1].Value -eq 'pl.gihome.gi_home.beta') $pkg.Groups[1].Value
Check 'versionName' ($pkg.Groups[3].Value -eq $BuildName) $pkg.Groups[3].Value
$vc = [int]$pkg.Groups[2].Value
# Flutter adds an ABI offset (arm64-v8a: 2000) to the version code with --split-per-abi.
$vcOk = ($vc -eq $BuildNumber) -or ($SplitAbi -and $vc -eq $BuildNumber + 2000)
Check 'versionCode' $vcOk "$vc (expected $BuildNumber)"
$min = [regex]::Match($badging, "minSdkVersion:'(\d+)'").Groups[1].Value
$tgt = [regex]::Match($badging, "targetSdkVersion:'(\d+)'").Groups[1].Value
Check 'minSdk 26' ($min -eq '26') $min
Check 'targetSdk 36' ($tgt -eq '36') $tgt
$label = [regex]::Match($badging, "application-label:'([^']*)'").Groups[1].Value
Check 'label' ($label -eq 'GI Home Beta') $label

$allowed = @('INTERNET', 'ACCESS_NETWORK_STATE', 'ACCESS_WIFI_STATE', 'CHANGE_WIFI_MULTICAST_STATE', 'NEARBY_WIFI_DEVICES')
$perms = [regex]::Matches($badging, "uses-permission(?:-sdk-\d+)?: name='([^']+)'") | ForEach-Object { $_.Groups[1].Value }
$unexpected = $perms | Where-Object {
    $short = $_ -replace '^android\.permission\.', ''
    -not ($allowed -contains $short) -and $_ -ne 'pl.gihome.gi_home.beta.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
}
Check 'permissions' (-not $unexpected) $(if ($unexpected) { "unexpected: $($unexpected -join ', ')" } else { ($perms -join ', ') })

$manifest = (& $aapt2 dump xmltree --file AndroidManifest.xml $apk) -join "`n"
$dbg = $manifest -match 'android:debuggable[^\n]*0xffffffff'
Check 'not debuggable' (-not $dbg) $(if ($dbg) { 'android:debuggable=true' } else { 'ok' })
$nsc = $manifest -match 'networkSecurityConfig'
Check 'network_security_config' $nsc $(if ($nsc) { 'declared' } else { 'missing' })
$cfgEntry = & $aapt2 dump resources $apk | Select-String 'xml/network_security_config' | Select-Object -First 1
Check 'network_security_config file' ([bool]$cfgEntry) $(if ($cfgEntry) { 'present' } else { 'missing' })

$sigOut = (& $apksigner verify --print-certs $apk 2>&1) -join "`n"
$sigOk = ($LASTEXITCODE -eq 0)
$dn = [regex]::Match($sigOut, 'Signer #1 certificate DN: ([^\r\n]+)').Groups[1].Value.Trim()
$isDebug = $dn -match 'CN=Android Debug'
Check 'apksigner verify' $sigOk $(if ($sigOk) { "signer: $dn" } else { $sigOut })
Write-Host "Signer: $(if ($isDebug) { 'Android Debug certificate (debug key)' } else { $dn })"

# Build-time check of the dart-define file that the build used.
$cfg = Get-Content (Join-Path $repo 'app/config/beta.json') -Raw | ConvertFrom-Json
Check 'define FLAVOR=beta' ($cfg.FLAVOR -eq 'beta') "$($cfg.FLAVOR)"
Check 'define FF_MOCK_CORE=false' ($cfg.FF_MOCK_CORE -eq $false) "$($cfg.FF_MOCK_CORE)"
$expected = [ordered]@{ FF_SCHEDULE_CLOCK_CONVERSION = $false; FF_SWITCH_CONTROL_BY_INTEGRATION = $false
    FF_ANDROID_LOCAL_NETWORK_PERMISSION_REQUEST = $false; FF_CONDITIONAL_GET = $false; FF_MDNS_FALLBACK = $true }
foreach ($k in $expected.Keys) {
    Check "define $k" ($cfg.$k -eq $expected[$k]) "$($cfg.$k)"
}

$results | Format-Table -AutoSize -Wrap | Out-String -Width 200 | Write-Host
$failed = @($results | Where-Object Result -eq 'FAIL')
if ($failed.Count -gt 0) {
    Write-Host "VERIFY FAILED: $($failed.Count) check(s)" -ForegroundColor Red
    exit 1
}
Write-Host "VERIFY OK: $($results.Count) checks passed" -ForegroundColor Green
