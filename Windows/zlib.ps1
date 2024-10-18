param(      
    # 在线地址：https://www.zlib.net/zlib131.zip
    [string]$SourceLocalPath = "../Source/zlib-1.3.1",
    [string]$BuildDir = "./zlib-1.3.1",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/zlib.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 复制符号库
$PdbFiles = @(
    "$BuildDir/RelWithDebInfo/zlib.pdb",
    "$BuildDir/RelWithDebInfo/zlibstatic.pdb"
)    

# 额外构建参数
$CMakeCacheVariables = @{
    ZLIB_BUILD_EXAMPLES = "OFF"
}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourceLocalPath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true  
