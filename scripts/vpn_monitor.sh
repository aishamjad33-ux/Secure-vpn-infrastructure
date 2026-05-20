#!/bin/bash
# =============================================================
# vpn_monitor.sh — Secure VPN Infrastructure
# VPN Health Monitoring Script
# =============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Secure VPN — VPN Monitoring System      ${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "Host: $(hostname) | Date: $(date)"
echo -e "Server IP: $(hostname -I | awk '{print $1}')"
echo ""

echo -e "${YELLOW}SELECT OPTION:${NC}"
echo "1) Check VPN service status"
echo "2) Check tunnel interface (tun0)"
echo "3) Check port 1194"
echo "4) Show connected clients"
echo "5) Restart VPN server"
echo "6) Exit"
echo ""
read -p "Enter option [1-6]: " opt

case $opt in
  1) echo -e "${YELLOW}--- OpenVPN Service Status ---${NC}"
     sudo systemctl status openvpn-server@server --no-pager
     ;;
  2) echo -e "${YELLOW}--- Tunnel Interface tun0 ---${NC}"
     if ip link show tun0 &>/dev/null; then
       TUN_IP=$(ip addr show tun0 | grep 'inet ' | awk '{print $2}')
       echo -e "${GREEN}[PASS] tun0 is UP — IP: $TUN_IP${NC}"
       ip addr show tun0
     else
       echo -e "${RED}[FAIL] tun0 interface not found!${NC}"
     fi
     ;;
  3) echo -e "${YELLOW}--- Port 1194 Status ---${NC}"
     if ss -tulpn | grep -q ':1194'; then
       echo -e "${GREEN}[PASS] Port 1194 is LISTENING${NC}"
       ss -tulpn | grep ':1194'
     else
       echo -e "${RED}[FAIL] Port 1194 NOT listening!${NC}"
     fi
     ;;
  4) echo -e "${YELLOW}--- Connected VPN Clients ---${NC}"
     LOG='/var/log/openvpn/openvpn-status.log'
     if [ -f "$LOG" ]; then
       cat "$LOG"
     else
       echo -e "${YELLOW}No clients connected yet.${NC}"
     fi
     ;;
  5) echo -e "${YELLOW}Restarting OpenVPN server...${NC}"
     sudo systemctl restart openvpn-server@server
     sleep 2
     sudo systemctl status openvpn-server@server --no-pager
     echo -e "${GREEN}[OK] VPN server restarted.${NC}"
     ;;
  6) echo "Exiting..."; exit 0 ;;
  *) echo -e "${RED}Invalid option${NC}" ;;
esac
