param(   
    [string]$SourceLocalPath = "../Source/cpp-httplib-0.18.0",
    [string]$BuildDir = "./cpp-httplib-0.18.0",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/include/httplib.h"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 清除旧的构建目录
if (Test-Path $BuildDir) {
    Remove-Item -Path $BuildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildDir

# 转到构建目录
# Push-Location $BuildDir

# 配置CMake  
cmake $SourceLocalPath `
    -B "$BuildDir" `
    -G "$Generator" `
    -A x64 `
    -DCMAKE_BUILD_TYPE=RelWithDebInfo `
    -DCMAKE_PREFIX_PATH="$InstallDir" `
    -DCMAKE_INSTALL_PREFIX="$InstallDir" `
   
# 构建阶段，指定构建类型
cmake --build $BuildDir --config RelWithDebInfo

# 安装阶段，指定构建类型和安装目标
cmake --build $BuildDir --config RelWithDebInfo --target install
