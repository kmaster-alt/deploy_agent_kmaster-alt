Deploy Agent - Attendance Tracker

How to Run:
Make the script executable:

chmod +x setup_project.sh
./setup_project.sh

Enter a project suffix (example: v1).
This creates a folder named attendance_tracker_v1.
You will be asked if you want to update attendance thresholds.
Enter y to set custom values or n to keep the defaults (75% warning, 50% failure).

Features:

Automatically creates the required project structure
Generates all necessary files (Python script, config, assets, logs)
Allows custom attendance threshold configuration
Checks that python3 is installed
Handles interruption with a SIGINT trap
Archives and deletes incomplete projects if interrupted

How to Trigger Archive:
While the script is running, press: CTRL + C

The script will:

Create a compressed archive (.tar.gz)
Delete the incomplete directory
Exit safely
