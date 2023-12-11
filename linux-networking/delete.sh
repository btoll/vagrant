sudo ip netns delete net0
sudo ip netns delete net1
sudo ip link delete br0
echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
