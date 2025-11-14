# gmp.ps1

param(    
    [string]$Name = "gmp-6.3.0-prebuilt",  
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 检查是否已经安装（通过目标 DLL）
$TargetDll = "$InstallDir/bin/gmp-10.dll"
if (-not $Force -and $TargetDll -and (Test-Path $TargetDll)) {
    Write-Output "Library already installed: $TargetDll"
    exit 0
}

. ./install-prebuilt.ps1 -Name $Name `
    -DestinationPath $InstallDir