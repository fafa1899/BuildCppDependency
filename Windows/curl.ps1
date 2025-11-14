# curl.ps1
param(    
    [string]$Name = "curl-curl-8_14_1",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/libcurl.dll"

# 依赖库数组
$Librarys = @("zlib","c-ares","openssl")  

# 符号库文件
$PdbFiles = @(
    "lib/RelWithDebInfo/libcurl.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    CURL_USE_LIBPSL = "OFF"
    CURL_USE_OPENSSL = "ON"
    CURL_ZSTD = "OFF"
    CURL_USE_LIBSSH = "OFF"
    CURL_USE_LIBSSH2 = "OFF"
    CURL_USE_WOLFSSH = "OFF"
    ENABLE_ARES = "ON"
    ENABLE_CURL_MANUAL = "OFF"
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
