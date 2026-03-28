# libtiff.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "tiff-4.6.0t"
$Dependencies = @(
    "libjpeg",
    "zlib"
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
    "-Dtiff-contrib=OFF"   
)

# --- 调用通用构建脚本 ---
& "$PSScriptRoot\build-common.ps1" `
    -PackageName $PackageName `
    -InstallDir $InstallDir `
    -Dependencies $Dependencies `
    -CMakeExtraArgs $MyCMakeArgs `
    -ForceRebuild $FORCE_REBUILD `
    -CleanupAfterBuild $true `
    -EnableParallel $true