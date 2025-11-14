# opencv.ps1
param(    
    [string]$Name = "opencv-3.4.16",
    [string]$SourceDir = "../Source",
    [string]$Generator,
    [string]$InstallDir,  
    [string]$SymbolDir,  
    [bool]$Force = $false,        # 是否强制重新构建
    [bool]$Cleanup = $true        # 是否在构建完成后删除源码和构建目录
)

# 目标文件
$DllPath = "$InstallDir/bin/opencv_world3416.dll"

# 依赖库数组
$Librarys = @("eigen")  

# 符号库文件
$PdbFiles = @(
    "bin/Release/opencv_world3416.pdb"
) 

# 额外构建参数
$CMakeCacheVariables = @{
    BUILD_opencv_world = "ON" 
    WITH_GDAL = "OFF"
    WITH_FFMPEG = "OFF"
    WITH_IPP = "OFF"
    BUILD_TESTS = "OFF"
    BUILD_PERF_TESTS = "OFF"
    BUILD_opencv_python_tests = "OFF"
    BUILD_opencv_python_bindings_generator = "OFF"
    BUILD_JAVA = "OFF"
    BUILD_opencv_java = "OFF"
    BUILD_opencv_java_bindings_generator = "OFF"
}
#-DBUILD_ZLIB=OFF `
#-DBUILD_JPEG=OFF `
#-DBUILD_PNG=OFF `
#-DBUILD_TIFF=OFF `
#-DWITH_PROTOBUF=ON `
#-DBUILD_PROTOBUF=ON `
#-DPROTOBUF_UPDATE_FILES=OFF `

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
    -Librarys $Librarys `
    -BuildType "Release"

# 将二进制成果文件复制到bin目录 
Copy-Item -Path "$InstallDir/x64/vc16/bin/*" -Destination "$InstallDir/bin" -Force

