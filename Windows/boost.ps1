# Boost 构建脚本，使用 1.89.0 完整源码包及版本化安装布局
param(
    [ValidatePattern('^boost-[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$Name = "boost-1.89.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true,
    [string]$SevenZipPath = ""
)

# 从完整 7z 源码包生成临时 ZIP，以复用公共构建流程
$StageDir = Join-Path $PSScriptRoot "$Name-package"
$CacheDir = Join-Path $StageDir 'cache'
$TreeDir = Join-Path $StageDir 'source'
$ZipPath = Join-Path $CacheDir "$Name.zip"
$Marker = Join-Path $InstallDir "installed/$Name.installed"
if ($Force -or -not (Test-Path -LiteralPath $Marker -PathType Leaf)) {
    if (-not $SevenZipPath) {
        $Command = Get-Command 7z.exe -ErrorAction SilentlyContinue
        if ($Command) { $SevenZipPath = $Command.Source }
        elseif (Test-Path -LiteralPath 'C:\Program Files\7-Zip\7z.exe') {
            $SevenZipPath = 'C:\Program Files\7-Zip\7z.exe'
        }
        else { throw '7-Zip not found. Install 7-Zip or specify -SevenZipPath.' }
    }
    $ArchivePath = Join-Path $SourceDir "$Name.7z"
    if (-not (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) { throw "Archive not found: $ArchivePath" }
    New-Item -ItemType Directory -Path $TreeDir, $CacheDir -Force -ErrorAction Stop | Out-Null
    & $SevenZipPath x $ArchivePath "-o$TreeDir" -y -bsp0
    if ($LASTEXITCODE -ne 0) { throw 'Failed to extract Boost archive.' }
    foreach ($RequiredFile in @('CMakeLists.txt', 'tools/cmake/include/BoostRoot.cmake', 'libs/config/include/boost/config.hpp')) {
        if (-not (Test-Path -LiteralPath (Join-Path "$TreeDir/$Name" $RequiredFile) -PathType Leaf)) {
            throw "Incomplete Boost CMake source archive: $RequiredFile"
        }
    }
    if (Test-Path -LiteralPath $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force -ErrorAction Stop }
    Push-Location $TreeDir
    try {
        & $SevenZipPath a -tzip -mx=0 $ZipPath $Name -bsp0
        if ($LASTEXITCODE -ne 0) { throw 'Failed to assemble Boost ZIP.' }
    }
    finally { Pop-Location }
}
$Librarys = @("zlib")
# 统一生成 PDB 到构建目录，避免移动安装目录中其他库的符号文件
$PdbDir = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $PWD $Name) 'symbols'))
$PdbFiles = @("symbols/RelWithDebInfo/*.pdb")
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "ON"
    BUILD_TESTING = "OFF"
    BOOST_INSTALL_LAYOUT = "versioned"
    BOOST_ENABLE_MPI = "OFF"
    BOOST_ENABLE_PYTHON = "OFF"
    BOOST_IOSTREAMS_ENABLE_ZLIB = "ON"
    CMAKE_PDB_OUTPUT_DIRECTORY = $PdbDir
    CMAKE_CXX_FLAGS = "/DWIN32 /D_WINDOWS /W3 /GR /EHsc /utf-8"
    OPENSSL_INCLUDE_DIR = ""
    SSL_EAY_RELEASE = ""
}

& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $CacheDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys

# Boost 安装规则会额外复制 PDB 到 bin；归档后移除这些重复文件
if ($SymbolDir) {
    $BoostBin = Join-Path $InstallDir 'bin'
    $SymbolPath = [System.IO.Path]::GetFullPath($SymbolDir).TrimEnd('\')
    if ($SymbolPath -eq [System.IO.Path]::GetFullPath($BoostBin).TrimEnd('\')) {
        Write-Warning 'SymbolDir is bin; PDB cleanup skipped to preserve symbols.'
    }
    elseif (Test-Path -LiteralPath $BoostBin -PathType Container) {
        New-Item -ItemType Directory -Path $SymbolDir -Force -ErrorAction Stop | Out-Null
        foreach ($pdb in Get-ChildItem -LiteralPath $BoostBin -Filter 'boost_*.pdb' -File) {
            $destination = Join-Path $SymbolDir $pdb.Name
            Copy-Item -LiteralPath $pdb.FullName -Destination $destination -Force -ErrorAction Stop
            if ((Get-FileHash -LiteralPath $pdb.FullName).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) {
                throw "PDB verification failed: $destination"
            }
            Remove-Item -LiteralPath $pdb.FullName -Force -ErrorAction Stop
            Write-Output "Archived PDB: $destination"
        }
    }
}

# 成功构建并归档符号后清理临时目录，失败时保留以便排查
if ($Cleanup -and (Test-Path -LiteralPath $StageDir)) {
    Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction Stop
}
