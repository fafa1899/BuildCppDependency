# Imath 构建脚本
param(
    [string]$Name = "Imath-3.2.3",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建已安装的库
    [bool]$Cleanup = $true        # 是否在构建成功后清理源码和构建目录
)

# 核心 C++ 库不需要额外的第三方依赖
$Librarys = @()

# 调试符号文件，相对于构建目录
$PdbFiles = @(
    "src/Imath/RelWithDebInfo/Imath-3_2.pdb"
)

# 只构建并安装 C++ 动态库及 CMake 配置
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    BUILD_TESTING = "OFF"
    IMATH_INSTALL = "ON"
    PYTHON = "OFF"
    PYBIND11 = "OFF"
    BUILD_WEBSITE = "OFF"
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
