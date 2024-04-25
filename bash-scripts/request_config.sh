#!/bin/bash

# Считывание настроек из JSON-файла
config_file="config.json"
if [ -f "$config_file" ]; then
    header_http=$(jq -r '.header-http' "$config_file")
    browser_list=$(jq -r '.browser-list[]' "$config_file")
    use_random_ip=$(jq -r '.use-random-ip // "true"' "$config_file")
    mac_address=$(jq -r '.mac-address' "$config_file")
    use_throttling=$(jq -r '.use-throttling // "false"' "$config_file")
else
    echo "Файл конфигурации не найден"
    exit 1
fi

# Генерация случайного IP-адреса
if [ "$use_random_ip" = "true" ]; then
    ip_address=$(shuf -n1 -e 1-255).$(shuf -n1 -e 1-255).$(shuf -n1 -e 1-255).$(shuf -n1 -e 1-255)
else
    ip_address="123.45.67.89"  # статический IP-адрес по умолчанию
fi

# Генерация случайного MAC-адреса
if [ -z "$mac_address" ]; then
    mac_address=$(printf ':%02x' $(shuf -n6 -e 0-255 | tr '\n' ' '))
fi

# Генерация случайного заголовка браузера
browser_header=$(shuf -n1 -e "${browser_list[@]}")

# Добавление настраиваемого заголовка HTTP, если он указан
if [ -n "$header_http" ]; then
    http_header="$header_http: custom-value"
fi

# Ограничение скорости запросов
if [ "$use_throttling" = "true" ]; then
    throttle_cmd="trickle -s -d 10 -u 10"
else
    throttle_cmd=""
fi

# Функция для отправки HTTP-запроса с использованием настроек
function send_request() {
    local url="$1"
    $throttle_cmd curl -s -H "User-Agent: $browser_header" -H "$http_header" --interface "$mac_address" --proxy "http://$ip_address" "$url" "$@"
}