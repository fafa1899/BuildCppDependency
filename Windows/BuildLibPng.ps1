param( 
    [string]$SourceAddress = "https://jaist.dl.sourceforge.net/project/libpng/libpng16/1.6.43/lpng1643.zip",
    [string]$SourceZipPath = "../Source/lpng1643.zip",
    [string]$SourceLocalPath = "./lpng1643",
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
        "./RelWithDebInfo/libpng16.pdb",
        "./RelWithDebInfo/libpng16_static.pdb"
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