# libexpat.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "libexpat-R_2_7_0.1"
$Dependencies = @()
$MyCMakeArgs = @(   
    "-DEXPAT_BUILD_DOCS=OFF"
    "-DEXPAT_BUILD_EXAMPLES=OFF"
    "-DEXPAT_BUILD_TESTS=OFF"
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