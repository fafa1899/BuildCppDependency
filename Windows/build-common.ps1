# build-library.ps1
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
    [string]$TargetDll,  # 用于判断是否已安装的 DLL 路径
    [bool]$MultiConfig = $false,  # 控制是否使用多配置类型
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true,        # 是否在构建完成后删除源码和构建目录   
    [string[]]$Librarys = @(),  # 可选的依赖库数组，例如：-Librarys "zlib", "libjpeg"
    [string]$BuildType = "RelWithDebInfo"  # 构建类型参数，默认为 RelWithDebInfo
)

# 动态路径构建
$zipFilePath = Join-Path -Path $SourceDir -ChildPath "$Name.zip"
$SourcePath = Join-Path -Path $SourceDir -ChildPath $Name
$BuildDir = Join-Path -Path "." -ChildPath $Name

# 检查是否已经安装（通过目标 DLL）
if (-not $Force -and $TargetDll -and (Test-Path $TargetDll)) {
    Write-Output "Library already installed: $TargetDll"
    exit 0
}

# 创建所有依赖库的容器
if ($Librarys.Count -gt 0) {
    . "./BuildRequired.ps1"
    BuildRequired -Librarys $Librarys
}

# 确保源码目录存在：解压 ZIP
if (!(Test-Path $SourcePath)) {
    if (!(Test-Path $zipFilePath)) {
        Write-Error "Archive not found: $zipFilePath"
        exit 1
    }
    Write-Output "Extracting $zipFilePath to $SourceDir..."
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $SourceDir -Force
}

# 如果是强制构建，且构建目录已存在，先删除旧的构建目录（确保干净构建）
if ($Force -and (Test-Path $BuildDir)) {
    Write-Output "Force mode enabled. Removing previous build directory: $BuildDir"
    Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 遍历并添加前缀
$PdbFiles = $PdbFiles | ForEach-Object {
    Join-Path -Path $BuildDir -ChildPath $_
}

# 调用通用 CMake 构建脚本
Write-Output "Starting build for $Name..."
. ./cmake-build.ps1 -SourceLocalPath $SourcePath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $MultiConfig `
    -BuildType $BuildType

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed for $Name."
    exit $LASTEXITCODE
}

# 构建成功后，根据 Cleanup 开关决定是否删除
if ($Cleanup) {
    Write-Output "Build succeeded. Cleaning up temporary directories..."
    if (Test-Path $SourcePath) { 
        Remove-Item $SourcePath -Recurse -Force -ErrorAction SilentlyContinue 
        Write-Output "Removed source directory: $SourcePath"
    }
    if (Test-Path $BuildDir) { 
        Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue 
        Write-Output "Removed build directory: $BuildDir"
    }
}

Write-Output "Build completed for $Name."