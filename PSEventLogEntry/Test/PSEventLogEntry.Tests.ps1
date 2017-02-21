$ModuleName="PSEventLogEntry"

    
    Describe  -Name 'Get-EventLogEntry Function Basic Tests' -Tags 'Basic,Get-EventLogEntry' -Fixture {
      BeforeAll {
        #Make sure PSEventLogEntry is installed
        if($null -eq (Get-Module -Name $ModuleName -ListAvailable)){
            Throw "PSEventLogEntry is not on PSModulePath "
        }
        Import-Module -Name $ModuleName
        $testEventLog=Get-WinEvent -LogName 'Application' -MaxEvents 1
        #Use the log we know exists on the test machine:
        if(!($null -eq $testEventLog)) {
            $ValidParamHash=@{
                LogName ='Application' 
                ServerName = if($null -eq $ENV:USERDNSDOMAIN){$env:COMPUTERNAME}else{ "$($env:COMPUTERNAME).$($ENV:USERDNSDOMAIN)" }
                EventID=$testEventLog.Id
                StartTime=Get-Date -Date ($testEventLog.TimeCreated.AddMinutes(-5)) -Format "yyyy-MM-dd hh:mm:ss"
                EndTime=Get-Date -Date ($testEventLog.TimeCreated.AddMinutes(+5)) -Format "yyyy-MM-dd hh:mm:ss"
            } 
        }
        #Create a dummy parameter set.
        $InvalidParamHash=@{
            LogName='NonExistent'
            EventID=9898009
            ServerName='NoServer'
            StartTime=(Get-Date).AddMinutes(-4)
            EndTime=(Get-Date).AddMinutes(-10)
        }
      }
      #First test with the invalid parameter set
      Context -Name 'Invalid Parameter Set' -Fixture {
        #Test1: Throw error for the invalid servername parameter.
        It -name 'Should Throw Error for invalid ServerName' -test {
            {Get-EventLogEntry -ServerName $InvalidParamHash.ServerName }| Should Throw "Cannot validate argument on parameter 'ServerName'"
        }
        #Test2: Throws error for the invalid Log Name parameter
        It -name 'Should Throw Error for invalid LogName' -test {
            {Get-EventLogEntry -ServerName $ValidParamHash.ServerName -LogName $InvalidParamHash.LogName }| Should Throw "Cannot validate argument on parameter 'LogName'"
        }

      }
      #Second, try with the valid parameter set
      Context -Name 'Valid Parameter Set' -Fixture {
        It -name 'Should Not Throw An Error for the Valid Logname, Start/End Time inputs' -test {

            {Get-EventLogEntry @ValidParamHash }| Should Not Throw
        }
      }
}
# SIG # Begin signature block
  # MIID1QYJKoZIhvcNAQcCoIIDxjCCA8ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
  # gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
  # AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURwxJOyd+kVwKaLedrQYCeRb2
  # Vs+gggH3MIIB8zCCAVygAwIBAgIQPczt+GcwQ7RO4RivY1O3izANBgkqhkiG9w0B
  # AQUFADAUMRIwEAYDVQQDDAlFYnJ1Q3VjZW4wHhcNMTcwMjIwMTYwMzEyWhcNMjEw
  # MjIwMDAwMDAwWjAUMRIwEAYDVQQDDAlFYnJ1Q3VjZW4wgZ8wDQYJKoZIhvcNAQEB
  # BQADgY0AMIGJAoGBAM9DHzKoHyTXvxl7q2uSDf8r2icxXOBXykg8E7AD9vzPOFG+
  # AFaHwbiMzpVvwkpQX8xKEcD3z9BqciwXOQn++qPhmtx1JGqJlESDzXRx5RUtUWob
  # pqL4gNlsCDzzorCedENwZj5vtU45MoI1mkx/GKxxaP0/2a0qGY3CQWxIYxNLAgMB
  # AAGjRjBEMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQqh+pM/8QBxCpf
  # rUOpfxheI7V3dzAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQEFBQADgYEAht0a
  # EDW/H4tenMZgt73ivMqi3lSVdrdECdZPgWBSj0g9kt7ngviLkqWpeD4Chyv7nUdm
  # Mi4rEkEldA3xloLMxijRb+gf5VZygmI2lXLPZZkqeRtSyMqT6fRD4N8y3Tg52mYu
  # hNvV1iuAvbmEK5iI8yBZJy2wjL26VFvY+qDWqU4xggFIMIIBRAIBATAoMBQxEjAQ
  # BgNVBAMMCUVicnVDdWNlbgIQPczt+GcwQ7RO4RivY1O3izAJBgUrDgMCGgUAoHgw
  # GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
  # NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
  # FgQUTrH71K7T92mjJNU+j9VZpHBqm0gwDQYJKoZIhvcNAQEBBQAEgYCNG+jMj9qo
  # 5YNYUa1ycHLwp+hzmSrRzDtgnWzsYak92Cwln6fZATpvAsvjpAWBCy2/RZiNsVIi
  # oOkxfeDHwlXPtKoWYqo8Kl+4Iv08TOkDwvxDZ79veuuabWCdntf7albZrhwfED/X
  # mMXmybvJrgaKQ69kNaIFFUBH8KN2Pa4qcA==
# SIG # End signature block
