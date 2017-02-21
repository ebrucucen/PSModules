$here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
. "$here\Get-PowerShellEventLogEntry.ps1"

    $TimeParams=@{
        StartTime=(Get-Date).AddMinutes(-5)
        EndTime=(Get-Date)
    }
    $InvalidTimeParams=@{
        StartTime=(Get-Date).AddMinutes(+5)
        EndTime=(Get-Date).AddMinutes(+20)
    }

    $ValidParamHash=@{
        ServerName = if($null -eq $ENV:USERDNSDOMAIN){$env:COMPUTERNAME}else{ "$($env:COMPUTERNAME).$($ENV:USERDNSDOMAIN)" }        
    }

    $InvalidParamHash=@{
        ServerName="NonExistent"
    }

    $TestHash=@{
        StartTime=$TimeParams.StartTime
        EndTime=$TimeParams.EndTime
        EventID= 4103 
        LogName ="Microsoft-Windows-Powershell/Operational" 
    }
    
#region ErrorDefinitions: 
	$inValidServerNameErrorMessage = "Cannot validate argument on parameter 'ServerName'."
    $exception = New-Object -TypeName System.Management.Automation.ParameterBindingException -ArgumentList $inValidServerNameErrorMessage
	$errorId = 'ParameterArgumentValidationError'
	$errorCategory = [System.Management.Automation.ErrorCategory]::InvalidData
	$InvalidServerNameDataError = New-Object -TypeName System.Management.Automation.ErrorRecord `
	    -ArgumentList $exception, $errorId, $errorCategory, $null

#endregion

    Describe  -Name "Tests for Get-PowerShellEventLogEntry" -Tags "Get-PowerShellEventLogEntry" -Fixture {
        Context -Name "Invalid Parameters sent" -Fixture {
        
            #Basic tests for the argument ServerName
            It -name "Test1: Should Throw Error for nonexist ServerName" -test {
                {Get-PowerShellEventLogEntry -ServerName $InvalidParamHash.ServerName @TimeParams}| Should Throw $InvalidServerNameDataError
            }
            #Basic tests for the argument DateTime
            It -name "Test2: Should Throw Error for invalid Date parameterset" -test {

                {Get-PowerShellEventLogEntry -ServerName $ValidParamHash.ServerName @InvalidTimeParams }| Should -Throw -ErrorId ParameterArgumentValidationError 
            }
        }
        Context -Name "DateTime parameters are provided. One to one comparison with Get-WinEvent" -Fixture {    
            #Proper arguments passed. Not expecting any error
            It -name "Test3: Should not Throw Error with only ServerNames passed" -test {
                {Get-PowerShellEventLogEntry -ServerName $ValidParamHash.ServerName @TimeParams}| Should Not Throw 
            }
            #We need to compare results with Get-WinEvent
            It -name "Test4: Should be the same result when we call Get-WinEvent " -test {
                try{
                    $ExpectedOutput=Get-WinEvent -FilterHashtable $TestHash -ComputerName $ValidParamHash.ServerName -ErrorAction Stop
                    }
                    catch{
                        #TODO : find a proper way to handle this exception
                        continue
                    }
                $ActualOutput=Get-PowerShellEventLogEntry -ServerName $ValidParamHash.ServerName @TimeParams
                $ActualOutput | Should Match $ExpectedOutput 
            }
        }
    }
