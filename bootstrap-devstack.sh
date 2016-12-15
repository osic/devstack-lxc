# Prepare the devstack source files
cp prep-guest.sh /var/lib/lxc/devstack-node/rootfs/root
lxc-attach -n devstack-node -- bash -c "echo /root/prep-guest.sh | sh"

# Copy the devstack configuration file to the container
# TODO: Make changes in the IPs of the config file
cp local.conf /var/lib/lxc/devstack-node/rootfs/opt/stack/devstack

# Run the script to install devstack
cp run-devstack.sh /var/lib/lxc/devstack-node/rootfs/opt/stack
lxc-attach -n devstack-node -- bash -c "echo sudo -H -u stack /opt/stack/run-devstack.sh | sh"
