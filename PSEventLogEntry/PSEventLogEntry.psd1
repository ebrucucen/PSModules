
@{
  RootModule = 'PSEventLogEntry'
  ModuleVersion = '1.0'
  GUID = 'f1b5d1f0-7f9a-49b3-ad42-79caf2f4f933'
  Author = 'Ebru Cucen'
  CompanyName = 'personal'
  Copyright = '(c) 2017 Ebru Cucen. All rights reserved.'
  Description = 'This is a wrapper module for Get-WinEvent to get EventLogs from multiple servers within the specified time period.'
  PowerShellVersion = '3.0'
  FunctionsToExport = @('Get-EventLogEntry')
  FileList = @('PSEventLogEntry.psm1','PSEventLogEntry.psd1', 'Test\PSEventLogEntry.Tests.ps1', '.\en-us\about_PSLogEntry.help.txt', '.\Examples\Get-PowershellEventLogEntry.ps1', '.\Examples\Get-PowerShellEventLogEntry.Tests.ps1')
}

