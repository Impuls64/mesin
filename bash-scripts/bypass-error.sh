#!/bin/bash

# Путь к файлам с URL для обхода ошибок 403 и 401
file_403="directory/directory_403.txt"
file_401="directory/directory_401.txt"

# Скрипт для обхода ошибок
bypass_script="../../Downloads/403-bypass.sh"

# Файл для сохранения результатов обхода
output_file="directory/bypass_results.txt"

# Создаем или очищаем файл результатов
> "$output_file"

# Функция для обработки файла
process_file() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        echo "Ошибка: файл $file_path не найден."
        return 1
    fi

    while read -r url; do
        # Вызываем скрипт обхода для каждого URL
        $bypass_script --exploit --url "$url" | tee >(sed 's/\x1b\[[0-9;]*m//g' >> "$output_file")
    done < "$file_path"
}

# Обрабатываем файлы 403 и 401
process_file "$file_403"
process_file "$file_401"

# Проверяем, что файл результатов не пустой
if [ ! -s "$output_file" ]; then
    echo "Ошибка: После попыток обхода в $output_file ничего не найдено."
    exit 1
fi

echo "Обход ошибок выполнен успешно, результаты в $output_file"