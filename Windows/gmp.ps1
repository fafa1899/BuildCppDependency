# GMP 预编译包安装脚本，使用与 CMake 构建脚本相同的入口参数
param(
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$Name = "gmp-6.3.0-prebuilt",
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

# 每次重新解压，Cleanup=false 时保留目录供检查
Write-Output "Extracting $ArchivePath to $WorkDir..."
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $WorkDir -Force
foreach ($required in @('include/gmp.h', 'include/gmpxx.h', 'lib/gmp.lib', 'lib/gmpxx.lib', 'bin/gmp-10.dll', 'bin/gmpxx-4.dll')) {
    if (-not (Test-Path -LiteralPath (Join-Path $PackagePath $required) -PathType Leaf)) {
        throw "Invalid GMP package, missing: $required"
    }
}

# 仅安装 GMP 内容，不覆盖包中附带的 iconv 等其他库的头文件
$PackagePrefix = [System.IO.Path]::GetFullPath($PackagePath).TrimEnd('\') + '\'
$Files = @(Get-ChildItem -LiteralPath $PackagePath -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($PackagePrefix.Length).Replace('\', '/')
    $relative -match '^(bin/gmp[^/]*\.dll|lib/gmp[^/]*\.lib|include/gmp[^/]*\.h|lib/pkgconfig/gmp[^/]*\.pc|share/gmp/.+)$'
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

# Generator 和 SymbolDir 保持入口兼容；预编译包不会重新编译，也不包含 PDB
Write-Output 'Using prebuilt x64 binaries; Generator is not used and no PDB files are supplied.'
New-Item -ItemType Directory -Path $MarkerDir -Force | Out-Null
Set-Content -LiteralPath $InstallMarker -Encoding UTF8 -Value "Installed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); Package=$Name; Method=prebuilt"
if ($Cleanup) {
    Remove-Item -LiteralPath $WorkDir -Recurse -Force
}
$global:LASTEXITCODE = 0
Write-Output "Installation completed for $Name. Marker: $InstallMarker"
