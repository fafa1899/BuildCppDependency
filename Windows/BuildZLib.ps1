param(   
    [string]$SourceAddress = "https://www.zlib.net/zlib131.zip",
    [string]$SourceZipPath = "../Source/zlib131.zip",
    [string]$SourceLocalPath = "./zlib-1.3.1",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir   
)

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
    cmake .. -G "$Generator" -A x64 -DCMAKE_CONFIGURATION_TYPES=RelWithDebInfo -DCMAKE_INSTALL_PREFIX="$InstallDir" -DZLIB_BUILD_EXAMPLES=OFF

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 复制符号库
    $PdbFiles = @(
        "./RelWithDebInfo/zlib.pdb",
        "./RelWithDebInfo/zlibstatic.pdb"
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