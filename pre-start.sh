ip link add name lxcbr0 type bridge
ip link set lxcbr0 up

modprobe openvswitch
modprobe ebtables
modprobe ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT
modprobe br_netfilter
