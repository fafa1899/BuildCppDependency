function FindVcVarsPath {
    param (
        [string]$vsVersion = "Visual Studio 16 2019"
    )

    # vswhere.exe 路径
    $vswhere = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

    if (-Not (Test-Path $vswhere)) {
        throw "vswhere.exe not found at $vswhere"
    }

    # 提取版本号，比如 16
    $versionNumber = ($vsVersion -split " ")[2]

    # 使用 vswhere 查找安装路径
    $vsPath = & $vswhere -version "[$versionNumber.0,$($versionNumber+1).0)" -property installationPath -latest

    if (-Not $vsPath) {
        throw "Visual Studio $vsVersion not found"
    }

    # 拼接 vcvarsall.bat 完整路径
    return (Join-Path $vsPath "VC\Auxiliary\Build\vcvarsall.bat")
}