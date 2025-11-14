# libtiff.ps1
param(    
    [string]$Name = "libzip-1.10.1",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/zip.dll"

# 依赖库数组
$Librarys = @("zlib")  

# 符号库文件
$PdbFiles = @(
    "lib/RelWithDebInfo/zip.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    BUILD_DOC = "OFF"
    BUILD_EXAMPLES = "OFF"
    BUILD_REGRESS = "OFF"
    ENABLE_OPENSSL = "OFF"
}

. ./build-common.ps1 -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -TargetDll $DllPath `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys