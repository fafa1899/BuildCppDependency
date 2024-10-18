param(        
    # 在线地址：http://www.libtiff.org/downloads/tiff-4.6.0t.zip"
    [string]$SourceLocalPath = "../Source/tiff-4.6.0t",
    [string]$BuildDir = "./tiff-4.6.0t",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/tiff.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("zlib", "libjpeg")
BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @(
    "$BuildDir/libtiff/RelWithDebInfo/tiff.pdb",
    "$BuildDir/libtiff/RelWithDebInfo/tiffxx.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    "tiff-docs"    = "OFF"
    "tiff-tests"   = "OFF"
    "tiff-contrib" = "OFF" 
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
