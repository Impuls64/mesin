#!/bin/bash

param_list=("debug_logic" "idor" "img-traversal" "interestingEXT" "interestingparams" "interestingsubs" "jsvar" "lfi" "rce" "redirect" "sqli" "ssrf" "ssti" "xss")

# Создаем папку для результатов gf
mkdir -p gf_param

for param in "${param_list[@]}"
do
    gf $param filterparam.txt | tee gf_param/$param.txt
done