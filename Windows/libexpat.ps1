param(    
    [string]$Name = "libexpat-R_2_7_0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$MSBuild,
    [string]$InstallDir,  
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录 
)

# 根据 $Name 动态构建路径
$zipFilePath = Join-Path -Path $SourceDir -ChildPath "$Name.zip"
$SourcePath = Join-Path -Path $SourceDir -ChildPath $Name
$BuildDir = Join-Path -Path "." -ChildPath $Name

# 检查是否已经安装（通过目标 DLL）
$TargetDll = "$InstallDir/bin/libexpat.dll"
if (-not $Force -and $TargetDll -and (Test-Path $TargetDll)) {
    Write-Output "Library already installed: $TargetDll"
    exit 0
}

# 确保源码目录存在：解压 ZIP
if (!(Test-Path $SourcePath)) {
    if (!(Test-Path $zipFilePath)) {
        Write-Error "Archive not found: $zipFilePath"
        exit 1
    }
    Write-Output "Extracting $zipFilePath to $SourceDir..."
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $SourceDir -Force
}

# 如果是强制构建，且构建目录已存在，先删除旧的构建目录（确保干净构建）
if ($Force -and (Test-Path $BuildDir)) {
    Write-Output "Force mode enabled. Removing previous build directory: $BuildDir"
    Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
}

# # 复制符号库
$PdbFiles = @(
     "$BuildDir/RelWithDebInfo/libexpat.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    EXPAT_BUILD_DOCS = "OFF"
    EXPAT_BUILD_EXAMPLES = "OFF"
    EXPAT_BUILD_TESTS = "OFF"
}

# 调用通用 CMake 构建脚本
$cmakeSourcePath = Join-Path -Path $SourcePath -ChildPath "expat"
Write-Output "Starting build for $Name..."
. ./cmake-build.ps1 -SourceLocalPath $cmakeSourcePath `
    -BuildDir $BuildDir `
    -Generator $Generator `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true  

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed for $Name."
    exit $LASTEXITCODE
}

# 构建成功后，根据 Cleanup 开关决定是否删除
if ($Cleanup) {
    Write-Output "Build succeeded. Cleaning up temporary directories..."
    if (Test-Path $SourcePath) { 
        Remove-Item $SourcePath -Recurse -Force -ErrorAction SilentlyContinue 
        Write-Output "Removed source directory: $SourcePath"
    }
    if (Test-Path $BuildDir) { 
        Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue 
        Write-Output "Removed build directory: $BuildDir"
    }
}

Write-Output "Build completed for $Name."
