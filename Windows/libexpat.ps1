# Expat 构建脚本
param(
    [string]$Name = "libexpat-R_2_7_0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)

$PdbFiles = @("RelWithDebInfo/libexpat.pdb")
$CMakeCacheVariables = @{
    EXPAT_SHARED_LIBS = "ON"
    EXPAT_BUILD_DOCS = "OFF"
    EXPAT_BUILD_EXAMPLES = "OFF"
    EXPAT_BUILD_TESTS = "OFF"
    EXPAT_BUILD_TOOLS = "OFF"
    EXPAT_BUILD_PKGCONFIG = "ON"
}

# 官方源码包的 CMake 工程位于 expat 子目录
& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir `
    -SourceSubDir "expat" `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys @()
