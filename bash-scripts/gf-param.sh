#!/bin/bash

param_list=("debug_logic" "idor" "img-traversal" "interestingEXT" "interestingparams" "interestingsubs" "jsvar" "lfi" "rce" "redirect" "sqli" "ssrf" "ssti" "xss")

# Создаем папку для результатов gf
mkdir -p gf_param

for param in "${param_list[@]}"
do
    gf $param filterparam.txt | tee gf_param/$param.txt
done

printf "\nФильтруем параметры с помощью uro..."
if ! check_if_empty "$current_dir/params.txt"; then
    cat "$current_dir/params.txt" | uro -o "$current_dir/filterparam.txt"
fi
if [ ! -s "$current_dir/filterparam.txt" ]; then
    echo "Команды gau и uro ничего не нашли"
fi

printf "\nИщем секреты в JS-файлах с помощью SecretFinder.py..."
if ! check_if_empty "$current_dir/secret.txt"; then
    while read url; do
        python3 "$HOME/Downloads/secretfinder/SecretFinder.py" -i "$url" -o cli >> "$current_dir/secret.txt"
    done < "$current_dir/jsfiles.txt"
fi
if [ ! -s "$current_dir/secret.txt" ]; then
    echo "Команды grep и SecretFinder.py ничего не нашли"
fi