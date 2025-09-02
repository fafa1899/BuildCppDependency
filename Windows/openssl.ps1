param(     
    [string]$Name = "openssl-openssl-3.4.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录 
)

# 检查是否已经安装（通过目标 DLL）
$TargetDll = "$InstallDir/bin/libssl-3-x64.dll"
if (-not $Force -and $TargetDll -and (Test-Path $TargetDll)) {
    Write-Output "Library already installed: $TargetDll"
    exit 0
}

# 动态路径构建
$zipFilePath = Join-Path -Path $SourceDir -ChildPath "$Name.zip"
$SourcePath = Join-Path -Path $SourceDir -ChildPath $Name
. "./FindVcVarsPath.ps1"
$Vcvarsall = FindVcVarsPath -vsVersion $Generator

# 确保源码目录存在：解压 ZIP
if (!(Test-Path $SourcePath)) {
    if (!(Test-Path $zipFilePath)) {
        Write-Error "Archive not found: $zipFilePath"
        exit 1
    }
    Write-Output "Extracting $zipFilePath to $SourceDir..."
    Expand-Archive -LiteralPath $zipFilePath -DestinationPath $SourceDir -Force
}

# 使用cmd.exe运行vcvars64.bat，并保持命令提示符窗口打开
cmd.exe /c openssl.bat $SourcePath $InstallDir $Vcvarsall

# 符号库文件
$pdbFiles = @(
    "$InstallDir/bin/libssl-3-x64.pdb",
    "$InstallDir/bin/libcrypto-3-x64.pdb"
) 

# 移动每个 .pdb 文件到目标目录
foreach ($file in $pdbFiles) {
    $destinationPath = Join-Path -Path $SymbolDir -ChildPath $file.Name
    Move-Item -Path $file -Destination $destinationPath -Force
    Write-Output "Moved: $file -> $destinationPath"
}     

# 构建成功后，根据 Cleanup 开关决定是否删除
if ($Cleanup) {
    Write-Output "Build succeeded. Cleaning up temporary directories..."
    if (Test-Path $SourcePath) { 
        Remove-Item $SourcePath -Recurse -Force -ErrorAction SilentlyContinue 
        Write-Output "Removed source directory: $SourcePath"
    }    
}

Write-Output "Build completed for openssl."

