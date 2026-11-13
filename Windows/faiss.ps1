# FAISS CPU 静态库，复用安装标记和通用 CMake 构建流程
param(
    [ValidatePattern('^faiss-[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$Name = "faiss-1.14.3",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)

$Marker = Join-Path $InstallDir "installed/$Name.installed"
if ($Force -or -not (Test-Path -LiteralPath $Marker -PathType Leaf)) {
    $SourcePath = Join-Path $SourceDir $Name
    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
        Expand-Archive -LiteralPath (Join-Path $SourceDir "$Name.zip") -DestinationPath $SourceDir -Force -ErrorAction Stop
    }
    # 仅增加 CMake 适配入口，不修改上游源码
    $AdapterDir = Join-Path $SourcePath 'windows-cmake'
    New-Item -ItemType Directory -Path $AdapterDir -Force -ErrorAction Stop | Out-Null
    Copy-Item -LiteralPath "$PSScriptRoot/cmake/FAISS/CMakeLists.txt" -Destination $AdapterDir -Force -ErrorAction Stop
}

$OpenBLAS = [System.IO.Path]::GetFullPath((Join-Path $InstallDir 'lib/openblas.lib')).Replace('\', '/')
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "OFF"
    BUILD_TESTING = "OFF"
    FAISS_ENABLE_GPU = "OFF"
    FAISS_ENABLE_CUVS = "OFF"
    FAISS_ENABLE_ROCM = "OFF"
    FAISS_ENABLE_METAL = "OFF"
    FAISS_ENABLE_SVS = "OFF"
    FAISS_ENABLE_MKL = "OFF"
    FAISS_ENABLE_PYTHON = "OFF"
    FAISS_ENABLE_C_API = "OFF"
    FAISS_ENABLE_EXTRAS = "OFF"
    FAISS_OPT_LEVEL = "generic"
    BLAS_LIBRARIES = $OpenBLAS
    LAPACK_LIBRARIES = $OpenBLAS
    CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreadedDLL"
    CMAKE_CXX_FLAGS = "/DWIN32 /D_WINDOWS /W3 /GR /EHsc /utf-8 /bigobj"
}

& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir `
    -SourceSubDir 'windows-cmake' `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles @('symbols/RelWithDebInfo/faiss.pdb') `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys @('OpenBLAS')
