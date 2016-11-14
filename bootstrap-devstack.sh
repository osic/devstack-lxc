cp prep-guest.sh /var/lib/lxc/devstack/rootfs/root
lxc-attach -n devstack -- bash -c "echo ./prep-guest.sh | sh"
cp localrc /var/lib/lxc/devstack/rootfs/opt/stack/devstack
cp run-devstack.sh /var/lib/lxc/devstack/rootfs/opt/stack
lxc-attach -n devstack -- bash -c "echo sudo -H -u stack /opt/stack/run-devstack.sh | sh"
