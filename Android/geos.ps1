# geos.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

$PackageName = "geos-3.12.2"

# 检查主包状态 (使用传入的 $InstallDir)
$InstallMarker = "$InstallDir\installed\$PackageName.installed"

if (-not $FORCE_REBUILD -and (Test-Path $InstallMarker)) {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "[$PackageName] 已安装 (路径：$InstallDir)，跳过构建!" -ForegroundColor Green
    Write-Host "标记路径：$InstallMarker"
    Write-Host "如需重新构建，请使用 -FORCE_REBUILD `$true"
    Write-Host "=========================================" -ForegroundColor Green
    exit 0
}

# 构建主包
Write-Host ">>> 开始配置和构建主包：$PackageName (目标：$InstallDir)" -ForegroundColor Magenta

# 定义特有的 CMake 参数
$MyCMakeArgs = @(    
    "-DBUILD_TESTING=OFF"
)

# 调用核心脚本 (传递 $InstallDir)
& "$PSScriptRoot\cmake-build.ps1" `
    -PackageName $PackageName `
    -InstallDir $InstallDir `
    -CMakeExtraArgs $MyCMakeArgs `
    -ForceRebuild $FORCE_REBUILD `
    -CleanupAfterBuild $true `
    -EnableParallel $true

if ($LASTEXITCODE -ne 0) {
    Write-Error "主包 $PackageName 构建失败!"
    exit 1
}