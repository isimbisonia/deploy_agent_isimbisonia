#!/bin/bash

T="templates"
PROJECT_DIR=""

interrupted() {
    echo ""
    echo "THE DEPLOYMENT WAS INTERRUPTED."
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        zip -rq "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR"
        rm -rf "$PROJECT_DIR"
        echo "I saved the file ${PROJECT_DIR}_archive.zip and removed the incomplete folder"
    fi
    exit 1
}

create_project() {
    PROJECT_DIR=""

    if python3 --version; then
        echo "python3 is installed."
    else
        echo "ERROR: python3 is not installed"
        return 1
    fi

    if command -v zip; then
        echo "zip is installed."
    else
        echo "ERROR: zip is not installed"
        return 1
    fi

    read -p "Project name: " n
    if [ -z "$n" ]; then
        echo "ERROR: project name cannot be empty"
        return 1
    fi
    dir="attendance_tracker_$n"

    read -p "Roster: 1) copy from template, 2) generate new: " r
    read -p "How many students (1-10)? " c

    if [ "$r" != 1 ] && [ "$r" != 2 ]; then
        echo "ERROR: choose 1 or 2"
        return 1
    fi
    if ! [[ "$c" =~ ^[0-9]+$ ]] || [ "$c" -lt 1 ] || [ "$c" -gt 10 ]; then
        echo "ERROR: enter a number from 1 to 10"
        return 1
    fi

    if [ -d "$dir" ]; then
        read -p "$dir already exists. Overwrite? (y/n): " a
        if [ "$a" != "y" ]; then
            echo "Aborted, nothing was changed"
            return 1
        fi
        rm -rf "$dir"
    fi

    PROJECT_DIR="$dir"
    mkdir -p "$dir/Helpers" "$dir/reports" &&
    cp "$T/attendance_checker.py" "$dir/" &&
    cp "$T/config.json" "$dir/Helpers/" || { echo "ERROR: could not create files (permissions?)"; return 1; }

    if [ "$r" = 1 ]; then
        head -n $((c + 1)) "$T/assets.csv" > "$dir/Helpers/assets.csv"
    else
        names=("Amina eve" "Brian Mugisha" "Mutesi Francine" "David Manzi" "Nkusi Linda" "sonia isimbi" "Grace iku" "Henry Habimana" "Ivy Iris" "James Kabarebe")
        emails=(amina@example.com brian@example.com mutesi@example.com david@example.com nkusi@example.com sonia@example.com grace@example.com henry@example.com ivy@example.com james@example.com)
        echo "Email,Names,Attendance Count,Absence Count" > "$dir/Helpers/assets.csv"
        for ((i = 0; i < c; i++)); do
            echo "${emails[i]},${names[i]},0,0" >> "$dir/Helpers/assets.csv"
        done
        sed -i 's/"total_sessions": *[0-9]*/"total_sessions": 1/' "$dir/Helpers/config.json"
    fi

    chmod +x "$dir/attendance_checker.py" && chmod 600 "$dir/Helpers/config.json" || { echo "ERROR: chmod failed"; return 1; }
    echo "Permissions set:"
    ls -l "$dir/attendance_checker.py" "$dir/Helpers/config.json"

    # Thresholds
    read -p "Update thresholds? (y/n): " u
    if [ "$u" = y ]; then
        read -p "Warning threshold [75]: " w
        w=${w:-75}
        read -p "Failure threshold [50]: " f
        f=${f:-50}
        if [[ $w =~ ^[0-9]+$ && $f =~ ^[0-9]+$ ]] && [ "$w" -le 100 ] && [ "$f" -lt "$w" ]; then
            sed -i "s/\"warning\": *[0-9]*/\"warning\": $w/; s/\"failure\": *[0-9]*/\"failure\": $f/" "$dir/Helpers/config.json"
            echo "Thresholds updated: warning=$w failure=$f"
        else
            echo "Invalid values (need numbers, failure < warning <= 100). Keeping defaults."
        fi
    fi
    return 0
}

start_app() {
    (cd "$1" && python3 attendance_checker.py)
}

ask_dir() {
    read -p "Project name: " n
    dir="attendance_tracker_$n"
    [ ! -d "$dir" ] && echo "Project $dir not found." && return 1
    return 0
}

deploy_project() {
    trap interrupted INT TSTP
    if create_project; then
        trap - INT TSTP
        echo "Deployed. Verifying by starting the app..."
        start_app "$PROJECT_DIR"
    fi
    trap - INT TSTP
}

run_project() {
    ask_dir && start_app "$dir"
}

archive_logs() {
    ask_dir || return 1
    ts=$(date +%Y%m%d_%H%M%S)
    mkdir -p "$dir/archives/attendance" "$dir/archives/absent"
    for log in attendance absent; do
        if [ -f "$dir/reports/$log.log" ]; then
            cp "$dir/reports/$log.log" "$dir/archives/$log/${log}_$ts.log" &&
            echo "Archived: $dir/archives/$log/${log}_$ts.log"
        else
            echo "No $log.log found, skipped."
        fi
    done
}

while true; do
    echo ""
    echo "=== ATTENDANCE TRACKER - DEPLOY AGENT ==="
    echo "1) Deploy the application"
    echo "2) Run the application"
    echo "3) Archive the log files"
    echo "4) Exit"
    read -p "Choose an option [1-4]: " choice
    case $choice in
        1) deploy_project ;;
        2) run_project ;;
        3) archive_logs ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
