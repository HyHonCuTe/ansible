import paramiko
import json
import os
import requests
from datetime import datetime

# Cấu hình máy Suricata 
SURICATA_SERVER = "192.168.193.200"
USERNAME = "suricata"
LOG_PATH = "/var/log/suricata/eve.json"

# Cấu hình nơi lưu log trên máy server
LOCAL_LOG_FILE = "/home/server_ansible/ansible/Log/suricata_alerts.log"

# Cấu hình VirusTotal API
VIRUSTOTAL_API_KEY = "4eebc9c9602ce2189d0aab06e973b9d5b4dc4cdd9fa1e4fb901de12e186a6ce3"
VIRUSTOTAL_URL = "https://www.virustotal.com/vtapi/v2/ip-address/report"

# Kiểm tra quyền ghi file log
if not os.access(os.path.dirname(LOCAL_LOG_FILE), os.W_OK):
    print(f"⚠ Không có quyền ghi vào {LOCAL_LOG_FILE}")
    exit(1)

# Kiểm tra IP trên VirusTotal
def check_ip_virustotal(ip):
    params = {"apikey": VIRUSTOTAL_API_KEY, "ip": ip}
    response = requests.get(VIRUSTOTAL_URL, params=params)
    if response.status_code == 200:
        data = response.json()
        if "detected_urls" in data and len(data["detected_urls"]) > 0:
            return True  # IP có hoạt động độc hại
    return False

# Kết nối SSH để lấy log từ máy Suricata
def get_suricata_logs():
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(SURICATA_SERVER, username=USERNAME)

        # Đọc log mới nhất (50 dòng cuối)
        command = f'tail -n 50 {LOG_PATH}'
        stdin, stdout, stderr = client.exec_command(command)
        logs = stdout.read().decode()

        alerts = []  # Danh sách lưu cảnh báo

        # Phân tích từng dòng log JSON
        for line in logs.split("\n"):
            try:
                data = json.loads(line)
                if data.get("event_type") == "alert":
                    alerts.append(data)
            except json.JSONDecodeError:
                continue  # Bỏ qua dòng lỗi

        client.close()

        # Ghi log vào máy server
        with open(LOCAL_LOG_FILE, "a") as f:
            f.write(f"\n[{now}] 🔍 Kiểm tra Suricata logs...\n")
            
            if alerts:
                for alert in alerts:
                    timestamp = alert.get("timestamp", "Unknown Time")
                    src_ip = alert.get("src_ip", "Unknown IP")
                    dest_ip = alert.get("dest_ip", "Unknown IP")
                    src_port = alert.get("src_port", "Unknown Port")
                    dest_port = alert.get("dest_port", "Unknown Port")
                    signature = alert.get("alert", {}).get("signature", "Unknown Alert")
                    proto = alert.get("proto", "Unknown Protocol")
                    
                    # Kiểm tra địa chỉ IP trên VirusTotal
                    is_malicious = check_ip_virustotal(src_ip)
                    vt_status = "⚠ IP độc hại!" if is_malicious else "✅ IP an toàn"
                    
                    log_entry = (f"[{timestamp}] 🚨 ALERT: {signature} | "
                                 f"Source: {src_ip}:{src_port} -> Destination: {dest_ip}:{dest_port} | "
                                 f"Protocol: {proto} | {vt_status}\n")

                    f.write(log_entry)
                    print(log_entry)

            else:
                f.write(f"[{now}] ✅ Không có cảnh báo nghiêm trọng nào được phát hiện.\n")
                print(f"[{now}] ✅ Không có cảnh báo nghiêm trọng nào được phát hiện.")

    except Exception as e:
        error_msg = f"[{now}] ❌ Lỗi khi kết nối SSH hoặc xử lý log: {e}\n"
        print(error_msg)
        with open(LOCAL_LOG_FILE, "a") as f:
            f.write(error_msg)

# Chạy script
if __name__ == "__main__":
    get_suricata_logs()
