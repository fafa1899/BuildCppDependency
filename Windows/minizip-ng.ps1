# minizip-ng 构建脚本
param(
    [string]$Name = "minizip-ng-4.2.2",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)

# 静态链接库，使用与其他依赖一致的动态 MSVC 运行库
$CMakeCacheVariables = @{
    BUILD_SHARED_LIBS = "OFF"
    MZ_COMPAT = "OFF"
    MZ_ZLIB = "ON"
    MZ_ZLIB_FLAVOR = "zlib"
    MZ_BZIP2 = "OFF"
    MZ_LZMA = "OFF"
    MZ_PPMD = "OFF"
    MZ_ZSTD = "OFF"
    MZ_LIBCOMP = "OFF"
    MZ_PKCRYPT = "OFF"
    MZ_WZAES = "OFF"
    MZ_OPENSSL = "OFF"
    MZ_LIBBSD = "OFF"
    MZ_ICONV = "OFF"
    MZ_FETCH_LIBS = "OFF"
    MZ_FORCE_FETCH_LIBS = "OFF"
    MZ_BUILD_TESTS = "OFF"
    MZ_BUILD_UNIT_TESTS = "OFF"
    MZ_BUILD_FUZZ_TESTS = "OFF"
}

& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -PdbFiles @() `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $true `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys @("zlib")