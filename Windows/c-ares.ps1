# build-cares.ps1
param(    
    [string]$Name = "c-ares-1.34.5",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

$DllPath = "$InstallDir/bin/cares.dll"

$PdbFiles = @("bin/RelWithDebInfo/cares.pdb")

$CMakeCacheVariables = @{}

. ./build-common.ps1 -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -TargetDll $DllPath `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup