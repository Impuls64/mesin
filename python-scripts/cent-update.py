import requests
from datetime import datetime, timedelta
import os

# Установка даты 30 дней назад в требуемом формате
today = datetime.now()
date_threshold = today - timedelta(days=30)

# Параметры для запроса к API GitHub
parameters = {
    'q': 'nuclei-templates path:./templates',
    'sort': 'updated',
    'per_page': 300
}

# Отправляем запрос к API GitHub
response = requests.get('https://api.github.com/search/repositories', params=parameters)

if response.status_code == 200:
    print("Получены репозитории из API GitHub успешно")
    data = response.json()

    # Фильтрация репозиториев, обновленных за последние 30 дней
    new_links = [f"  - {repo['html_url']}" for repo in data['items'] if datetime.strptime(repo['pushed_at'], '%Y-%m-%dT%H:%M:%SZ') > date_threshold]

    # Путь к файлу для хранения ссылок
    links_file = "/home/bob/.cent.yaml"

    # Чтение существующих ссылок из файла
    existing_links = []
    if os.path.exists(links_file):
        with open(links_file, 'r') as file:
            content = file.readlines()
            # Поиск секции community-templates
            community_templates_index = next((i for i, line in enumerate(content) if 'community-templates:' in line), -1)
            if community_templates_index != -1:
                existing_links = [line.strip() for line in content[community_templates_index+1:] if line.strip().startswith('-')]

    # Удаление повторяющихся ссылок
    unique_links = list(set(existing_links + new_links))

    with open(links_file, 'w') as file:

        file.writelines(content[:community_templates_index+1])
    
        for link in unique_links:
            file.write(f"{link}\n")

    print("Обновление ссылок завершено. Повторяющиеся ссылки удалены.")
else:
    print("Не удалось получить репозитории из API GitHub")