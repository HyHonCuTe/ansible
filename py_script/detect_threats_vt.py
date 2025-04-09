#!/usr/bin/env python3
import json
import subprocess
import sys
import requests
import time
import os

INVENTORY_PATH = "/home/server_ansible/ansible/inventory.yml"
PLAYBOOK_PATH = "/home/server_ansible/ansible/patch_security.yml"
VIRUSTOTAL_API_KEY = "4eebc9c9602ce2189d0aab06e973b9d5b4dc4cdd9fa1e4fb901de12e186a6ce3"
VIRUSTOTAL_URL = "https://www.virustotal.com/vtapi/v2/file/report"
TIMESTAMP_FILE = "/tmp/last_suricata_timestamp"

def run_ansible_command(command):
    print(f"Running Ansible command: {command}")
    cmd = ["ansible", "all", "-i", INVENTORY_PATH, "-m", "command", "-a", command]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"Ansible command output: {result.stdout[:100]}...")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running Ansible command '{command}': {e.stderr}")
        return None
    except Exception as e:
        print(f"Unexpected error running Ansible command '{command}': {str(e)}")
        return None

def get_file_hash(file_path):
    print(f"Getting hash for file: {file_path}")
    if file_path == "Unknown path":
        print("Skipping hash calculation for unknown path")
        return "Unknown hash"
    output = run_ansible_command(f"sha256sum {file_path}")
    if output:
        try:
            hash_value = output.split()[0].strip('"')
            print(f"File hash: {hash_value}")
            return hash_value
        except (IndexError, AttributeError):
            print(f"Failed to parse hash for {file_path}")
            return "Unknown hash"
    print(f"No hash returned for {file_path}")
    return "Unknown hash"

def check_virustotal(file_hash):
    print(f"Checking VirusTotal for hash: {file_hash}")
    if file_hash == "Unknown hash":
        return "Không lỗi (không có hash)"
    params = {"apikey": VIRUSTOTAL_API_KEY, "resource": file_hash}
    try:
        response = requests.get(VIRUSTOTAL_URL, params=params, timeout=10)
        if response.status_code == 200:
            result = response.json()
            if result.get("response_code") == 1 and result.get("positives", 0) > 0:
                status = f"Có lỗi (VirusTotal positives: {result['positives']})"
                print(f"VirusTotal result: {status}")
                return status
            print("VirusTotal: No positives detected")
            return "Không lỗi"
        elif response.status_code == 429:
            print(f"Rate limit exceeded for {file_hash}. Waiting...")
            time.sleep(60)
            return "Không lỗi (rate limit)"
        print(f"VirusTotal unexpected response: {response.status_code}")
        return "Không lỗi (lỗi không xác định)"
    except requests.RequestException as e:
        print(f"Network error checking VirusTotal for {file_hash}: {e}")
        return "Không lỗi (lỗi mạng)"

def parse_suricata_log(last_timestamp):
    print(f"Parsing Suricata log with last timestamp: {last_timestamp}")
    output = run_ansible_command("cat /var/log/suricata/eve.json")
    if not output:
        print("No log data received from Suricata.")
        return [], last_timestamp
    suspicious_files = []
    new_timestamp = last_timestamp or "1970-01-01T00:00:00+0000"
    for line in output.splitlines():
        if "{" not in line:
            continue
        try:
            event = json.loads(line.strip('"'))
            if event.get("event_type") == "alert":
                timestamp = event.get("timestamp", "Unknown time")
                if timestamp > new_timestamp:
                    fileinfo = event.get("fileinfo", {})
                    file_path = fileinfo.get("filename", "Unknown path")
                    file_hash = fileinfo.get("sha256", "Unknown hash")
                    src_ip = event.get("src_ip", "Unknown IP")
                    dest_ip = event.get("dest_ip", "Unknown IP")
                    suspicious_files.append({
                        "timestamp": timestamp,
                        "path": file_path,
                        "hash": file_hash,
                        "src_ip": src_ip,
                        "dest_ip": dest_ip
                    })
                    new_timestamp = timestamp
                    print(f"Found alert: {timestamp} - {file_path} - {src_ip} -> {dest_ip}")
        except json.JSONDecodeError as e:
            print(f"JSON decode error: {e} - Line: {line}")
            continue
    print(f"New timestamp: {new_timestamp}, Found {len(suspicious_files)} alerts")
    return suspicious_files, new_timestamp

def run_ansible_playbook(threat_files):
    if not threat_files or not os.path.exists(PLAYBOOK_PATH):
        print(f"No threat files to process or playbook not found at {PLAYBOOK_PATH}")
        return
    extra_vars = {"threat_files": threat_files}
    cmd = ["ansible-playbook", PLAYBOOK_PATH, "-i", INVENTORY_PATH, "--extra-vars", json.dumps(extra_vars)]
    print(f"Running playbook with threat files: {threat_files}")
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("Playbook executed successfully")
    except subprocess.CalledProcessError as e:
        print(f"Playbook error: {e.stderr}")

def main():
    print("Starting script execution")
    last_timestamp = ""
    if os.path.exists(TIMESTAMP_FILE):
        try:
            with open(TIMESTAMP_FILE, "r") as f:
                last_timestamp = f.read().strip()
                print(f"Loaded last timestamp: {last_timestamp}")
        except IOError as e:
            print(f"Error reading timestamp file: {e}")

    suspicious_files, new_timestamp = parse_suricata_log(last_timestamp)
    
    if not suspicious_files:
        print("Không nhận diện thấy file có vấn đề.")
    else:
        print("Có nhận diện thấy file có vấn đề.")
        print("Danh sách các sự kiện mới nhất:")
        threat_files = []
        for file in suspicious_files:
            file_hash = file["hash"] if file["hash"] != "Unknown hash" else get_file_hash(file["path"])
            status = check_virustotal(file_hash)
            print(f"{file['timestamp']} - {file['path']} - {status} - {file['src_ip']} - {file['dest_ip']}")
            if "Có lỗi" in status and file["path"] != "Unknown path":
                threat_files.append(file["path"])
        if threat_files:
            run_ansible_playbook(threat_files)

    try:
        with open(TIMESTAMP_FILE, "w") as f:
            f.write(new_timestamp)
            print(f"Updated timestamp file with: {new_timestamp}")
    except IOError as e:
        print(f"Error writing timestamp file: {e}")
    print("Script execution completed")

if __name__ == "__main__":
    main()
