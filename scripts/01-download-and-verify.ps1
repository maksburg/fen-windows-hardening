<#
.SYNOPSIS
  Downloads fen (Windows amd64) and prints the local SHA256 hash.

.DESCRIPTION
  This script downloads the upstream release binary from GitHub Releases and computes
  its SHA256 hash locally. Students must manually compare the hash with the value shown
  on the GitHub release page before running the executable.

.PREREQUISITES
  - Windows 10/11
  - PowerShell 5.1+
  - Internet access
  - No Administrator rights required

.SECURITY NOTES
  - This step is a basic supply-chain integrity control.
  - If the SHA256 does NOT match exactly, do not run the file.

.ROLLBACK
  - Delete the downloaded file from the Downloads directory.

.EXAMPLE
  PS> .\scripts\01-download-and-verify.ps1
#>

$downloadUrl = "https://github.com/kivattt/fen/releases/download/v1.7.24/fen-windows-amd64.exe"
$outFile = Join-Path $env:USERPROFILE "Downloads\fen-windows-amd64.exe"

Write-Host "Downloading fen from: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $outFile

Write-Host "`nCalculating SHA256 hash (local)..."
Get-FileHash $outFile -Algorithm SHA256

Write-Host "`nAction required:"
Write-Host "1) Open the GitHub release page for v1.7.24"
Write-Host "2) Compare the SHA256 shown there with the hash printed above"
Write-Host "3) Only proceed if it matches 100%."
