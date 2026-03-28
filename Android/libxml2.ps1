# libxml2.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "libxml2-v2.14.4"
$Dependencies = @(
    "zlib",
    "iconv"
)
$MyCMakeArgs = @( 
    "-DBUILD_SHARED_LIBS=ON"
    "-DLIBXML2_WITH_ZLIB=ON"
    "-DLIBXML2_WITH_ICONV=ON"
    "-DLIBXML2_WITH_HTTP=ON"
    "-DLIBXML2_WITH_PYTHON=OFF"
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