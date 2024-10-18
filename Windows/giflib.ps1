param( 
    [string]$SourceLocalPath = "../Source/giflib-5.2.2",
    [string]$BuildDir = "./giflib-5.2.2",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/giflib.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 复制符号库
$PdbFiles = @(
    "$BuildDir/RelWithDebInfo/giflib.pdb"        
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
    -MultiConfig $true  
