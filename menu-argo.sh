#!/bin/bash
#
#  |════════════════════════════════════════════════════════════════════════════════════════════════════════════════|
#  • Autoscript AIO Lite Menu By FN Project                                          |
#  • FN Project Developer @Rerechan02 | @PR_Aiman | @farell_aditya_ardian            |
#  • Copyright 2024 18 Marc Indonesia [ Kebumen ] | [ Johor ] | [ 上海，中国 ]       |
#  |════════════════════════════════════════════════════════════════════════════════════════════════════════════════|
#

# Fix Nameserver
[[ -e $(which curl) ]] && grep -q "1.1.1.1" /etc/resolv.conf || {
    echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf > /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf
}

setup() {
# Clear Screen
clear

# Copy File Core
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
rm -fr cloudflared-linux-amd64.deb

# Membuat Konfigurasi
rm -fr /etc/cloudflared/*
mkdir -p /etc/cloudflared

clear
echo -e "Login to your cloudflare Account"
cloudflared tunnel login

clear
random=$(openssl rand -base64 15 | tr -dc 'a-z' | head -c 8)
echo " Create Node For Server Data "
echo "$random" > /root/.rcs
rcs=$(cat /root/.rcs)
cloudflared tunnel create $rcs
clear
id=$(basename ~/.cloudflared/*.json | sed 's/\.json$//')
echo -e "Save Your ID"
echo -e "ID: $id"
sleep 10
clear
echo -e "
Setup Your Domain Argo Tunnel
=============================

Example: mysubdom.myvpn.com

replace mysubdomain with your desired subdomain and replace myvpn.com with the domain you chose in cloudflare for argo tunnel after login
=============================
"
read -p "Input Subdomain: " opws
cloudflared tunnel route dns $rcs $opws
echo "$opws" > /etc/xray/domargo
domargo="$opws"
clear
# Membuar Konfigurasi
cat>  /etc/cloudflared/config.yml << END
tunnel: $rcs
credentials-file: /root/.cloudflared/$id.json

ingress:
  - hostname: $domargo
    service: http://localhost:80
  - service: http_status:404
END

# Menyimpan Domain
#echo "$domargo" > /etc/xray/domargo

# Menjalankan Servixe
sudo cloudflared service install
}

detail() {
clear
edussh_service=$(systemctl status cloudflared | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edussh_service == "running" ]]; then
ssws="\e[1;32m[ ON ]\033[0m"
else
ssws="\e[1;31m[ OFF ]\033[0m"
fi
domargo=$(cat /etc/xray/domargo)
clear
echo -e "
<= Detail Service Argo Tunnel =>
════════════════════════════════

Port HTTP:
- 80 ( Standar )
- 8080
- 8880
- 2052
- 2082
- 2086
- 2095

Port HTTPS:
- 443 ( Standar )
- 8443
- 2053
- 2083
- 2087
- 2096

#Detail
- Status    : $ssws
- Domain    : $domargo
════════════════════════════════
Currently only supports connections on
-> X-ray/V2ray/V2rayfly protocols
"
}
tamp() {
edussh_service=$(systemctl status cloudflared | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $edussh_service == "running" ]]; then
ssws="\e[1;32m[ ON ]\033[0m"
else
ssws="\e[1;31m[ OFF ]\033[0m"
fi
clear
echo -e "
<= Menu Argo Tunnel By FN =>
════════════════════════════
Status: $ssws

1. Install Argo
2. Restart Argo Tunnel
3. Detail Service Argo
0. Back To Menu Default
════════════════════════════
    Pres CTRL + C to Exit
"
read -p "Input Option: " opws
case $opws in
1) setup ;;
2) clear ; reres ;;
3) clear ; detail ;;
0) clear ; menu ;;
*) clear ; tamp ;;
esac
}

tamp
