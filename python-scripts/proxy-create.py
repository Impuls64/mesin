import os
import subprocess
import requests
import shutil
from concurrent.futures import ThreadPoolExecutor
import threading

base_dir = os.path.expanduser("~/Downloads")
proxy_dir = os.path.join(base_dir, "proxy-list")
working_proxy_file = os.path.join(proxy_dir, "working_proxies.txt")

if os.path.exists(proxy_dir):
    shutil.rmtree(proxy_dir)
subprocess.run(["git", "clone", "https://github.com/monosans/proxy-list.git", proxy_dir])

def check_proxy(proxy):
    try:
        if requests.get('https://www.google.com', proxies={'http': proxy, 'https': proxy}, timeout=1).status_code == 200:
            with open(working_proxy_file, 'a') as f:
                f.write(proxy + '\n')
    except:
        pass

def check_proxies():
    proxy_files = [os.path.join(proxy_dir, "proxies/all.txt"), os.path.join(proxy_dir, "proxies_anonymous/all.txt")]
    with open(working_proxy_file, 'w') as f:
        pass
    with ThreadPoolExecutor(max_workers=20) as executor:
        for proxy_file in proxy_files:
            with open(proxy_file, 'r') as file:
                proxies = file.readlines()
                executor.map(check_proxy, [proxy.strip() for proxy in proxies])

if __name__ == "__main__":
    lock = threading.Lock()
    check_proxies()