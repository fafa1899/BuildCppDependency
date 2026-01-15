# md4c.ps1
param(    
    [string]$Name = "md4c-release-0.5.2",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/md4c.dll"

# 依赖库数组
#$Librarys = @("OpenBLAS", "gmp", "mpfr")
$Librarys = @()    

# 符号库文件
$PdbFiles = @(
#    "SuiteSparse_config/RelWithDebInfo/suitesparseconfig.pdb"
#    "Mongoose/RelWithDebInfo/suitesparse_mongoose.pdb"
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
