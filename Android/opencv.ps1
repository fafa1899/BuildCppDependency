# opencv.ps1

param(
    [string]$InstallDir = "D:\Work\Android3rdParty", 
    [bool]$FORCE_REBUILD = $false
)

# --- 定义包特定信息 ---
$PackageName = "opencv-3.4.16"
$Dependencies = @()
$MyCMakeArgs = @(  
    "-DBUILD_opencv_world=ON",
    "-DWITH_GDAL=OFF",
    "-DWITH_FFMPEG=OFF",
    "-DWITH_IPP=OFF",
    "-DBUILD_TESTS=OFF",
    "-DBUILD_PERF_TESTS=OFF",
    "-DBUILD_opencv_python_tests=OFF",
    "-DBUILD_opencv_python_bindings_generator=OFF",
    "-DBUILD_JAVA=OFF",
    "-DBUILD_opencv_java=OFF",
    "-DBUILD_opencv_java_bindings_generator=OFF"  
    "-DBUILD_ANDROID_EXAMPLES=OFF"  
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