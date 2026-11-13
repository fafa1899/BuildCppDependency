# OpenColorIO 构建脚本
param(
    [string]$Name = "OpenColorIO-2.6.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    CMAKE_BUILD_TYPE = "RelWithDebInfo"
    OCIO_BUILD_APPS = "OFF"
    OCIO_BUILD_TESTS = "OFF"
    OCIO_BUILD_GPU_TESTS = "OFF"
    OCIO_BUILD_PYTHON = "OFF"
    OCIO_BUILD_DOCS = "OFF"
    OCIO_INSTALL_EXT_PACKAGES = "NONE"
    OCIO_DIRECTX_ENABLED = "OFF"
    OCIO_VULKAN_ENABLED = "OFF"
    CMAKE_CXX_FLAGS = "/utf-8"
}
& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir -InstallDir $InstallDir -SymbolDir $SymbolDir `
    -Generator $Generator -PdbFiles @("src/OpenColorIO/RelWithDebInfo/OpenColorIO.pdb") `
    -CMakeCacheVariables $CMakeCacheVariables -MultiConfig $true `
    -Force $Force -Cleanup $Cleanup -Librarys @("libexpat", "yaml-cpp", "pystring", "Imath", "minizip-ng", "zlib")
