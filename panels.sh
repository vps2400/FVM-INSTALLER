#!/bin/bash
GREEN='\033[1;32m'
CYAN='\033[1;36m'

echo -e "${CYAN}[+] Directing to FVM Panel sub-installers...${NC}"
bash <(curl -fsSL https://raw.githubusercontent.com/node2ws-glitch/LPINSTALLER/main/panel/ptero.sh)
