# lerc.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "lerc-4.1.0"
$Dependencies = @()
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