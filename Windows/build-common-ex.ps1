# 使用安装标记判断安装状态的通用构建脚本
param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [string]$SourceDir,
    [Parameter(Mandatory=$true)]
    [string]$InstallDir,
    [string]$SymbolDir,
    [string]$Generator,
    [string]$MSBuild,
    [hashtable]$CMakeCacheVariables = @{},
    [string[]]$PdbFiles = @(),
    [bool]$MultiConfig = $false,
    [bool]$Force = $false,
    [bool]$Cleanup = $true,
    [bool]$PreserveSource = $false,  # 保留仓库自带的源码，Cleanup 仍清理构建目录
    [string[]]$Librarys = @(),
    [string]$BuildType = "RelWithDebInfo"
)

$zipFilePath = Join-Path $SourceDir "$Name.zip"
$SourcePath = Join-Path $SourceDir $Name
$BuildDir = Join-Path "." $Name
$MarkerDir = Join-Path $InstallDir "installed"
$InstallMarker = Join-Path $MarkerDir "$Name.installed"

if (-not $Force -and (Test-Path -LiteralPath $InstallMarker -PathType Leaf)) {
    Write-Output "Library already installed: $InstallMarker"
    $global:LASTEXITCODE = 0
    return
}

# 强制重建失败后不能保留旧的成功标记
if (Test-Path -LiteralPath $InstallMarker) {
    Remove-Item -LiteralPath $InstallMarker -Force -ErrorAction Stop
}

foreach ($library in $Librarys) {
    & (Join-Path $PSScriptRoot "$library.ps1") `
        -Generator $Generator -InstallDir $InstallDir -SymbolDir $SymbolDir
    if ($LASTEXITCODE -ne 0) {
        throw "Dependency build failed: $library (exit code $LASTEXITCODE)"
    }
}

if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
    if (-not (Test-Path -LiteralPath $zipFilePath -PathType Leaf)) {
        throw "Archive not found: $zipFilePath"
    }
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $SourceDir -Force -ErrorAction Stop
}

if ($Force -and (Test-Path -LiteralPath $BuildDir)) {
    Remove-Item -LiteralPath $BuildDir -Recurse -Force -ErrorAction Stop
}

# 复用 CMake 配置、构建、安装和符号复制流程，失败时终止，避免误写标记
$BuildPdbFiles = @()
if ($SymbolDir -and $PdbFiles.Count -gt 0) {
    New-Item -ItemType Directory -Path $SymbolDir -Force -ErrorAction Stop | Out-Null
    $BuildPdbFiles = @($PdbFiles | ForEach-Object { Join-Path $BuildDir $_ })
}

& "$PSScriptRoot/cmake-build-ex.ps1" -SourceLocalPath $SourcePath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $BuildPdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $MultiConfig `
    -BuildType $BuildType

New-Item -ItemType Directory -Path $MarkerDir -Force -ErrorAction Stop | Out-Null
Set-Content -LiteralPath $InstallMarker -Encoding UTF8 -ErrorAction Stop `
    -Value "Installed on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); BuildType=$BuildType; Generator=$Generator"

if ($Cleanup) {
    $CleanupPaths = @($BuildDir)
    if (-not $PreserveSource) {
        $CleanupPaths += $SourcePath
    }
    foreach ($path in $CleanupPaths) {
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        }
    }
}

$global:LASTEXITCODE = 0
Write-Output "Build completed for $Name. Installation marker: $InstallMarker"
