param(    
    [string]$Name = "json-3.11.3",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 根据 $Name 动态构建路径
$zipFilePath = Join-Path -Path $SourceDir -ChildPath "$Name.zip"
$SourcePath = Join-Path -Path $SourceDir -ChildPath $Name
$BuildDir = Join-Path -Path "." -ChildPath $Name

# 解压ZIP文件到指定目录
if (!(Test-Path $SourcePath)) {
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $SourceDir -Force
}

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/include/nlohmann/json.hpp"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 额外构建参数
$CMakeCacheVariables = @{
    JSON_BuildTests = "OFF"
}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourcePath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true      