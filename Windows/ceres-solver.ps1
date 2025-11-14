# ceres-solver.ps1
param(    
    [string]$Name = "ceres-solver-2.2.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/lib/ceres.lib"

# 依赖库数组
$Librarys = @("eigen", "gflags", "glog", "OpenBLAS", "SuiteSparse")  

# 符号库文件
$PdbFiles = @(
    "lib/RelWithDebInfo/ceres.pdb"
    "lib/RelWithDebInfo/ceres_cuda_kernels.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    BUILD_TESTING = "OFF"
    BUILD_EXAMPLES = "OFF"
    BUILD_SHARED_LIBS = "OFF"    
    USE_CUDA = "ON"
}

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
