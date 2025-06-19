param(     
    [string]$SourceLocalPath = "../Source/proj-9.4.1",
    [string]$BuildDir = "./proj-9.4.1",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/proj_9_4.dll"
if (Test-Path $DstFilePath) {
   Write-Output "The current library has been installed."
   exit 1
} 

# 创建所有依赖库的容器
. "./BuildRequired.ps1"
$Librarys = @("nlohmann-json", "sqlite", "libtiff")
BuildRequired -Librarys $Librarys

# 复制符号库
$PdbFiles = @(
    "$BuildDir/bin/RelWithDebInfo/proj_9_4.pdb"      
) 

# 额外构建参数
$CMakeCacheVariables = @{  
    BUILD_TESTING  = "OFF"
    ENABLE_CURL    = "OFF"
    BUILD_PROJSYNC = "OFF"
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
