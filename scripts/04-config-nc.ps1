<#
.SYNOPSIS
  Creates a safe NC-style configuration file for fen.

.DESCRIPTION
  Writes a minimal config.lua to %AppData%\fen\config.lua that enables an NC-like
  dual-pane UI layout and safe defaults. This lab profile does not enable scripting
  or custom open-handlers.

.PREREQUISITES
  - No Administrator rights required
  - fen can be installed or not; config is user-scoped

.SECURITY NOTES
  - Configuration is kept "safe": no Lua scripts, no custom command handlers.
  - Keeps hidden files disabled by default for a cleaner student experience.

.ROLLBACK
  - Delete %AppData%\fen\config.lua
  - Or delete the whole %AppData%\fen folder (if not locked down)

.EXAMPLE
  PS> .\scripts\04-config-nc.ps1
#>

$cfgDir  = Join-Path $env:APPDATA "fen"
$cfgFile = Join-Path $cfgDir "config.lua"

New-Item -ItemType Directory -Force $cfgDir | Out-Null

@"
ui = {
  dual_pane = true,
  borders = true,
  status_bar = true,
  show_hidden = false,
  sort = "name",
}

colors = {
  theme = "classic",
}

keys = {
  quit = "q",
  refresh = "r",
}
"@ | Set-Content -Encoding UTF8 $cfgFile

Write-Host "Created safe NC-style config:"
Write-Host "  $cfgFile"
