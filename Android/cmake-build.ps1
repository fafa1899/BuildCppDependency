# cmake-build.ps1 (修改版)

param(
    [Parameter(Mandatory=$true)][string]$PackageName,
    [Parameter(Mandatory=$true)][string]$InstallDir,
    [string[]]$CMakeExtraArgs = @(),
    [bool]$ForceRebuild = $false,
    [bool]$CleanupAfterBuild = $true,
    [bool]$EnableParallel = $true
)

# ================= 1. 从环境变量获取 NDK 路径 =================
if (-not $env:UNITY_NDK) {
    Write-Error "❌ 错误：环境变量 UNITY_NDK 未设置！请使用 build.ps1 入口脚本运行，或手动设置该变量。"
    exit 1
}

$UNITY_NDK = $env:UNITY_NDK

# 再次验证路径有效性
if (-not (Test-Path $UNITY_NDK)) {
    Write-Error "❌ 错误：UNITY_NDK 指向的路径不存在：$UNITY_NDK"
    exit 1
}

Write-Host ">>> 使用 NDK: $UNITY_NDK" -ForegroundColor Gray

# ================= 全局配置 =================
# 注意：SourceBaseDir 和 BuildBaseDir 依然基于当前脚本所在目录
$SourceBaseDir = "$pwd\..\Source"
$BuildBaseDir = "$pwd"

# 派生路径
$ZipPath = "$SourceBaseDir\$PackageName.zip"
$SourceDir = "$SourceBaseDir\$PackageName"
$BuildDir = "$BuildBaseDir\$PackageName"
$InstallMarker = "$InstallDir\installed\$PackageName.installed"

# 通用链接器标志 (Android 15+ 16KB Page Size)
$LINKER_FLAGS = "-Wl,-z,max-page-size=16384,-z,common-page-size=16384"

# CMake 公共参数
$CommonCMakeArgs = @(
    "-S", $SourceDir,
    "-B", $BuildDir,
    "-G", "Ninja",
    "-DCMAKE_TOOLCHAIN_FILE=$UNITY_NDK/build/cmake/android.toolchain.cmake",
    "-DANDROID_ABI=arm64-v8a",
    "-DANDROID_PLATFORM=android-21",
    "-DCMAKE_FIND_ROOT_PATH=$InstallDir",
    "-DCMAKE_PREFIX_PATH=$InstallDir",
    "-DCMAKE_INSTALL_PREFIX=$InstallDir",
    "-DCMAKE_BUILD_TYPE=Release",
    "-DCMAKE_SHARED_LINKER_FLAGS=$LINKER_FLAGS",
    "-DCMAKE_EXE_LINKER_FLAGS=$LINKER_FLAGS"
)

# ================= 2. 检查安装标记 =================
if (-not $ForceRebuild -and (Test-Path $InstallMarker)) {
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "[$PackageName] 检测到安装标记，跳过构建!" -ForegroundColor Green
    Write-Host "标记路径：$InstallMarker"
    Write-Host "如需重建，请使用 -ForceRebuild `$true"
    Write-Host "=========================================" -ForegroundColor Green
    exit 0
}

if ($ForceRebuild) {
    Write-Host ">>> [$PackageName] 强制重建模式 (ForceRebuild=$ForceRebuild)"
    if (Test-Path $InstallMarker) {
        Write-Host ">>> 正在移除旧的安装标记..."
        Remove-Item -Path $InstallMarker -Force
    }
} else {
    Write-Host ">>> [$PackageName] 未检测到安装标记，开始构建流程..."
}

# ================= 3. 源码准备 (解压) =================
if (-not (Test-Path $SourceDir)) {
    Write-Host ">>> [$PackageName] 源目录不存在，正在解压..."
    
    if (-not (Test-Path $ZipPath)) {
        Write-Error "错误：找不到压缩包 $ZipPath"
        exit 1
    }

    $ExtractPath = Split-Path -Path $ZipPath -Parent
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractPath)
    } catch {
        Write-Error "解压失败: $_"
        exit 1
    }
    
    if (-not (Test-Path $SourceDir)) {
        $PotentialDirs = Get-ChildItem -Path $ExtractPath -Directory | Where-Object { $_.Name -like "*$PackageName*" -or $_.Name -like "$PackageName*" }
        if ($PotentialDirs) {
            $RealSource = $PotentialDirs[0].FullName
            Rename-Item -Path $RealSource -NewName $PackageName
            Write-Host ">>> 自动重命名目录为 $PackageName"
        } else {
            Write-Error "错误：解压后仍未找到目录 $SourceDir，请检查 Zip 内部结构。"
            exit 1
        }
    }
    Write-Host ">>> [$PackageName] 解压完成"
} else {
    Write-Host ">>> [$PackageName] 源目录已存在，跳过解压"
}

# ================= 4. 清理构建目录 =================
if (Test-Path $BuildDir) {
    Write-Host ">>> [$PackageName] 清理旧构建目录..."
    Remove-Item -Recurse -Force $BuildDir
}
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

# ================= 5. 配置 CMake =================
Write-Host ">>> [$PackageName] 开始配置 CMake..."
$AllCMakeArgs = $CommonCMakeArgs + $CMakeExtraArgs

cmake @AllCMakeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "[$PackageName] CMake 配置失败!"
    exit 1
}

# ================= 6. 构建与安装 =================
Write-Host ">>> [$PackageName] 开始构建..."

$BuildArgs = @("--build", $BuildDir)
if ($EnableParallel) {
    $BuildArgs += "--parallel"
    Write-Host ">>> 并行构建已启用"
}

cmake @BuildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "[$PackageName] 构建失败!"
    exit 1
}

Write-Host ">>> [$PackageName] 开始安装..."
cmake --build $BuildDir --target install

if ($LASTEXITCODE -ne 0) {
    Write-Error "[$PackageName] 安装失败!"
    exit 1
}

# ================= 7. 生成安装标记 =================
try {
    $MarkerDir = Split-Path -Path $InstallMarker -Parent
    if (-not (Test-Path $MarkerDir)) {
        New-Item -ItemType Directory -Force -Path $MarkerDir | Out-Null
    }

    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Set-Content -Path $InstallMarker -Value "Installed on $Timestamp via cmake-build.ps1 (Success)"
    Write-Host ">>> [$PackageName] ✅ 安装标记已生成：$InstallMarker"

} catch {
    Write-Warning "警告：无法生成安装标记文件 ($_)"
}

# ================= 8. 清理 (可选) =================
if ($CleanupAfterBuild) {
    Write-Host ">>> [$PackageName] 正在清理临时文件..."
    if (Test-Path $SourceDir) { Remove-Item -Recurse -Force $SourceDir }
    if (Test-Path $BuildDir) { Remove-Item -Recurse -Force $BuildDir }
    Write-Host ">>> [$PackageName] 清理完成"
} else {
    Write-Host ">>> [$PackageName] 保留临时文件"
}

Write-Host "=========================================" -ForegroundColor Green
Write-Host "[$PackageName] 🎉 Build completed successfully!" -ForegroundColor Green
Write-Host "输出目录：$InstallDir"
Write-Host "=========================================" -ForegroundColor Green