param( 
    [string]$SourceAddress = "https://github.com/opencv/opencv/archive/refs/tags/3.4.16.zip",
    [string]$SourceZipPath = "../Source/opencv-3.4.16.zip",
    [string]$SourceLocalPath = "./opencv-3.4.16",
    [string]$Generator = "Visual Studio 16 2019",
    [string]$MSBuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    [string]$InstallDir = "$env:GISBasic"  
)

if (!(Test-Path $SourceLocalPath)) {
    if (!(Test-Path $SourceZipPath)) {
        #下载源代码
        Write-Output "Download Zip..."
        Invoke-WebRequest -Uri $SourceAddress -OutFile $SourceZipPath
    }

    # 解压缩 ZIP 文件   
    Write-Output "Unzip Source..."
    Expand-Archive -Path $SourceZipPath -DestinationPath "./"
}

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
        -DBUILD_opencv_java_bindings_generator=OFF

    # 构建阶段，指定构建类型
    cmake --build . --config Release

    # # 安装阶段，指定构建类型和安装目标
    cmake --build . --config Release --target install

    # 复制符号库
    $PdbFiles = @(     
        "./bin/Release/opencv_world3416.pdb"
    ) 
    $SymbolDir = $InstallDir + "/symbol"
    foreach ($file in $PdbFiles) {  
        Write-Output $file
        Copy-Item -Path $file -Destination $SymbolDir
    }   
  
    # 将二进制成果文件复制到bin目录 
    Copy-Item -Path "$env:GISBasic/x64/vc16/bin/*" -Destination "$env:GISBasic/bin" -Recurse -Force
}
finally {
    # 返回原始工作目录
    Pop-Location
}