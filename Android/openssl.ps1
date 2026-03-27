# openssl.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

$PackageName = "openssl-openssl-3.4.0"

# 检查主包状态 
$InstallMarker = "$InstallDir\installed\$PackageName.installed"
if (-not $FORCE_REBUILD -and (Test-Path $InstallMarker)) {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "[$PackageName] 已安装，跳过所有步骤 (包括依赖检查)!" -ForegroundColor Green
    Write-Host "标记路径：$InstallMarker"
    Write-Host "如需重新构建，请设置 `$FORCE_REBUILD = `$true"
    Write-Host "=========================================" -ForegroundColor Green
    exit 0
}else{
    Write-Host ">>> 主包 [$PackageName] 需要在Ubuntu下构建 (Force=$FORCE_REBUILD)" -ForegroundColor Red   
}
