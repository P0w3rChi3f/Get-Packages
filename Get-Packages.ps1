#######################################################
###         Created by CW3 James Honeycutt          ###
###                 28 October 2021                 ###
###                                                 ###
###             Twitter: @P0w3rChi3f                ###
#######################################################

<#
.SYNOPSIS
    Script to create an offline FireEye Commando VM and Chocolatey Repo using the FireEye provided csv file.

.Description
    The problem statement is that I need to provide a way to allow Windows VMs to install applications create a FireEye Commando VM in an environment that has no Internet connectivity.  I could create the VM offline and import the machine into the environment, but that does not help with the install of additonal applications.  I was able to install the Repo offline, but it doens't have any apps.  I have to import the apps one by one.  This script helps solve both problems.  1) It downloads what it can find on Community.Chocolatey.com and 2) does a git clone on anything it can find on GitHub.  The script will create a directory in its current location called "Downloads".  This is where are the files will be downloaded to.  It will also produce a report (CSV File), in its current location, of everything it downloaded or tried to download.

.Parameter csvPath
    This is the path to the csv file you wish to have read in.  It is a mandatory parameter and has the alias' of -path and -csv.

.Example
    .\Offline-download.ps1 -csvPath <path/to/file>

.Example
    .\Offline-download.ps1 -Path <path/to/file>

.Example
    .\Offline-download.ps1 -csv <path/to/file>

#>

[CmdletBinding(SupportsShouldProcess=$true)]

    param (

        [Parameter(Mandatory=$true, Position=0, HelpMessage = "Please enter a path the csv file you would like to import")]
        [ValidatePattern(".csv", ErrorMessage = "{0} is not a valid csv file")]
        [alias('Path', 'CSV')]
        [String[]]
        $csvPath #= './packages.csv'
    )

Function Get-InstallPackages {

    $apps = @()
    $myDownloadList = @()
    $AppObject = [PSCustomObject]@{}


    if (!(Test-Path $csvPath)) {Write-host "File does not exist!"; break}

    try{
        $apps = Import-Csv $csvPath

        if (!($apps.PackageName -or $apps.URL)) {
            Write-host " Your CSV file is in the wrong format.  Please use the newly created csv provided, titled 'ImportCSVTemplate.csv'"

            $TemplateFile = [PSCustomObject]@{
                PackageName = 'PackageName'
                Description = 'Description'
                Dependencies = 'Dependencies'
                Category = 'Category'
                URL = 'URL'
                HowToInstall = 'HowToInstall'
            }
            $TemplateFile | Export-Csv .\ImportCSVTemplate.csv
            break
        }
    }
    catch {Write-host "You must use a CSV file.  No other extention will be accepted"}
     
    

    New-Item -ItemType Directory -name Downloads -path . -Force
    Set-Location .\Downloads


    foreach ($app in $apps) {

        $TrimmedApp = [System.IO.Path]::GetFileNameWithoutExtension((($app)."PackageName"))
        if ((Test-Path .\$trimmedApp)-or (Test-Path ".\$TrimmedApp.*.nupkg")) {
            Write-host "$TrimmedApp already downloaded, coninuing on"
        }
        else {
            Write-host "Downloading $TrimmedApp now"
            if ($app.url -like "https://github.com*") {
                Write-host "$trimmedApp is on GitHub "
                $AppObject = [PSCustomObject]@{
                    AppName = $TrimmedApp
                    PackageName = "$trimmedApp.git"
                    Description = $app.Description
                    Category = $app.Category
                    AppUrl = $app.URL
                    DownloadURL = "$($app.url).git"
                    HowToInstall = "git clone $($app.url).git"
                    } # End Custom Object
                
                $myDownloadList += $AppObject
                #Test to see if it exists
                git clone $AppObject.DownloadURL
            }
            Else {
                write-host "Searching on Chocolatey for $trimmedApp"

                $APPhref = (Invoke-WebRequest  -Uri https://community.chocolatey.org/packages?q=$TrimmedApp).links.href | Where-Object {$_ -like "*$trimmedApp" -and $_ -notlike "*?q=tag%3A*"} | Select-Object -first 1
                try {
                    $myApps = (((Invoke-WebRequest -uri https://community.chocolatey.org$APPhref).rawcontent).split(" ")).split(">") | Select-String -Pattern ".nupkg"
                }

                Catch { }

                $AppObject = [PSCustomObject]@{
                    AppName = $TrimmedApp
                    PackageName = $myApps
                    Description = $app.Description
                    Category = $app.Category
                    AppUrl = $app.URL
                    DownloadURL = "https://packages.chocolatey.org/$myapps"
                    HowToInstall = "choco install $myapps -y"
                    } # End Custom Object
                
                
                try {
                    Invoke-WebRequest -Uri $AppObject.DownloadURL -OutFile ./"$($AppObject.PackageName)"
                }
                catch { Write-host " Cannot find application on Chocolatey"
                        $AppObject.DownloadURL = "App Not Found"
                        $AppObject.HowToInstall = $null
                }
                
                $myDownloadList += $AppObject
            } 
        } #end Test-path  

    } # End ForEach

    set-location ..
    $myDownloadList | export-csv ./myDownloadList.csv -Force

} # Close Function

Get-InstallPackages 




<# TO DO List:

1) Created template creates 2 headders
2) Check to see if there is internet connection



#>

<# Links below are just for reference  

https://packages.myget.org/F/fireeye/common.fireeye

https://community.chocolatey.org/packages?q=$shortapp

https://packages.chocolatey.org/

https://community.chocolatey.org/packages/wsl 

(Invoke-WebRequest -Uri https://packages.chocolatey.org/apktool.2.5.0.nupkg).raw

#>