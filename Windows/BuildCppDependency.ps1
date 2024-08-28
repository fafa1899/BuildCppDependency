param(   
    [string]$Generator = "Visual Studio 16 2019",
    [string]$MSBuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    [string]$InstallDir = "$env:eGova3rdParty",
    [string]$SymbolDir = "$InstallDir/symbols",   
    [string]$Install,   
    [string]$List
)

# 创建所有的库的容器
$LibrarySet = [System.Collections.Generic.SortedSet[string]]::new()
$LibrarySet.Add("zlib") > $null
$LibrarySet.Add("libpng") > $null
$LibrarySet.Add("libjpeg") > $null
$LibrarySet.Add("libtiff") > $null

# 检查是否传递了$Install参数
if ($PSBoundParameters.ContainsKey('Install')) {   
    # 比较时忽略大小写
    if ($Install.ToLower() -eq "-all".ToLower()) {
        Write-Output "All libraries will be installed soon..."
        foreach ($item in $LibrarySet) {
            Write-Output "Find the library named $item and start installing..."        
            # 动态构建脚本文件名并执行
            $BuildScript = "./$item.ps1";           
            & $BuildScript -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir
        }
    }
    else {
        # 查找某个字符串
        if ($LibrarySet.Contains("$Install")) {
            Write-Output "Find the library named $Install and start installing..."        
            # 动态构建脚本文件名并执行
            $BuildScript = "./$Install.ps1";           
            & $BuildScript -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir
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

#Write-Output "Build giflib..."
#./BuildGifLib.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#需要zlib、libpng
#Write-Output "Build FreeType..."
#./BuildFreeType.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#需要Freetype、GIFLIB、JPEG、ZLIB、PNG、TIFF，额外链接了没有重新构建的FBX、GDAL、CURL
#Write-Output "Build OpenSceneGraph..."
#./BuildOpenSceneGraph.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#需要OpenSceneGraph
#Write-Output "Build OsgQt5..."
#./BuildOsgQt5.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#需要OpenSceneGraph
#Write-Output "Build OsgQt..."
#./BuildOsgQt.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#Write-Output "Build minizip..."
#./BuildMiniZip.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#Write-Output "Build Eigen..."
#./BuildEigen.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir