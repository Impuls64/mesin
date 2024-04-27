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
sudo apt install sublist3r -y
sudo apt install httprobe -y
sudo apt install tor -y
sudo apt install proxychains -y
sudo apt install yq -y

go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install github.com/projectdiscovery/cvemap/cmd/cvemap@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/xm1k3/cent@latest
go install github.com/hahwul/dalfox/v2@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/tomnomnom/gf@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/KathanP19/Gxss@latest
go install github.com/rix4uni/xsschecker@latest
go install -v github.com/rix4uni/unew@latest
go install github.com/tomnomnom/qsreplace@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/takshal/freq@latest

sudo cp ~/go/bin/* /usr/local/bin


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
git clone https://github.com/s0md3v/XSStrike.git  
git clone https://github.com/cevaboyz/user_agents.git
git clone https://github.com/monosans/proxy-list.git

# git clone https://github.com/rix4uni/pvreplace.git ~/bin/pvreplace
# echo "alias pvreplace='python3 ~/bin/pvreplace/pvreplace.py'" >> ~/.bashrc && source ~/.bashrc

# добавить клонирование скрипта по обновлению базы cent

sudo ln -s $(which httpx-toolkit) /usr/bin/httpx
sudo ln -s $(which subfinder) /usr/bin/subfinder
sudo ln -sf ~/Downloads/XSStrike/xsstrike.py /usr/local/bin/xsstrike
sudo chmod +x /usr/local/bin/xsstrike

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
pip3 instal -r XSStrike/requirements.txt
pip3 install -r SSRFmap/requirements.txt
pip3 install -r dirsearch/requirements.txt
pip3 install uro

sudo rm -r OneListForAll/*.00*

chmod +x XSStrike/*

sudo apt update
sudo apt upgrade -y