# libtiff.ps1
param(    
    [string]$Name = "libxml2-v2.14.4",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/libxml2.dll"

# 依赖库数组
$Librarys = @("zlib")  

# 符号库文件
$PdbFiles = @(
    "RelWithDebInfo/libxml2.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    LIBXML2_WITH_ZLIB = "ON"
    LIBXML2_WITH_ICONV = "ON"
    LIBXML2_WITH_HTTP = "ON"
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
    -Cleanup $Cleanup `
    -Librarys $Librarys
