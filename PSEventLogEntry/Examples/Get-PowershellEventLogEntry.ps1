
function Get-PowershellEventLogEntry{
  <#
      .SYNOPSIS
      When Powershell Logging is enabled, the event logs keep track of scripts running via Powershell.
      If you want to check logs from multiple computers, Get-WinEvent is limited to check all. 
        
      .DESCRIPTION
      This function filters the eventlog for the specific Logs and EventIDs making search easier 
      to query multiple servers by the help of the module of PSEventLogEntry.

      .PARAMETER ServerName
      Gets the Powershell Log Entries on the Servers logged.

      .PARAMETER StartTime
      Specifies the first log to find in the logs. 

      .PARAMETER EndTime
      Specifies the last log to find in the logs. 

      .EXAMPLE
      Get-PowershellEventLogEntry -ServerName @("Server1","Server2") -StartTime (Get-Date).AddMinutes(-5) -EndTime (Get-Date)
      This function will find the "Microsoft-Windows-Powershell/Operational" logs on Server1 and Server2 logged in the last 5 minutes with EventID 4103

      .NOTES
      The logname and EventID are the core part of this function to filter the real log, and provide what the user wants quickly.


      .INPUTS
      string array, datetime. 

      .OUTPUTS
      Creates a collection of System.Diagnostics.Eventing.Reader.EventLogRecord type objects
  #>


    param(
        [Parameter(Mandatory, HelpMessage='Gets the Log Entries from the specified server(s)',
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        Position=0)]
        [ValidateScript({Test-Connection -ComputerName $PSItem -Quiet -Count 1})]
        [System.String[]]$ServerName, 
    
        [Parameter(Mandatory,HelpMessage='Gets the Log entries after the specified start time')]
        [ValidateScript({$PSItem -le (Get-Date)})]
        [System.DateTime]$StartTime,
    
        [Parameter(Mandatory,HelpMessage='Gets the Log entries after the specified end time')]
        [ValidateScript({$PSItem -gt ($StartTime)})]
        [System.DateTime]$EndTime
    )
    Begin {
      Import-Module PSEventLogEntry
    
        #Set the default values: 
        $FilterHashTable=@{
            LogName="Microsoft-Windows-Powershell/Operational" 
            EventID=4103
            StartTime=$StartTime
            EndTime=$EndTime
        }
    }
    Process{
    #Check for hashtable values and add the result to the FilteredEventLog
        try{
        
            $FilteredPSEventLog= Get-EventLogEntry -ServerName $ServerName @FilterHashTable
        }
        catch{
          # get error record
          [System.Management.Automation.ErrorRecord]$e = $_

          # retrieve information about runtime error
          $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
          }
          
          # output information. Post-process collected info, and log info (optional)
          $info
        }
    }
    End{
        return $FilteredPSEventLog
    }
}
# SIG # Begin signature block
# MIID1QYJKoZIhvcNAQcCoIIDxjCCA8ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwbUvnH8Mso/dLolNfs2sFOu4
# AdWgggH3MIIB8zCCAVygAwIBAgIQPczt+GcwQ7RO4RivY1O3izANBgkqhkiG9w0B
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
# FgQUIX7BYWdQtiXEBPWoH9LS3nZzv1EwDQYJKoZIhvcNAQEBBQAEgYC6cdNJ+tAy
# Wc2jyd0DcH0rjIx1ewZKEvMyYEJK/p88w8d2Tm9py8yQuWNg6at62g2hTcvGb0Z1
# 5LEOYD9DZ1Qtqv5m1vFaodMlsjtKNM6nlT90R/GjYjHp92I74snRxhFZy56rIp7/
# /RGrvDM2iBdgKK8JETyf7k3fl/UejKUXnw==
# SIG # End signature block
