# pystring 构建脚本
param(
    [string]$Name = "pystring-1.2.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)

# 静态链接库，使用与其他依赖一致的动态 MSVC 运行库
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "OFF"
    CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreadedDLL"
}

& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles @() `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys @()