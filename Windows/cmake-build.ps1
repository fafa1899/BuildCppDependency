param(
    [string]$SourceLocalPath,
    [string]$BuildDir,
    [string]$Generator,
    [string]$InstallDir,
    [string]$SymbolDir,
    [string[]]$PdbFiles,
    [hashtable]$CMakeCacheVariables,
    [bool]$MultiConfig = $false,  # 控制是否使用多配置类型
    [string]$BuildType = "RelWithDebInfo"  # 构建类型参数，默认为 RelWithDebInfo
)

# 构建CMake命令行参数
$CMakeArgs = @(
    "-B", "`"$BuildDir`"",
    "-G", "`"$Generator`"",
    "-A", "x64"
)

if ($MultiConfig) {
    $CMakeArgs += "-DCMAKE_CONFIGURATION_TYPES=$BuildType"
}
else {
    $CMakeArgs += "-DCMAKE_BUILD_TYPE=$BuildType"
}

$CMakeArgs += (
    "-DCMAKE_PREFIX_PATH=`"$InstallDir`"",
    "-DCMAKE_INSTALL_PREFIX=`"$InstallDir`""
)

# 添加额外的CMake缓存变量
foreach ($key in $CMakeCacheVariables.Keys) {
    $CMakeArgs += "-D$key=$($CMakeCacheVariables[$key])"
}

# 配置CMake
cmake $SourceLocalPath $CMakeArgs

# 构建阶段，指定构建类型
cmake --build $BuildDir --config $BuildType --parallel

# 安装阶段，指定构建类型和安装目标
cmake --build $BuildDir --config $BuildType --target install

# 复制符号库
foreach ($file in $PdbFiles) {  
    Write-Output $file
    if (Test-Path $file) {
        Copy-Item -Path $file -Destination $SymbolDir
    }
    else {
        Write-Output "Warning: PDB file not found: $file"
    }
}

# 清理构建目录
#Remove-Item -Path $BuildDir -Recurse -Force