#!/bin/bash

~/Downloads/mesin/banner.sh

# Проверяем наличие файла nulei-rezult.txt в папке nuclei
if [ ! -f "nuclei/nulei-rezult.txt" ]; then
  # Запускаем скрипт, если файл отсутствует
  ./nuclei-start.sh
fi

# Проверяем наличие файла sqlmap-rezult.txt в папке sqlmapi
if [ ! -f "sqlmapi/sqlmap-rezult.txt" ]; then
  # Запускаем скрипт, если файл отсутствует
  ./sqlmap-start.sh
fi

# Проверяем наличие файла full-rezult.txt
if [ -f "full-rezult.txt" ]; then
  # Делаем что-то, если файл существует
fi
# Остальные проверки и действия можно добавить по аналогии

# Конец файла