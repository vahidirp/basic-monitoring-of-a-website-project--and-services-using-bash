#!/bin/bash

# List of services to monitor
services=("service1" "service2" "service3") #for example  "nginx" "mysql" "zabbix-agent"

# Email address to send notifications
recipient_email="your@email.com" #change this variables 

# Function to check and restart services
check_and_restart_service() {
    local service_name="$1"
    local service_status=$(systemctl is-active "$service_name")

    if [ "$service_status" != "active" ]; then
        # Service is down, attempt to restart
        systemctl restart "$service_name"
        if [ $? -eq 0 ]; then
            # Service was successfully restarted
            echo "Service $service_name was unavailable and has been restarted. Sending email notification..."
            echo "Service $service_name was unavailable and has been restarted." | mail -s "Service $service_name is Restarted. Please check the reason as soon as you can!" "$recipient_email"
        else
            # Service restart failed, notify with error message
            echo "Service $service_name is unavailable, and an error occurred while trying to restart it. Sending email notification..."
            echo "Service $service_name is unavailable, and an error occurred while trying to restart it." | mail -s "Service $service_name is unavailable and Restart Error Please check service as soon as you can!" "$recipient_email"
        fi
    fi
}

# Loop to check services every 30 minutes
while true; do
    for service in "${services[@]}"; do
        check_and_restart_service "$service"
    done

    # Sleep for 30 minutes (1800 seconds) 
    sleep 1800 # this is time interval and you can convert minute to second and change this variables.
done
