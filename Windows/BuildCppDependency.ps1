param(   
    [string]$Generator, 
    [string]$InstallDir,
    [string]$SymbolDir,   
    [string]$Install,   
    [string]$List,
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 创建所有的库的容器
$LibrarySet = [System.Collections.Generic.SortedSet[string]]::new()
$LibrarySet.Add("zlib") > $null
$LibrarySet.Add("libpng") > $null
$LibrarySet.Add("libjpeg") > $null
$LibrarySet.Add("libtiff") > $null
$LibrarySet.Add("giflib") > $null
$LibrarySet.Add("freetype") > $null
$LibrarySet.Add("OpenSceneGraph") > $null
$LibrarySet.Add("eigen") > $null
$LibrarySet.Add("osgQt5") > $null
$LibrarySet.Add("osgQt") > $null
$LibrarySet.Add("minizip") > $null
$LibrarySet.Add("libzip") > $null
$LibrarySet.Add("opencv") > $null
$LibrarySet.Add("uriparser") > $null
$LibrarySet.Add("cpp-httplib") > $null
$LibrarySet.Add("nlohmann-json") > $null
$LibrarySet.Add("sqlite") > $null
$LibrarySet.Add("libwebp") > $null
$LibrarySet.Add("proj") > $null
$LibrarySet.Add("geos") > $null
$LibrarySet.Add("gdal") > $null
$LibrarySet.Add("boost") > $null
$LibrarySet.Add("qwindowkit") > $null
$LibrarySet.Add("SARibbon") > $null
$LibrarySet.Add("tinyxml2") > $null
$LibrarySet.Add("magic_enum") > $null
$LibrarySet.Add("iconv") > $null
$LibrarySet.Add("libxml2") > $null
$LibrarySet.Add("libexpat") > $null
$LibrarySet.Add("c-ares") > $null
$LibrarySet.Add("openssl") > $null
$LibrarySet.Add("curl") > $null
$LibrarySet.Add("gflags") > $null
$LibrarySet.Add("glog") > $null
$LibrarySet.Add("OpenBLAS") > $null
$LibrarySet.Add("TBB") > $null
$LibrarySet.Add("SuiteSparse") > $null
$LibrarySet.Add("gmp") > $null
$LibrarySet.Add("mpfr") > $null
$LibrarySet.Add("ceres-solver") > $null
$LibrarySet.Add("md4c") > $null
$LibrarySet.Add("apriltag") > $null
$LibrarySet.Add("faiss") > $null
#$LibrarySet.Add("OpenMVG") > $null
#$LibrarySet.Add("protobuf") > $null
#$LibrarySet.Add("abseil-cpp") > $null

# 检查是否传递了$Install参数
if ($PSBoundParameters.ContainsKey('Install')) {   
    # 比较时忽略大小写
    if ($Install.ToLower() -eq "-all".ToLower()) {
        Write-Output "All libraries will be installed soon..."
        foreach ($item in $LibrarySet) {
            Write-Output "Find the library named $item and start installing..."        
            # 动态构建脚本文件名并执行
            $BuildScript = "./$item.ps1";           
            & $BuildScript -Generator $Generator -InstallDir $InstallDir -SymbolDir $SymbolDir -Force $Force -Cleanup $Cleanup
        }
    }
    else {
        # 查找某个字符串
        if ($LibrarySet.Contains("$Install")) {
            Write-Output "Find the library named $Install and start installing..."        
            # 动态构建脚本文件名并执行
            $BuildScript = "./$Install.ps1";           
            & $BuildScript -Generator $Generator -InstallDir $InstallDir -SymbolDir $SymbolDir -Force $Force -Cleanup $Cleanup
        }
        else {
            Write-Output "Cannot find library named $Install !"
        }
    }
}
elseif ($PSBoundParameters.ContainsKey('List')) {       
    if ($List.ToLower() -eq "-all".ToLower()) {
        Write-Output "The list of all libraries that can currently be installed in the repository is as follows:"
        foreach ($item in $LibrarySet) {
            Write-Output $item
        }
    }
}
else {
    Write-Host "Please enter the parameters!"
}
