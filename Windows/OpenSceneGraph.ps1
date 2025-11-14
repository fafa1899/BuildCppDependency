# OpenSceneGraph.ps1
param(    
    [string]$Name = "OpenSceneGraph-3.6.5",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/osg161-osg.dll"

# 依赖库数组(FBX、GDAL、CURL)
$Librarys = @("zlib", "libpng", "libjpeg", "libtiff", "giflib", "freetype", "curl") 

# 符号库文件
$PdbFiles = @() 

# 额外构建参数
$CMakeCacheVariables = @{ 
    CURL_LIBRARY="$InstallDir/lib/libcurl_imp.lib"
    CURL_IS_STATIC = "OFF"
    GIFLIB_LIBRARY = "$InstallDir/lib/giflib.lib"    
    BUILD_OSG_APPLICATIONS = "ON"
    BUILD_OSG_EXAMPLES = "OFF"
    CMAKE_RELWITHDEBINFO_POSTFIX = ""  
}

. ./build-common.ps1 -Name $Name `
    -SourceDir $SourceDir `
    -InstallDir $InstallDir `
    -SymbolDir $SymbolDir `
    -Generator $Generator `
    -TargetDll $DllPath `
    -PdbFiles $PdbFiles `
    -CMakeCacheVariables $CMakeCacheVariables `
    -MultiConfig $false `
    -Force $Force `
    -Cleanup $Cleanup `
    -Librarys $Librarys


# 获取源目录下的所有 .pdb 文件
$pdbFiles = Get-ChildItem -Path "$InstallDir/bin" -Filter *.pdb -Recurse

# 移动每个 .pdb 文件到目标目录
foreach ($file in $pdbFiles) {
    $destinationPath = Join-Path -Path $SymbolDir -ChildPath $file.Name
    Move-Item -Path $file.FullName -Destination $destinationPath -Force
    Write-Output "Moved: $($file.FullName) -> $destinationPath"
}        
