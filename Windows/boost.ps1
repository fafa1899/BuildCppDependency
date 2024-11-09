param(    
    [string]$SourceLocalPath = "../Source/boost-1.86.0",
    [string]$BuildDir = "./boost-1.86.0",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/include/boost-1_86/boost"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("zlib")
BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @() 

# 额外构建参数
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS   = "ON"
    OPENSSL_INCLUDE_DIR = ""
    SSL_EAY_RELEASE     = ""
}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourceLocalPath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false  

# 移动符号库
$PdbFiles = Get-ChildItem -Path $InstallDir/bin -Filter *.pdb -Recurse
foreach ($file in $PdbFiles) {  
    Write-Output $file.FullName
    if (Test-Path $file.FullName) {
        Move-Item -Path $file.FullName -Destination $SymbolDir
    }
    else {
        Write-Output "Warning: PDB file not found: $file.FullName"
    }
}