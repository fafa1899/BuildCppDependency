param(   
    [string]$SourceZipPath = "../Source/osgQt-topic-Qt4.zip",
    [string]$SourceLocalPath = "./osgQt-topic-Qt4",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir   
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/osg145-osgQt5.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("OpenSceneGraph") 
BuildRequired -Librarys $Librarys

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
        -DOPENTHREADS_LIBRARY_RELEASE="$InstallDir/lib/OpenThreads.lib" `
        -DOSG_LIBRARY_RELEASE="$InstallDir/lib/osg.lib" `
        -DOSGDB_LIBRARY_RELEASE="$InstallDir/lib/osgDB.lib" `
        -DOSGGA_LIBRARY_RELEASE="$InstallDir/lib/osgGA.lib" `
        -DOSGUTIL_LIBRARY_RELEASE="$InstallDir/lib/osgUtil.lib" `
        -DOSGTEXT_LIBRARY_RELEASE="$InstallDir/lib/osgText.lib" `
        -DOSGVIEWER_LIBRARY_RELEASE="$InstallDir/lib/osgViewer.lib" `
        -DOSGWIDGET_LIBRARY_RELEASE="$InstallDir/lib/osgWidget.lib" `
        -DCMAKE_RELWITHDEBINFO_POSTFIX=""

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo -- /m:8

    # 安装阶段，指定构建类型和安装目标
    #cmake --build . --config RelWithDebInfo --target install

    # 自定义安装
    # 复制include文件夹
    Copy-Item -Path "../include/osgQt" -Destination "$InstallDir/include" -Recurse -Force
    # 复制输出文件
    Copy-Item -Path "./lib/osgQt5.lib" -Destination "$InstallDir/lib" -Force
    Copy-Item -Path "./packaging/pkgconfig/openscenegraph-osgQt5.pc" -Destination "$InstallDir/lib/pkgconfig" -Force
    Copy-Item -Path "./bin/osg145-osgQt5.dll" -Destination "$InstallDir/bin" -Force
    Copy-Item -Path "./bin/osg145-osgQt5.pdb" -Destination "$SymbolDir" -Force
}
finally {
    # 返回原始工作目录
    Pop-Location
}