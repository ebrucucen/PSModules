
#Script properties: 
    $lines = '----------------------------------------------------------------------'
    $ProjectRoot = $ENV:BHProjectPath 
    if(! $ProjectRoot) 
    { 
        $ProjectRoot = $PSScriptRoot 
    } 
    $Verbose = @{Verbose = $True}

    $TestLocation= Join-Path -Path $ProjectRoot "PSEventLogEntry\Test"
    $timestamp= Get-date -format "ddMM_hhmmss"
    $ModuleName="PSEventlogEntry"

#Init Task
task Init {
    $lines
    Set-location $ProjectRoot

    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
    $ModuleList= @("InvokeBuild","PSDeploy", "BuildHelpers", "Pester")
    Foreach ($module in $ModuleList){
        if (Get-module -name $module -ListAvailable) {
            #skip
        }
        else{
            install-module -Name $module -Force
        }
        Import-Module -Name $module 
    }
    
    Set-BuildEnvironment
    
    $lines
    "Build System Details: "
    Get-Item "ENV:BH*" | Format-List
    "`n"
    $lines

}

#PreTest Task
task PreTest {
    $lines 
    $buildModulePath= Get-item (Join-Path -Path $PSScriptRoot "PSEventlogEntry\PSEventlogEntry.psm1" ) 
    if (!(Get-Module -Name $ModuleName)) {
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
            if (Get-command -Module $ModuleName){
                write-output "Sucess import"
            }
            else {
                write-output "Failed import"
            }
        }
        catch {
            throw "weeorr"
        }
    $lines
}

#Clean Task
task Clean{
    #Todo : remove test files: 
}

#Test Task 
task Test{
    $lines 
    'TDD: Tests first! ' 

    #Get the test files: 
    $TestFiles= Get-ChildItem -Path $TestLocation -Filter "*.Tests.*"
    foreach ($testFile in $testFiles){
        $testOutputFileName= Join-path -path $testfile.Directory -ChildPath "$($testfile.basename)_$timestamp.xml"
        $testResult=Invoke-Pester -Script $testFile.Fullname  -OutputFile $testOutputFileName -OutputFormat NUnitXml
    }

    #upload to Appveyor
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $testOutputFileName))
    
    if($testResult.FailedCount -gt 0) 
    { 
         Write-Error "Failed '$($testResult.FailedCount)' tests, build failed" 
    } 

    $lines 
}
#Packaging task 
task Package {
    $lines
    $Params = @{ 
             Path = $ProjectRoot 
             Force = $true 
         } 
 
         Invoke-PSDeploy @Verbose @Params 
   $lines      
}
#Version Task
task Version {
    $lines
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
  $lines  
}
task . Init, PreTest, Test 
