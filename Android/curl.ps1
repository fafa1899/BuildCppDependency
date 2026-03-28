# curl.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "curl-curl-8_14_1"
$Dependencies = @(
    "zlib",
    "c-ares",
    "openssl"
)
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

# --- 调用通用构建脚本 ---
& "$PSScriptRoot\build-common.ps1" `
    -PackageName $PackageName `
    -InstallDir $InstallDir `
    -Dependencies $Dependencies `
    -CMakeExtraArgs $MyCMakeArgs `
    -ForceRebuild $FORCE_REBUILD `
    -CleanupAfterBuild $true `
    -EnableParallel $true
