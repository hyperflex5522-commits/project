#!/bin/bash

# automation_tool.sh - A system automation toolkit

# === Configuration ===
BACKUP_DIR="$HOME/system_backups"
SOFTWARE_LIST=("curl" "git" "vim")
DISK_THRESHOLD=80

# === Helper Functions ===
print_header() {
    echo "======================================="
    echo "     Bash Automation Tool v1.0"
    echo "======================================="
}

pause() {
    read -rp "Press [Enter] to continue..."
}

update_system() {
    echo "[*] Updating system..."
    sudo apt update && sudo apt upgrade -y
    echo "[+] System updated."
    pause
}

install_software() {
    echo "[*] Installing predefined software..."
    for pkg in "${SOFTWARE_LIST[@]}"; do
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
    done
    echo "[+] Software installation complete."
    pause
}

backup_folder() {
    echo "[*] Starting backup..."
    mkdir -p "$BACKUP_DIR"
    read -rp "Enter folder path to backup: " folder
    if [[ -d "$folder" ]]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        tar -czf "$BACKUP_DIR/backup_$timestamp.tar.gz" "$folder"
        echo "[+] Backup saved to $BACKUP_DIR/backup_$timestamp.tar.gz"
    else
        echo "[!] Folder not found."
    fi
    pause
}

manage_logs() {
    echo "[*] Clearing logs older than 7 days..."
    sudo find /var/log -type f -name "*.log" -mtime +7 -exec rm -f {} \;
    echo "[+] Old logs cleared."
    pause
}

check_disk() {
    echo "[*] Checking disk usage..."
    usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Disk Usage: $usage%"
    if (( usage > DISK_THRESHOLD )); then
        echo "[!] Warning: Disk usage exceeds ${DISK_THRESHOLD}%!"
    fi
    pause
}

user_management() {
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. Change User Password"
    read -rp "Choose option: " choice
    case $choice in
        1) read -rp "Enter username: " user; sudo adduser "$user";;
        2) read -rp "Enter username: " user; sudo deluser "$user";;
        3) read -rp "Enter username: " user; sudo passwd "$user";;
        *) echo "Invalid option.";;
    esac
    pause
}

service_management() {
    read -rp "Enter service name (e.g. ssh): " service
    echo "1. Start"
    echo "2. Stop"
    echo "3. Restart"
    echo "4. Status"
    read -rp "Choose option: " opt
    case $opt in
        1) sudo systemctl start "$service";;
        2) sudo systemctl stop "$service";;
        3) sudo systemctl restart "$service";;
        4) sudo systemctl status "$service";;
        *) echo "Invalid option.";;
    esac
    pause
}

setup_cron_job() {
    read -rp "Enter command to run: " cmd
    read -rp "Enter schedule (e.g. '0 5 * * *' for daily at 5AM): " schedule
    (crontab -l; echo "$schedule $cmd") | crontab -
    echo "[+] Cron job added."
    pause
}

network_tools() {
    echo "1. Ping Test"
    echo "2. Show IP Address"
    echo "3. Traceroute"
    read -rp "Choose option: " choice
    case $choice in
        1) read -rp "Enter host to ping: " host; ping -c 4 "$host";;
        2) ip a;;
        3) read -rp "Enter host: " host; traceroute "$host";;
        *) echo "Invalid option.";;
    esac
    pause
}

main_menu() {
    while true; do
        clear
        print_header
        echo "1. Update System"
        echo "2. Install Software"
        echo "3. Backup Folder"
        echo "4. Manage Logs"
        echo "5. Check Disk Usage"
        echo "6. User Management"
        echo "7. Service Management"
        echo "8. Setup Cron Job"
        echo "9. Network Tools"
        echo "0. Exit"
        echo "------------------------------"
        read -rp "Enter your choice: " choice

        case $choice in
            1) update_system;;
            2) install_software;;
            3) backup_folder;;
            4) manage_logs;;
            5) check_disk;;
            6) user_management;;
            7) service_management;;
            8) setup_cron_job;;
            9) network_tools;;
            0) echo "Exiting..."; break;;
            *) echo "Invalid option."; pause;;
        esac
    done
}

# === Start Script ===
main_menu
