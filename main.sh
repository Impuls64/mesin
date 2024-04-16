#!/bin/bash

[ -d ~/Downloads ] || mkdir -p ~/Downloads
cd ~/Downloads

sudo apt update
sudo apt upgrade -y
sudo apt install python3 -y
sudo apt install dirsearch -y
sudo apt install python3-pip -y
sudo apt install httpx-toolkit -y
sudo apt install seclists -y
sudo apt install subfinder -y
sudo apt install gccgo-go -y
sudo apt install golang-go -y
sudo apt install npm -y
sudo apt install -y libpcap-dev
sudo apt install naabu -y
sudo apt install unzip -y
sudo apt install dotdotpwn -y
sudo apt install python2-minimal -y
sudo apt install nmap -y
sudo apt install nuclei -y
sudo apt install sqlmap -y
sudo apt install python3-httpx -y
sudo apt install jq -y

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/xm1k3/cent@latest
go install github.com/hahwul/dalfox/v2@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/tomnomnom/gf@latest

sudo cp ~/go/bin/* /usr/local/bin

sudo ln -s $(which httpx-toolkit) /usr/bin/httpx
sudo ln -s $(which subfinder) /usr/bin/subfinder

export PATH=$PATH:$(go env GOPATH)/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/go/bin

git clone https://github.com/1ndianl33t/Gf-Patterns $HOME/.gf
git clone https://github.com/coffinxp/CoffinCNt.git
git clone https://github.com/swisskyrepo/SSRFmap.git
git clone https://github.com/maurosoria/dirsearch.git
git clone https://github.com/six2dez/OneListForAll.git
git clone https://github.com/ruevaughn/top25-parameter-ssrf.git
git clone https://github.com/s0md3v/uro.git
# добавить клонирование скрипта по обновлению базы cent

cat << EOF > ~/.gau.toml
threads = 2
verbose = false
retries = 15
subdomains = false
parameters = false
providers = ["wayback","commoncrawl","otx","urlscan"]
blacklist = ["ttf","woff","svg","png","jpg"]
json = false

[urlscan]
  apikey = ""

[filters]
  from = ""
  to = ""
  matchstatuscodes = []
  matchmimetypes = []
  filterstatuscodes = []
  filtermimetypes = ["image/png", "image/jpg", "image/svg+xml"]
EOF

cent init
# запуск скрипта по обновлению базы cent 
cent
pip3 install requests
pip3 install networkx
pip3 install requests
pip3 install -r SSRFmap/requirements.txt
pip3 install -r dirsearch/requirements.txt
pip3 install uro

sudo rm -r OneListForAll/*.00*


sudo apt update
sudo apt upgrade -y