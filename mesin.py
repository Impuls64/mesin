#!/usr/bin/env python3

import os
import subprocess
import sys
import time
from datetime import datetime

username = os.getenv("USER")

script_path = f"/home/{username}/Downloads/mesin/bash-scripts/banner.sh"
subprocess.call(['bash', script_path])

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

def execute_script(flag, script_name, total_scripts, current_index):
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
            animation_process = subprocess.Popen(["python3", os.path.join(os.path.dirname(os.path.realpath(__file__)), "python-scripts", "mesin-animation.py"), str(current_index), str(total_scripts), script_name]) 
            process = None
            if script_type == "sh":
                process = subprocess.Popen(["bash", script_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            elif script_type == "py":
                process = subprocess.Popen(["python3", script_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            
            while process.poll() is None:
                time.sleep(0.1)
            
            animation_process.terminate()

            stdout, stderr = process.communicate()
            if process.returncode == 0:
                update_progress(flag, script_name, "done")
                return script_name
            else:
                raise subprocess.CalledProcessError(returncode=process.returncode, cmd=script_name, output=stderr)
        except subprocess.CalledProcessError as e:
            update_progress(flag, script_name, e.output.decode().strip() or "failed")
            sys.stdout.write(f"\033[2K\rError occurred while executing script {script_name}: {e.output.decode().strip()}")
            return False
    else:
        print(f"\rScript {script_path} does not exist")
        update_progress(flag, script_name, "not found")
        return False

def prepare_script_list(flag):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    flag_file = os.path.join(script_dir, "case-list", flag)

    if not os.path.exists(console_log):
        open(console_log, 'a').close()

    script_list = []
    with open(flag_file, 'r') as file:
        script_list = [script_name.strip() for script_name in file if script_name.strip()]

    for script_name in script_list:
        update_progress(flag, script_name, "not done")

    return script_list

flag = "mesin"

script_list = prepare_script_list(flag)
total_scripts = len(script_list)
for index, script_name in enumerate(script_list):
    current_script = execute_script(flag, script_name, total_scripts, index)
    if not current_script:
        print(f"Error occurred while executing script {script_name}")
        sys.exit(1)
    if index < total_scripts - 1:
        time.sleep(1)

print("\nAll scripts executed.")