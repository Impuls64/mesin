#!/bin/bash

for arg in "$@"
do
    if [[ $arg == "-h" || $arg == "--help" ]]; then
        echo "Usage: mesin [fast] [smart] [install] [-h | --help]"
        exit 0
    fi

    if [[ $arg == "install" ]]; then
        ./install-program.sh
        exit 0
    fi
done

if [[ ! -d "temp" ]]; then
    mkdir temp
fi

case_list=("mesin" "mesin-fast" "mesin-smart")
script_log=""

execute_script() {
  script_name=$1
  script_type=${script_name##*.}
  script_dir=""

  if [[ $script_type == "sh" ]]; then
    script_dir="bash-scripts"
  elif [[ $script_type == "py" ]]; then
    script_dir="python-scripts"
  else
    echo "Unsupported script type: $script_type"
    return 1
  fi

  if [[ ! -f "$script_dir/$script_name" ]]; then
    echo "$script_dir/$script_name does not exist"
  else
    if [[ $script_type == "sh" ]]; then
      ./"$script_dir/$script_name"
    elif [[ $script_type == "py" ]]; then
      python3 "$script_dir/$script_name"
    fi
    sed -i "s/$script_name: Not Done/$script_name: Done/g" temp/progress.log
  fi
}

update_progress_log() {
  local case_dir=$1
  # Remove existing entries for this case
  sed -i "/^### $case_dir ###/,/^###/d" temp/progress.log
  # Add new entries for current scripts
  if [[ -f "case-list/$case_dir" ]]; then
    echo "### $case_dir ###" >> temp/progress.log
    while IFS= read -r script; do
      echo "$script: Not Done" >> temp/progress.log
    done < "case-list/$case_dir"
  fi
}

# Initialize or update progress log with all scripts
if [[ -f "temp/progress.log" ]]; then
    for case_dir in "${case_list[@]}"; do
      if [[ -f "case-list/$case_dir" ]]; then
        update_progress_log "$case_dir"
      fi
    done
else
    touch temp/progress.log
    for case_dir in "${case_list[@]}"; do
      if [[ -f "case-list/$case_dir" ]]; then
        echo "### $case_dir ###" >> temp/progress.log
        while IFS= read -r script; do
          echo "$script: Not Done" >> temp/progress.log
        done < "case-list/$case_dir"
      fi
    done
fi

for case_dir in "${case_list[@]}"; do
  if [[ -f "case-list/$case_dir" ]]; then
    echo "### $case_dir ###"
    while IFS= read -r script; do
      flag=$(grep -c -w "$script: Done" "temp/progress.log")
      if [[ $flag -eq 0 ]]; then
        execute_script "$script"
      fi
    done < "case-list/$case_dir"
  fi
done