

param(  
    # 在线地址：https://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.43/lpng1643.zip
    [string]$SourceLocalPath = "../Source/lpng1643",
    [string]$BuildDir = "./lpng1643",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/libpng16.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("zlib")
BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @(
    "$BuildDir/RelWithDebInfo/libpng16.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    PNG_TESTS = "OFF"
    PNG_STATIC = "OFF"
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
