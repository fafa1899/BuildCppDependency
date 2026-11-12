# CGAL 构建脚本：从 7z 分卷组装临时 ZIP，再使用增强构建流程
param(
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$Name = "cgal-5.2.4",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true,
    [string]$SevenZipPath = ""
)

$ErrorActionPreference = 'Stop'
$Librarys = @("boost", "gmp", "mpfr")
$CMakeCacheVariables = @{
    CGAL_HEADER_ONLY = "ON"
    WITH_CGAL_Qt5 = "OFF"
    WITH_examples = "OFF"
    WITH_demos = "OFF"
    BUILD_TESTING = "OFF"
}
$Marker = Join-Path $InstallDir "installed/$Name.installed"
# 已安装时直接让公共脚本处理跳过逻辑，无需重新组装压缩包
$StageDir = Join-Path $PSScriptRoot "$Name-package"
$CacheDir = Join-Path $StageDir 'cache'
if ($Force -or (-not (Test-Path -LiteralPath $Marker -PathType Leaf) -and -not (Test-Path -LiteralPath (Join-Path $CacheDir "$Name/CMakeLists.txt")))) {
    if (-not $SevenZipPath) {
        $command = Get-Command 7z.exe -ErrorAction SilentlyContinue
        if ($command) { $SevenZipPath = $command.Source }
        elseif (Test-Path -LiteralPath 'C:\Program Files\7-Zip\7z.exe') {
            $SevenZipPath = 'C:\Program Files\7-Zip\7z.exe'
        }
        else { throw '7-Zip not found. Install 7-Zip or specify -SevenZipPath.' }
    }
    foreach ($volume in @("$Name.7z.001", "$Name.7z.002")) {
        if (-not (Test-Path -LiteralPath (Join-Path $SourceDir $volume) -PathType Leaf)) {
            throw "Archive volume not found: $volume"
        }
    }
    $UnpackDir = Join-Path $StageDir 'unpack'
    $TreeDir = Join-Path $StageDir 'source'
    New-Item -ItemType Directory -Path $UnpackDir, $TreeDir, $CacheDir -Force | Out-Null
    & $SevenZipPath x (Join-Path $SourceDir "$Name.7z.001") "-o$UnpackDir" -y -bsp0
    if ($LASTEXITCODE -ne 0) { throw 'Failed to extract CGAL archive volumes.' }
    # 当前分卷中嵌套了同名 ZIP，兼容直接包含源码目录的分卷
    $NestedZip = Join-Path $UnpackDir "$Name.zip"
    if (Test-Path -LiteralPath $NestedZip -PathType Leaf) {
        & $SevenZipPath x $NestedZip "-o$TreeDir" -y -bsp0
        if ($LASTEXITCODE -ne 0) { throw 'Failed to extract nested CGAL ZIP.' }
    }
    else { $TreeDir = $UnpackDir }
    if (-not (Test-Path -LiteralPath (Join-Path $TreeDir "$Name/CMakeLists.txt"))) {
        throw "CGAL source directory not found: $Name"
    }
    # 生成 ZIP 到缓存目录，不向 Source 写入大文件
    $ZipPath = Join-Path $CacheDir "$Name.zip"
    if (Test-Path -LiteralPath $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force }
    Push-Location $TreeDir
    try {
        & $SevenZipPath a -tzip -mx=0 $ZipPath $Name -bsp0
        if ($LASTEXITCODE -ne 0) { throw 'Failed to assemble CGAL ZIP.' }
    }
    finally { Pop-Location }
}

# Windows PowerShell 5.1 会将原生程序的 stderr 提示映射成错误记录；
# 公共脚本已经逐阶段检查退出码，因此调用期间不将普通 stderr 提示升级为异常。
$SavedErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $CacheDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles @() `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys
}
finally { $ErrorActionPreference = $SavedErrorActionPreference }

# 成功后清理组装目录；失败时保留以便排查，原始分卷始终保留
if ($Cleanup -and (Test-Path -LiteralPath $StageDir)) {
    Remove-Item -LiteralPath $StageDir -Recurse -Force
}
