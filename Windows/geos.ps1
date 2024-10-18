param( 
    # 在线地址：https://codeload.github.com/libgeos/geos/zip/refs/tags/3.12.2
    [string]$SourceLocalPath = "../Source/geos-3.12.2",
    [string]$BuildDir = "./geos-3.12.2",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/geos_c.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 复制符号库
$PdbFiles = @(
    "$BuildDir/bin/RelWithDebInfo/geos.pdb",
    "$BuildDir/bin/RelWithDebInfo/geos_c.pdb"
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
    