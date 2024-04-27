import os
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
import re
import getpass 

def path(*args):
    return os.path.join(*args)

user_name = getpass.getuser() 
working_proxy_file = os.path.expanduser(f"~/Downloads/proxy-list/working_proxies.txt")
scripts_dir = os.path.expanduser(f"~/Downloads/mesin/python-scripts")
current_dir = os.getcwd()

nuclei_list_file = path(current_dir, "nuclei-list.txt")
run_py_script = path(scripts_dir, "proxy-create.py")

if os.path.exists(run_py_script):
    subprocess.run(["python3", run_py_script], check=True)
else:
    print(f"Error: The file {run_py_script} does not exist.")
    exit(1)

search_words = {
    # "sql": ("sqli.txt", "sql"),
    # "xss": ("xss.txt", "xss"),
    # "lfi": ("lfi.txt", "lfi"),
    "idor": ("idor.txt", "idor"),
    "img": ("img-traversal.txt", "img"),
    "int": ("interestingEXT.txt", ""),
    "intparam": ("interestingparams.txt", ""),
    "intsub": ("interestingsubs.txt", ""),
    "js": ("jsvar.txt", "js"),
    "rce": ("rce.txt", "rce"),
    "redirect": ("redirect.txt", "redirect"),
    "ssrf": ("ssrf.txt", "ssrf"),
    "ssti": ("ssti.txt", "ssti")
}

nuclei_dir = path(current_dir, "nuclei-scan")
os.makedirs(nuclei_dir, exist_ok=True)

def parse_template_paths(file_path, keyword):
    paths = []
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            for line in file:
                if keyword in line:
                    match = re.search(r'path:\s*([^\s,]+)', line)
                    if match:
                        paths.append(match.group(1).strip())
    else:
        print(f"File {file_path} does not exist.")
    return paths

template_files = {}
for key, (filename, word) in search_words.items():
    templates_file_path = nuclei_list_file
    list_file_path = path(current_dir, "gf_param", filename)

    if os.path.exists(templates_file_path) and os.path.exists(list_file_path):
        additional_paths = parse_template_paths(templates_file_path, word)
        template_file = path(nuclei_dir, f"{key}-template.txt")
        with open(template_file, 'w') as f:
            for template_path in additional_paths:
                f.write(template_path + "\n")
        template_files[key] = template_file
    else:
        print(f"One or both of the files {templates_file_path} and {list_file_path} do not exist.")

futures = []
with ThreadPoolExecutor(max_workers=len(search_words)) as executor:
    for key, template_file in template_files.items():
        cmd = [
            "nuclei", "-list", list_file_path, "-t", template_file,
            "-o", path(nuclei_dir, f"{key}-nuclei-results.txt"),
            "-proxy", working_proxy_file,
            "-H", os.path.expanduser("~/Downloads/user_agents/db-1.csv"),
            "-fhr", "-lfa", "-es", "info"
        ]
        futures.append(executor.submit(subprocess.run, cmd, check=True, text=True, capture_output=True))

for future in as_completed(futures):
    try:
        result = future.result()
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}: {e.output}")

for template_file in template_files.values():
    os.remove(template_file)