param(      
    # 在线地址：https://codeload.github.com/libjpeg-turbo/libjpeg-turbo/zip/refs/tags/3.0.3
    [string]$SourceLocalPath = "../Source/libjpeg-turbo-3.0.3",
    [string]$BuildDir = "./libjpeg-turbo-3.0.3",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/turbojpeg.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 复制符号库
$PdbFiles = @(
    "$BuildDir/RelWithDebInfo/jpeg62.pdb",
    "$BuildDir/RelWithDebInfo/turbojpeg.pdb"
)

# 额外构建参数
$CMakeCacheVariables = @{
    ENABLE_STATIC = "OFF"
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
