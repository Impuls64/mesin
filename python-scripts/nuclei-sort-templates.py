import os
import yaml

directory_path_1 = os.path.expanduser('~/Downloads/cent-nuclei-templates')
directory_path_2 = os.path.expanduser('~/nuclei-templates')

def parse_yaml(template):
    data = []
    for line in template.strip().split('\n'):
        if line.startswith(('id:', 'info:', 'name:', 'tags:')):
            key, value = line.split(':', 1)
            if value.strip():
                data.append(f"{key.strip()}: {value.strip()}")
    return data

def process_directory(directory):
    file_data = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.yaml', '.yml')):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r') as stream:
                        template = stream.read()
                        parsed_data = parse_yaml(template)
                        file_data.append(', '.join(parsed_data) + f", path:{file_path}, size:{os.path.getsize(file_path)}")
                except yaml.YAMLError as exc:
                    print(f'Error reading {file}: {exc}')
    return file_data

file_data_1 = process_directory(directory_path_1)
file_data_2 = process_directory(directory_path_2)

unique_file_data = []
for data in file_data_1 + file_data_2:
    data_parts = data.split(', ')
    data_parts.remove(data_parts[-1])
    data_parts.remove(data_parts[-1])
    data_key = ', '.join(data_parts)
    if data_key not in [d.split(', ')[:-2] for d in unique_file_data]:
        unique_file_data.append(data)

with open('nuclei-list.txt', 'w') as outfile:
    outfile.write('\n'.join(unique_file_data) + '\n')

print(f"Total files in {directory_path_1}: {len(file_data_1)}")
print(f"Total files in {directory_path_2}: {len(file_data_2)}")
print(f"Total unique entries in nuclei-list.txt: {len(unique_file_data)}")
print(f"Duplicates removed: {len(file_data_1 + file_data_2) - len(unique_file_data)}")