param( 
    [string]$SourceAddress = "https://codeload.github.com/abseil/abseil-cpp/zip/refs/tags/20240722.0",
    [string]$SourceZipPath = "../Source/abseil-cpp-20240722.0.zip",
    [string]$SourceLocalPath = "./abseil-cpp-20240722.0",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/abseil_dll.dll"
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
    # 配置阶段，指定生成器、平台和安装路径
    cmake .. -G "$Generator" -A x64 `
        -DCMAKE_CONFIGURATION_TYPES=RelWithDebInfo `
        -DCMAKE_PREFIX_PATH="$env:GISBasic" `
        -DCMAKE_INSTALL_PREFIX="$InstallDir" `
        -DABSL_BUILD_TESTING=OFF `
        -DABSL_PROPAGATE_CXX_STD=ON `
        -DCMAKE_CXX_STANDARD=17 `
        #-DABSL_BUILD_MONOLITHIC_SHARED_LIBS=ON `
        #-DBUILD_SHARED_LIBS=ON

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo  -- /m:8

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # # 复制符号库
    # $PdbFiles = @(
    #     "./bin/RelWithDebInfo/abseil_dll.pdb"
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