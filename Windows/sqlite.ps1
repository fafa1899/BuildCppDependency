param( 
    [string]$SourceLocalPath = "../Source/sqlite-3.4.6",
    [string]$BuildDir = "./sqlite-3.4.6",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir, 
    [string]$PrecompiledBinarie = "./Precompiled/sqlite-dll-win-x64-3460000.zip",
    [string]$PrecompiledBinarieTools = "./Precompiled/sqlite-tools-win-x64-3460000.zip"
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/sqlite3.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 清除旧的构建目录
if (Test-Path $BuildDir) {
    Remove-Item -Path $BuildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildDir
  
cmake $SourceLocalPath `
    -B "$BuildDir" `
    -G "$Generator" `
    -A x64 `
    -DCMAKE_CONFIGURATION_TYPES=RelWithDebInfo `
    -DCMAKE_INSTALL_PREFIX="$InstallDir"

# 构建阶段，指定构建类型
cmake --build $BuildDir --config RelWithDebInfo

# 安装阶段，指定构建类型和安装目标
cmake --build $BuildDir --config RelWithDebInfo --target install
  
# 复制符号库
$PdbFiles = @(
    $BuildDir + "/RelWithDebInfo/sqlite3.pdb"        
) 
foreach ($file in $PdbFiles) {  
    Write-Output $file
    Copy-Item -Path $file -Destination $SymbolDir
}     

# 解压缩 ZIP 文件
Write-Output "Install precompiled package..."
#Expand-Archive -Path $PrecompiledBinarie -DestinationPath $InstallDir -Force
Expand-Archive -Path $PrecompiledBinarieTools -DestinationPath "$InstallDir/bin" -Force

# 清理构建目录
Remove-Item -Path $BuildDir -Recurse -Force