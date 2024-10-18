param(      
    # 在线地址：https://chromium.googlesource.com/webm/libwebp/+/refs/tags/v1.3.2
    [string]$SourceLocalPath = "../Source/libwebp-1.3.2",
    [string]$BuildDir = "./libwebp-1.3.2",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/libwebp.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器：FBX、GDAL、CURL
. "./BuildRequired.ps1"
$Librarys = @("zlib", "libpng", "libjpeg", "libtiff", "giflib") 
BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @(
    "$BuildDir/RelWithDebInfo/libwebp.pdb"
)

# 额外构建参数
$CMakeCacheVariables = @{
    WEBP_UNICODE      = "ON"
    BUILD_SHARED_LIBS = "ON"
    WEBP_LINK_STATIC  = "OFF"
}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourceLocalPath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false  
