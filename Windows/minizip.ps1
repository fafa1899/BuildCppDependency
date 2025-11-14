param( 
    [string]$SourceLocalPath = "../Source/minizip-1.3.1",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,
    [string]$SymbolDir
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/lib/minizip.lib"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
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
    # 配置CMake  
    cmake .. -G "$Generator" -A x64 `
    -DCMAKE_CONFIGURATION_TYPES=RelWithDebInfo `
    -DCMAKE_PREFIX_PATH="$InstallDir" `
    -DCMAKE_INSTALL_PREFIX="$InstallDir"

    # 构建阶段，指定构建类型
    cmake --build . --config RelWithDebInfo

    # 安装阶段，指定构建类型和安装目标
    cmake --build . --config RelWithDebInfo --target install

    # 复制符号库
    $PdbFiles = @(
        "./RelWithDebInfo/minizip.pdb"        
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
