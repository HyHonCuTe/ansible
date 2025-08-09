
---

````markdown
# Ansible Automation Project

## 📌 Giới thiệu
Dự án này sử dụng **Ansible** để tự động hóa việc cấu hình và quản trị hệ thống.  
Bao gồm các playbook và role để triển khai, cấu hình, sao lưu, bảo mật và giám sát nhiều dịch vụ như cơ sở dữ liệu, DHCP, DNS, Firewall, Web Server, Suricata, quản lý người dùng, vá lỗi hệ thống, v.v.

---

## ⚙️ Chức năng chính

- **Backup**: Sao lưu và phục hồi dữ liệu cho Linux và SQL Server.
- **Common**: Các tác vụ chung như kiểm tra kết nối.
- **Database**: Cài đặt SQL Server, tạo cơ sở dữ liệu, cấu hình ban đầu.
- **DHCP**: Cài đặt và cấu hình dịch vụ DHCP, bao gồm failover, chính sách, bảo mật.
- **DNS**: Cài đặt và cấu hình DNS Server, tạo các zone, flush cache.
- **Firewall**: Cấu hình tường lửa (Firewalld) để bảo vệ hệ thống.
- **Patching**: Cập nhật và vá bảo mật cho Linux và Windows.
- **Suricata**: Cài đặt và cấu hình IDS Suricata.
- **User**: Quản lý người dùng và quyền truy cập.
- **Webserver**: Triển khai Web Server (IIS, HTML site, ứng dụng zip).
- **Security & Threat Detection**: Tích hợp script Python để phát hiện mối đe dọa qua Suricata log và VirusTotal API.

---

## 📂 Cấu trúc thư mục

```plaintext
.
├── ansible.cfg                 # Cấu hình Ansible
├── README.md                   # Tài liệu dự án
├── .vscode/                    # Cấu hình VS Code
│   └── settings.json
├── host_vars/                  # Biến dành cho từng host
│   └── vars.yml
├── inventory/                  # Danh sách host
│   └── hosts.yml
├── log/
│   └── ansible_backup.log      # Log sao lưu
├── playbooks/                  # Playbooks chính
│   ├── patching.yml
│   └── site.yml
├── py_script/                  # Script Python hỗ trợ
│   ├── detect_threats_vt.py
│   └── get_suricata_logs.py
└── roles/                      # Các role của Ansible
    ├── backup/                 # Role sao lưu và phục hồi
    ├── common/                 # Tác vụ chung
    ├── database/               # Triển khai SQL Server
    ├── dhcp/                    # Cấu hình DHCP
    ├── dns/                     # Cấu hình DNS
    ├── firewall/                # Cấu hình tường lửa
    ├── patching/                # Vá lỗi hệ thống
    ├── suricata/                # Cài đặt Suricata IDS
    ├── user/                    # Quản lý người dùng
    └── webserver/               # Triển khai web server
````

---

## 🚀 Cách sử dụng

1. **Cài đặt Ansible** trên máy điều khiển.
2. **Cập nhật file `inventory/hosts.yml`** với thông tin máy đích.
3. **Chạy playbook**:

   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/site.yml
   ```
4. **Chạy playbook vá lỗi**:

   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/patching.yml
   ```

---

## 📜 Ghi chú

* Thư mục `py_script/` chứa các script Python có thể chạy độc lập hoặc tích hợp vào playbook.
* Log sao lưu được lưu trong `log/ansible_backup.log`.
* Mỗi role có thể tái sử dụng cho nhiều môi trường khác nhau bằng cách thay đổi biến trong `vars/`.

---

## 👨‍💻 Tác giả

**Võ Đào Huy Hoàng**
Tự động hóa hạ tầng bằng Ansible

