#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Installing LXC, LXD, and bridging utilities...${NC}"
sudo apt update && sudo apt install -y lxc lxd lxd-tools bridge-utils uidmap

echo -e "${CYAN}[*] Applying safe container storage configurations...${NC}"
sudo systemctl enable --now lxd

if ! lxd waitready --timeout=5 >/dev/null 2>&1; then
    cat <<EOF | sudo lxd init --preseed
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: auto
  name: lxdbr0
  type: bridge
storage_pools:
- config: {}
  name: default
  driver: dir
profiles:
- config: {}
  description: Default LXD profile for FVM
  devices:
    root:
      path: /
      pool: default
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
  name: default
EOF
fi

echo -e "${GREEN}[✓] LXC / LXD engine is fully configured and ready for VPS containers!${NC}"
