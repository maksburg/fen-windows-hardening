<#
.SYNOPSIS
  Creates a Windows Firewall rule to block outbound traffic for fen.exe.

.DESCRIPTION
  Adds an outbound deny rule for fen.exe across all profiles. This is defense in depth:
  a file manager should not need network access in this lab profile.

.PREREQUISITES
  - Run PowerShell as Administrator
  - fen.exe must be installed at C:\Program Files\fen\fen.exe

.SECURITY NOTES
  - Defense in depth: blocking outbound traffic reduces potential abuse.
  - If a tool does not need network access, do not allow it.

.ROLLBACK
  - Remove the firewall rule:
      Remove-NetFirewallRule -DisplayName "Block fen outbound"

.EXAMPLE
  PS> Start PowerShell as Administrator
  PS> .\scripts\03-firewall.ps1
#>

$exePath = "C:\Program Files\fen\fen.exe"

if (-not (Test-Path $exePath)) {
    Write-Error "fen.exe not found at: $exePath"
    Write-Error "Run scripts/02-install-and-acl.ps1 first."
    exit 1
}

New-NetFirewallRule `
  -DisplayName "Block fen outbound" `
  -Direction Outbound `
  -Program $exePath `
  -Action Block `
  -Profile Any | Out-Null

Write-Host "Firewall rule created: Block fen outbound"
Write-Host "Outbound network access is now blocked for: $exePath"
