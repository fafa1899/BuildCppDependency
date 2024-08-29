# 简介

只通过脚本，自动化构建C/C++依赖库。

需安装CMake和Visual Studio。

在Windows下使用Powershell脚本。

# 指令

查看能安装的库：

```shell
./BuildCppDependency.ps1 -List -all
```

安装特定的库：

```shell
./BuildCppDependency.ps1 -Generator "Visual Studio 16 2019" `
-MSBuild "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe" `
-InstallDir "$env:GISBasic" `
-SymbolDir "$env:GISBasic/symbols" `
-Install libzip
```




