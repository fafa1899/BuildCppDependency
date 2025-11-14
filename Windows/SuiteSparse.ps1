# SuiteSparse.ps1
param(    
    [string]$Name = "SuiteSparse-7.11.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/umfpack.dll"

# 依赖库数组
$Librarys = @("OpenBLAS", "gmp", "mpfr")  

# 符号库文件
$PdbFiles = @(
    "SuiteSparse_config/RelWithDebInfo/suitesparseconfig.pdb"
    "Mongoose/RelWithDebInfo/suitesparse_mongoose.pdb"
    "AMD/RelWithDebInfo/amd.pdb"
    "BTF/RelWithDebInfo/btf.pdb"
    "CAMD/RelWithDebInfo/camd.pdb"
    "CCOLAMD/RelWithDebInfo/ccolamd.pdb"
    "CHOLMOD/RelWithDebInfo/cholmod.pdb"
    "COLAMD/RelWithDebInfo/colamd.pdb"
    "CXSparse/RelWithDebInfo/cxsparse.pdb"
    "GraphBLAS/RelWithDebInfo/graphblas.pdb"    
    "KLU/RelWithDebInfo/klu.pdb"
    "LAGraph/dlls/RelWithDebInfo/lagraph.pdb"
    "LAGraph/dlls/RelWithDebInfo/lagraphx.pdb"
    "LDL/RelWithDebInfo/ldl.pdb"
    "ParU/RelWithDebInfo/paru.pdb"
    "RBio/RelWithDebInfo/rbio.pdb"
    "SPEX/RelWithDebInfo/spex.pdb"
    "SPEX/RelWithDebInfo/spexpython.pdb"
    "SPQR/RelWithDebInfo/spqr.pdb"
    "UMFPACK/RelWithDebInfo/umfpack.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    SUITESPARSE_REQUIRE_BLAS = "ON"
    SUITESPARSE_USE_64BIT_BLAS = "ON"   
    BUILD_TESTING = "OFF"
    BUILD_STATIC_LIBS = "OFF"
    BUILD_SHARED_LIBS = "ON"
    SUITESPARSE_USE_FORTRAN = "ON"
    SUITESPARSE_C_TO_FORTRAN = "(name,NAME) name##_"
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
