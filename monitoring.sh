#!/bin/bash

projectURL="your-website-project-url" # Replace with your website project's URL (e.g., "example.com")
emailRecipient="your@email.com" # Replace with the recipient's email address
logFile="/path/to/monitoring.log" # Replace with the path to the log file
interval=300 # Monitoring interval in seconds (e.g., 300 seconds = 5 minutes)

# Telegram Configuration
telegram_token="YOUR_TELEGRAM_BOT_TOKEN"
telegram_chat_id="YOUR_TELEGRAM_CHAT_ID"

# Discord Webhook URL
discord_webhook_url="YOUR_DISCORD_WEBHOOK_URL"

while true; do
  # Measure ping time
  ping_result=$(ping -c 3 "$projectURL")
  ping_time=$(echo "$ping_result" | tail -n 1 | awk '{print $4}' | cut -d '/' -f 2)

  # Check port 80 (HTTP)
  nc -z -w 2 "$projectURL" 80
  port_80_status=$?

  # Check port 443 (HTTPS)
  nc -z -w 2 "$projectURL" 443
  port_443_status=$?

  if [ "$port_80_status" -eq 0 ] || [ "$port_443_status" -eq 0 ]; then
    # Project is up
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Project is up. Ping: ${ping_time}ms, Port 80 Status: $port_80_status, Port 443 Status: $port_443_status" >> "$logFile"
  else
    # Project is down
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Project is down. Sending notifications."

    # Send email notification
    email_subject="Project Down Notification"
    email_body="The project is down.\nPing: ${ping_time}ms\nPort 80 Status: $port_80_status\nPort 443 Status: $port_443_status\nPlease investigate."
    echo -e "$email_body" | mail -s "$email_subject" "$emailRecipient"

    # Send Telegram notification
    telegram_message="Project is down.\nPing: ${ping_time}ms\nPort 80 Status: $port_80_status\nPort 443 Status: $port_443_status\nPlease investigate."
    curl -s -X POST "https://api.telegram.org/bot$telegram_token/sendMessage" -d "chat_id=$telegram_chat_id&text=$telegram_message"

    # Send Discord notification
    discord_message="Project is down.\nPing: ${ping_time}ms\nPort 80 Status: $port_80_status\nPort 443 Status: $port_443_status\nPlease investigate."
    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$discord_message\"}" "$discord_webhook_url"
  fi

  sleep $interval
done
