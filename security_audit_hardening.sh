#!/bin/bash

# Function to perform user and group audits
user_group_audit() {
    echo "==== User and Group Audit ===="
    echo "Listing all users:"
    awk -F':' '{ print $1 }' /etc/passwd
    echo ""

    echo "Listing all groups:"
    awk -F':' '{ print $1 }' /etc/group
    echo ""

    echo "Checking for users with UID 0 (root privileges):"
    awk -F: '($3 == 0) {print $1}' /etc/passwd
    echo ""

    echo "Checking for users without passwords:"
    awk -F: '($2 == "" ) { print $1 " has no password." }' /etc/shadow
    echo ""

    echo "Checking for weak passwords (length < 8):"
    awk -F: '($2 != "" && length($2) < 8) {print $1 " has a weak password."}' /etc/shadow
    echo ""
}

# Function to audit file and directory permissions
file_permissions_audit() {
    echo "==== File and Directory Permissions Audit ===="
    echo "Scanning for world-writable files and directories:"
    find / -xdev -type d -perm -0002 -exec ls -ld {} \;
    find / -xdev -type f -perm -0002 -exec ls -l {} \;
    echo ""

    echo "Checking .ssh directories for secure permissions:"
    find /home -name ".ssh" -exec ls -ld {} \; -exec stat -c "%a %n" {} \;
    echo ""

    echo "Checking for files with SUID or SGID bits set:"
    find / -perm /6000 -type f -exec ls -l {} \;
    echo ""
}

# Function to audit running services
service_audit() {
    echo "==== Service Audit ===="
    echo "Listing all running services:"
    systemctl list-units --type=service --state=running
    echo ""

    echo "Checking for critical services:"
    services=("sshd" "iptables")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            echo "$service is running"
        else
            echo "$service is NOT running"
        fi
    done
    echo ""

    echo "Checking for services listening on non-standard or insecure ports:"
    netstat -tuln | grep -vE "(:22|:80|:443|:53|:3306)"
    echo ""
}

# Function to audit firewall and network security
firewall_network_security() {
    echo "==== Firewall and Network Security Audit ===="
    echo "Checking if firewall is active:"
    if systemctl is-active --quiet iptables || systemctl is-active --quiet ufw; then
        echo "Firewall is active"
    else
        echo "Firewall is NOT active"
    fi
    echo ""

    echo "Listing open ports and associated services:"
    netstat -tuln
    echo ""

    echo "Checking for IP forwarding:"
    if [ "$(sysctl net.ipv4.ip_forward | awk '{print $3}')" -eq 0 ]; then
        echo "IPv4 forwarding is disabled"
    else
        echo "IPv4 forwarding is enabled"
    fi

    if [ "$(sysctl net.ipv6.conf.all.forwarding | awk '{print $3}')" -eq 0 ]; then
        echo "IPv6 forwarding is disabled"
    else
        echo "IPv6 forwarding is enabled"
    fi
    echo ""
}

# Function to check IP and network configurations
ip_network_configuration() {
    echo "==== IP and Network Configuration Checks ===="
    echo "Public vs. Private IP Checks:"
    ip -o -4 addr show | awk '/scope global/ {print $2, $4 " (public)"}'
    ip -o -4 addr show | awk '/scope link/ {print $2, $4 " (private)"}'
    echo ""

    echo "Ensuring SSH is not exposed on public IPs unless required:"
    if grep -i "ListenAddress" /etc/ssh/sshd_config | grep -q "0.0.0.0"; then
        echo "SSH is listening on all interfaces (including public IPs)"
    else
        echo "SSH is restricted to specific IPs"
    fi
    echo ""
}

# Function to check for security updates and patching
security_updates_patch() {
    echo "==== Security Updates and Patching ===="
    echo "Checking for available security updates:"
    apt-get update >/dev/null
    apt-get --just-print upgrade | grep -i "security"
    echo ""

    echo "Ensuring automatic updates are configured:"
    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
        echo "Automatic updates are configured"
    else
        echo "Automatic updates are NOT configured"
    fi
    echo ""
}

# Function to monitor logs for suspicious activity
log_monitoring() {
    echo "==== Log Monitoring ===="
    echo "Checking for suspicious log entries (e.g., too many SSH login attempts):"
    grep "Failed password" /var/log/auth.log | tail -n 10
    echo ""
}

# Function to harden the server
server_hardening() {
    echo "==== Server Hardening Steps ===="
    
    echo "Configuring SSH for key-based authentication:"
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "SSH configured for key-based authentication and root login restricted."
    echo ""

    echo "Disabling IPv6 if not required:"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    echo "IPv6 disabled."
    echo ""

    echo "Setting GRUB bootloader password:"
    if ! grep -q "^GRUB_PASSWORD=" /etc/grub.d/40_custom; then
        grub-mkpasswd-pbkdf2 | tee -a /etc/grub.d/40_custom
        echo 'set superusers="root"' >> /etc/grub.d/40_custom
        echo 'password_pbkdf2 root '$(grub-mkpasswd-pbkdf2)'' >> /etc/grub.d/40_custom
        update-grub
        echo "GRUB bootloader password set."
    else
        echo "GRUB bootloader password already set."
    fi
    echo ""

    echo "Configuring firewall rules:"
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    echo "Firewall rules configured."
    echo ""

    echo "Configuring automatic updates:"
    apt-get install unattended-upgrades -y
    dpkg-reconfigure unattended-upgrades
    echo "Automatic updates configured."
    echo ""
}

# Function to run custom security checks
custom_security_checks() {
    echo "==== Custom Security Checks ===="
    if [ -f ./custom_checks.conf ]; then
        source ./custom_checks.conf
    else
        echo "No custom security checks found."
    fi
    echo ""
}

# Function to generate a comprehensive report
generate_report() {
    echo "==== Generating Security Audit and Hardening Report ===="
    report_file="security_audit_report_$(date +'%Y%m%d').txt"
    exec > >(tee -a $report_file)
    exec 2>&1

    user_group_audit
    file_permissions_audit
    service_audit
    firewall_network_security
    ip_network_configuration
    security_updates_patch
    log_monitoring
    custom_security_checks

    echo "Security audit completed. Report saved to $report_file"
}

# Command-line interface for the script
case "$1" in
    -audit)
        generate_report
        ;;
    -harden)
        server_hardening
        ;;
    -all)
        generate_report
        server_hardening
        ;;
    *)
        echo "Usage: $0 {-audit|-harden|-all}"
        ;;
esac
