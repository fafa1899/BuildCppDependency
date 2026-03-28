# proj.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "proj-9.4.1"
$Dependencies = @(
    "nlohmann-json",
    "sqlite",
    "libtiff"
)
$MyCMakeArgs = @(    
    "-DBUILD_TESTING=OFF"
    "-DENABLE_CURL=OFF"
    "-DBUILD_PROJSYNC=OFF"
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
