# #!/bin/bash

# # Путь к файлу directory.txt
# input_file="directory.txt"

# # Проверяем, есть ли файл
# if [ ! -f "$input_file" ]; then
#     echo "Файл $input_file не существует."
#     exit 1
# fi

# # Читаем файл и обрабатываем каждую строку
# while read -r line; do
#     # Получаем номер, который идет первым в строке и URL
#     number=$(echo "$line" | awk '{print $1}')
#     url=$(echo "$line" | awk '{print $3}')

#     # Проверяем, является ли значение номера числом
#     if [[ $number =~ ^[0-9]+$ ]]; then
#         # Сохраняем URL в соответствующий файл directory_$number.txt
#         echo "$url" >> "directory_$number.txt"
#     fi
# done < "$input_file"

# exit 0
#!/bin/bash

# Путь к файлу directory.txt
input_file="directory.txt"

# Название папки для сохранения файлов
output_directory="directory"

# Файл для сохранения всех URL
output_file="$output_directory/all_urls.txt"

# Проверяем, есть ли файл
if [ ! -f "$input_file" ]; then
    echo "Файл $input_file не существует."
    exit 1
fi

# Создаем папку для выходных файлов, если она еще не существует
mkdir -p "$output_directory"

# Очищаем или создаем файл all_urls.txt перед началом использования
> "$output_file"

# Читаем файл и обрабатываем каждую строку
while read -r line; do
    # Получаем номер, который идет первым в строке и URL
    number=$(echo "$line" | awk '{print $1}')
    url=$(echo "$line" | awk '{print $3}')

    # Проверяем, является ли значение номера числом
    if [[ $number =~ ^[0-9]+$ ]]; then
        # Формируем путь к файлу для текущего номера
        file_path="$output_directory/directory_$number.txt"
        # Сохраняем URL в соответствующий файл
        echo "$url" >> "$file_path"
        # Также добавляем URL в общий файл
        echo "$url" >> "$output_file"
    fi
done < "$input_file"

echo "Обработка завершена. Все URL сохранены в папке $output_directory."
exit 0