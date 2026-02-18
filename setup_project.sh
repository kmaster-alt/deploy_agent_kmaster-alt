#!/bin/bash

read -p "Enter project name suffix: " input
project="attendance_tracker_${input}"

cleanup() {
    echo "Interrupt detected. Archiving project..."
    [ -d "$project" ] && tar -czf "${project}_archive.tar.gz" "$project" && rm -rf "$project"
    echo "Cleanup complete. Exiting."
    exit 1
}

trap cleanup SIGINT

[ -d "$project" ] && { echo "Error: Directory already exists."; exit 1; }

mkdir -p "$project/Helpers" "$project/reports"

cat > "$project/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log',
                  f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, \
         open('reports/reports.log', 'w') as log:

        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat > "$project/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > "$project/Helpers/config.json" << 'EOF'
{
  "thresholds": {
    "warning": 75,
    "failure": 50
  },
  "run_mode": "live",
  "total_sessions": 15
}
EOF

cat > "$project/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

read -p "Update attendance thresholds? (y/n): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    read -p "Enter Warning threshold (default 75): " warn
    read -p "Enter Failure threshold (default 50): " fail

    warn=${warn:-75}
    fail=${fail:-50}

    [[ "$warn" =~ ^[0-9]+$ ]] && \
    sed -i "s/\"warning\": *[0-9]\+/\"warning\": $warn/" "$project/Helpers/config.json"

    [[ "$fail" =~ ^[0-9]+$ ]] && \
    sed -i "s/\"failure\": *[0-9]\+/\"failure\": $fail/" "$project/Helpers/config.json"
fi

if python3 --version >/dev/null 2>&1; then
    echo "Python3 is installed."
else
    echo "Warning: Python3 is not installed."
fi

echo "Project setup complete."

