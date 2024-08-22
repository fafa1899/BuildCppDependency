param(   
    [string]$Generator = "Visual Studio 16 2019",
    [string]$MSBuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    [string]$InstallDir = "$env:eGova3rdParty",
    [string]$SymbolDir = "$InstallDir/symbols"    
)

#Write-Output "Build zlib..."
#./BuildZLib.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#需要zlib
#Write-Output "Build libpng..."
#./BuildLibPng.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#Write-Output "Build libjpeg..."
#./BuildLibJPEGTurbo.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

#需要libjpeg
#Write-Output "Build libtiff..."
#./BuildLibTIFF.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir

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
./BuildOsgQt.ps1 -Generator $Generator -MSBuild $MSBuild -InstallDir $InstallDir -SymbolDir $SymbolDir
