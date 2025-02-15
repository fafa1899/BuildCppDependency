param(   
    [string]$SourceAddress = "https://github.com/openscenegraph/OpenSceneGraph/archive/refs/tags/OpenSceneGraph-3.6.5.zip",
    [string]$SourceZipPath = "../Source/OpenSceneGraph-3.6.5.zip",
    [string]$SourceLocalPath = "./OpenSceneGraph-OpenSceneGraph-3.6.5",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir   
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/osg161-osg.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器：FBX、GDAL、CURL
. "./BuildRequired.ps1"
$Librarys = @("zlib", "libpng", "libjpeg", "libtiff", "giflib", "freetype") 
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
    # 配置CMake      
    cmake .. -G "$Generator" -A x64 `
        -DCMAKE_BUILD_TYPE=RelWithDebInfo `
        -DCMAKE_PREFIX_PATH="$InstallDir" `
        -DCMAKE_INSTALL_PREFIX="$InstallDir" `
        -DGIFLIB_LIBRARY="$InstallDir/lib/giflib.lib" `
        -DBUILD_OSG_APPLICATIONS=ON `
        -DBUILD_OSG_EXAMPLES=OFF `
        -DCMAKE_RELWITHDEBINFO_POSTFIX=""
        #-DBUILD_OSG_DEPRECATED_SERIALIZERS=OFF `

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo -- /m:8

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 获取源目录下的所有 .pdb 文件
    $pdbFiles = Get-ChildItem -Path "$InstallDir/bin" -Filter *.pdb -Recurse

    # 移动每个 .pdb 文件到目标目录
    foreach ($file in $pdbFiles) {
        $destinationPath = Join-Path -Path $SymbolDir -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destinationPath -Force
        Write-Output "Moved: $($file.FullName) -> $destinationPath"
    }        
}
finally {
    # 返回原始工作目录
    Pop-Location
}