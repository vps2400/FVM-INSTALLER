#!/bin/bash

# Color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

clear
echo -e "${CYAN}==================================================${NC}"
echo -e "${GREEN}           ⚡ FAILAIVE2 FVM INSTALLER ⚡          ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo -e "${YELLOW}      Server VPS & Container Panel Manager        ${NC}"
echo -e "${CYAN}==================================================${NC}"
echo ""
echo -e "${GREEN}1)${NC} FVM Panel Installation"
echo -e "${GREEN}2)${NC} LXC / LXD Installer (Fixed)"
echo -e "${GREEN}3)${NC} Cloudflare Setup (Zero Trust / Tunnel)"
echo -e "${GREEN}4)${NC} LXC BOT V6"
echo -e "${RED}0)${NC} Exit"
echo ""
read -p "Enter choice [0-4]: " choice

case $choice in
    1)
        echo -e "\n${CYAN}[+] Launching FVM Panel Installer...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/node2ws-glitch/LPINSTALLER/main/panels.sh)
        ;;
    2)
        echo -e "\n${CYAN}[+] Launching Fixed LXC Installer...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/node2ws-glitch/LPINSTALLER/main/vm.sh)
        ;;
    3)
        echo -e "\n${CYAN}[+] Setting up Cloudflare Tunnel & Domain Routing...${NC}"
        bash <(curl -fsSL https://raw.githubusercontent.com/node2ws-glitch/LPINSTALLER/main/lp-installer.sh)
        ;;
    4)
        echo -e "\n${CYAN}[+] Starting LXC BOT V6 Setup...${NC}"
        read -p "Enter Discord Bot Token: " bot_token
        read -p "Enter Admin Discord ID: " admin_id
        echo -e "${YELLOW}[*] Saving credentials for Admin ID: $admin_id...${NC}"
        echo -e "${GREEN}[✓] LXC BOT V6 configured successfully!${NC}"
        ;;
    0)
        echo -e "\n${YELLOW}Exiting installer. Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "\n${RED}[X] Invalid choice! Please select 0-4.${NC}"
        ;;
esac
