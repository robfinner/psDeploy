
#Import all the commandlets

$currentDir = Split-Path $MyInvocation.MyCommand.Path

Import-Module -Name "$currentDir\Windows\Groups.psm1" -Force
Import-Module -Name "$currentDir\Windows\ScheduledTasks.psm1" -Force
Import-Module -Name "$currentDir\Windows\Users.psm1" -Force
Import-Module -Name "$currentDir\Windows\Shares.psm1" -Force
Import-Module -Name "$currentDir\Windows\Permissions.psm1" -Force
Import-Module -Name "$currentDir\IIS6\AppPools.psm1" -Force
Import-Module -Name "$currentDir\IIS6\Websites.psm1" -Force
Import-Module -Name "$currentDir\IIS6\VirtualDirectories.psm1" -Force



<#
.Synopsis
Checks that WMI is accessible.
Please call this before calling any other cmdlets in psDeploy
#>
function Assert-PsDeploySupported
{
	[wmiclass] 'root/MicrosoftIISv2:IIsWebServer' > $null
	if (!$?)
	{
		throw "The IIS WMI Provider does not appear to be installed"
	}
}


