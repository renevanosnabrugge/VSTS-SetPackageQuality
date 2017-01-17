param
(
        [string] $feedName="",
        [string] $packageId="",
        [string] $packageVersion="",
        [string] $packageQuality="",
        [switch] $pester
)

#global variables
$baseurl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI 
$baseurl += $env:SYSTEM_TEAMPROJECT + "/_apis"
$basepackageurl = $env:SYSTEM_TEAMFOUNDATIONSERVERURI  -replace ".visualstudio.com/", ".pkgs.visualstudio.com/DefaultCollection/_apis/packaging/feeds"

Write-Debug  "baseurl=$baseurl"
Write-Debug  "basepackageurl=$basepackageurl"

<#
.Synopsis
Creates either a Basic Authentication token or a Bearer token depending on where the method is called from VSTS. 
When you send a Personal Access Token that you generate in VSTS it uses this one. Within the VSTS pipeline it uses env:System_AccessToken 
#>
function New-VSTSAuthenticationToken
{
    [CmdletBinding()]
    [OutputType([object])]
         
    $accesstoken = "";
    if([string]::IsNullOrEmpty($env:System_AccessToken)) 
    {
        if([string]::IsNullOrEmpty($env:PersonalAccessToken))
        {
            throw "No token provided. Use either env:PersonalAccessToken for Localruns or use in VSTS Build/Release (System_AccessToken)"
        } 
        Write-Debug $($env:PersonalAccessToken)
        $userpass = ":$($env:PersonalAccessToken)"
        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($userpass))
        $accesstoken = "Basic $encodedCreds"
    }
    else 
    {
        $accesstoken = "Bearer $env:System_AccessToken"
    }

    return $accesstoken;
}


function Set-PackageQuality
{
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [string] $feedName="",
        [string] $packageId="",
        [string] $packageVersion="",
        [string] $packageQuality=""
        
    )

    $token = New-VSTSAuthenticationToken
    $releaseViewURL = "$basepackageurl/$feedName/nuget/packages/$packageId/versions/$($packageVersion)?api-version=3.0-preview.1"
    
     $json = @{
        views = @{
            op = "add"
            path = "/views/-"
            value = "$releaseView"
        }
    }

    $response = Invoke-RestMethod -Uri $releaseViewURL -Headers @{Authorization = $token}   -ContentType "application/json" -Method Patch -Body (ConvertTo-Json $json)
    return $response
}


if (-not $pester)
{
    Set-PackageQuality -feedName $feedName -packageId $packageId -packageVersion $packageVersion -packageQuality $packageQuality
}