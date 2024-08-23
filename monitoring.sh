#!/bin/bash

# Function to retrieve and display top 10 most used applications
function display_top_apps() {
    top -bn1 | head -n 11 | awk '{print $12, $9, $10}'
}

# Function to monitor network statistics
function monitor_network() {
    ifconfig | grep -E "inet addr:|RX bytes:|TX bytes:" | awk '{print $2, $3, $4}'
}

# Function to monitor disk usage
function monitor_disk_usage() {
    df -h | awk '{print $1, $2, $3, $5}'
}

# Function to monitor system load
function monitor_system_load() {
    uptime | awk '{print $10, $11, $12}'
    top -bn1 | grep "Cpu(s)" | awk '{print $8, $9, $10, $12}'
}

# Function to monitor memory usage
function monitor_memory_usage() {
    free -m | awk 'NR==1 {print "Total", $2, $3, $4, $5, $6}; NR==2 {print "Used", $2, $3, $4, $5, $6}; NR==3 {print "Free", $2, $3, $4, $5, $6}'
}

# Function to monitor process information
function monitor_processes() {
    top -bn1 | head -n 11 | awk '{print $12, $9, $10}'
}

# Function to monitor service status
function monitor_services() {
    systemctl status sshd nginx iptables | awk '{print $1, $2, $3}'
}

# Main function to handle command-line arguments and call the appropriate functions
function main() {
    while getopts ":cpu memory network disk load processes services" opt; do
        case $opt in
            cpu) display_top_apps;;
            memory) monitor_memory_usage;;
            network) monitor_network;;
            disk) monitor_disk_usage;;
            load) monitor_system_load;;
            processes) monitor_processes;;
            services) monitor_services;;
            \?) echo "Invalid option: -$OPTARG";;
        esac
    done

    # If no options are provided, display the entire dashboard
    if [[ $# -eq 0 ]]; then
        display_top_apps
        monitor_network
        monitor_disk_usage
        monitor_system_load
        monitor_memory_usage
        monitor_processes
        monitor_services
    fi
}

main "$@"
