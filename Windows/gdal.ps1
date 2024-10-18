param( 
    # 在线地址：https://github.com/OSGeo/gdal/releases/download/v3.8.5/gdal385.zip"
    [string]$SourceLocalPath = "../Source/gdal-3.8.5",
    [string]$BuildDir = "./gdal-3.8.5",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/gdal.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("zlib", "libjpeg", "libpng", "giflib", "libtiff", "libwebp")
BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @(  
    "$BuildDir/RelWithDebInfo/gdal.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    GDAL_USE_CURL         = "OFF"
    BUILD_TESTING         = "OFF"
    GDAL_USE_OPENSSL      = "OFF"
    GDAL_USE_SPATIALITE   = "OFF"
    GDAL_USE_MSSQL_NCLI   = "OFF"
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

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourceLocalPath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false  

# 取消代理设置
Remove-Item env:http_proxy
Remove-Item env:https_proxy

# 验证代理设置已取消
Write-Output "HTTP Proxy: $env:http_proxy"
Write-Output "HTTPS Proxy: $env:https_proxy"