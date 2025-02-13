param(     
    [string]$SourcePath = "../Source/openssl-openssl-3.4.0",
    [string]$BuildDir = "./openssl-openssl-3.4.0",
    [string]$Generator,
    [string]$MSBuild,
    [string]$vcVarsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    [string]$InstallDir,  
    [string]$SymbolDir 
)

# 使用cmd.exe运行vcvars64.bat，并保持命令提示符窗口打开
cmd.exe /c openssl.bat
