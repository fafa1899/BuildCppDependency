# GKlib 静态库构建，保持 /MD 运行库和统一安装参数
param(
    [string]$Name = "GKlib-master",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [bool]$Force = $false,
    [bool]$Cleanup = $true
)
$Marker = Join-Path $InstallDir "installed/$Name.installed"
if ($Force -or -not (Test-Path -LiteralPath $Marker -PathType Leaf)) {
    $SourcePath = Join-Path $SourceDir $Name
    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
        Expand-Archive -LiteralPath (Join-Path $SourceDir "$Name.zip") -DestinationPath $SourceDir -Force -ErrorAction Stop
    }
    # 只添加构建适配层，不修改上游 C 源码和压缩包
    $AdapterDir = Join-Path $SourcePath 'windows-cmake'
    New-Item -ItemType Directory -Path $AdapterDir -Force -ErrorAction Stop | Out-Null
    Copy-Item -LiteralPath "$PSScriptRoot/cmake/GKlib/CMakeLists.txt" -Destination $AdapterDir -Force -ErrorAction Stop
}
$CMakeCacheVariables = @{
    CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreadedDLL"
}
& "$PSScriptRoot/build-common-ex.ps1" -Name $Name `
    -SourceDir $SourceDir -SourceSubDir 'windows-cmake' `
    -Generator $Generator -InstallDir $InstallDir -SymbolDir $SymbolDir `
    -PdbFiles @("symbols/RelWithDebInfo/GKlib.pdb") `
    -CMakeCacheVariables $CMakeCacheVariables -MultiConfig $true `
    -Force $Force -Cleanup $Cleanup -Librarys @()