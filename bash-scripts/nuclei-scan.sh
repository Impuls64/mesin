#!/bin/bash

search_word="sql"

# Создание списка шаблонов
templates_file="templates_to_scan.txt"

> "$templates_file"  # Очистка файла перед использованием

# Поиск и обработка данных
grep "$search_word" "$HOME/Downloads/mesin/python-scripts/nuclei-list.txt" | sed -n 's/.*path:\([^,]*\),.*/\1/p' >> "$templates_file"

# Удаление дубликатов из файла
sort -u "$templates_file" -o "$templates_file"

# Удаление запятых в конце строк, если они есть
sed -i 's/,$//' "$templates_file"

# Клонирование репозитория с прокси
git clone https://github.com/monosans/proxy-list.git "$HOME/Downloads/proxy-list"

# Функция для проверки всех прокси из двух файлов и сохранения только рабочих
check_proxies() {
    local proxy_files=("$HOME/Downloads/proxy-list/proxies/all.txt" "$HOME/Downloads/proxy-list/proxies_anonymous/all.txt")
    local working_proxy_file="$HOME/Downloads/proxy-list/working_proxies.txt"
    > "$working_proxy_file"
    for proxy_file in "${proxy_files[@]}"; do
        while IFS= read -r proxy; do
            if timeout 1 curl -x $proxy -s https://www.google.com > /dev/null; then
                echo $proxy >> "$working_proxy_file"
            else
                echo "Proxy $proxy is dead, skipping..."
            fi
        done < "$proxy_file"
    done
}

# Проверка прокси и обновление списка прокси
check_proxies

# Проверка на наличие шаблонов и их использование
if [ -s "$templates_file" ]; then
    while true; do
        while IFS= read -r template
        do
            # proxy=$(shuf -n 1 "$HOME/Downloads/proxy-list/working_proxies.txt") # Выбор случайного рабочего прокси
            nuclei -list gf_param/sqli.txt -t "$template" -o "../report/$search_word-nuclei-rez.txt" -proxy $HOME/Downloads/proxy-list/working_proxies.txt -v
        done < "$templates_file"
    done
else
    echo "No templates found."
fi