# install-prebuilt.ps1
# 功能：解压并覆盖复制到目标目录

param(    
    [string]$DestinationPath,
    [string]$Name
)

# 获取当前脚本所在目录作为工作目录
$workingDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

Write-Host "Working dir: $workingDir" -ForegroundColor Green
Write-Host "Destination path: $DestinationPath" -ForegroundColor Green

# 检查 zip 文件是否存在
$zipName = "$Name.zip"
$zipFile = Join-Path $workingDir $zipName
if (-Not (Test-Path $zipFile)) {
    Write-Error "Error! Can't find '$zipFile'"
    exit 1
}

# 定义解压后的源文件夹路径
$sourceFolder = Join-Path $workingDir $Name

# 如果已存在同名文件夹，先删除（确保干净解压）
if (Test-Path $sourceFolder) {
    Write-Host "Existing extracted folder found, cleaning up..." -ForegroundColor Yellow
    try {
        Remove-Item $sourceFolder -Recurse -Force
    }
    catch {
        Write-Error "Error: Failed to remove old extracted folder '$sourceFolder'. Error: $_"
        exit 1
    }
}

# 解压 zip 文件
Write-Host "Extracting '$zipFile' ..." -ForegroundColor Cyan
try {
    # Use .NET's ZipFile class (built-in support in PowerShell 5.0+)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $workingDir)
    Write-Host "Extraction completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Extraction failed. Error: $_"
    exit 1
}

# 检查解压后的文件夹是否存在
if (-Not (Test-Path $sourceFolder)) {
    Write-Error "Error: Folder '$sourceFolder' not found after extraction."
    exit 1
}

# 执行覆盖复制
Write-Host "Copying files from '$sourceFolder' to '$DestinationPath' with overwrite ..." -ForegroundColor Cyan
try {
    # 使用 Copy-Item 进行递归复制，并强制覆盖
    Copy-Item -Path "$sourceFolder\*" -Destination $DestinationPath -Recurse -Force
    Write-Host "Copy and overwrite completed successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Copy operation failed. Error: $_"
    exit 1
}

# （可选）清理解压出的临时文件夹
Write-Host "Cleaning up temporary extracted folder..." -ForegroundColor Yellow
Remove-Item $sourceFolder -Recurse -Force

Write-Host "Script execution completed." -ForegroundColor Magenta