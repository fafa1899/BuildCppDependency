# OpenEXR 构建脚本
param(
    [string]$Name = "openexr-3.5.3",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建已安装的库
    [bool]$Cleanup = $true        # 是否在构建成功后清理源码和构建目录
)

# 复用独立安装的 Imath；libdeflate 和 OpenJPH 使用源码包内置版本
$Librarys = @("Imath")

$PdbFiles = @(
    "bin/RelWithDebInfo/Iex-3_5.pdb"
    "bin/RelWithDebInfo/IlmThread-3_5.pdb"
    "bin/RelWithDebInfo/OpenEXRCore-3_5.pdb"
    "bin/RelWithDebInfo/OpenEXR-3_5.pdb"
    "bin/RelWithDebInfo/OpenEXRUtil-3_5.pdb"
)

# 只构建并安装 C++ 动态库及 CMake 配置
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    BUILD_TESTING = "OFF"
    OPENEXR_INSTALL = "ON"
    OPENEXR_BUILD_LIBS = "ON"
    OPENEXR_BUILD_TOOLS = "OFF"
    OPENEXR_INSTALL_TOOLS = "OFF"
    OPENEXR_BUILD_EXAMPLES = "OFF"
    OPENEXR_BUILD_PYTHON = "OFF"
    OPENEXR_USE_TBB = "OFF"
    OPENEXR_FORCE_INTERNAL_DEFLATE = "ON"
    OPENEXR_FORCE_INTERNAL_OPENJPH = "ON"
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
