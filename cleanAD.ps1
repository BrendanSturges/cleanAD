Import-Module ActiveDirectory 

$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm"

$disableTime = (Get-Date).Adddays(-75)	
$deleteTime = (Get-Date).Adddays(-90)

$serverList = Get-ADComputer -Filter * | Select -Expand Name

#Check if FilePath exists, if not - create
$doesItExist = Test-Path C:\Automation\ADComputerObjMaintenance -pathType container
if($doesItExist -eq False){
New-Item -path C:\Automation\ -Name ADComputerObjMaintenance -type Directory
}

#declare log file name
$filename = "C:\Automation\ADComputerObjMaintenance\ADMaintenance"+$LogTime+".log"

ForEach ($Computer in $serverList)
{   
	$ADprops = Get-ADComputer -Identity $serverList -Properties LastLogonDate
	$ADpass = Get-ADComputer -Identity $serverList -Properties PasswordLastSet
	[datetime]$lastLogon = $ADprops.LastLogonDate
	[datetime]$lastPass = $ADpass.lastPass
	$timestamp = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
	
	if($lastLogon -lt $disableTime -and $lastPass -lt $disableTime){
		Try {
			Disable-ADAccount $Computer -ErrorAction Stop
			Add-Content $fileName -Value $timestamp + " "+ $Computer + " removed"
		}
		Catch {
			Add-Content $filename -Value $timestamp + " " + $Computer + " not found because $($Error[0])"
		}
	}
	
	if($lastLogon -lt $deleteTime -and $lastPass -lt $deleteTime){
		Try {
			Remove-ADComputer $Computer -ErrorAction Stop
			Add-Content $fileName -Value $timestamp + " "+ $Computer + " removed"
		}
		Catch {
			Add-Content $filename -Value $timestamp + " " + $Computer + " not found because $($Error[0])"
		}
	}
}