param(   
    [string]$SourceAddress = "https://github.com/uriparser/uriparser/archive/refs/tags/uriparser-0.9.8.zip", 
    [string]$SourceZipPath = "../Source/uriparser-0.9.8.zip",
    [string]$SourceLocalPath = "./uriparser-uriparser-0.9.8",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/uriparser.dll"
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
    # 配置CMake  
    cmake .. -G "$Generator" -A x64 `
        -DCMAKE_BUILD_TYPE=RelWithDebInfo `
        -DCMAKE_INSTALL_PREFIX="$InstallDir" `
        -DURIPARSER_BUILD_TESTS=OFF `
        -DURIPARSER_BUILD_DOCS=OFF

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 复制符号库
    $PdbFiles = @(
        "./RelWithDebInfo/uriparser.pdb"      
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