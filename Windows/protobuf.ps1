

param( 
    [string]$SourceAddress = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v27.4.zip",
    [string]$SourceZipPath = "../Source/protobuf-27.4.zip",
    [string]$SourceLocalPath = "./protobuf-27.4",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir 
)

# # 检查目标文件是否存在，以判断是否安装
# $DstFilePath = "$InstallDir/bin/libpng16.dll"
# if (Test-Path $DstFilePath) {
#     Write-Output "The current library has been installed."
#     exit 1
# } 

# # 创建所有依赖库的容器
# . "./BuildRequired.ps1"
# $Librarys = @("zlib")
# BuildRequired -Librarys $Librarys

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
    -DCMAKE_CXX_STANDARD=17 `
    -Dprotobuf_BUILD_TESTS=OFF `
    -Dprotobuf_ABSL_PROVIDER=package `
    #-Dprotobuf_BUILD_SHARED_LIBS=ON
    
    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo -- /m:8

    # # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # # 复制符号库
    # $PdbFiles = @(
    #     "./RelWithDebInfo/libpng16.pdb"
    # ) 
    # foreach ($file in $PdbFiles) {  
    #     Write-Output $file
    #     Copy-Item -Path $file -Destination $SymbolDir
    # }   
}
finally {
    # 返回原始工作目录
    Pop-Location
}