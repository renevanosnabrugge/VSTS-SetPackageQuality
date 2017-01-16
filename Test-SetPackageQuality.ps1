$env:SYSTEM_TEAMFOUNDATIONSERVERURI = "https://accountname.visualstudio.com/"
$env:SYSTEM_TEAMPROJECT = "TeamProjectNam"
$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI = "https://accountname.visualstudio.com/"
$env:PersonalAccessToken="PAT"

cd $PSScriptRoot

. .\Set-PackageQuality.ps1 -pester

$feedName = "Feedname"
$packageId = "packageID" 
$packageVersion = "Version"
$packageQuality = "ReleaseViewName"

Set-PackageQuality -feedName $feedName -packageId $packageId -packageVersion $packageVersion -packageQuality $packageQuality

