# OpenImageIO 构建脚本
param(
    [string]$Name = "OpenImageIO-3.2.2.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    CMAKE_CXX_STANDARD = "17"
    CMAKE_CXX_FLAGS = "/utf-8 /EHsc"
    OIIO_BUILD_TOOLS = "OFF"
    OIIO_BUILD_TESTS = "OFF"
    BUILD_DOCS = "OFF"
    INSTALL_DOCS = "OFF"
    INSTALL_FONTS = "OFF"
    USE_PYTHON = "OFF"
    USE_QT = "OFF"
    USE_OpenCV = "OFF"
    USE_OpenVDB = "OFF"
    USE_FFmpeg = "OFF"
    USE_LibRaw = "OFF"
    USE_Libheif = "OFF"
    USE_DCMTK = "OFF"
    USE_Ptex = "OFF"
    USE_OpenJPEG = "OFF"
    USE_openjph = "OFF"
    USE_JXL = "OFF"
    USE_libuhdr = "OFF"
    USE_libdeflate = "OFF"
    USE_TBB = "OFF"
    USE_Freetype = "OFF"
    USE_GIF = "OFF"
    USE_WebP = "OFF"
    OpenImageIO_BUILD_MISSING_DEPS = "none"
    OpenImageIO_BUILD_LOCAL_DEPS = "none"
}
& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir -InstallDir $InstallDir -SymbolDir $SymbolDir `
    -Generator $Generator -PdbFiles @("bin/RelWithDebInfo/OpenImageIO.pdb", "bin/RelWithDebInfo/OpenImageIO_Util.pdb") `
    -CMakeCacheVariables $CMakeCacheVariables -MultiConfig $true `
    -Force $Force -Cleanup $Cleanup -Librarys @("OpenColorIO", "OpenEXR", "Imath", "fmt", "robin-map", "zlib", "libjpeg", "libtiff", "libpng")