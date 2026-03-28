# libwebp.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "libwebp-1.3.2"
$Dependencies = @(
    "zlib", "libpng", "libjpeg", "libtiff", "giflib"
)
$MyCMakeArgs = @(    
    "-DWEBP_UNICODE=ON"
    "-DBUILD_SHARED_LIBS=ON"
    "-DWEBP_LINK_STATIC=OFF"
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