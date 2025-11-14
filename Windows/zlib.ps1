# zlib.ps1
param(    
    [string]$Name = "zlib-1.3.1",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/zlib.dll"

# 符号库文件
$PdbFiles = @(
    "RelWithDebInfo/zlib.pdb",
    "RelWithDebInfo/zlibstatic.pdb"
)  

# 额外构建参数
$CMakeCacheVariables = @{
    ZLIB_BUILD_EXAMPLES = "OFF"
}

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