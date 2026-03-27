# curl.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

$PackageName = "curl-curl-8_14_1"

# 检查主包状态 
$InstallMarker = "$InstallDir\installed\$PackageName.installed"
if (-not $FORCE_REBUILD -and (Test-Path $InstallMarker)) {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "[$PackageName] 已安装，跳过所有步骤 (包括依赖检查)!" -ForegroundColor Green
    Write-Host "标记路径：$InstallMarker"
    Write-Host "如需重新构建，请设置 `$FORCE_REBUILD = `$true"
    Write-Host "=========================================" -ForegroundColor Green
    exit 0
}

# 构建依赖项
Write-Host ">>> 主包 [$PackageName] 需要构建 (Force=$FORCE_REBUILD)" -ForegroundColor Cyan
Write-Host ">>> 正在确保依赖项就绪 (InstallDir: $InstallDir)..." -ForegroundColor Cyan

$Dependencies = @(   
    "zlib",
    "c-ares", 
    "openssl"
)

# 【关键】传递 -InstallDir 参数给依赖管理器
& "$PSScriptRoot\Invoke-BuildDependencies.ps1" `
    -DependencyScripts $Dependencies `
    -InstallDir $InstallDir

# 如果上面脚本执行失败，它会直接 exit，代码不会运行到这里。

# 构建主包
Write-Host ">>> 开始配置和构建主包：$PackageName" -ForegroundColor Magenta

$MyCMakeArgs = @(   
    "-DCURL_USE_LIBPSL=OFF",
    "-DCURL_USE_OPENSSL=ON",
    "-DCURL_ZSTD=OFF",
    "-DCURL_USE_LIBSSH=OFF",
    "-DCURL_USE_LIBSSH2=OFF",
    "-DCURL_USE_WOLFSSH=OFF",
    "-DENABLE_ARES=ON",
    "-DENABLE_CURL_MANUAL=OFF"   
)

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
