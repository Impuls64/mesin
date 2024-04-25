#!/bin/bash

cd mesin
current_dir=$(pwd)

source request_config.sh

subfinder -dL "$current_dir/domains.txt" -all -recursive -o "$current_dir/subdomains.txt"
while IFS= read -r domain; do
    send_request "https://crt.sh/?q=$domain&output=json" | jq -r '.[].name_value' | grep --color=auto -Eo '(\w+\.\w+\.\w+)$'
done < "$current_dir/domains.txt" | sort -u >> "$current_dir/subdomains.txt"
cat "$current_dir/domains.txt" | while read domain; do
    send_request "sublist3r -d $domain" >> "$current_dir/subdomains.txt"
done
cat "$current_dir/domains.txt" | while read domain; do
    send_request "subfinder -d $domain" >> "$current_dir/subdomains.txt"
done
sort -u -o "$current_dir/subdomains.txt" "$current_dir/subdomains.txt"
if [ ! -s "$current_dir/subdomains.txt" ]; then
    echo "Команды subfinder, curl и subfinder ничего не нашли"
    exit 1
fi

sudo send_request "naabu -list $current_dir/subdomains.txt -c 50 -nmap-cli 'nmap -sV -sC' -o $current_dir/naabu-full.txt"
if [ ! -s "$current_dir/naabu-full.txt" ]; then
    echo "Команда naabu ничего не нашла"
    exit 1
fi

cat "$current_dir/subdomains.txt" | send_request "httpx-toolkit -ports 443,80,8080,8000,8888 -threads 200" > "$current_dir/subdomains_alive.txt"
# if [ ! -s "$current_dir/subdomains_alive.txt" ]; then
#     echo "Команда httpx-toolkit ничего не нашла"
#     exit 1
# fi

send_request "dirsearch -l $current_dir/subdomains_alive.txt -x 500,502,429,404,400 -R 5 --random-agent -t 100 -F -o $current_dir/endpoints.txt -w ~/Downloads/OneListForAll/onelistforallmicro.txt"
if [ ! -s "$current_dir/endpoints.txt" ]; then
    echo "Команда dirsearch ничего не нашла"
    exit 1
fi

cat "$current_dir/subdomains_alive.txt" | "gau" > "$current_dir/params.txt"
cat "$current_dir/params.txt" | uro -o "$current_dir/filterparam.txt"
if [ ! -s "$current_dir/filterparam.txt" ]; then
    echo "Команды gau и uro ничего не нашли"
    exit 1
fi
# cat subdomains_alive.txt | gau > params.txt
# cat params.txt | uro -o filterparam.txt
# cat filterparam.txt | grep  ".js$" > jsfiles.txt

# cat subdomains_alive.txt | gau | uro -o filterparam.txt | grep ".js$" > jsfiles.txt

while read url; do
    python3 $HOME/Downloads/secretfinder/SecretFinder.py -i $url -o cli >> "$current_dir/secret.txt";
done < "$current_dir/jsfiles.txt"
if [ ! -s "$current_dir/secret.txt" ]; then
    echo "Команды grep и SecretFinder.py ничего не нашли"
    exit 1
fi
# python3 ~/Downloads/SecretFinder/SecretFinder.py -i jsfiles.txt -o cli >> secret.txt

nuclei -list $current_dir/subdomains_alive.txt -c 70 -rl 200 -fhr -lfa -t ~/Downloads/cent-nuclei-templates/ -o $current_dir/nuclei_rezult.txt -es info
if [ ! -s "$current_dir/nuclei_rezult.txt" ]; then
    echo "Команда nuclei ничего не нашла"
    exit 1
fi

# proxychains xsstrike -u gf_param/xss.txt --data=/usr/share/seclists/Fuzzing/XSS-Fuzzing
#
#while IFS= read -r line; do
#    echo "$line" | katana -passive -pss waybackarchive,commoncrawl,alienvault | uro | gf xss | Gxss -p XSSRef | dalfox pipe
#done < адреса.txt
#
# echo "opensea.io" | katana -passive -pss waybackarchive,commoncrawl,alienvault -f qurl | gf sqli | uro | nuclei -t ~/Downloads/mesin/bash --dast
# cat gf_param/sqli.txt | katana -passive -pss waybackarchive,commoncrawl,alienvault -f qurl | uro | nuclei -t prsnltemplates/bsqli-time-based.yaml --dast
# 
# !!! cat endpoints/all_urls.txt | katana -passive -pss waybackarchive,commoncrawl,alienvault -f qurl | gf sqli | uro | nuclei -t ~/Downloads/mesin/bash-scripts/bsqli-time-based.yaml --dast > 1

# ../../Downloads/dirclean.sh для формирования очищенный адресов
# while read -r line; do ../../Downloads/403-bypass.sh "$line"; done < endpoints/endpoints_403.txt

# Работает - nuclei -list gf_param/sqli.txt -t ~/Downloads/mesin/bash-scripts/bsqli-time-based.yaml --dast