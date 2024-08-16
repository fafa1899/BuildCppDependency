function DownloadAndUnzip {
    param (
        [string]$SourceLocalPath,   # 解压后的源代码路径
        [string]$SourceZipPath,     # ZIP 文件的本地路径
        [string]$SourceAddress      # ZIP 文件的下载地址
    )

    if (!(Test-Path $SourceLocalPath)) {
        if (!(Test-Path $SourceZipPath)) {
            #下载源代码
            Write-Output "Download Zip..."
            Invoke-WebRequest -Uri $SourceAddress -OutFile $SourceZipPath
        }
    
        # 解压缩 ZIP 文件   
        Write-Output "Unzip Source..."
        Expand-Archive -Path $SourceZipPath -DestinationPath "./"
    }
}

