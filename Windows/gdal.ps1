# libtiff.ps1
param(    
    [string]$Name = "gdal-3.10.3",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/gdal.dll"

# 依赖库数组
$Librarys = @("zlib", "libjpeg", "libpng", "giflib", "libtiff", "libwebp", "geos", "sqlite", "proj", "curl", "openssl", "libexpat","libxml2")

# 符号库文件
$PdbFiles = @(  
    "RelWithDebInfo/gdal.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    GDAL_USE_CURL         = "ON"
    BUILD_TESTING         = "OFF"
    GDAL_USE_OPENSSL      = "ON"
    GDAL_USE_SPATIALITE   = "ON"
    GDAL_USE_MSSQL_NCLI   = "OFF"
    GDAL_USE_DEFLATE      = "OFF"
    GDAL_USE_LERC         = "OFF"
    GDAL_USE_PCRE2        = "OFF" 
    GDAL_USE_OPENCL       = "OFF"
    GDAL_USE_LIBLZMA      = "OFF"
    GDAL_USE_LZ4          = "OFF"
    GDAL_USE_BLOSC        = "OFF"
    GDAL_USE_OPENJPEG     = "OFF"
    GDAL_USE_ZSTD         = "OFF"
    GDAL_USE_HDF5         = "OFF"
    GDAL_USE_ARCHIVE      = "OFF"
    BUILD_JAVA_BINDINGS   = "OFF"
    BUILD_CSHARP_BINDINGS = "OFF"    
    BUILD_PYTHON_BINDINGS = "OFF"
}

# 设置代理
$env:http_proxy = "http://127.0.0.1:7890"
$env:https_proxy = "http://127.0.0.1:7890"

# 验证代理设置
Write-Output "HTTP Proxy: $env:http_proxy"
Write-Output "HTTPS Proxy: $env:https_proxy"

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

# 取消代理设置
Remove-Item env:http_proxy
Remove-Item env:https_proxy

# 验证代理设置已取消
Write-Output "HTTP Proxy: $env:http_proxy"
Write-Output "HTTPS Proxy: $env:https_proxy"
