#!/bin/bash

log_dir="temp"
console_log="$log_dir/console.log"
mkdir -p "$log_dir"

timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

update_progress() {
    local flag=$1
    local script=$2
    local status=$3

    if [ ! -f "$console_log" ]; then
        touch "$console_log"
    fi

    if grep -q "^$flag:$script" "$console_log" 2>/dev/null; then
        sed -i "s|^$flag:$script:.*|$flag:$script:$status|" "$console_log"
    else
        echo "$flag:$script:$status" >> "$console_log"
    fi
}


execute_script() {
    local flag=$1
    local script_name=$2
    local script_dir
    local script_type=${script_name##*.}

    case $script_type in
        sh) script_dir="bash-scripts" ;;
        py) script_dir="python-scripts" ;;
        *) echo "Unsupported script type: $script_type"; return 1 ;;
    esac

    if [[ -f "$script_dir/$script_name" ]]; then
        if [[ $script_type == "sh" ]]; then
            (bash "$script_dir/$script_name") && update_progress "$flag" "$script_name" "done"
        elif [[ $script_type == "py" ]]; then
            (python3 "$script_dir/$script_name") && update_progress "$flag" "$script_name" "done"
        fi
    else
        echo "Script $script_dir/$script_name does not exist"
        update_progress "$flag" "$script_name" "not found"
    fi
}

prepare_script_list() {
    local flag=$1
    local flag_file="case-list/$flag"
    local status

    while IFS= read -r script_name; do
        if ! grep -q "^$flag:$script_name" "$console_log"; then
            status="not done"
            echo "$flag:$script_name:$status" >> "$console_log"
        fi
    done < "$flag_file"
}

flag="${1:-mesin}"

if [ ! -f "$console_log" ]; then
    touch "$console_log"
fi

prepare_script_list "$flag"

if [ -f "$console_log" ]; then
    while IFS=: read -r flag script status; do
        if [[ $status != "done" && $script != "" ]]; then
            execute_script "$flag" "$script"
        fi
    done < <(grep "^$flag:" "$console_log")
fi

sed -i "1s/.*/$(timestamp): Updated flag '$flag'/" "$console_log"
