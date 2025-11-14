param(  
    [string]$SourceLocalPath = "../Source/OpenMVG-2.1/src",
    [string]$BuildDir = "./OpenMVG-2.1",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# # 检查目标文件是否存在，以判断是否安装
# $DstFilePath = "$InstallDir/bin/gdal.dll"
# if (Test-Path $DstFilePath) {
#     Write-Output "The current library has been installed."
#     exit 1
# } 

# # 创建所有依赖库的容器
# . "./BuildRequired.ps1"
# $Librarys = @("zlib", "libjpeg", "libpng", "giflib", "libtiff", "libwebp")
# BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @(  
    #"$BuildDir/RelWithDebInfo/gdal.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourceLocalPath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false  
