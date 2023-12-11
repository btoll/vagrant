printf "# Network devices:\n"
ip link list

printf "\n# Network routes (routing table):\n"
ip route list

printf "\n# Iptables rules:\n"
sudo iptables --list-rules

