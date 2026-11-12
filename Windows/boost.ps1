# Boost 构建脚本，保持现有 1.86 版本及版本化安装布局
param(
    [string]$Name = "boost-1.86.0",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)

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
    CMAKE_PDB_OUTPUT_DIRECTORY = $PdbDir
    OPENSSL_INCLUDE_DIR = ""
    SSL_EAY_RELEASE = ""
}

& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -PreserveSource $true `
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
