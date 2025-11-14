# giflib.ps1
param( 
    [string]$SourceLocalPath = "../Source/giflib-5.2.2",
    [string]$BuildDir = "./giflib-5.2.2",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 检查目标文件是否存在，以判断是否安装
$TargetDll = "$InstallDir/bin/giflib.dll"
if (-not $Force -and $TargetDll -and (Test-Path $TargetDll)) {
    Write-Output "Library already installed: $TargetDll"
    exit 0
}

# 如果是强制构建，且构建目录已存在，先删除旧的构建目录（确保干净构建）
if ($Force -and (Test-Path $BuildDir)) {
    Write-Output "Force mode enabled. Removing previous build directory: $BuildDir"
    Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 复制符号库
$PdbFiles = @(
    "$BuildDir/RelWithDebInfo/giflib.pdb"        
) 

# 额外构建参数
$CMakeCacheVariables = @{}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourceLocalPath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true
 
# 构建成功后，根据 Cleanup 开关决定是否删除
if ($Cleanup) {
    Write-Output "Build succeeded. Cleaning up temporary directories..."
    if (Test-Path $BuildDir) { 
        Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue 
        Write-Output "Removed build directory: $BuildDir"
    }
}

Write-Output "Build completed for giflib."
