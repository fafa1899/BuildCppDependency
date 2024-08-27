param( 
    [string]$SourceAddress = "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip",
    [string]$SourceZipPath = "../Source/eigen-3.4.0.zip",
    [string]$SourceLocalPath = "./eigen-3.4.0",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

. "./DownloadAndUnzip.ps1"

DownloadAndUnzip -SourceLocalPath $SourceLocalPath -SourceZipPath $SourceZipPath -SourceAddress $SourceAddress

# 清除旧的构建目录
$BuildDir = $SourceLocalPath + "/build"  
if (Test-Path $BuildDir) {
    Remove-Item -Path $BuildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildDir

# 转到构建目录
Push-Location $BuildDir

try {
    # 配置CMake  
    cmake .. -G "$Generator" -A x64 `
    -DCMAKE_BUILD_TYPE=RelWithDebInfo `
    -DCMAKE_PREFIX_PATH="$InstallDir" `
    -DCMAKE_INSTALL_PREFIX="$InstallDir" `
    -DBUILD_TESTING=OFF

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install
}
finally {
    # 返回原始工作目录
    Pop-Location
}