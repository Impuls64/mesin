#!/bin/bash

while IFS=: read -r domain port; do
  ip=$(dig +short "$domain" | head -1)
  if [ -n "$ip" ]; then
    echo "$ip $port" >> naabu-find-IP.txt
  fi
done < naabu-full.txt

# Remove lines that don't match the IP:port pattern
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} [0-9]+' naabu-find-IP.txt > temp.txt
mv temp.txt naabu-find-IP.txt

sort -u naabu-find-IP.txt -o naabu-find-IP.txt