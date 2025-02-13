param(    
    [string]$Name = "qwindowkit-1.2.x",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 根据 $Name 动态构建路径
$zipFilePath = Join-Path -Path $SourceDir -ChildPath "$Name.zip"
$SourcePath = Join-Path -Path $SourceDir -ChildPath $Name
$BuildDir = Join-Path -Path "." -ChildPath $Name

# 解压ZIP文件到指定目录
if (!(Test-Path $SourcePath)) {
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $SourceDir -Force
}

# 检查目标文件是否存在，以判断是否安装
$DstFilePath = "$InstallDir/bin/QWKWidgets.dll"
if (Test-Path $DstFilePath) {
    Write-Output "The current library has been installed."
    exit 1
} 

# 复制符号库
$PdbFiles = @( 
    "$BuildDir/out-amd64-RelWithDebInfo/bin/QWKCore.pdb",
    "$BuildDir/out-amd64-RelWithDebInfo/bin/QWKWidgets.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{}

# 调用通用构建脚本
. ./cmake-build.ps1 -SourceLocalPath $SourcePath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true  
