#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}[+] Installing Cloudflare Tunnel (cloudflared) for Port Forwarding & Zero Trust...${NC}"

# Download and install cloudflared securely
curl -L --output cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
sudo chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/cloudflared

echo -e "${GREEN}[✓] cloudflared installed successfully!${NC}"
echo -e "${CYAN}[*] To run a quick tunnel to your FVM panel on port 3000, execute:${NC}"
echo -e "${GREEN}    cloudflared tunnel --url http://localhost:3000${NC}"
