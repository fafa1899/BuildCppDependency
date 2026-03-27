<#
.SYNOPSIS
    统一的 Android C++ 库构建入口脚本
.DESCRIPTION
    根据提供的包名调用对应的构建脚本，并统一管理 NDK 环境变量。
.PARAMETER PackageName
    要构建的包名称 (例如: libjpeg, libtiff)
.PARAMETER InstallDir
    安装目录 (默认: D:\Work\Android3rdParty)
.PARAMETER ForceRebuild
    是否强制重新构建 (默认: $false)
.PARAMETER UnityNdkPath
    Unity NDK 的路径 (默认: 自动检测或指定路径)
.EXAMPLE
    .\build.ps1 -PackageName libjpeg
    .\build.ps1 -PackageName libtiff -ForceRebuild
    .\build.ps1 -PackageName libtiff -InstallDir "D:\MyLibs" -UnityNdkPath "C:\NDK"
#>

param(
    [Parameter(Mandatory=$true)][string]$PackageName,
    [string]$InstallDir = "D:\Github\AndroidNativeKit\ndk23\arm64-v8a",
    [bool]$ForceRebuild = $false,
    [string]$UnityNdkPath = "D:\Program Files\Unity\Hub\Editor\2022.3.62f3\Editor\Data\PlaybackEngines\AndroidPlayer\NDK"
)

# ================= 1. 设置环境变量 =================
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ">>> 配置构建环境..." -ForegroundColor Cyan
Write-Host "目标包：$PackageName"
Write-Host "安装目录：$InstallDir"
Write-Host "强制重建：$ForceRebuild"
Write-Host "NDK 路径：$UnityNdkPath"
Write-Host "=========================================" -ForegroundColor Cyan

# 验证 NDK 路径是否存在
if (-not (Test-Path $UnityNdkPath)) {
    Write-Error "❌ 错误：找不到指定的 NDK 路径 '$UnityNdkPath'。请检查路径是否正确。"
    exit 1
}

# 设置环境变量 (当前进程有效，子进程自动继承)
$env:UNITY_NDK = $UnityNdkPath
Write-Host "✅ 环境变量 UNITY_NDK 已设置。"

# ================= 2. 定位并调用子脚本 =================
$ScriptPath = "$PSScriptRoot\$PackageName.ps1"

if (-not (Test-Path $ScriptPath)) {
    Write-Error "❌ 错误：找不到对应的构建脚本 '$ScriptPath'。"
    Write-Host "支持的包名示例：libjpeg, libtiff"
    exit 1
}

Write-Host ">>> 开始调用构建脚本：$PackageName.ps1" -ForegroundColor Yellow
Write-Host ""

# 调用具体的构建脚本，传递参数
# 注意：这里使用 & 调用，并显式传递参数
& $ScriptPath `
    -InstallDir $InstallDir `
    -FORCE_REBUILD $ForceRebuild

# 捕获子脚本的退出代码
$ExitCode = $LASTEXITCODE

# ================= 3. 清理与总结 =================
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ">>> 构建流程结束" -ForegroundColor Cyan

# 可选：清除环境变量 (其实脚本结束后会自动清除，但这更显式)
Remove-Item Env:\UNITY_NDK -ErrorAction SilentlyContinue
Write-Host "✅ 环境变量 UNITY_NDK 已清除。"

if ($ExitCode -ne 0) {
    Write-Host "❌ 构建失败！退出代码：$ExitCode" -ForegroundColor Red
    exit $ExitCode
} else {
    Write-Host "🎉 构建成功！" -ForegroundColor Green
}