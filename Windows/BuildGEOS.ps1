param( 
    [string]$SourceAddress = "https://codeload.github.com/libgeos/geos/zip/refs/tags/3.12.2",
    [string]$SourceZipPath = "../Source/geos-3.12.2.zip",
    [string]$SourceLocalPath = "./geos-3.12.2",
    [string]$Generator = "Visual Studio 16 2019",
    [string]$MSBuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    [string]$InstallDir = "$env:GISBasic"  
)

if (!(Test-Path $SourceLocalPath)) {
    if (!(Test-Path $SourceZipPath)) {
        #下载源代码
        Write-Output "Download Zip..."
        Invoke-WebRequest -Uri $SourceAddress -OutFile $SourceZipPath
    }

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
    # 配置CMake  
    cmake .. -G "$Generator" -A x64 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH="$env:GISBasic" -DCMAKE_INSTALL_PREFIX="$InstallDir"

    # 生成解决方案并编译
    & $MSBuild ALL_BUILD.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64 /m

    # 安装库
    & $MSBuild INSTALL.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64 /m

    # 复制符号库
    $PdbFiles = @(
        "./bin/RelWithDebInfo/geos.pdb",
        "./bin/RelWithDebInfo/geos_c.pdb"
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