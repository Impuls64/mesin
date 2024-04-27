import os
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
import re

working_proxy_file = "/home/bob/Downloads/proxy-list/working_proxies.txt"
base_dir = os.getcwd()
nuclei_list_file = os.path.abspath(os.path.join(base_dir, "../../../Downloads/mesin/python-scripts/nuclei-list.txt"))

run_py_script = os.path.abspath(os.path.join(os.path.dirname(nuclei_list_file), "proxy-create.py"))
subprocess.run(["python3", run_py_script], check=True)

search_words = {
    "sql": (nuclei_list_file, "gf_param/sqli.txt"),
    "xss": (nuclei_list_file, "gf_param/xss.txt"),
    "lfi": (nuclei_list_file, "gf_param/lfi.txt")
}

nuclei_dir = os.path.abspath(os.path.join(base_dir, "..", "nuclei-scan"))
if not os.path.exists(nuclei_dir):
    os.makedirs(nuclei_dir)

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

# Create temporary templates for all search words
template_files = {}
for word, (templates_file_path, list_file_path) in search_words.items():
    if os.path.exists(templates_file_path) and os.path.exists(list_file_path):
        additional_paths = parse_template_paths(templates_file_path, word)
        template_file = os.path.join(nuclei_dir, f"{word}-template.txt")
        with open(template_file, 'w') as f:
            for template_path in additional_paths:
                f.write(template_path + "\n")
        template_files[word] = [template_file]
    else:
        print(f"One or both of the files {templates_file_path} and {list_file_path} do not exist.")

# Run nuclei in separate processes for each search word
futures = []
with ThreadPoolExecutor(max_workers=len(search_words)) as executor:
    for word, templates in template_files.items():
        for template_file in templates:
            cmd = [
                "nuclei", "-list", search_words[word][1], "-t", template_file,
                "-o", os.path.join(nuclei_dir, f"{word}-nuclei-rez.txt"),
                "-proxy", working_proxy_file,
                "-H", "/home/bob/Downloads/user_agents/db-1.csv",
                "-fhr", "-lfa", "-es", "info"
            ]
            futures.append(executor.submit(subprocess.run, cmd, universal_newlines=True))

for future in as_completed(futures):
    try:
        result = future.result()
        print(result.stdout)
    except Exception as e:
        print(f"Error running command: {e}")

# Remove the template files after scanning
for templates in template_files.values():
    for template_file in templates:
        os.remove(template_file)