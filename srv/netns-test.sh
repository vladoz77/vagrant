# On node 1
# Config first NS
ip netns add NS1
ip link add veth0 type veth peer name veth1
ip link set veth1 netns NS1
ip link set dev veth0 up
ip netns exec NS1 ip link set dev lo up
ip netns exec NS1 ip addr add dev veth1 172.19.35.3/24
ip netns exec NS1 ip link set veth1 up

# Config second NS
ip netns add NS2
ip link add veth2 type veth peer name veth3
ip link set veth3 netns NS2
ip link set dev veth2 up
ip netns exec NS2 ip link set dev lo up
ip netns exec NS2 ip addr add dev veth3 172.19.35.2/24
ip netns exec NS2 ip link set veth3 up

# Configure bridge
ip link add br0 type bridge
ip link set veth0 master br0
ip link set veth2 master br0
ip addr add dev br0 172.19.35.1/24
ip link set dev br0 up 

# Configure internet access
echo 1 > /proc/sys/net/ipv4/ip_forward
ip netns exec NS1 ip route add default via 172.19.35.1
ip netns exec NS2 ip route add default via 172.19.35.1
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# On node 2
ip netns add NS1
ip link add veth0 type veth peer name veth1
ip link set veth1 netns NS1
ip link set dev veth0 up
ip netns exec NS1 ip link set dev lo up
ip netns exec NS1 ip addr add dev veth1 172.19.36.2/24
ip netns exec NS1 ip link set veth1 up

# add bridge
ip link add br0 type bridge
ip link set veth0 master br0
ip addr add dev br0 172.19.36.1/24
ip link set dev br0 up 

# Configure internet
echo 1 > /proc/sys/net/ipv4/ip_forward
ip netns exec NS1 ip route add default via 172.19.36.1
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Connect each other
ip route add 172.19.36.0/24 via 192.168.57.12 dev enp0s8
# on node 2
ip route add 172.19.35.0/24 via 192.168.57.11 dev enp0s8
