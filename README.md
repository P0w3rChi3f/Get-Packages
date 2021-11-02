# Get-Packages

## SYNOPSIS

Script to create an offline FireEye Commando VM and Chocolatey Repo using the FireEye provided csv file.

## Description

The problem statement is that I need to provide a way to allow Windows VMs to install applications create a FireEye Commando VM in an environment that has no Internet connectivity.  I could create the VM offline and import the machine into the environment, but that does not help with the install of additonal applications.  I was able to install the Repo offline, but it doens't have any apps.  I have to import the apps one by one.  This script helps solve both problems.  1) It downloads what it can find on Community.Chocolatey.com and 2) does a git clone on anything it can find on GitHub.  The script will create a directory in its current location called "Downloads".  This is where are the files will be downloaded to.  It will also produce a report (CSV File), in its current location, of everything it downloaded or tried to download.

## Parameter csvPath

This is the path to the csv file you wish to have read in.  It is a mandatory parameter and has the alias' of -path and -csv.

## Example csvPath

.\Offline-download.ps1 -csvPath <path/to/file>

## Example Path

.\Offline-download.ps1 -Path <path/to/file>

## Example CSV

.\Offline-download.ps1 -csv <path/to/file>
