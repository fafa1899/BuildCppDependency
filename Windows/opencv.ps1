param( 
    [string]$SourceAddress = "https://github.com/opencv/opencv/archive/refs/tags/3.4.16.zip",
    [string]$SourceZipPath = "../Source/opencv-3.4.16.zip",
    [string]$SourceLocalPath = "./opencv-3.4.16",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/opencv_world3416.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
#$Librarys = @("zlib", "libpng", "libjpeg", "libtiff", "eigen")
$Librarys = @("eigen")
BuildRequired -Librarys $Librarys

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
    # 配置阶段，指定生成器、平台和安装路径
    cmake .. -G "$Generator" -A x64 `
        -DCMAKE_BUILD_TYPE=Release `
        -DCMAKE_PREFIX_PATH="$env:GISBasic" `
        -DCMAKE_INSTALL_PREFIX="$InstallDir" `
        -DBUILD_opencv_world=ON `
        -DWITH_GDAL=OFF `
        -DWITH_FFMPEG=OFF `
        -DWITH_IPP=OFF `
        -DBUILD_TESTS=OFF `
        -DBUILD_PERF_TESTS=OFF `
        -DBUILD_opencv_python_tests=OFF `
        -DBUILD_opencv_python_bindings_generator=OFF `
        -DBUILD_JAVA=OFF `
        -DBUILD_opencv_java=OFF `
        -DBUILD_opencv_java_bindings_generator=OFF `
        #-DBUILD_ZLIB=OFF `
        #-DBUILD_JPEG=OFF `
        #-DBUILD_PNG=OFF `
        #-DBUILD_TIFF=OFF `
        #-DWITH_PROTOBUF=ON `
        #-DBUILD_PROTOBUF=ON `
        #-DPROTOBUF_UPDATE_FILES=OFF `

    # 构建阶段，指定构建类型
    cmake --build . --config Release

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config Release --target install

    # 复制符号库
    $PdbFiles = @(     
        "./bin/Release/opencv_world3416.pdb"
    ) 
    foreach ($file in $PdbFiles) {  
        Write-Output $file
        Copy-Item -Path $file -Destination $SymbolDir
    }   
  
    # 将二进制成果文件复制到bin目录 
    Copy-Item -Path "$InstallDir/x64/vc16/bin/*" -Destination "$InstallDir/bin" -Force
}
finally {
    # 返回原始工作目录
    Pop-Location
}