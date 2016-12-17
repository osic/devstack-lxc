ip link add name lxcbr0 type bridge
ip link set lxcbr0 up
ip addr add 10.0.1.1/24 dev lxcbr0

modprobe openvswitch
modprobe ebtables
modprobe ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT
modprobe br_netfilter
