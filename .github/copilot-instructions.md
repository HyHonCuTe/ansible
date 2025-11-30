**Repository Overview**

- **What:** Ansible automation repo focused on deploying/maintaining Wazuh, monitoring (Prometheus/Grafana/Zabbix), OpenVAS, OpenSCAP, backups, patching and more.
- **Key directories:** `playbooks/` (entry-point playbooks), `roles/` (reusable roles), `inventory/` and `inventory.ini` (hosts), `py_script/` (helper scripts).

**Big Picture / Architecture**

- **Control node:** This repo is designed to run from the Ansible control node (the machine where you run `ansible-playbook`). Playbooks target groups defined in `inventory.ini` or `inventory/hosts.yml`.
- **Server vs Agents:** Server installs (Wazuh Manager + Indexer + Dashboard) are performed via `playbooks/deploy_wazuh_server_official.yml` (downloads and runs Wazuh's official script). Agent installs use `playbooks/deploy_wazuh_agent.yml` and the `roles/wazuh/` role.
- **Roles:** Each service has a dedicated role under `roles/`. Roles contain `tasks/`, `defaults/`, `vars/`, `templates/` and `files/` following standard Ansible layout.

**Project-specific workflows & commands**

- **Check ansible.cfg before running:** `ansible.cfg` sets `inventory=inventory/hosts.yml` and other defaults (fact caching, `roles_path=roles`, `stdout_callback=yaml`). Examples in docs use `inventory.ini` — prefer explicit `-i` if you want to follow README examples.
- **Recommended Server deploy (official):**
  - `ansible-playbook -i inventory.ini playbooks/deploy_wazuh_server_official.yml`
  - This playbook downloads `wazuh-install.sh`, runs it, checks services, saves credentials to `./wazuh-credentials-<hostname>.txt` on the control node.
- **Deploy agents:** `ansible-playbook -i inventory.ini playbooks/deploy_wazuh_agent.yml` (supports `--limit linux_agents` / `windows_agents`).
- **Cleanup before re-install:** `ansible-playbook -i inventory.ini playbooks/cleanup_wazuh_server.yml`
- **Common QA commands:**
  - Connectivity: `ansible all -i inventory.ini -m ping`
  - Syntax check: `ansible-playbook --syntax-check playbooks/<playbook>.yml`
  - Verbose troubleshooting: add `-vvv` to `ansible-playbook`.

**Important conventions & gotchas**

- **Two inventory patterns:** README and quickstart use `inventory.ini` while `ansible.cfg` points to `inventory/hosts.yml`. Always confirm which inventory the user expects; prefer `-i inventory.ini` when following README examples.
- **Preferred playbook:** `deploy_wazuh_server_official.yml` is the recommended/“new” path; `deploy_wazuh_server.yml` is deprecated — don't introduce changes that re-enable the old flow without a clear reason.
- **Credentials handling:** The official server playbook fetches credentials to `./wazuh-credentials-<hostname>.txt` and saves files under the remote `wazuh_install_dir`. Treat these as sensitive (mode `0600`) — avoid committing them.
- **Performance & environment:** `ansible.cfg` sets `forks=5`, `pipelining=True`, fact caching to `/tmp/ansible_facts` and `collections_paths` to `/home/server_ansible/.ansible/collections`. CI or local runs may need adjustments.
- **Windows targets:** Playbooks that target Windows use WinRM. Inventory entries include `ansible_connection=winrm` and `ansible_winrm_server_cert_validation=ignore` in examples. Validate WinRM config before making changes.

**Patterns for code changes**

- **Modify role behavior:** Add variables in `roles/<role>/defaults/main.yml` or `roles/<role>/vars/main.yml` and update `roles/<role>/tasks/main.yml`. Follow existing idempotent module usage (avoid raw shell unless necessary).
- **New tasks:** Prefer built-in modules (e.g., `ansible.builtin.package`, `ansible.posix.firewalld`, `ansible.builtin.systemd`, `ansible.builtin.get_url`) and match the style used in `playbooks/deploy_wazuh_server_official.yml`.
- **Logging & artifacts:** Installation logs and credentials are written under a tmp installation directory (e.g., `/tmp/wazuh-installation`) and fetched to control node. When adding steps that change file locations, update the playbook’s `copy`/`fetch` tasks accordingly.

**Integration points & external dependencies**

- **Wazuh official scripts:** `playbooks/deploy_wazuh_server_official.yml` downloads from `https://packages.wazuh.com/{{ wazuh_version }}/wazuh-install.sh` — network access required.
- **Collections:** `ansible.posix`, `community.general` and standard Ansible modules are used. Ensure `ansible-galaxy collection install` is run when provisioning new control nodes.
- **Python scripts:** `py_script/detect_threats_vt.py` and `py_script/get_suricata_logs.py` are used for threat detection and log parsing; changes to parsing or fields should be coordinated with Suricata/OpenVAS outputs.

**Files to inspect when working on tasks**

- `ansible.cfg` — default inventory, roles path, caching and performance settings.
- `inventory.ini` and `inventory/hosts.yml` — reconcile or use `-i` explicitly.
- `playbooks/deploy_wazuh_server_official.yml` — canonical server deployment flow (script download, install, verify, fetch credentials).
- `playbooks/deploy_wazuh_agent.yml` and `roles/wazuh/` — agent onboarding and role conventions.
- `QUICKSTART.md` / `README.md` — user-facing workflows and troubleshooting commands (follow these when writing user-facing playbook output).

**When making PRs / edits**

- Keep changes small and role-localized (modify a role rather than many playbooks).
- Preserve idempotency and module usage; add `--check`/`--diff` friendly changes when possible.
- Update `README.md` or `QUICKSTART.md` only for user-visible changes; keep operational notes (credentials, ports) accurate.

**If you need clarification**

- Ask which inventory the user wants to use (`inventory.ini` vs `inventory/hosts.yml`) and whether the control node has network access to `packages.wazuh.com`.

---

If you'd like, I can now: (1) commit this file, (2) also add a short CONTRIBUTING section, or (3) merge in any existing internal agent guidance you want preserved. Tell me which next step you prefer.
