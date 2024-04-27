#!/bin/bash

cd mesin || exit 1
current_dir=$(pwd)

check_if_empty() {
    if [ ! -s "$1" ]; then
        return 1
    fi
    return 0
}

printf "\nСобираем поддомены с помощью subfinder..."
if ! check_if_empty "$current_dir/subdomains.txt"; then
    while IFS= read -r domain; do
        printf "Проверяем домен: $domain\n"
        https://crt.sh/?q="$domain"&output=json | jq -r '.[].name_value' | grep --color=auto -Eo '(\w+\.\w+\.\w+)$' | sort -u >> "$current_dir/subdomains.txt"
    done < "$current_dir/domains.txt"
fi

printf "\nСобираем поддомены с помощью sublist3r..."
if ! check_if_empty "$current_dir/subdomains.txt"; then
    cat "$current_dir/domains.txt" | while read domain; do
        sublist3r -d "$domain" >> "$current_dir/subdomains.txt"
    done
fi

printf "\nОбъединяем и удаляем дубликаты:"
sort -u -o "$current_dir/subdomains.txt" "$current_dir/subdomains.txt"

if [ ! -s "$current_dir/subdomains.txt" ]; then
    echo "Команды subfinder, curl и subfinder ничего не нашли"
fi

printf "\nИщем открытые порты с помощью naabu..."
if ! check_if_empty "$current_dir/naabu-full.txt"; then
    sudo naabu -list "$current_dir/subdomains.txt" -c 50 -nmap-cli 'nmap -sV -sC' -o "$current_dir/naabu-full.txt"
fi
if [ ! -s "$current_dir/naabu-full.txt" ]; then
    echo "Команда naabu ничего не нашла"
fi

printf "\nИщем живые поддомены с помощью httpx-toolkit..."
if ! check_if_empty "$current_dir/subdomains_alive.txt"; then
    cat "$current_dir/subdomains.txt" | httpx-toolkit -ports 443,80,8080,8000,8888 -threads 200 > "$current_dir/subdomains_alive.txt"
fi
if [ ! -s "$current_dir/subdomains_alive.txt" ]; then
    echo "Команда httpx-toolkit ничего не нашла"
fi

printf "\nИщем endpoints с помощью dirsearch..."
if ! check_if_empty "$current_dir/endpoints.txt"; then
    dirsearch -l "$current_dir/subdomains_alive.txt" -x 500,502,429,404,400 -R 5 --random-agent -t 100 -F -o "$current_dir/endpoints.txt" -w ~/Downloads/OneListForAll/onelistforallmicro.txt
fi
if [ ! -s "$current_dir/endpoints.txt" ]; then
    echo "Команда dirsearch ничего не нашла"
fi