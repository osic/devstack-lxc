cp prep-guest.sh /var/lib/lxc/devstack-node/rootfs/root
lxc-attach -n devstack-node -- bash -c "echo /root/prep-guest.sh | sh"
cp localrc /var/lib/lxc/devstack/rootfs/opt/stack/devstack
cp run-devstack.sh /var/lib/lxc/devstack/rootfs/opt/stack
lxc-attach -n devstack -- bash -c "echo sudo -H -u stack /opt/stack/run-devstack.sh | sh"
