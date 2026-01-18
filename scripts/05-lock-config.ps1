<#
.SYNOPSIS
  Locks down the fen config directory so only SYSTEM and the current user can modify it.

.DESCRIPTION
  Removes inherited permissions from %AppData%\fen and grants Full Control only to:
    - SYSTEM (SID-based)
    - Current user (resolved via whoami)

  This prevents other local accounts from modifying the configuration.

.PREREQUISITES
  - No Administrator rights required (user-scoped folder)
  - %AppData%\fen must exist

.SECURITY NOTES
  - Hardening configuration reduces tampering risk on shared machines.
  - Uses whoami to avoid hardcoding usernames or machine names in scripts.

.ROLLBACK
  - Re-enable inheritance:
      icacls "%AppData%\fen" /inheritance:e
  - Or remove the directory (if desired)

.EXAMPLE
  PS> .\scripts\05-lock-config.ps1
#>

$cfgDir = Join-Path $env:APPDATA "fen"

if (-not (Test-Path $cfgDir)) {
    Write-Error "Config directory not found: $cfgDir"
    Write-Error "Run scripts/04-config-nc.ps1 first."
    exit 1
}

$currentUser = (whoami)

icacls $cfgDir /inheritance:r | Out-Null
icacls $cfgDir /grant "*S-1-5-18:(OI)(CI)F" "${currentUser}:(OI)(CI)F" | Out-Null

Write-Host "Config directory locked down:"
Write-Host "  $cfgDir"
Write-Host "Allowed: SYSTEM + $currentUser"
