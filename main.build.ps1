
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
    "Build System Details: "
    Get-Item "ENV:BH*" | Format-List
    "`n"
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
        Import-Module -Name $module 
    }
    
    Set-BuildEnvironment

}

#PreTest Task
task PreTest {
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
    
}

#Clean Task
task Clean{

}

#Test Task 
task Test{
    $lines 
    'TDD: Tests first! ' 

    #Set-Location $TestLocation
    $TestFiles= Get-ChildItem -Path $TestLocation -Filter "*.Tests.*"
    foreach ($testFile in $testFiles){
        $testOutputFileName= Join-path -path $testfile.Directory -ChildPath "$($testfile.basename)_$timestamp.xml"
        $testResult=Invoke-Pest -Script $testFile.Fullname  -OutputFile $testOutputFileName -OutputFormat NUnitXml
    }
    New-Object -TypeName PSObject -Property @{
        Passed = $testResult.PassedCount
        Failed = $testResult.FailedCount
    }
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path $testOutputFileName))
    if($testResult.FailedCount -gt 0) 
    { 
         Write-Error "Failed '$($testResult.FailedCount)' tests, build failed" 
    } 
    $lines 
}
task Package {
    
    $Params = @{ 
             Path = $ProjectRoot 
             Force = $true 
         } 
 
         Invoke-PSDeploy @Verbose @Params 
 
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
task . Init, PreTest, Test 
