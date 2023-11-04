#!/bin/bash

projectURL="http://your-web-project-url" # Replace with your website project's URL
emailRecipient="your@email.com" # Replace with the recipient's email address
interval=300 # Monitoring interval in seconds (e.g., 300 seconds = 5 minutes)

while true; do
  # Measure ping time
  ping_result=$(ping -c 3 "$projectURL")
  ping_time=$(echo "$ping_result" | tail -n 1 | awk '{print $4}' | cut -d '/' -f 2)

  # Measure load time using curl
  load_time=$(curl -o /dev/null -s -w '%{time_total}\n' "$projectURL")

  status_code=$(curl -Is "$projectURL" | head -n 1 | cut -d ' ' -f 2)

  if [ "$status_code" = "200" ]; then
    # Project is up
    echo "Project is up."
  else
    # Project is down
    echo "Project is down. Sending email notification."
    email_subject="Project Down Notification"
    email_body="The project is down.\nPing: ${ping_time}ms\nLoad Time: ${load_time} seconds\nPlease investigate."

    echo -e "$email_body" | mail -s "$email_subject" "$emailRecipient"
  fi

  sleep $interval
done
