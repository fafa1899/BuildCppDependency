# build-common.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$PackageName,          # 包名称

    [Parameter(Mandatory=$true)]
    [string]$InstallDir,           # 安装目录

    [string[]]$Dependencies = @(), # 依赖项名称数组

    [string[]]$CMakeExtraArgs = @(), # 额外的 CMake 参数

    [bool]$ForceRebuild = $false,  # 是否强制重新构建

    [bool]$CleanupAfterBuild = $true, # 构建成功后是否清理源码和构建目录

    [bool]$EnableParallel = $true  # 是否启用并行构建
)

# --- 1. 检查安装状态 ---
$InstallMarker = "$InstallDir\installed\$PackageName.installed"
if (-not $ForceRebuild -and (Test-Path $InstallMarker)) {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "[$PackageName] 已安装，跳过构建。" -ForegroundColor Green
    Write-Host "标记路径：$InstallMarker"
    Write-Host "如需重新构建，请使用 -ForceRebuild `$true"
    Write-Host "=========================================" -ForegroundColor Green
    exit 0
}

Write-Host ">>> 开始处理包: $PackageName (Force=$ForceRebuild)" -ForegroundColor Cyan

# --- 2. 构建依赖项 ---
if ($Dependencies.Count -gt 0) {
    Write-Host ">>> 正在确保依赖项就绪..." -ForegroundColor Cyan
    & "$PSScriptRoot\Invoke-BuildDependencies.ps1" `
        -DependencyScripts $Dependencies `
        -InstallDir $InstallDir
    
    # 如果依赖构建失败，Invoke-BuildDependencies.ps1 应该会退出，
    # 但为了安全，我们检查一下 LASTEXITCODE
    if ($LASTEXITCODE -ne 0) {
        Write-Error "依赖项构建失败，中止 $PackageName 的构建。"
        exit 1
    }
}

# --- 3. 调用 CMake 构建脚本 ---
Write-Host ">>> 开始配置和构建主包：$PackageName" -ForegroundColor Magenta

& "$PSScriptRoot\cmake-build.ps1" `
    -PackageName $PackageName `
    -InstallDir $InstallDir `
    -CMakeExtraArgs $CMakeExtraArgs `
    -ForceRebuild $ForceRebuild `
    -CleanupAfterBuild $CleanupAfterBuild `
    -EnableParallel $EnableParallel

# --- 4. 检查构建结果 ---
if ($LASTEXITCODE -ne 0) {
    Write-Error "主包 $PackageName 构建失败!"
    exit 1
}

Write-Host ">>> [$PackageName] 构建成功!" -ForegroundColor Green