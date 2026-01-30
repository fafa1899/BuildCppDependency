# apriltag.ps1
param(    
    [string]$Name = "apriltag-3.4.5",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/apriltag.dll"

# 依赖库数组
#$Librarys = @("OpenBLAS", "gmp", "mpfr")
$Librarys = @()    

# 符号库文件
$PdbFiles = @(
    "/RelWithDebInfo/apriltag.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{  
   BUILD_SHARED_LIBS = "ON"
}

. ./build-common.ps1 -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -TargetDll $DllPath `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys
