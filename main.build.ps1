task Init {
    
    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

    Install-Module InvokeBuild , PSDeploy, BuildHelpers -force
    Install-Module Pester -Force -SkipPublisherCheck
    Import-Module InvokeBuild, BuildHelpers
}

task Build {
    $buildModulePath= Get-item (Join-Path -Path $PSScriptRoot "PSEventlogEntry\PSEventlogEntry.psm1" ) 
    if (!(Get-Module -Name "PSEventlogEntry")) {
        #pick the first module path copy the content , install the module...
        $buildModulePathExp=$buildModulePath.Directory.Tostring().replace("\", "\\")
        $p = [Environment]::GetEnvironmentVariable("PSModulePath")
        if (!($p -match $buildModulePathExp)) {
            $p += ";$($buildModulePath.Directory)"
            [Environment]::SetEnvironmentVariable("PSModulePath", $p, [System.EnvironmentVariableTarget]::Machine)
            Write-Output $PSModulePath
        }
    }
        try{    
            Write-Output $buildModulePath
            Import-module ($buildModulePath.Directory)
        }
        catch {
            throw "weeorr"
        }
    
}

task Clean{

}

task Test{
    Pester\Invoke-Pester 
}
task Version {
    $path=".\PSEventLogEntry\PSEventLogEntry.1.psd1"
    [regex]$rx="ModuleVersion\s=\s'(?<majorversion>\d).(?<minversion>\d).(?<buildversion>\d).(?<revisionversion>\d)'"
    (Get-Content $path )|ForEach-Object {
        $m=$rx.Match($_)
        if($m.captures.count -gt 0){
        $NewMinorValue=[int]($m.Groups["revisionversion"].Value)+1
        write-debug $m.Groups["majorversion"].Value
        write-debug $m.Groups["minversion"].Value
        write-debug $m.Groups["buildversion"].Value
        $newVersion= "{0}.{1}.{2}.{3}" -f ($m.Groups["majorversion"].Value), ($m.Groups["minversion"].Value), ($m.Groups["buildversion"].Value),$NewMinorValue
        $_ -Replace [regex]('\d.\d.\d.\d'),$newVersion
    }
    else {
      $_
    }
  }|Set-content $path
  
}
task . Init,Build 