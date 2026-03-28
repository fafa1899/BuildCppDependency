# c-ares.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "c-ares-1.34.5"
$Dependencies = @(
    # c-ares 没有依赖项
)
$MyCMakeArgs = @()

# --- 调用通用构建脚本 ---
& "$PSScriptRoot\build-common.ps1" `
    -PackageName $PackageName `
    -InstallDir $InstallDir `
    -Dependencies $Dependencies `
    -CMakeExtraArgs $MyCMakeArgs `
    -ForceRebuild $FORCE_REBUILD `
    -CleanupAfterBuild $true `
    -EnableParallel $true