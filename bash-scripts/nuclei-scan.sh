#!/bin/bash

param_list=("debug_logic" "idor" "img-traversal" "interestingEXT" "interestingparams" "interestingsubs" "jsvar" "lfi" "rce" "redirect" "sqli" "ssrf" "ssti" "xss")

for param in "${param_list[@]}"
do
    if [ -s "gf_param/$param.txt" ]; then
        nuclei -l "gf_param/$param.txt" -c 70 -rl 200 -fhr -lfa -t ../../Downloads/cent-nuclei-templates/ --tags $param | sed "s/\x1B\[[0-9;]*m//g" > "$param-nuclei.txt"
    else
        echo "gf_param/$param.txt is empty. Skipping nuclei scan."
    fi
done

find . -empty -type f -delete