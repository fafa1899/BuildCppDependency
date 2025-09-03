function BuildRequired {
    param (
        [string[]]$Librarys
    )

    Write-Output "------------------------------------------------"  
    Write-Output "Start installing all required dependencies..."     
    foreach ($item in $Librarys) { 
        Write-Output "Find the library named $item and start installing..."        
        # 动态构建脚本文件名并执行
        $BuildScript = "./$item.ps1";           
        & $BuildScript -Generator $Generator -InstallDir $InstallDir -SymbolDir $SymbolDir       
    }
    Write-Output "All required dependencies have been installed."   
    Write-Output "------------------------------------------------"  
}

 

