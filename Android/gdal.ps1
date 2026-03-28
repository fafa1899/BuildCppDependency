# gdal.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "gdal-3.10.3"
$Dependencies = @(
    "zlib", 
    "libjpeg", 
    "libpng", 
    "giflib", 
    "libtiff", 
    "libwebp", 
    "geos", 
    "sqlite", 
    "proj", 
    "curl", 
    "openssl", 
    "libexpat",
    "libxml2"
)
$MyCMakeArgs = @(
    "-Dlibdeflate=OFF",
    "-Dlzma=OFF",
    "-Dlerc=OFF",
    "-Dzstd=OFF",
    "-Dwebp=OFF",
    "-Dtiff-opengl=OFF",
    "-Dtiff-docs=OFF",
    "-Dtiff-tests=OFF",
    "-Dtiff-contrib=OFF",   
    "-DGDAL_USE_CURL=ON",
    "-DBUILD_TESTING=OFF",
    "-DGDAL_USE_OPENSSL=ON",
    "-DGDAL_USE_SPATIALITE=OFF",
    "-DGDAL_USE_MSSQL_NCLI=OFF",
    "-DGDAL_USE_DEFLATE=OFF",
    "-DGDAL_USE_LERC=OFF",
    "-DGDAL_USE_PCRE2=OFF", 
    "-DGDAL_USE_OPENCL=OFF",
    "-DGDAL_USE_LIBLZMA=OFF",
    "-DGDAL_USE_LZ4=OFF",
    "-DGDAL_USE_BLOSC=OFF",
    "-DGDAL_USE_OPENJPEG=OFF",
    "-DGDAL_USE_ZSTD=OFF",
    "-DGDAL_USE_HDF5=OFF",
    "-DGDAL_USE_ARCHIVE=OFF",
    "-DBUILD_JAVA_BINDINGS=OFF",
    "-DBUILD_CSHARP_BINDINGS=OFF",   
    "-DBUILD_PYTHON_BINDINGS=OFF"
)
# 额外构建参数
$CMakeCacheVariables = @{

}

# --- 调用通用构建脚本 ---
& "$PSScriptRoot\build-common.ps1" `
    -PackageName $PackageName `
    -InstallDir $InstallDir `
    -Dependencies $Dependencies `
    -CMakeExtraArgs $MyCMakeArgs `
    -ForceRebuild $FORCE_REBUILD `
    -CleanupAfterBuild $true `
    -EnableParallel $true