<#	
	.DESCRIPTION
		This script will simply install Teams for the current user.
		Below is the Teams Work or School download URL as of Jan 18, 2023
		https://go.microsoft.com/fwlink/p/?LinkID=2187327&clcid=0x1009&culture=en-ca&country=CA
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[string]$WorkingFolder,
	[Parameter(Mandatory = $true)]
	[string]$TeamsDownloadURL
)

Start-Transcript -Path "$WorkingFolder\TeamsInstaller.log"

#Below will download and install teams if it isn't installed for the user.
If ($(Test-Path -type Leaf -Path "C:\Users\$($env:USERNAME)\AppData\Local\Microsoft\Teams\Update.exe") -eq $false)
{
	#URL for downloading Teams
	Invoke-WebRequest -Uri "$TeamsDownloadURL" -OutFile "$WorkingFolder\teamsSetup.exe"
	#Check File Description before running to ensure it is Teams
	$GetFileDesc = Get-item "$WorkingFolder\teamsSetup.exe"
	IF ($($GetFileDesc.VersionInfo.FileDescription) -eq "Microsoft Teams")
	{
		Write-Host "The downloaded file description is $($GetFileDesc.VersionInfo.FileDescription)"
		Write-Host "The downloaded file has a description of Microsoft Teams, will continue."
		#Checks if the downloaded file is signed by Microsoft
		$GetFileCert = Get-AuthenticodeSignature "$WorkingFolder\teamsSetup.exe"
		If (($($GetFileCert.Status) -eq "Valid") -and ($($GetFileCert.SignerCertificate.Subject) -match "O=Microsoft Corporation"))
		{
			Write-Host "The downloaded file has a cert that is: $($GetFileCert.Status)"
			Write-Host "The downloaded file has a cert is signed by:  $($GetFileCert.SignerCertificate.Subject)"
			Write-Host "The downloaded file has been launched and will now install"
			Start-Process -FilePath "C:\TeamsLauncher\TeamsSetup.exe" -Wait
		}
		else
		{
			Write-Host "The downloaded file is not VALID and Signed by Microsoft Will not run"
			Write-Host "The downloaded file cert is:  $($GetFileCert.Status)"
			Write-Host "The downloaded file has a cert is signed by:  $($GetFileCert.SignerCertificate.Subject)"
		}
		
	}
	else
	{
		Write-Host "The downloaded file description doesn't match Microsoft Teams"
	}
}
else
{
	Write-Host "Teams is already installed under $($env:USERNAME)"
}
Stop-Transcript
