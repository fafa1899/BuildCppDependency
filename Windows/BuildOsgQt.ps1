param(   
    [string]$SourceZipPath = "../Source/osgQt-master.zip",
    [string]$SourceLocalPath = "./osgQt-master",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir   
)

if (!(Test-Path $SourceLocalPath)) {
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
    #配置CMake      
    cmake .. -G "$Generator" -A x64 `
        -DCMAKE_BUILD_TYPE=RelWithDebInfo `
        -DCMAKE_PREFIX_PATH="$InstallDir" `
        -DCMAKE_INSTALL_PREFIX="$InstallDir" `
        -DCMAKE_RELWITHDEBINFO_POSTFIX="" `
        -DBUILD_OSG_EXAMPLES=OFF

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo -- /m:8

    # 安装阶段，指定构建类型和安装目标
    #cmake --build . --config RelWithDebInfo --target install

    # 自定义安装
    # 复制include文件夹
    Copy-Item -Path "../include/osgQOpenGL" -Destination "$InstallDir/include" -Recurse -Force
    # # 复制输出文件
    Copy-Item -Path "./lib/osgQOpenGL.lib" -Destination "$InstallDir/lib" -Force
    Copy-Item -Path "./packaging/pkgconfig/openscenegraph-osgQt.pc" -Destination "$InstallDir/lib/pkgconfig" -Force
    Copy-Item -Path "./bin/osg145-osgQOpenGL.dll" -Destination "$InstallDir/bin" -Force
    Copy-Item -Path "./bin/osg145-osgQOpenGL.pdb" -Destination "$SymbolDir" -Force
}
finally {
    # 返回原始工作目录
    Pop-Location
}