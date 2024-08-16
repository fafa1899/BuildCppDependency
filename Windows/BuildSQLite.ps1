param( 
    [string]$PrecompiledBinarie = "./Precompiled/sqlite-dll-win-x64-3460000.zip",
    [string]$PrecompiledBinarieTools = "./Precompiled/sqlite-tools-win-x64-3460000.zip",
    [string]$SourceLocalPath = "../Source/sqlite-3.4.6",
    [string]$Generator = "Visual Studio 16 2019",
    [string]$MSBuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    [string]$InstallDir = "$env:GISBasic"
)

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
    cmake .. -G "$Generator" -A x64 -DCMAKE_CONFIGURATION_TYPES=RelWithDebInfo -DCMAKE_INSTALL_PREFIX="$InstallDir"

    # 生成解决方案并编译
    & $MSBuild ALL_BUILD.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64 /m

    # 安装库
    & $MSBuild INSTALL.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64 /m  

    # # 复制符号库
    $PdbFiles = @(
        "./RelWithDebInfo/sqlite3.pdb"        
    ) 
    $SymbolDir = $InstallDir + "/symbol"
    foreach ($file in $PdbFiles) {  
        Write-Output $file
        Copy-Item -Path $file -Destination $SymbolDir
    }     
}
finally {
    # 返回原始工作目录
    Pop-Location
}

# 解压缩 ZIP 文件
Write-Output "Install precompiled package..."
#Expand-Archive -Path $PrecompiledBinarie -DestinationPath $InstallDir -Force
Expand-Archive -Path $PrecompiledBinarieTools -DestinationPath "$InstallDir/bin" -Force