<#
.SYNOPSIS
    通用依赖构建检查器
.DESCRIPTION
    遍历给定的构建脚本列表，依次执行它们。
    将 InstallDir 传递给子脚本，确保所有库安装到同一位置。
.PARAMETER DependencyScripts
    依赖脚本的文件名数组 (例如: @("libjpeg", "zlib"))
.PARAMETER ScriptRoot
    脚本所在的根目录
.PARAMETER InstallDir
    【新增】统一的安装目录，将传递给所有子构建脚本
#>

param(
    [Parameter(Mandatory=$true)][string[]]$DependencyScripts,
    [string]$ScriptRoot = $PSScriptRoot,
    [Parameter(Mandatory=$true)][string]$InstallDir
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ">>> 开始检查构建依赖..." -ForegroundColor Cyan
Write-Host "目标安装目录：$InstallDir"
Write-Host "=========================================" -ForegroundColor Cyan

$TotalCount = $DependencyScripts.Count
$CurrentIndex = 0

foreach ($ScriptName in $DependencyScripts) {
    $CurrentIndex++ 
    Write-Host "[$CurrentIndex/$TotalCount] 检查依赖：$ScriptName" -ForegroundColor Yellow

    $ScriptPath = Join-Path -Path $ScriptRoot -ChildPath "$ScriptName.ps1"
    if (-not (Test-Path $ScriptPath)) {
        Write-Error "❌ 错误：找不到依赖脚本 '$ScriptPath'。请确认文件存在。"
        exit 1
    }

    # 【关键】执行依赖脚本，并显式传递 -InstallDir 参数
    # 子脚本必须支持 -InstallDir 参数才能正常工作
    & $ScriptPath -InstallDir $InstallDir
    
    # 检查执行结果
    if ($LASTEXITCODE -ne 0) {
        Write-Host "-----------------------------------------" -ForegroundColor Red
        Write-Error "❌ 失败：依赖项 '$ScriptName' 构建出错 (Exit Code: $LASTEXITCODE)"
        Write-Host "-----------------------------------------" -ForegroundColor Red
        Write-Error "终止当前构建流程，请先解决上述依赖问题。"
        exit 1
    }
    
    Write-Host "✅ 通过：$ScriptName 已就绪。" -ForegroundColor Green
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Green
Write-Host ">>> 所有依赖项检查通过！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green