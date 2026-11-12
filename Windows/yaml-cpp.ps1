# yaml-cpp 构建脚本
param(
    [string]$Name = "yaml-cpp-0.8.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建已安装的库
    [bool]$Cleanup = $true        # 是否在构建成功后清理源码和构建目录
)

# 核心库不需要第三方依赖
$PdbFiles = @("RelWithDebInfo/yaml-cpp.pdb")
$CMakeCacheVariables = @{
    CMAKE_CXX_STANDARD = "17"
    YAML_BUILD_SHARED_LIBS = "ON"
    YAML_MSVC_SHARED_RT = "ON"
    YAML_CPP_INSTALL = "ON"
    YAML_CPP_BUILD_TESTS = "OFF"
    BUILD_TESTING = "OFF"
    YAML_CPP_BUILD_TOOLS = "OFF"
    YAML_CPP_FORMAT_SOURCE = "OFF"
}

& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys @()
