# fen – Windows Hardening Lab

This repository provides a **secure, step-by-step learning lab** for installing and hardening **fen** on Windows using PowerShell.

This is **not** a one-click installer.  
It is a **hands-on security exercise** designed to teach how professional hardening is actually done.

---

## Start here (important for beginners)

This repository is a **learning lab**, not an automated setup tool.

Before running anything:
- Read each script
- Understand what it changes on your system
- Pay attention to which scripts require **Administrator privileges**

You are expected to **think, read, and verify**, not just copy and paste.

---

## How to clone this repository (important for beginners)

Before you can run any scripts, you must first **clone (download) this repository** to your computer.

### Option A: Clone using VS Code (recommended)

This is the easiest and safest option for beginners.

1. Open **Visual Studio Code**
2. Press **Ctrl + Shift + P**
3. Type: `Git: Clone`
4. Paste the repository URL:

https://github.com/maksburg/fen-windows-hardening.git

5. Choose a location (recommended: your user folder)
6. When VS Code asks, click **Open**

You should now see:
- README.md
- scripts/

---

### Option B: Clone using PowerShell (alternative)

1. Open **PowerShell**
2. Go to your user directory:

cd $env:USERPROFILE

3. Clone the repository:

git clone https://github.com/maksburg/fen-windows-hardening.git

4. Enter the repository folder:

cd fen-windows-hardening

5. Verify the contents:

ls

You should see:
- README.md
- scripts/

---

### Authentication note (important)

If you clone the repository using PowerShell, Git may ask for a username and password.

- Username: your **GitHub username**
- Password: **a Personal Access Token (PAT)** — NOT your GitHub password

GitHub no longer allows account passwords for Git operations.

If you clone using **VS Code**, authentication is handled automatically.

---

## What you will learn

By completing this lab, students will practice:

- **Supply-chain verification** (SHA256)
- **Least privilege** (ACL hardening)
- **Defense in depth** (firewall isolation)
- **Safe configuration** (NC-style UI without scripting)
- Realistic **PowerShell-based verification**

---

## How to run the scripts (important for beginners)

All scripts in this lab are run from **PowerShell**.

### Step 1: Open PowerShell

- Press the **Windows key**
- Search for **PowerShell**
- Choose:
  - **Windows PowerShell** (normal user), or
  - **Run as Administrator** (when explicitly required)

### Step 2: Go to the repository folder

Navigate to the repository folder:

cd $env:USERPROFILE\fen-windows-hardening

Verify that you are in the correct folder:

ls

You should see:
- README.md
- scripts/

### Step 3: Run a script

Scripts are executed using this format:

.\scripts\<script-name>.ps1

Example:

.\scripts\01-download-and-verify.ps1

---

## PowerShell execution policy

If PowerShell blocks script execution, you may see an error like:

running scripts is disabled on this system

Temporarily allow scripts **for this session only**:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

This change:
- applies only to the current PowerShell window
- does **not** permanently weaken system security

---

## Student Lab Flow (Windows)

This lab must be completed **in the exact order listed below**.

### Execution order

1. **Download & verify (non-admin)**  
   Run: scripts/01-download-and-verify.ps1  
   Manually compare the printed SHA256 value with the GitHub release page.  
   Do **not** continue if the values do not match exactly.

2. **Install & ACL hardening (admin)**  
   Run PowerShell **as Administrator**  
   Run: scripts/02-install-and-acl.ps1

3. **Network isolation (admin)**  
   Run PowerShell **as Administrator**  
   Run: scripts/03-firewall.ps1

4. **Create safe NC-style configuration (non-admin)**  
   Run: scripts/04-config-nc.ps1

5. **Lock down the configuration directory (non-admin)**  
   Run: scripts/05-lock-config.ps1

---

## What each script does (plain language)

- **01-download-and-verify.ps1**  
  Downloads the fen executable and prints its SHA256 hash.  
  You must manually verify the hash before using the file.

- **02-install-and-acl.ps1** (Administrator required)  
  Installs fen into Program Files and locks file permissions so users cannot modify it.

- **03-firewall.ps1** (Administrator required)  
  Blocks all outbound network traffic for fen as a defense-in-depth measure.

- **04-config-nc.ps1**  
  Creates a safe, minimal configuration with a Norton Commander–style interface.

- **05-lock-config.ps1**  
  Locks the configuration directory so only the current user and SYSTEM can modify it.

---

## Verification and negative tests (important)

Hardening is only correct if it can be **verified**.

### Verify file permissions (ACL)

Run:

icacls "C:\Program Files\fen"

Expected result (language may vary):

- SYSTEM: Full (operating system ownership)
- Administrators: Full (maintenance and updates)
- Users: Read / Execute (can run, cannot modify)

Important:  
This does **not** mean that fen runs with SYSTEM or Administrator privileges.  
fen always runs with the privileges of the user who starts it.

#### Interpreting `icacls` output (ACL notation)

`icacls` uses short flags to describe inheritance and permission levels. You will encounter these during the verification steps:

- `OI` = **Object Inherit** (applies to files inside the folder)
- `CI` = **Container Inherit** (applies to subfolders inside the folder)
- `RX` = **Read & Execute** (read files and run executables)
- `F`  = **Full Control** (read, write, modify, delete, and take ownership)

Example:

```text
BUILTIN\Users:(OI)(CI)(RX)
```

Meaning: **Users can read and execute**, and the permission **inherits to all files and subfolders**.

This is intentional: it allows running `fen` while preventing non-admin users from modifying binaries in `Program Files`.


---

### Negative test: users must NOT be able to write to Program Files

Run the following command as a **normal (non-admin) user**:

New-Item "C:\Program Files\fen\test.txt"

Expected result:

Access to the path is denied.

This failure is **expected** and proves that:
- ACL hardening is active
- Users cannot write to Program Files
- The system is correctly protected

Graphical tools (such as Notepad) may hide this error.  
PowerShell shows the actual access control result.

---

### Verify firewall isolation (defense in depth)

fen does not require network access to function.  
Outbound network traffic is therefore explicitly blocked.

#### Check that the firewall rule exists

Run:

Get-NetFirewallRule -DisplayName "Block fen outbound"

Expected result:
- A rule named **Block fen outbound** exists
- Enabled: True
- Direction: Outbound
- Action: Block

If the rule does not exist, the hardening step was not applied correctly.

---

#### Runtime verification (behavior check)

Start **fen** as a normal user.

Observe that:
- fen starts and functions normally
- no outbound network connections are established

Optional (advanced):  
Use a network monitoring tool (Resource Monitor, TCPView, etc.)  
to confirm that fen does not create outbound connections.

This confirms that:
- firewall rules are enforced at runtime
- network access is blocked regardless of user privileges

---

## Quick verification checklist

After completing the lab:

- fen.exe exists at C:\Program Files\fen\fen.exe
- Users cannot create or modify files in C:\Program Files\fen
- Firewall rule **Block fen outbound** exists and is enabled
- %AppData%\fen\config.lua exists
- Only SYSTEM and the current user can modify %AppData%\fen

---

## Common beginner mistakes

- Skipping SHA256 verification
- Confusing file permissions with runtime privileges
- Running admin scripts without understanding what they do
- Running commands outside the repository folder
- Ignoring error messages instead of reading them

Making mistakes is normal.  
Understanding **why** they happen is the goal.

---

## Notes

- This repository **does not ship binaries**
- All binaries are downloaded directly from the upstream project
- ACL hardening uses **SID-based permissions** for language-independent behavior
- This lab intentionally avoids enabling:
  - Lua scripts
  - shell bindings
  - custom open-handlers

---

## Important mindset

Security work is not about blind automation.

It is about:
- verifying what you install
- understanding what changes
- proving that protections actually work

If a command **fails in the expected way**, security is working.

---

## License

This project is licensed under the MIT License.
See the LICENSE file for details.

---

## Upstream project notice

This repository does **not** contain or replace *fen* itself.

- *fen* is developed and maintained by its original author(s)
- This project provides **Windows hardening, installation, and verification**
  workflows **around** fen
- All fen binaries are downloaded directly from the official upstream releases

For the fen project itself, see the upstream repository:
https://github.com/kivattt/fen


