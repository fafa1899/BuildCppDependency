# TBB.ps1
param(    
    [string]$Name = "oneTBB-2022.2.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/tbb12.dll"

# 依赖库数组 
$Librarys = @()  

# 符号库文件
$PdbFiles = @() 

# 额外构建参数
$CMakeCacheVariables = @{}

. ./build-common.ps1 -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -TargetDll $DllPath `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys

$PdbFiles = @(
    "$InstallDir/bin/tbb12.pdb",
    "$InstallDir/bin/tbbmalloc.pdb",
    "$InstallDir/bin/tbbmalloc_proxy.pdb"
) 
    
# 移动符号库
foreach ($file in $PdbFiles) {  
    Write-Output $file
    if (Test-Path $file) {
        Move-Item -Path $file -Destination $SymbolDir -Force
    }
    else {
        Write-Output "Warning: PDB file not found: $file"
    }
}