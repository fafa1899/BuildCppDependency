param(        
    [string]$SourceAddress = "http://www.libtiff.org/downloads/tiff-4.6.0t.zip",
    [string]$SourceZipPath = "../Source/tiff-4.6.0t.zip",
    [string]$SourceLocalPath = "./tiff-4.6.0t", 
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/tiff.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("libjpeg")
BuildRequired -Librarys $Librarys

#
. "./DownloadAndUnzip.ps1"
DownloadAndUnzip -SourceLocalPath $SourceLocalPath -SourceZipPath $SourceZipPath -SourceAddress $SourceAddress

# 清除旧的构建目录
$BuildDir = $SourceLocalPath + "/build-dir"  
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
        -Dtiff-docs=OFF `
        -Dtiff-tests=OFF `
        -Dtiff-contrib=OFF 

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo -- /m

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 复制符号库
    $PdbFiles = @(
        "./libtiff/RelWithDebInfo/tiff.pdb",
        "./libtiff/RelWithDebInfo/tiffxx.pdb"
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