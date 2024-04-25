import os
import yaml
from collections import Counter

def count_tags(directory):
    tags_counter = Counter()
    unmatched_files = []
    other_counter = 0
    
    # First pass to collect all tags
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.yaml') or file.endswith('.yml'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r') as stream:
                        template = yaml.safe_load(stream)
                        if 'tags' in template:
                            for tag in template['tags']:
                                if isinstance(tag, str):
                                    tags_counter.update([tag])
                                elif isinstance(tag, dict):
                                    for key, value in tag.items():
                                        tags_counter.update([value])
                        elif 'info' in template and 'name' in template['info']:
                            tags_counter.update([template['info']['name']])
                        else:
                            unmatched_files.append(file_path)
                except yaml.YAMLError as exc:
                    print(f'Error reading {file}: {exc}')

    # Second pass to handle unmatched files
    for file_path in unmatched_files:
        try:
            with open(file_path, 'r') as stream:
                template = yaml.safe_load(stream)
                if 'name' in template:
                    name = template['name']
                    # Check if any part of the name matches the collected tags
                    if any(tag in name for tag in tags_counter):
                        tags_counter.update([name])
                    else:
                        other_counter += 1
                else:
                    other_counter += 1
        except yaml.YAMLError as exc:
            print(f'Error reading {file}: {exc}')

    return tags_counter, other_counter

directory_path = os.path.expanduser('~/Downloads/cent-nuclei-templates')
tags_counter, other_count = count_tags(directory_path)
print(f'Total tags: {sum(tags_counter.values())}')
print(f'Unique tags: {len(tags_counter)}')
print(f'Files without matching tags or names: {other_count}')
for tag, count in tags_counter.most_common():
    print(f'{tag}: {count}')