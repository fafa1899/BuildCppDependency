

param( 
    [string]$SourceAddress = "https://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.43/lpng1643.zip",
    [string]$SourceZipPath = "../Source/lpng1643.zip",
    [string]$SourceLocalPath = "./lpng1643",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/libpng16.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("zlib")
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
    -DPNG_TESTS=OFF `
    -DPNG_STATIC=OFF `
    
    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 复制符号库
    $PdbFiles = @(
        "./RelWithDebInfo/libpng16.pdb"
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