<#
.SYNOPSIS
  Installs fen to Program Files and applies hardened ACL permissions.

.DESCRIPTION
  Moves the verified fen executable into C:\Program Files\fen\fen.exe and applies
  strict, language-independent ACLs using SIDs:
    - SYSTEM: Full control
    - Administrators: Full control
    - Users: Read/Execute

  Inheritance is removed to avoid unexpected permissions.

.PREREQUISITES
  - Run PowerShell as Administrator
  - The file fen-windows-amd64.exe must exist in the user's Downloads folder

.SECURITY NOTES
  - Least privilege: standard users can execute but not modify program files.
  - SID-based ACLs work across Windows language/localization differences.

.ROLLBACK
  - Remove C:\Program Files\fen (requires admin)
  - Remove firewall rule if added later (scripts/03)

.EXAMPLE
  PS> Start PowerShell as Administrator
  PS> .\scripts\02-install-and-acl.ps1
#>

$installDir = "C:\Program Files\fen"
$sourceExe  = Join-Path $env:USERPROFILE "Downloads\fen-windows-amd64.exe"
$targetExe  = Join-Path $installDir "fen.exe"

if (-not (Test-Path $sourceExe)) {
    Write-Error "Source file not found: $sourceExe"
    Write-Error "Run scripts/01-download-and-verify.ps1 first."
    exit 1
}

New-Item -ItemType Directory -Force $installDir | Out-Null
Move-Item $sourceExe $targetExe -Force

# Remove inherited permissions
icacls $installDir /inheritance:r | Out-Null

# Apply hardened ACLs (SID-based and language independent)
# S-1-5-18         = SYSTEM
# S-1-5-32-544     = Administrators
# S-1-5-32-545     = Users
icacls $installDir /grant `
  "*S-1-5-18:(OI)(CI)F" `
  "*S-1-5-32-544:(OI)(CI)F" `
  "*S-1-5-32-545:(OI)(CI)RX" | Out-Null

Write-Host "fen installed to: $targetExe"
Write-Host "ACL hardening applied to: $installDir"
