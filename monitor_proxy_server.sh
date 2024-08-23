#!/bin/bash

# Function to display top 10 most used applications by CPU and memory
top_apps() {
    echo "Top 10 Applications by CPU Usage:"
    ps aux --sort=-%cpu | head -n 11
    
    echo ""
    
    echo "Top 10 Applications by Memory Usage:"
    ps aux --sort=-%mem | head -n 11
}

# Function to monitor network activity
network_monitor() {
    echo "Concurrent Connections:"
    ss -s
    
    echo ""
    
    echo "Network Traffic (in MB):"
    ifconfig | grep 'RX packets\|TX packets\|RX bytes\|TX bytes'
}

# Function to display disk usage
disk_usage() {
    echo "Disk Usage:"
    df -h | awk '$5 > 20 {print $0}'
}

# Function to display system load and CPU usage
system_load() {
    echo "System Load Average:"
    uptime
    
    echo ""
    
    echo "CPU Usage Breakdown:"
    mpstat
}

# Function to display memory usage
memory_usage() {
    echo "Memory Usage:"
    free -m
    
    echo ""
    
    echo "Swap Memory Usage:"
    free -m | grep "Swap"
}

# Function to monitor processes
process_monitor() {
    echo "Number of Active Processes:"
    ps aux | wc -l
    
    echo ""
    
    echo "Top 5 Processes by CPU Usage:"
    ps aux --sort=-%cpu | head -n 6
    
    echo ""
    
    echo "Top 5 Processes by Memory Usage:"
    ps aux --sort=-%mem | head -n 6
}

# Function to monitor essential services
service_monitor() {
    services=(sshd nginx iptables)
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            echo "$service is running."
        else
            echo "$service is not running."
        fi
    done
}

# Custom dashboard based on command-line switches
case "$1" in
    -cpu)
        top_apps
        ;;
    -network)
        network_monitor
        ;;
    -disk)
        disk_usage
        ;;
    -load)
        system_load
        ;;
    -memory)
        memory_usage
        ;;
    -process)
        process_monitor
        ;;
    -services)
        service_monitor
        ;;
    -all)
        top_apps
        network_monitor
        disk_usage
        system_load
        memory_usage
        process_monitor
        service_monitor
        ;;
    *)
        echo "Usage: $0 {-cpu|-network|-disk|-load|-memory|-process|-services|-all}"
        ;;
esac

