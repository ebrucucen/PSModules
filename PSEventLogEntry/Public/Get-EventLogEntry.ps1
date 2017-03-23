
function Get-EventLogEntry{
  <#
      .SYNOPSIS
      To filter Powershell Logs, we need a wrapper to create a base search for logs and 
     the filter with a proper error handling, paramer validation when we pass a set of server names.

      .DESCRIPTION
      This function filters the Event Log for the specified Servers, LogNames and EventIDS

      .PARAMETER ServerName
      Gets the EventLogs on the specified Server(s)

      .PARAMETER LogName
      Filters the EventLogs for the specified Logs. 

      .PARAMETER EventID
      Filters the EventLogs for the specified EventID.

      .PARAMETER StartTime
      Filters the requested EventLogs after the specified time.

      .PARAMETER EndTime
      Filters the requested EventLogs before the specified time.

      .EXAMPLE
      Get-EventLogEntry -ServerName "Server1" -LogName "System" -EventID 7036 -StartTime (Get-Date).AddMinutes(-5) -EndTime (Get-Date)
      Returns the System logs on the server Server1 with EventID 7036 in the last 5 minutes. 

      .NOTES
      This is a wrapper funtion to Get-WinEvent and to its FilterHashTable parameter. It does not (yet) provide a better way to handle event logs.


      .INPUTS
      string arrays, date time, 

      .OUTPUTS
      System.Diagnostics.Eventing.Reader.EventLogRecord
  #>


    param(
        [Parameter(Mandatory, HelpMessage='Gets the Log Entries from the specified server(s)',
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        Position=0)]
        [ValidateScript({Test-Connection -ComputerName $PSItem -Quiet -Count 1})]
        [System.String[]]$ServerName, 
    
        [Parameter(Mandatory,HelpMessage='Gets the entries from the specified Logs. 
        Returns an error if none of servers provided does not have this Log',
        Position=1)]
        [ValidateScript({ 
            try{
                $logExists=$false
                foreach ($server in $ServerName){
                  if( $null -ne (Get-WinEvent -ListLog "$PSItem" -ComputerName $server )){
                    $logExists=$true
                    break
                  }
                }
            }catch { 
                Throw [System.Management.Automation.ValidationMetadataException] "$_.Exception"
            }
            return $logExists
        })]
        [System.String]$LogName,

        [Parameter(HelpMessage='Filters the Log entries by the specified Event ID')]
        [ValidateRange(0,65535)]
        [System.Int16]$EventID,
        
        [Parameter(HelpMessage='Gets the Log entries after the specified start time')]
        [ValidateScript({$PSItem -le (Get-Date)})]
        [System.DateTime]$StartTime,
    
        [Parameter(HelpMessage='Gets the Log entries after the specified end time')]
        [ValidateScript({$PSItem -gt ($StartTime)})]
        [System.DateTime]$EndTime
    )
    Begin {
        $FilterHashTable=@{
            LogName=$LogName
        }
        if(0 -ne $EventID){
            $FilterHashTable.EventID=$EventID
        }
        if ($null -ne $StartTime ){
            $FilterHashTable.StartTime=$StartTime
            $FilterHashTable.EndTime=$EndTime
        }

    }
    Process{
    #Check for hashtable values and add the result to the FilteredEventLog
        try{
            foreach ($server in $ServerName){
              try{
                $FilteredEventLog+=(Get-WinEvent -FilterHashtable $FilterHashTable -ComputerName $server -ErrorAction Stop )
                }
                catch{
                    #TODO: ideally catch the correct exception
                    continue
               }
             }
        }
        catch{
          # get a generic error record
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
          #Write the error object
          
          $info
 }
    }
    End{
        return $FilteredEventLog
    }
}

