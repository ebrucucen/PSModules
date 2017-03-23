
#Script properties: 
    $lines = '`n----------------------------------------------------------------------'
    $ProjectRoot = $ENV:BHProjectPath 
    if(! $ProjectRoot) 
    { 
        $ProjectRoot = $PSScriptRoot 
    } 

#Init Task
task Init {
    $lines
    Set-location $ProjectRoot
    "Build System Details: "
    Get-Item ENV:BH* | Format-List
    $lines

    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
    $ModuleList= @("InvokeBuild","PSDeploy", "BuildHelpers", "Pester")
    Foreach ($module in $ModuleList){
        if (Get-module -name $module -ListAvailable) {
            #skip
        }
        else{
            install-module -Name $module -Force
        }
    }
 #   Install-Module InvokeBuild , PSDeploy, BuildHelpers -force
 #   Install-Module Pester -Force
 #   Import-Module InvokeBuild, BuildHelpers
}

#Build Task
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

#Clean Task
task Clean{

}

#Test Task
task Test{
    $lines 
    'TDD: Tests first! ' 
    $TestResults = Invoke-Pester -Path $ProjectRoot\Test\*tests* -PassThru -Tag Build  
      
    if($TestResults.FailedCount -gt 0) 
    { 
         Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed" 
    } 
    "`n" 
}

#Version Task
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
task . Init,Build, Test 
