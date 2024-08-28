param(   
    [string]$SourceAddress = "https://codeload.github.com/libjpeg-turbo/libjpeg-turbo/zip/refs/tags/3.0.3",
    [string]$SourceZipPath = "../Source/libjpeg-turbo-3.0.3.zip",
    [string]$SourceLocalPath = "./libjpeg-turbo-3.0.3",
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
    cmake .. -G "$Generator" -A x64 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX="$InstallDir" -DENABLE_STATIC=off

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 复制符号库
    $PdbFiles = @(
        "./RelWithDebInfo/jpeg62.pdb",
        "./RelWithDebInfo/turbojpeg.pdb"
    ) 
    foreach ($file in $PdbFiles) {  
        Write-Output $file
        Copy-Item -Path $file -Destination $SymbolDir
    }    
}
finally {
    # 返回原始工作目录
    Pop-Location
}