# Patch Management Role

## 📌 Overview

Automated OS patching cho Linux và Windows systems với reboot management.

## 🚀 Quick Start

```bash
# Linux patching
ansible-playbook playbooks/patch_linux.yml

# Windows patching
ansible-playbook playbooks/patch_window.yaml

# Check mode (no changes)
ansible-playbook playbooks/patch_linux.yml --check
```

## ⚙️ Variables

```yaml
# Linux
patching_auto_reboot: no
patching_reboot_timeout: 600
patching_update_cache: yes
patching_exclude_packages: []

# Windows
windows_update_category:
  - SecurityUpdates
  - CriticalUpdates
  - UpdateRollups

windows_auto_reboot: no
```

## 🔧 Operations

```bash
# Check available updates
# Linux:
sudo dnf check-update

# Windows:
Get-WindowsUpdate

# View update history
# Linux:
sudo dnf history

# Windows:
Get-HotFix | Sort-Object -Property InstalledOn -Descending

# Rollback (Linux)
sudo dnf history undo <ID>
```

**Last Updated**: 2025-12-27
