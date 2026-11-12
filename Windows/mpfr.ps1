# MPFR 预编译包安装脚本，使用与 CMake 构建脚本相同的入口参数
param(
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$Name = "mpfr-4.2.2-prebuilt",
    [string]$SourceDir = $PSScriptRoot,
    [string]$Generator,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 强制覆盖安装，即使安装标记已经存在
    [bool]$Cleanup = $true        # 成功后删除本次解压目录，保留原始压缩包
)

$ErrorActionPreference = 'Stop'
$InstallDir = [System.IO.Path]::GetFullPath($InstallDir)
$ArchivePath = Join-Path $SourceDir "$Name.zip"
$WorkDir = Join-Path $PSScriptRoot "$Name-build"
$PackagePath = Join-Path $WorkDir $Name
$MarkerDir = Join-Path $InstallDir 'installed'
$InstallMarker = Join-Path $MarkerDir "$Name.installed"

if (-not $Force -and (Test-Path -LiteralPath $InstallMarker -PathType Leaf)) {
    Write-Output "Library already installed: $InstallMarker"
    $global:LASTEXITCODE = 0
    return
}

# 避免安装目录位于待清理目录内部
$WorkPrefix = [System.IO.Path]::GetFullPath($WorkDir).TrimEnd('\') + '\'
if ($InstallDir.Equals($WorkPrefix.TrimEnd('\'), [System.StringComparison]::OrdinalIgnoreCase) -or
    $InstallDir.StartsWith($WorkPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'InstallDir must not be inside the temporary extraction directory.'
}

# 失败时不保留旧的成功标记
if (Test-Path -LiteralPath $InstallMarker) {
    Remove-Item -LiteralPath $InstallMarker -Force
}
if (-not (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) {
    throw "Archive not found: $ArchivePath"
}

# 安装匹配的 GMP 运行库；该预编译 MPFR 引用 gmp-10.dll
& "$PSScriptRoot/gmp.ps1" -Generator $Generator -InstallDir $InstallDir -SymbolDir $SymbolDir -Cleanup $Cleanup
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $InstallDir 'bin/gmp-10.dll') -PathType Leaf)) {
    throw 'GMP dependency installation failed.'
}

# 每次重新解压，Cleanup=false 时保留目录供检查
Write-Output "Extracting $ArchivePath to $WorkDir..."
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $WorkDir -Force
foreach ($required in @('include/mpfr.h', 'include/mpf2mpfr.h', 'lib/mpfr.lib', 'bin/mpfr-6.dll', 'symbols/mpfr-6.pdb')) {
    if (-not (Test-Path -LiteralPath (Join-Path $PackagePath $required) -PathType Leaf)) {
        throw "Invalid MPFR package, missing: $required"
    }
}

# 仅安装 MPFR 内容，不覆盖其他库
$PackagePrefix = [System.IO.Path]::GetFullPath($PackagePath).TrimEnd('\') + '\'
$Files = @(Get-ChildItem -LiteralPath $PackagePath -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($PackagePrefix.Length).Replace('\', '/')
    $relative -match '^(bin/mpfr[^/]*\.dll|lib/mpfr[^/]*\.lib|include/(mpfr|mpf2mpfr)\.h|lib/pkgconfig/mpfr[^/]*\.pc|share/mpfr/.+)$'
})
foreach ($file in $Files) {
    $relative = $file.FullName.Substring($PackagePrefix.Length)
    $destination = Join-Path $InstallDir $relative
    New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
    if ((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) {
        throw "Installed file verification failed: $destination"
    }
    Write-Output "Installed: $destination"
}

# 按调用者指定的目录安装预编译包附带的调试符号
if ($SymbolDir) {
    New-Item -ItemType Directory -Path $SymbolDir -Force | Out-Null
    $pdbSource = Join-Path $PackagePath 'symbols/mpfr-6.pdb'
    $pdbDestination = Join-Path $SymbolDir 'mpfr-6.pdb'
    Copy-Item -LiteralPath $pdbSource -Destination $pdbDestination -Force
    if ((Get-FileHash -LiteralPath $pdbSource).Hash -ne (Get-FileHash -LiteralPath $pdbDestination).Hash) {
        throw "Installed symbol verification failed: $pdbDestination"
    }
    Write-Output "Installed symbols: $pdbDestination"
}
# 预编译包不使用 Generator 参数重新编译
Write-Output 'Using prebuilt x64 binaries; Generator is not used.'
New-Item -ItemType Directory -Path $MarkerDir -Force | Out-Null
Set-Content -LiteralPath $InstallMarker -Encoding UTF8 -Value "Installed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); Package=$Name; Method=prebuilt"
if ($Cleanup) {
    Remove-Item -LiteralPath $WorkDir -Recurse -Force
}
$global:LASTEXITCODE = 0
Write-Output "Installation completed for $Name. Marker: $InstallMarker"
