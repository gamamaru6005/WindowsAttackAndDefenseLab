configuration AdminDesktopConfig 
{ 
  Param(
    [Parameter(Mandatory)]
    [string]$classUrl
  )
  Import-DscResource -ModuleName PSDesiredStateConfiguration

  Node "admindesktop" {

    Script DownloadWAADFiles {
      SetScript  = { 
        $file = $using:classUrl + 'WAAD.zip'
        Add-Content -Path "C:\Windows\Temp\jah-dsc-log.txt" -Value "[DownloadWAADFiles] Downloading $file"
        Invoke-WebRequest -Uri $file -OutFile C:\Windows\Temp\WAAD.zip
      }
      GetScript  = { @{} }
      TestScript = { 
        Test-Path C:\Windows\Temp\WAAD.zip
      }
    }
    Archive UnzipWAADFiles {
      Ensure      = "Present"
      Destination = "C:\WAAD"
      Path        = "C:\Windows\Temp\WAAD.zip"
      Force       = $true
      DependsOn   = "[Script]DownloadWAADFiles"
    }
    Script SetTimeZone {
      SetScript  = { 
        Add-Content -Path "C:\Windows\Temp\jah-dsc-log.txt" -Value "[SetTimeZone] Running.."
        cmd.exe /c 'tzutil /s "Eastern Standard Time"'
      }
      GetScript  = { @{} }
      TestScript = { $false }
    }
    WindowsFeature DotNetCore {
      Ensure = "Present" 
      Name   = "Net-Framework-Core"
    }
    WindowsFeature RemoteDesktop
    {
        Ensure = "Present" 
        Name = "RDS-RD-Server"
    }
    LocalConfigurationManager {
      ConfigurationMode  = 'ApplyOnly'
      RebootNodeIfNeeded = $true
    }
  } 
}