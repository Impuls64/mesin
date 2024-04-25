#!/usr/bin/env python3

import os
import subprocess
from datetime import datetime

log_dir = os.path.join(os.getcwd(), "mesin")
console_log = os.path.join(log_dir, "console.log")
os.makedirs(log_dir, exist_ok=True)

def timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def update_progress(flag, script, status):
    if not os.path.exists(console_log):
        open(console_log, 'a').close()

    with open(console_log, 'r') as file:
        lines = file.readlines()

    with open(console_log, 'w') as file:
        found = False
        for line in lines:
            if line.startswith(f"{flag}:{script}"):
                file.write(f"{flag}:{script}:{status}\n")
                found = True
            else:
                file.write(line)
        if not found:
            file.write(f"{flag}:{script}:{status}\n")

def execute_script(flag, script_name):
    script_type = script_name.split('.')[-1]
    script_dir = ""

    if script_type == "sh":
        script_dir = "bash-scripts"
    elif script_type == "py":
        script_dir = "python-scripts"
    else:
        print(f"Unsupported script type: {script_type}")
        return False

    script_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), script_dir, script_name)

    if os.path.exists(script_path):
        try:
            if script_type == "sh":
                subprocess.run(["bash", script_path], check=True)
                update_progress(flag, script_name, "done")
                return True
            elif script_type == "py":
                subprocess.run(["python3", script_path], check=True)
                update_progress(flag, script_name, "done")
                return True
        except subprocess.CalledProcessError as e:
            if e.returncode == 1:
                update_progress(flag, script_name, "not done")
            else:
                update_progress(flag, script_name, "failed")
            return False
    else:
        print(f"Script {script_path} does not exist")
        update_progress(flag, script_name, "not found")
        return False

def prepare_script_list(flag):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    flag_file = os.path.join(script_dir, "case-list", flag)

    if not os.path.exists(console_log):
        open(console_log, 'a').close()

    with open(flag_file, 'r') as file:
        for script_name in file:
            script_name = script_name.strip()
            with open(console_log, 'r') as log:
                if f"{flag}:{script_name}" not in log.read():
                    update_progress(flag, script_name, "not done")

flag = "mesin"  # You can change this to the desired flag value

prepare_script_list(flag)

with open(console_log, 'r') as file:
    for line in file:
        if line.startswith(flag):
            _, script, status = line.strip().split(':')
            if status != "done" and script != "":
                if not execute_script(flag, script):
                    print(f"Error occurred while executing script {script}")
                    exit(1)

with open(console_log, 'r+') as file:
    lines = file.readlines()
    file.seek(0)
    file.write(f"{timestamp()}: Updated flag '{flag}'\n")
    file.writelines(lines[1:])