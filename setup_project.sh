#!/bin/bash

# ---- Setup Trap for Ctrl+C ----
cleanup() {
    echo -e "\nInterrupt detected! Archiving incomplete project..."
    tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR" 2>/dev/null
    rm -rf "$PROJECT_DIR"
    echo "Archive created: ${PROJECT_DIR}_archive.tar.gz"
    exit 1
}
trap cleanup SIGINT

# ---- Prompt for Project Name ----
read -p "Enter project identifier: " INPUT
PROJECT_DIR="attendance_tracker_$INPUT"

# ---- Check if Directory Already Exists ----
if [ -d "$PROJECT_DIR" ]; then
    echo "Directory $PROJECT_DIR already exists. Exiting."
    exit 1
fi

# ---- Create Directory Structure ----
mkdir -p "$PROJECT_DIR"/{Helpers,reports}
touch "$PROJECT_DIR/attendance_checker.py"
touch "$PROJECT_DIR/Helpers/assets.csv"
touch "$PROJECT_DIR/Helpers/config.json"
touch "$PROJECT_DIR/reports/reports.log"

echo "Project structure created."

# ---- Environment Validation ----
if command -v python3 >/dev/null 2>&1; then
    echo "Python3 is installed: $(python3 --version)"
else
    echo "WARNING: Python3 not found! Please install it."
fi

# ---- Configure Thresholds ----
read -p "Do you want to update attendance thresholds? (y/n) " UPDATE
if [[ "$UPDATE" == "y" || "$UPDATE" == "Y" ]]; then
    read -p "Enter Warning threshold (default 75): " WARN
    read -p "Enter Failure threshold (default 50): " FAIL

    WARN=${WARN:-75}
    FAIL=${FAIL:-50}

    # Validate numeric input
    if ! [[ "$WARN" =~ ^[0-9]+$ && "$FAIL" =~ ^[0-9]+$ ]]; then
        echo "Invalid input! Using default thresholds."
        WARN=75
        FAIL=50
    fi

    cat > "$PROJECT_DIR/Helpers/config.json" <<EOF
{
    "thresholds": {
        "warning": $WARN,
        "failure": $FAIL
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
else
    # Write default config if not updated
    cat > "$PROJECT_DIR/Helpers/config.json" <<EOF
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
fi

echo "Setup complete!"

