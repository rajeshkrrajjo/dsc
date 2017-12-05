Configuration ContosoWebsite
{
  param ($MachineName)

  Node $MachineName
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = “Present”
      Name = “Web-Server”
    }

    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = “Present”
      Name = “Web-Asp-Net45”
    }

     WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }
  }
} 
Save-Module -LiteralPath "C:\Program Files\WindowsPowerShell\Modules" -Name "xPSDesiredStateConfiguration"
Save-Module -LiteralPath "C:\Program Files\WindowsPowerShell\Modules" -Name "xDSCFirewall"
Save-Module -LiteralPath "C:\Program Files\WindowsPowerShell\Modules" -Name "psdesiredstateconfiguration"
Save-Module -LiteralPath "C:\Program Files\WindowsPowerShell\Modules" -Name "xTimeZone"
Save-Module -LiteralPath "C:\Program Files\WindowsPowerShell\Modules" -Name "xWinEventLog"

[DscLocalConfigurationManager()]
Configuration LCMConfig3
{
    

        Node localhost
        {
        Settings
        {
            #RefreshFrequencyMins            = 30;
            ActionAfterReboot               = "StopConfiguration";
            RefreshMode                     = "Push";
            ConfigurationMode               ="ApplyAndMonitor";
            AllowModuleOverwrite            = $true;
            RebootNodeIfNeeded              = $true;
            #ConfigurationModeFrequencyMins  = 60;
        }

}
}
LCMConfig3 -OutputPath c:\lcmpushmode
slcm -ComputerName localhost -Path c:\lcmpushmode -Force -Verbose 


configuration Serviceconfig
{

Import-DSCResource -ModuleName xDSCFirewall
Import-DSCResource -ModuleName psdesiredstateconfiguration
Import-DscResource -ModuleName xPSDesiredStateConfiguration
Import-DSCResource -ModuleName xTimeZone
Import-DscResource -module xWinEventLog


node localhost
{

Service WindowsFirewall
{
Name = "MPSSvc"
StartupType = "Automatic"
State = "Running"
}
xDSCFirewall DisablePublic
{
  Ensure = "Absent"
  Zone = "Public"
  Dependson = "[Service]WindowsFirewall"
}
xDSCFirewall EnabledDomain
{
  Ensure = "Present"
  Zone = "Domain"
  LogAllowed = "False"
  LogIgnored = "False"
  LogBlocked = "False"
  LogMaxSizeKilobytes = "4096"
  DefaultInboundAction = "Block"
  DefaultOutboundAction = "Allow"
  Dependson = "[Service]WindowsFirewall"
}
xDSCFirewall EnabledPrivate
{
  Ensure = "Present"
  Zone = "Private"
  Dependson = "[Service]WindowsFirewall"
}  
 

    xService Windows_Image_acquisition
    {
        Name = 'stisvc'
        StartupType = 'Manual'    
        State = 'Stopped'
    }

    xService Special_Administration_Console_Helper
    {
        Name = 'Sacsvr'
        StartupType = 'Manual'    
        State = 'Stopped'
    }

    xService Smart_card
    {
        Name = 'SCardSvr'
        StartupType = 'Manual'    
        State = 'Stopped'
    }

    xService Portable_Device_Enumerator_Service
    {
        Name = 'WPDBusEnum'
        StartupType = 'Manual'    
        State = 'Stopped'
    }

    xService Internet_Connection_Sharing
    {
        Name = 'SharedAccess'
        StartupType = 'Manual'    
        State = 'Stopped'
    }

    xService Human_Interface_Device_Service
    {
        Name = 'hidserv'
        StartupType = 'Manual'    
        State = 'Running'
    }

     xTimeZone TimeZoneExample
        {
            IsSingleInstance = 'Yes'
            TimeZone         = "Fiji Standard Time"
        }

        xWinEventLog Demo1
    {
        LogName            = "Application"
        IsEnabled          = $true
        LogMode            = "AutoBackup"
        MaximumSizeInBytes = 20mb
        
    }

}
}

Serviceconfig -OutputPath c:\serviceconfig

Start-DscConfiguration -ComputerName localhost -path C:\serviceconfig -Force -Wait -Verbose   

Configuration WindowsUpdate
{


Import-DscResource -ModuleName xPSDesiredStateConfiguration
Import-DscResource -ModuleName PSDesiredStateConfiguration

Node localhost

{
WindowsFeature Telnet
    {
        Ensure = "Present"
        Name ="Telnet-Client"
    
    }

Registry WUServer
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate"
        ValueName = 'WUServer'
        ValueType = 'String'
        ValueData = 'http://testvm.pullserver.com:8530'
        Ensure = "Present"
    }

Registry StatusServer
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate"
        ValueName = 'WUStatusServer'
        ValueType = 'String'
        ValueData = 'http://testvm.pullserver.com:8530'
        Ensure = "Present"

    }

Registry SetTargetGroup
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate"
        ValueName = 'TargetGroup'
        ValueType = 'String'
        ValueData = 'TestServers'
        Ensure = "Present"

    }

Registry TargetMode
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate"
        ValueName = 'TargetGroupEnabled'
        ValueType = 'Dword'
        ValueData = 1
        Ensure = "Present"
    }


Registry InstallOption
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate\AU"
        ValueName = 'AUOptions'
        ValueType = 'Dword'
        ValueData = 4
        Ensure = "Present"
    }

Registry WSUSServer
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate\AU"
        ValueName = 'UseWUServer'
        ValueType = 'Dword'
        ValueData = 1
        Ensure = "Present"
    }

Registry DetectFrequency
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate\AU"
        ValueName = 'DetectionFequency'
        ValueType = 'Dword'
        ValueData = 1
        Ensure = "Present"
    }

Registry InstallTime
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate\Au"
        ValueName = 'ScheduledInstallTime'
        ValueType = 'Dword'
        ValueData = '13'
        Ensure = "Present"
    }

Registry AutoRebootTime
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate\AU"
        ValueName = 'AlwaysAutoRebootAtSchduledTime'
        ValueType = 'Dword'
        ValueData = 1
        Ensure = "Present"
    }

Registry RebootMinutes
    {
        key="HKLM:\Software\Policies\MIcrosoft\Windows\WindowsUpdate\AU"
        ValueName =  'AlwaysAutoRebootAtSchduledTimeMinutes'
        ValueType = 'Dword'
        ValueData = '15'
        Ensure = "Present"
    }

}
}


WindowsUpdate -OutputPath c:\windowsupdate

Start-DscConfiguration -ComputerName localhost -path C:\Windowsupdate -Force -Wait -Verbose
