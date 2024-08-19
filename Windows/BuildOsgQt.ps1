param(   
    [string]$SourceZipPath = "../Source/osgQt-topic-Qt4.zip",
    [string]$SourceLocalPath = "./osgQt-topic-Qt4",
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
        -DOPENTHREADS_LIBRARY_RELEASE="$InstallDir/lib/OpenThreadsrd.lib" `
        -DOSG_LIBRARY_RELEASE="$InstallDir/lib/osgrd.lib" `
        -DOSGDB_LIBRARY_RELEASE="$InstallDir/lib/osgDBrd.lib" `
        -DOSGGA_LIBRARY_RELEASE="$InstallDir/lib/osgGArd.lib" `
        -DOSGUTIL_LIBRARY_RELEASE="$InstallDir/lib/osgUtilrd.lib" `
        -DOSGTEXT_LIBRARY_RELEASE="$InstallDir/lib/osgTextrd.lib" `
        -DOSGVIEWER_LIBRARY_RELEASE="$InstallDir/lib/osgViewerrd.lib" `
        -DOSGWIDGET_LIBRARY_RELEASE="$InstallDir/lib/osgWidgetrd.lib"

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo -- /m:8

    # 安装阶段，指定构建类型和安装目标
    #cmake --build . --config RelWithDebInfo --target install

    # 自定义安装
    # 复制include文件夹
    Copy-Item -Path "../include/osgQt" -Destination "$InstallDir/include" -Recurse -Force
    # 复制输出文件
    Copy-Item -Path "./lib/osgQt5rd.lib" -Destination "$InstallDir/lib" -Force
    Copy-Item -Path "./packaging/pkgconfig/openscenegraph-osgQt5.pc" -Destination "$InstallDir/lib/pkgconfig" -Force
    Copy-Item -Path "./bin/osg145-osgQt5rd.dll" -Destination "$InstallDir/bin" -Force
    Copy-Item -Path "./bin/osg145-osgQt5rd.pdb" -Destination "$SymbolDir" -Force
}
finally {
    # 返回原始工作目录
    Pop-Location
}