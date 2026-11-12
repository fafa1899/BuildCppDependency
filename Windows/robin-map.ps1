# robin-map 构建安装脚本
param(
    [string]$Name = "robin-map-1.4.1",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新安装
    [bool]$Cleanup = $true        # 是否在安装成功后清理源码和构建目录
)

# 纯头文件库，无第三方依赖，也不生成 DLL、LIB 或 PDB
$Librarys = @()
$PdbFiles = @()

# 安装头文件、CMake 配置和 Visual Studio 调试可视化文件
$CMakeCacheVariables = @{
    TSL_ROBIN_MAP_ENABLE_INSTALL = "ON"
}

. ./build-common-ex.ps1 -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys
