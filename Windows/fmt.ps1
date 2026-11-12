# fmt 构建脚本
param(
    [string]$Name = "fmt-12.2.1",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建已安装的库
    [bool]$Cleanup = $true        # 是否在构建成功后清理源码和构建目录
)

# 核心库不依赖额外的第三方库
$Librarys = @()
$PdbFiles = @("bin/RelWithDebInfo/fmt.pdb")

# 安装动态库、头文件及 CMake 配置，关闭测试和文档
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    FMT_INSTALL = "ON"
    FMT_DOC = "OFF"
    FMT_TEST = "OFF"
    FMT_FUZZ = "OFF"
    FMT_CUDA_TEST = "OFF"
    FMT_MODULE = "OFF"
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
